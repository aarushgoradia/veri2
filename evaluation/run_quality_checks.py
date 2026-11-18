#!/usr/bin/env python3
"""Package saved test checkers, run the tautology and redundancy checks, and summarize explicit outcomes."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess

from collect_verdicts import inventory, parse_log, strip_comments
from run_formal_analysis import tcl_string

ROOT = Path(__file__).resolve().parents[1]
CONDITIONS = ['adapter_all', 'adapter_syntax_pass', 'adapter_verified',
              'adapter_vert', 'base_qwen', 'chatgpt_baseline']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_settings(source):
    clean = strip_comments(source)
    modules = re.findall(r'\bmodule\s+(?:automatic\s+)?(\w+)', clean)
    if len(modules) != 1:
        raise ValueError(f'Expected one standalone checker module; found {modules}')
    clocks = set(re.findall(r'@\s*\(\s*(?:posedge|negedge)\s+(\w+)\s*\)', clean))
    if len(clocks) > 1:
        raise ValueError(f'Multiple checker clocks need explicit setup: {sorted(clocks)}')
    event_source = re.sub(r'@\s*\(\s*(?:\$global_clock|\*)\s*\)', '', clean)
    if re.search(r'@\s*\(', event_source) and not clocks:
        raise ValueError('Unsupported event expression; requires explicit clock setup')
    resets = {x.strip() for x in re.findall(r'\bdisable\s+iff\s*\(([^()]*)\)', clean)}
    # Constant false and $initstate are property guards, not physical reset
    # ports. Leave them untouched in the assertion and use formal -none.
    resets -= {"1'b0", "1'b1", '0', '1', '$initstate'}
    if len(resets) > 1 or any(not re.fullmatch(r'[!~]?\s*\w+', x) for x in resets):
        raise ValueError(f'Reset expressions need explicit setup: {sorted(resets)}')
    return modules[0], next(iter(clocks), '-none'), next(iter(resets), '-none')


def prepare(args):
    out = args.out_dir.resolve()
    out.mkdir(parents=True, exist_ok=False)
    tasks = []
    for condition in args.conditions:
        for sample in sorted((ROOT / 'inference_outputs' / condition).iterdir()):
            if not sample.is_dir() or (args.ids and sample.name not in args.ids):
                continue
            raw = sample / 'sva.sv'
            if not raw.is_file():
                continue
            saved = ROOT / 'inference_outputs' / 'verification_results' / condition / 'ids' / sample.name
            # Reuse exactly the repaired VERT checker used by historical proof
            # evaluation, when present; never silently apply a new repair here.
            effective = saved / 'sva_fixed.sv' if condition == 'adapter_vert' else raw
            task = {'condition': condition, 'id': sample.name,
                    'case': f'cases/{condition}/{sample.name}',
                    'source': str(raw.relative_to(ROOT)), 'source_sha256': digest(raw),
                    'effective_source': str(effective.relative_to(ROOT)),
                    'status': 'ready'}
            case = out / task['case']
            case.mkdir(parents=True)
            try:
                source = effective.read_text()
                task['effective_sha256'] = digest(effective)
                # Generation may wrap the checker in a Markdown fence; proof
                # evaluation strips it, so the same text is checked here.
                source = re.sub(r'\A\s*```[^\n]*\n|\n```\s*\Z', '', source)
                # A standalone checker has no DUT. Remove external bind statements
                # only; preserve property bodies, ports, state, and assumptions.
                source = re.sub(r'(?m)^\s*bind\b[^;]*;', lambda m: '\n' * m[0].count('\n'), source)
                if re.search(r'\bbind\s+', strip_comments(source)):
                    raise ValueError('Unsupported bind syntax; input needs explicit extraction')
                task['top'], task['clock'], task['reset'] = checker_settings(source)
                (case / 'checker.sv').write_text(source)
                task['checker_sha256'] = digest(case / 'checker.sv')
                log = saved / 'run.log'
                props = saved / 'property_list.txt'
                events, _ = parse_log(log.read_text(errors='replace')) if log.is_file() else ({}, None)
                names = inventory(props.read_text()) if props.is_file() else []
                task['baseline_evidence'] = 'present' if log.is_file() and props.is_file() else 'missing'
                labels = Counter(n.rsplit('.', 1)[-1] for n in names)
                task['baseline_proven'] = sorted(n.rsplit('.', 1)[-1] for n in names
                    if labels[n.rsplit('.', 1)[-1]] == 1 and events.get(n) == {'proven'})
                task['baseline_assertions'] = len(names)
                task['ambiguous_baseline_labels'] = sorted(k for k, v in labels.items() if v > 1)
                task['evidence_sha256'] = {str(p.relative_to(ROOT)): digest(p) for p in [log, props] if p.is_file()}
            except (OSError, ValueError) as error:
                task.update(status='unsupported', reason=str(error))
            tasks.append(task)
    manifest = {'tasks': tasks, 'settings': {'proof_time_limit_seconds': args.time_limit,
                'process_timeout_seconds': args.process_timeout},
                'note': 'Original checking algorithms retained. Redundancy uses saved explicit proofs; '
                        'short-label joins must be unique. Unknowns remain unresolved. '
                        'VERT uses its historical repaired checker where available.',
                'runner_sha256': digest(Path(__file__)),
                'script_sha256': {str(p.relative_to(ROOT)): digest(p)
                                 for p in sorted((ROOT / 'evaluation/tcl').glob('*')) if p.is_file()}}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(Counter(t['status'] for t in tasks)))


def read_events(stage):
    path = stage / 'events.jsonl'
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()] if path.exists() else []


def run_stage(package, task, name, settings, tautologies):
    case = package / task['case']
    stage = case / name
    attempt = 1
    while stage.exists():
        attempt += 1
        stage = case / f'{name}-attempt-{attempt:03d}'
    stage.mkdir()
    values = {'CHECK_CHECKER': case / 'checker.sv', 'CHECK_TOP': task['top'],
              'CHECK_CLOCK': task['clock'], 'CHECK_RESET': task['reset'],
              'CHECK_WORK': stage, 'CHECK_TIME_LIMIT': settings['proof_time_limit_seconds'],
              'CHECK_SCRIPT': ROOT / 'evaluation/tcl' / f'{name}_chk.tcl'}
    driver = 'driver.tcl'
    config = stage / 'config.tcl'
    lines = [f'set {k} {tcl_string(v)}' for k, v in values.items()]
    lines += ['set BASELINE_PROVEN [dict create ' + ' '.join(tcl_string(x) + ' 1' for x in task['baseline_proven']) + ']',
              'set TAUTOLOGIES [list ' + ' '.join(tcl_string(x) for x in tautologies) + ']',
              'set CHECK_CLOCK_OPTIONS [list ' + ' '.join(tcl_string(x) for x in task.get('clock_options', [])) + ']']
    config.write_text('\n'.join(lines) + '\n')
    command = ['jg', '-no_gui', '-proj', str(stage / 'project'),
               str(ROOT / 'evaluation/tcl' / driver), '---', str(config)]
    (stage / 'command.json').write_text(json.dumps(command) + '\n')
    try:
        with (stage / 'console.log').open('w') as log:
            process = subprocess.Popen(command, cwd=stage, stdout=log, stderr=subprocess.STDOUT,
                                       start_new_session=True)
            try:
                code = process.wait(timeout=settings['process_timeout_seconds'])
            except subprocess.TimeoutExpired:
                import os
                import signal
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()
                return {'status': 'timeout', 'events': read_events(stage)}
        output = 'tautologies.txt' if name == 'tautology' else 'redundant_props.txt'
        ok = code == 0 and (stage / 'completed.txt').exists() and (stage / output).exists()
        result = {'status': 'completed' if ok else 'error', 'exit_code': code,
                  'events': read_events(stage), 'stage_dir': str(stage),
                  'clock_options': task.get('clock_options', [])}
        # Follow the documented Jasper ECK112 prompt without changing properties
        # or the checking algorithm. Preserve the failed attempt in place.
        if not ok and not task.get('clock_options') and 'ERROR (ECK112)' in (stage / 'console.log').read_text(errors='replace'):
            retry = run_stage(package, {**task, 'clock_options': ['-both_edges']}, name, settings, tautologies)
            retry['previous_attempt'] = result
            return retry
        return result
    except OSError as error:
        return {'status': 'error', 'reason': str(error), 'events': read_events(stage)}


def run(args):
    package = args.package.resolve()
    manifest = json.loads((package / 'manifest.json').read_text())
    for relative, expected in manifest['script_sha256'].items():
        if digest(ROOT / relative) != expected:
            raise ValueError(f'Analysis script differs from prepared manifest: {relative}')
    for i, task in enumerate(manifest['tasks']):
        if i % args.shards != args.shard:
            continue
        case = package / task['case']
        result_path = case / 'result.json'
        if result_path.exists():
            continue
        result = {k: task[k] for k in ['condition', 'id', 'status']}
        if task['status'] == 'ready':
            if digest(case / 'checker.sv') != task['checker_sha256']:
                raise ValueError(f'Checker changed: {case}')
            result['tautology'] = run_stage(package, task, 'tautology', manifest['settings'], [])
            tautologies = [e['name'].rsplit('.', 1)[-1] for e in result['tautology']['events']
                          if e['phase'] == 'tautology' and e['validity_status'] == 'proven']
            if result['tautology']['status'] == 'completed':
                effective = {**task, 'clock_options': result['tautology'].get('clock_options', [])}
                result['redundancy'] = run_stage(package, effective, 'redundancy', manifest['settings'], tautologies)
                result['status'] = result['redundancy']['status']
            else:
                result['status'] = result['tautology']['status']
        else:
            result['reason'] = task['reason']
        temporary = case / 'result.json.tmp'
        temporary.write_text(json.dumps(result, indent=2) + '\n')
        temporary.replace(result_path)
        print(task['condition'], task['id'], result['status'], flush=True)


def summarize(args):
    package = args.package.resolve()
    manifest = json.loads((package / 'manifest.json').read_text())
    counts = {}
    for t in manifest['tasks']:
        c = counts.setdefault(t['condition'], Counter())
        c['total'] += 1
        path = package / t['case'] / 'result.json'
        if not path.exists():
            c['pending'] += 1
            continue
        result = json.loads(path.read_text())
        c[result['status']] += 1
        for stage in ['tautology', 'redundancy']:
            if stage not in result:
                continue
            phase = 'tautology' if stage == 'tautology' else 'redundancy_step'
            events = [e for e in result[stage]['events'] if e['phase'] == phase]
            for e in events:
                source_type = e.get('source_type', 'assert')
                c[stage + '_' + source_type + '_' + e['validity_status']] += 1
    (package / 'summary.json').write_text(json.dumps(counts, indent=2) + '\n')
    print(json.dumps(counts, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='mode', required=True)
    p = sub.add_parser('prepare')
    p.add_argument('--out-dir', type=Path, required=True)
    p.add_argument('--conditions', nargs='+', choices=CONDITIONS, default=CONDITIONS)
    p.add_argument('--ids', nargs='+')
    p.add_argument('--time-limit', type=int, default=30)
    p.add_argument('--process-timeout', type=int, default=300)
    p.set_defaults(func=prepare)
    p = sub.add_parser('run')
    p.add_argument('--package', type=Path, required=True)
    p.add_argument('--shard', type=int, default=0)
    p.add_argument('--shards', type=int, default=1)
    p.set_defaults(func=run)
    p = sub.add_parser('summarize')
    p.add_argument('--package', type=Path, required=True)
    p.set_defaults(func=summarize)
    args = parser.parse_args()
    if args.mode == 'run' and not (args.shards > 0 and 0 <= args.shard < args.shards):
        parser.error('Require 0 <= shard < shards')
    if args.mode == 'prepare' and (args.time_limit <= 0 or args.process_timeout <= 0):
        parser.error('Time limits must be positive')
    args.func(args)


if __name__ == '__main__':
    main()
