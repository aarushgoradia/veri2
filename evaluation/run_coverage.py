#!/usr/bin/env python3
"""Replay saved test designs through the proof-core coverage flow."""
import argparse
from collections import Counter, defaultdict
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import statistics
import subprocess
from types import SimpleNamespace

from run_formal_analysis import prepare as prepare_jasper


ROOT = Path(__file__).resolve().parents[1]
MODELS = ('adapter_verified', 'chatgpt_baseline')
LABELS = {'adapter_verified': 'Verified-trained Qwen', 'chatgpt_baseline': 'GPT-5 baseline',
          'adapter_all': 'All adapter', 'adapter_syntax_pass': 'Syntax adapter', 'base_qwen': 'Base Qwen',
          'adapter_vert': 'VERT adapter'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def replay_setup(log):
    def field(key):
        values = re.findall(rf'^  {key}[ \t]*:[ \t]*([^\r\n]*)', log, re.M)
        if len(values) != 1:
            raise ValueError(f'Expected one saved {key} setting')
        return values[0].strip()

    top = field('TOP')
    if not re.fullmatch(r'[a-zA-Z_][\w$]*', top):
        raise ValueError(f'Unsupported top name: {top}')
    if (field('STD'), field('INCDIRS'), field('DEFINES'), field('NO_CLOCK')) != ('sv12', '', '', '1'):
        raise ValueError('Saved frontend or clock setup requires review')
    resets = re.findall(r'^INFO: Using (?:active-low reset expression|reset expression|reset signal): ([^\r\n]+)', log, re.M)
    resets += [''] * len(re.findall(r'^INFO: No reset signal found; using reset -none', log, re.M))
    if len(resets) != 1:
        raise ValueError('Expected one saved reset setting')
    auto_bind = field('AUTO_BIND')
    if auto_bind not in ('0', '1'):
        raise ValueError('Unrecognized saved bind mode')
    return {'top': top, 'reset': resets[0], 'auto_bind': auto_bind == '1'}


def prepare(args):
    out = args.package.resolve()
    out.mkdir(parents=True, exist_ok=False)
    inference = ROOT / 'inference_outputs'
    cohort = args.cohort.resolve() if args.cohort else ROOT / 'results/test_set/case_quality.csv'
    with cohort.open(newline='') as f:
        cohort_rows = list(csv.DictReader(f))
    models = tuple(dict.fromkeys(row['condition'] for row in cohort_rows))
    if not models or len(models) > 2 or not set(models) <= set(LABELS):
        raise ValueError(f'Expected one or two supported model conditions, got {models}')
    evidence = ROOT / 'results/test_set/assertion_verdicts.csv'
    proofs = defaultdict(list)
    with evidence.open(newline='') as f:
        for row in csv.DictReader(f):
            if row['condition'] in models and row['evidence_status'] == 'proven':
                proofs[row['condition'], row['id']].append(row['property'])

    cases = []
    with cohort.open(newline='') as f:
        for row in csv.DictReader(f):
            model, design = row['condition'], row['id']
            if model not in models:
                raise ValueError(f'Unexpected condition: {model}')
            saved_proofs = proofs[model, design]
            if len(saved_proofs) != int(row['original_proven_assertions']):
                raise ValueError(f'Saved proof evidence disagrees for {model}/{design}')
            source = inference / model / design
            case = {'condition': model, 'id': design, 'status': 'ready',
                    'syntax_status': row['syntax_status'], 'saved_proofs': saved_proofs,
                    'rtl_sha256': sha(source / 'module.v'), 'rtl_bytes': (source / 'module.v').stat().st_size}
            cases.append(case)
            if row['syntax_status'] != 'ok':
                case['status'] = 'prior_syntax_failure'
                continue
            if not saved_proofs:
                case['status'] = 'no_saved_proofs'
                continue
            saved = inference / 'verification_results' / model / 'ids' / design
            try:
                setup = replay_setup((saved / 'run.log').read_text(errors='replace'))
                # VERT is replayed with the repaired checker of its saved proof run.
                checker = saved / 'sva_fixed.sv' if model == 'adapter_vert' else source / 'sva.sv'
                files = [source / 'module.v', checker]
                if setup['auto_bind']:
                    files.append(saved / 'auto_bind.sv')
                hashes = {('sva.sv' if p == checker else p.name): sha(p) for p in files}
            except (ValueError, OSError) as error:
                case.update(status='unsupported_setup', reason=str(error))
                continue
            inputs = out / 'inputs' / model / design
            inputs.mkdir(parents=True)
            for path in files:
                shutil.copyfile(path, inputs / ('sva.sv' if path == checker else path.name))
            case.update(setup, input_sha256=hashes, saved_log_sha256=sha(saved / 'run.log'))

    by_design = defaultdict(list)
    for case in cases:
        by_design[case['id']].append(case)
    if len(by_design) != 578 or any({c['condition'] for c in group} != set(models)
                                    or len(group) != len(models) for group in by_design.values()):
        raise ValueError('Expected one record per condition across all 578 held-out designs')
    strata = defaultdict(list)
    for design, group in by_design.items():
        first = group[0]
        if all(c['status'] == 'ready' for c in group) and all(
            c[k] == first[k] for c in group for k in ('rtl_sha256', 'top', 'reset')
        ):
            strata[bool(first['reset'])].append((first['rtl_bytes'], design))
    pilot = []
    for group in strata.values():
        group.sort()
        pilot.extend(group[i][1] for i in sorted({0, len(group) // 2, len(group) - 1}))
    manifest = {'cases': cases, 'conditions': models, 'pilot_ids': sorted(pilot),
                'pilot_selection': 'Smallest, median and largest RTL by bytes within each reset stratum among paired replayable designs',
                'source_sha256': {str(p.relative_to(ROOT)): sha(p) for p in
                                  (cohort, evidence, ROOT / 'evaluation/tcl/coverage.tcl')}}
    write_json(out / 'manifest.json', manifest)
    print('Pilot IDs:', *manifest['pilot_ids'])
    for model in models:
        print(model, dict(Counter(c['status'] for c in cases if c['condition'] == model)))


def prepare_package(args):
    """Build a coverage package from an external evaluation package.

    Reads the layout written by run_assertionbench.py (runs/inference/<condition>/<id>
    plus the bound-checker proof results) instead of the frozen
    held-out cohort files. Top and reset come from each case's metadata.
    """
    from collect_verdicts import inventory, parse_log
    out = args.package.resolve()
    source_root = args.source.resolve()
    out.mkdir(parents=True, exist_ok=False)
    inference = source_root / 'runs/inference'
    results = 'verification_results'
    cases = []
    for model in args.conditions:
        for source in sorted((inference / model).iterdir()):
            if not (source / 'sva.sv').is_file():
                continue
            saved = inference / results / model / 'ids' / source.name
            meta = json.loads((source / 'metadata.json').read_text())
            log = (saved / 'run.log').read_text(errors='replace') if (saved / 'run.log').is_file() else ''
            names = inventory((saved / 'property_list.txt').read_text()) if (saved / 'property_list.txt').is_file() else []
            events, _ = parse_log(log)
            saved_proofs = [n for n in names if events.get(n) == {'proven'}]
            case = {'condition': model, 'id': source.name, 'status': 'ready',
                    'syntax_status': 'ok' if names else 'no_elaborated_assertions', 'saved_proofs': saved_proofs,
                    'rtl_sha256': sha(source / 'module.v'), 'rtl_bytes': (source / 'module.v').stat().st_size,
                    'top': meta['top'], 'reset': meta.get('reset_expression', ''), 'auto_bind': True}
            cases.append(case)
            if not names:
                case['status'] = 'prior_syntax_failure'
                continue
            if not saved_proofs:
                case['status'] = 'no_saved_proofs'
                continue
            inputs = out / 'inputs' / model / source.name
            inputs.mkdir(parents=True)
            shutil.copyfile(source / 'module.v', inputs / 'module.v')
            shutil.copyfile(saved / 'checker.sv', inputs / 'sva.sv')
            bind = saved / 'auto_bind.sv'
            if bind.is_file():
                shutil.copyfile(bind, inputs / 'auto_bind.sv')
            else:
                (inputs / 'auto_bind.sv').write_text('// bind statement is inside sva.sv\n')
            case.update(input_sha256={p.name: sha(p) for p in sorted(inputs.iterdir())},
                        saved_log_sha256=sha(saved / 'run.log'))
    manifest = {'cases': cases, 'conditions': list(args.conditions), 'pilot_ids': [],
                'source_package': str(source_root),
                'source_sha256': {str(p.relative_to(ROOT)): sha(p) for p in (ROOT / 'evaluation/tcl/coverage.tcl',)}}
    write_json(out / 'manifest.json', manifest)
    for model in args.conditions:
        print(model, dict(Counter(c['status'] for c in cases if c['condition'] == model)))


def parse_coverage(report, top, targets):
    header = next((line.split('|')[1:-1] for line in report.splitlines() if 'Instance Name' in line), [])
    columns = [cell.strip() for cell in header]
    if not {'Instance Name', 'Checker'} <= set(columns):
        raise ValueError('Missing Checker Coverage header')
    root_rows = [line.split('|')[1:-1] for line in report.splitlines() if line.startswith('|')
                 and line.split('|')[1].strip() == top]
    if len(root_rows) != 1:
        raise ValueError(f'Expected exactly one DUT root row for {top}')
    cell = root_rows[0][columns.index('Checker')].strip()
    match = re.fullmatch(r'\d+(?:\.\d+)?%\s*\((\d+)\s*/\s*(\d+)\)', cell)
    if not match:
        raise ValueError(f'Unexpected Checker Coverage value: {cell}')
    checked, total = map(int, match.groups())
    reported_targets = re.findall(r'\bTotal Assertions:\s*(\d+)', report)
    if reported_targets != [str(targets)] or not 0 <= checked <= total:
        raise ValueError('Coverage report target count or item counts disagree')
    return checked, total


def normalize_proof_names(names):
    prefix = '<embedded>::'
    return {name[len(prefix):] if name.startswith(prefix) else name for name in names}


def evaluate_case(package, case, coverage, timeout):
    model, design = case['condition'], case['id']
    stage = package / 'runs' / coverage / model / design
    result_path = stage / 'result.json'
    if result_path.exists():
        return
    if stage.exists():
        raise ValueError(f'Incomplete stage already exists: {stage}')
    inputs = package / 'inputs' / model / design
    for name, expected in case['input_sha256'].items():
        if sha(inputs / name) != expected:
            raise ValueError(f'Packaged input changed: {inputs / name}')
    options = SimpleNamespace(input_dir=inputs, out_dir=stage, top=case['top'], clock=None,
                              reset_expr=case['reset'], rtl=None, bind=inputs / 'auto_bind.sv' if case['auto_bind'] else None,
                              embedded_bind=not case['auto_bind'], coverage=coverage, dut_instance=case['top'],
                              time_limit=60, prove_covers=False, dump_traces=False, jg='jg', execute=True)
    result = {'status': 'error', 'condition': model, 'id': design, 'mode': coverage}
    try:
        _, command = prepare_jasper(options)
        with (stage / 'console.log').open('w') as log:
            process = subprocess.Popen(command, cwd=stage, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            try:
                code = process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                code = -9
        result['exit_code'] = code
        if code == -9:
            result['status'] = 'timeout'
        elif code or not (stage / 'completed.txt').exists():
            result['reason'] = 'Jasper run incomplete. See console.log and error.txt.'
        else:
            fresh = (stage / 'proven.txt').read_text().splitlines()
            saved_names = normalize_proof_names(case['saved_proofs'])
            fresh_names = normalize_proof_names(fresh)
            result.update(saved_proven=len(case['saved_proofs']), fresh_proven=len(fresh),
                          saved_not_reproved=sorted(saved_names - fresh_names),
                          additional_proofs=sorted(fresh_names - saved_names))
            if (stage / 'assumptions.txt').read_text().strip():
                result['status'] = 'model_assumptions'
            elif not fresh:
                result['status'] = 'no_fresh_proofs'
            else:
                targets = (stage / 'coverage_targets.txt').read_text().splitlines()
                if sorted(targets) != sorted(fresh):
                    raise ValueError('Coverage targets differ from the fresh proof set')
                checked, total = parse_coverage((stage / 'coverage_report.txt').read_text(), case['top'], len(targets))
                result.update(status='measured' if total else 'no_coverage_items', covered=checked, total=total,
                              percent=100 * checked / total if total else None)
    except (ValueError, OSError) as error:
        stage.mkdir(parents=True, exist_ok=True)
        result.update(status='error', reason=str(error))
    write_json(result_path, result)
    print(coverage, model, design, result['status'], result.get('percent', ''), flush=True)


def summarize(package, coverage, selected=None):
    manifest = json.loads((package / 'manifest.json').read_text())
    models = tuple(manifest.get('conditions', MODELS))
    win_keys = ('qwen_higher', 'gpt5_higher') if models == MODELS else tuple(f'{m}_higher' for m in models)
    rows, by_design = [], defaultdict(dict)
    for case in manifest['cases']:
        if selected is not None and case['id'] not in selected:
            continue
        path = package / 'runs' / coverage / case['condition'] / case['id'] / 'result.json'
        result = json.loads(path.read_text()) if path.exists() else {}
        row = {k: case.get(k) for k in ('condition', 'id', 'rtl_sha256', 'top', 'reset')}
        row.update(saved_proven=len(case['saved_proofs']), syntax_status=case['syntax_status'],
                   scheduled=case['status'] == 'ready',
                   status=result.get('status', 'pending' if case['status'] == 'ready' else case['status']))
        row.update({k: result.get(k) for k in ('fresh_proven', 'covered', 'total', 'percent')})
        fresh_path = path.with_name('proven.txt')
        row['missing_saved_proofs'] = (len(normalize_proof_names(case['saved_proofs']) -
                                          normalize_proof_names(fresh_path.read_text().splitlines()))
                                       if 'fresh_proven' in result else None)
        rows.append(row)
        by_design[case['id']][case['condition']] = row
    paired = []
    comparisons = Counter()
    incompatible = []
    for design, pair in by_design.items():
        if len(models) != 2:
            continue
        a, b = (pair[m] for m in models)
        if a['status'] == b['status'] == 'measured':
            if all(a[k] == b[k] for k in ('rtl_sha256', 'top', 'reset', 'total')):
                paired.append((a['percent'], b['percent']))
                comparison = win_keys[0] if a['covered'] > b['covered'] else (
                    win_keys[1] if a['covered'] < b['covered'] else 'equal')
                comparisons[comparison] += 1
            else:
                incompatible.append(design)
    summary = {'mode': coverage, 'design_ids': len(by_design), 'models': {},
               'both_have_saved_proofs': sum(all(row['saved_proven'] > 0 for row in pair.values())
                                              for pair in by_design.values()) if len(models) == 2 else 0,
               'paired_measured_designs': len(paired), 'incompatible_pair_ids': incompatible,
               'paired_comparison_counts': dict(comparisons),
               'paired_mean_percent': {m: statistics.mean(p[i] for p in paired) if paired else None
                                       for i, m in enumerate(models)}, 'win_keys': win_keys}
    for model in models:
        selected_rows = [r for r in rows if r['condition'] == model]
        measured = [r for r in selected_rows if r['status'] == 'measured']
        summary['models'][model] = {
            'statuses': dict(Counter(r['status'] for r in selected_rows)),
            'syntax_pass': sum(r['syntax_status'] == 'ok' for r in selected_rows),
            'designs_with_saved_proof': sum(r['saved_proven'] > 0 for r in selected_rows),
            'saved_proofs': sum(r['saved_proven'] for r in selected_rows),
            'scheduled': sum(r['scheduled'] for r in selected_rows),
            'saved_proofs_reproduced': sum(r['saved_proven'] - r['missing_saved_proofs']
                                         for r in selected_rows if r['missing_saved_proofs'] is not None),
            'mean_percent_measured': statistics.mean(r['percent'] for r in measured) if measured else None,
        }
    out = package / ('pilot_summary' if selected is not None else 'summary') / coverage
    out.mkdir(parents=True, exist_ok=True)
    with (out / 'case_coverage.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    write_json(out / 'summary.json', summary)
    write_summary_table(out / 'coverage_table.md', summary, pilot=selected is not None)
    print(json.dumps(summary, indent=2))


def write_summary_table(path, summary, pilot):
    conditions = list(summary['models'])
    models = list(summary['models'].values())
    pending = sum(model['statuses'].get('pending', 0) for model in models)
    metric = {'coi': 'COI', 'proof': 'Proof-core'}[summary['mode']]
    title = f'# {metric} coverage' + (' pilot' if pilot else ' on held-out RTL')
    scope = ('Run in progress. Comparative averages will appear when all scheduled cases have a result.'
             if pending else 'All scheduled cases have a recorded outcome.')
    lines = [title, '', scope, '', '| Step | ' + ' | '.join(LABELS[c] for c in conditions) + ' |',
             '| --- |' + ' ---: |' * len(models)]

    def row(label, *values):
        lines.append('| ' + ' | '.join([label, *map(str, values)]) + ' |')

    def count(key):
        return [f'{model[key]:,}' for model in models]

    def status(key):
        return [f"{model['statuses'].get(key, 0):,}" for model in models]

    def ratio(numerator, denominator):
        share = f' ({100 * numerator / denominator:.1f}%)' if denominator else ''
        return f'{numerator:,} / {denominator:,}{share}'

    designs = summary['design_ids']
    row('**Test designs**', *[f'{designs:,}'] * len(models))
    row('Passed syntax', *[ratio(m['syntax_pass'], designs) for m in models])
    row('At least one saved proof', *[ratio(m['designs_with_saved_proof'], designs) for m in models])
    row('**Saved proven assertions**', *count('saved_proofs'))
    row('Saved proofs reproduced so far' if pending else 'Saved proofs reproduced',
        *[ratio(m['saved_proofs_reproduced'], m['saved_proofs']) for m in models])
    row('**Coverage replays scheduled**', *count('scheduled'))
    row('Designs with a coverage measurement',
        *[ratio(m['statuses'].get('measured', 0), m['scheduled']) for m in models])
    for key, label in [('no_coverage_items', 'DUT had zero coverage items'),
                       ('no_fresh_proofs', 'No assertions proved on replay'),
                       ('model_assumptions', 'Excluded because of checker assumptions'),
                       ('error', 'Execution or report error'), ('timeout', 'Timed out'), ('pending', 'Result pending')]:
        if any(m['statuses'].get(key, 0) for m in models):
            row(label, *status(key))
    paired = summary['paired_measured_designs']
    candidates = summary['both_have_saved_proofs']
    pair_count = f'{paired:,} / {candidates:,}'
    if len(models) == 2:
        row('**Matched designs with measurable coverage**', pair_count, pair_count)
        means = summary['paired_mean_percent']
        row(f'**Mean {metric.lower()} coverage on matched designs**',
            *['Pending' if pending else f'{means[m]:.1f}%' if paired else 'Unavailable' for m in conditions])
    if paired and not pending:
        comparisons = summary['paired_comparison_counts']
        row('Matched designs with higher coverage', *[f'{comparisons.get(k, 0):,}' for k in summary['win_keys']])
        lines.extend(['', f"Equal coverage on {comparisons.get('equal', 0):,} matched designs."])
    lines.extend(['', 'A design enters the paired mean when both models have measurable coverage under the same RTL, top, '
                  'reset, and item count. The mean gives each matched design equal weight. '
                  'Within each run, coverage combines all freshly proven assertions. '
                  'The saved proof counts come from the original held-out evaluation.'])
    if summary['incompatible_pair_ids']:
        lines.extend(['', f"Matched IDs with incompatible measurement settings or item counts: {len(summary['incompatible_pair_ids']):,}."])
    lines.extend(['', '[Per-design coverage rows](case_coverage.csv) · [Exact summary values](summary.json)', ''])
    path.write_text('\n'.join(lines))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'prepare-package', 'run', 'summarize'])
    parser.add_argument('--source', type=Path, help='External evaluation package (prepare-package)')
    parser.add_argument('--conditions', nargs='+',
                        default=['base_qwen', 'adapter_all', 'adapter_syntax_pass', 'adapter_verified'])
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--cohort', type=Path, help='Frozen case-quality CSV for preparation')
    parser.add_argument('--mode', choices=['coi', 'proof'], default='coi')
    parser.add_argument('--pilot', action='store_true')
    parser.add_argument('--shard', type=int, default=0)
    parser.add_argument('--shards', type=int, default=1)
    parser.add_argument('--timeout', type=int, default=120)
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args)
        return
    if args.command == 'prepare-package':
        prepare_package(args)
        return
    if not 0 <= args.shard < args.shards or args.timeout < 1:
        parser.error('Require 0 <= shard < shards and positive timeout')
    package = args.package.resolve()
    manifest = json.loads((package / 'manifest.json').read_text())
    selected = set(manifest['pilot_ids']) if args.pilot else None
    if args.command == 'summarize':
        summarize(package, args.mode, selected)
        return
    for case in manifest['cases'][args.shard::args.shards]:
        if case['status'] == 'ready' and (selected is None or case['id'] in selected):
            evaluate_case(package, case, args.mode, args.timeout)


if __name__ == '__main__':
    main()
