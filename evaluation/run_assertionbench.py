#!/usr/bin/env python3
"""Run the Veri2 inference and Jasper proof protocol on AssertionBench RTL.

AssertionBench is used only as an external RTL corpus. The prompt, sampling
settings, and proof script are the ones used for the in-distribution test set;
the benchmark's own few-shot protocol and published scores are not reproduced.

Commands (package = a directory laid out like the repository root):
  prepare    build tasks from a pinned AssertionBench checkout (run locally)
  generate   vLLM inference (not used for the reported results)
  generate-hf  transformers inference for base Qwen and the three adapters (GPU)
  verify     JasperGold proof run for one shard of (condition, design) pairs
  summarize  explicit per-assertion verdict counts per condition
"""
import argparse
from collections import Counter, defaultdict
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
REVISION = '07840fbbfe882b67fb7c549bdb7fe1328aadd6d2'
CONDITIONS = ['base_qwen', 'adapter_all', 'adapter_syntax_pass', 'adapter_verified']
# Hub id of each trained adapter (reproducible with fine_tuning/sva_qlora_finetune.ipynb).
ADAPTERS = {'adapter_all': 'veri2-anon/sva-qlora-all',
            'adapter_syntax_pass': 'veri2-anon/sva-qlora-syntax_pass',
            'adapter_verified': 'veri2-anon/sva-qlora-verified'}
BASE = 'Qwen/Qwen2.5-Coder-7B-Instruct'
BASE_REVISION = 'c03e6d358207e414f1eca0bb1891e29f1db0e242'
SETTINGS = {'temperature': 0.1, 'top_p': 0.95, 'max_new_tokens': 2048, 'max_model_len': 8192,
            'seed': 20261109, 'proof_time_limit_seconds': 300, 'process_timeout_seconds': 3600}
KEYWORDS = set('''module if else begin end always assign case casex casez for function task initial
generate wire reg input output inout parameter localparam integer or and not nand nor xor xnor buf
while repeat defparam genvar real time event default forever wait disable specify primitive table
supply0 supply1 tri bufif0 bufif1 notif0 notif1 pullup pulldown endmodule endfunction endtask
endgenerate endcase posedge negedge signed return'''.split())


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def strip_comments(text):
    return re.sub(r'/\*.*?\*/|//[^\n]*', '', text, flags=re.S)


def normalize(text):
    return re.sub(r'\s+', '', strip_comments(text))


def modules(text):
    return re.findall(r'\bmodule\s+(\w+)', strip_comments(text))


def instantiated(text):
    clean = strip_comments(text)
    found = re.findall(r'^\s*([A-Za-z_]\w*)\s+(?:#\s*\([^;]*?\)\s*)?[A-Za-z_]\w*\s*(?:\[[^\]]*\]\s*)?\(', clean, re.M)
    return {name for name in found if name not in KEYWORDS} - set(modules(text))


def inline_includes(path, project, seen=()):
    """Return source with `include lines replaced by the included text."""
    def replace(match):
        name = match.group(1)
        for base in [path.parent, *[p for p in path.parents if project in p.parents or p == project]]:
            candidate = base / name
            if candidate.is_file():
                if candidate in seen:
                    return ''
                return inline_includes(candidate, project, (*seen, candidate))
        if Path(name).name == 'timescale.v':
            return ''  # a time-unit directive only; irrelevant to formal analysis
        raise FileNotFoundError(f'include {name}')
    return re.sub(r'^[ \t]*`include\s+"([^"]+)"[^\n]*', replace, path.read_text(errors='replace'), flags=re.M)


def reset_expression(rtl, name):
    """Use the released reset signal; read its polarity from the RTL itself."""
    if name in ('-none', ''):
        return ''
    clean = strip_comments(rtl)
    low = re.search(rf'negedge\s+{re.escape(name)}\b|if\s*\(\s*[!~]\s*{re.escape(name)}\s*\)|'
                    rf'{re.escape(name)}\s*==\s*(?:1\'b)?0', clean)
    high = re.search(rf'posedge\s+{re.escape(name)}\b|if\s*\(\s*{re.escape(name)}\s*\)|'
                     rf'{re.escape(name)}\s*==\s*(?:1\'b)?1', clean)
    if not re.search(rf'\b{re.escape(name)}\b', clean):
        return ''
    return f'!{name}' if low and not high else name


def prepare(args):
    upstream = args.upstream.resolve()
    version = subprocess.check_output(['git', '-C', str(upstream), 'rev-parse', 'HEAD'], text=True).strip()
    if version != REVISION:
        raise SystemExit(f'Expected AssertionBench revision {REVISION}, got {version}')
    out = args.package.resolve()
    out.mkdir(parents=True, exist_ok=False)
    listed = [row[0] for row in csv.reader((upstream / 'results.csv').open())][1:]
    setups = defaultdict(list)
    for path in sorted((upstream / 'Jasper_results').rglob('FPV_*.tcl')):
        match = re.search(r'RTL_PATH\}/(\S+\.v)', path.read_text())
        if match:
            setups[match.group(1)].append(path)
    existing, existing_names = set(), set()
    for path in sorted((ROOT / 'data/veri_thoughts/prepared/all').glob('*.jsonl')):
        for line in path.read_text().splitlines():
            if line.strip():
                rtl = json.loads(line)['rtl']
                existing.add(normalize(rtl))
                existing_names.update(modules(rtl))
    tasks, excluded = [], []
    for name in listed:
        candidates = [p for p in setups.get(name, []) if (p.parent / name).is_file()]
        if not candidates:
            excluded.append({'design': name, 'reason': 'no released Jasper setup beside the RTL file'})
            continue
        setup = candidates[0]
        source = setup.parent / name
        project = upstream / 'Jasper_results' / setup.relative_to(upstream / 'Jasper_results').parts[0]
        script = setup.read_text()
        try:
            rtl = inline_includes(source, project)
            defined = modules(rtl)
            top = re.search(r'elaborate\s+-top\s+(\S+)', script)
            top = top.group(1) if top else (defined[0] if len(defined) == 1 else None)
            if top not in defined:
                raise ValueError(f'released top {top} is not defined in {name}')
            parts, dependencies = [rtl], []
            while True:
                missing = sorted(instantiated('\n'.join(parts)) - set(modules('\n'.join(parts))))
                if not missing:
                    break
                wanted = missing[0]
                files = [p for p in sorted(project.rglob('*.v')) if wanted in modules(p.read_text(errors='replace'))]
                if not files:
                    raise ValueError(f'submodule {wanted} is not in the release')
                text = inline_includes(files[0], project)
                # Keep only modules not already present to avoid redefinition.
                have = set(modules('\n'.join(parts)))
                blocks = re.findall(r'\bmodule\b.*?\bendmodule\b', text, flags=re.S)
                keep = [b for b in blocks if modules(b) and modules(b)[0] not in have]
                if not keep:
                    raise ValueError(f'could not extract submodule {wanted}')
                parts.append('\n'.join(keep))
                dependencies.append(str(files[0].relative_to(upstream)))
            rtl = '\n\n'.join(parts)
        except (FileNotFoundError, ValueError) as error:
            excluded.append({'design': name, 'reason': str(error)})
            continue
        clock = re.search(r'^clock\s+(.+)$', script, re.M)
        reset = re.search(r'^reset\s+(.+)$', script, re.M)
        released_reset = reset.group(1).strip() if reset else '-none'
        task = {'id': Path(name).stem, 'top': top, 'source': str(source.relative_to(upstream)),
                'source_sha256': sha(source), 'dependencies': dependencies,
                'released_clock': clock.group(1).strip() if clock else '', 'released_reset': released_reset,
                'reset_expression': reset_expression(rtl, released_reset),
                'rtl_chars': len(rtl), 'rtl_lines': rtl.count('\n') + 1,
                'exact_veri2_overlap': normalize(rtl) in existing,
                'top_name_in_veri2': top in existing_names, 'rtl': rtl}
        if task['exact_veri2_overlap']:
            excluded.append({'design': name, 'reason': 'exact normalized RTL match with Veri2'})
            continue
        tasks.append(task)
    if len({t['id'] for t in tasks}) != len(tasks):
        raise SystemExit('Duplicate task ids')
    with (out / 'tasks.jsonl').open('w') as handle:
        for task in tasks:
            handle.write(json.dumps(task) + '\n')
    manifest = {'benchmark': 'AssertionBench', 'upstream_revision': REVISION,
                'upstream': 'https://github.com/achieve-lab/assertion_data_for_LLM',
                'listed_designs': len(listed), 'tasks': len(tasks), 'excluded': excluded,
                'conditions': CONDITIONS, 'adapters': ADAPTERS, 'base_model': BASE, 'settings': SETTINGS,
                'tasks_sha256': sha(out / 'tasks.jsonl'), 'runner_sha256': sha(__file__),
                'protocol': 'Veri2 in-distribution prompt (fine_tuning/sva_inference.ipynb), sampling settings, '
                            'and scripts/jasper_verif_check.tcl. Includes are inlined and released submodules '
                            'appended after the top module. The top is the released top. The reset signal is the '
                            'released one with polarity read from the RTL. The checker is bound to the top by signal name with an '
                            'exactly parsed port list (run_assertionbench.write_bind). AssertionBench few-shot prompts, '
                            'syntax correction, and published scores are not used.',
                'overlap_check': 'Comment/whitespace-normalized exact RTL match against all prepared Veri2 splits'}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Prepared {len(tasks)} tasks; excluded {len(excluded)}')
    for item in excluded:
        print('  excluded', item['design'], '-', item['reason'])


def load_tasks(package):
    manifest = json.loads((package / 'manifest.json').read_text())
    if sha(package / 'tasks.jsonl') != manifest['tasks_sha256']:
        raise SystemExit('The frozen task file changed')
    tasks = [json.loads(line) for line in (package / 'tasks.jsonl').read_text().splitlines() if line.strip()]
    return manifest, tasks


def notebook_prompt():
    """Execute the prompt cell of the inference notebook unchanged."""
    notebook = json.loads((ROOT / 'fine_tuning/sva_inference.ipynb').read_text())
    cells = [''.join(c['source']) for c in notebook['cells'] if c['cell_type'] == 'code']
    cell = next(c for c in cells if 'SYSTEM_PROMPT' in c and 'def make_user_prompt' in c)
    namespace = {}
    exec(compile(cell, 'sva_inference.ipynb', 'exec'), namespace)
    return namespace['SYSTEM_PROMPT'], namespace['make_user_prompt'], hashlib.sha256(cell.encode()).hexdigest()


def generate(args):
    package = args.package.resolve()
    manifest, tasks = load_tasks(package)
    settings = manifest['settings']
    system, make_user, prompt_hash = notebook_prompt()
    from huggingface_hub import snapshot_download
    from transformers import AutoTokenizer
    from vllm import LLM, SamplingParams
    from vllm.lora.request import LoRARequest
    base = snapshot_download(BASE, revision=BASE_REVISION, local_files_only=True)
    tokenizer = AutoTokenizer.from_pretrained(base)
    prompts, kept, skipped = [], [], []
    for task in tasks:
        text = tokenizer.apply_chat_template([{'role': 'system', 'content': system},
                                              {'role': 'user', 'content': make_user(task['rtl'])}],
                                             tokenize=False, add_generation_prompt=True)
        tokens = len(tokenizer.encode(text))
        if tokens + settings['max_new_tokens'] > settings['max_model_len']:
            skipped.append({'id': task['id'], 'prompt_tokens': tokens})
            continue
        prompts.append(text)
        kept.append((task, tokens))
    inference = package / 'runs/inference'
    inference.mkdir(parents=True, exist_ok=True)
    (package / 'generation.json').write_text(json.dumps({
        'prompt_cell_sha256': prompt_hash, 'base_snapshot': Path(base).name, 'generated_tasks': len(kept),
        'skipped_over_context': skipped, 'engine': 'vllm'}, indent=2) + '\n')
    print(f'{len(kept)} prompts; {len(skipped)} exceed the context allowance', flush=True)
    llm = LLM(model=base, enable_lora=True, max_lora_rank=64, max_model_len=settings['max_model_len'],
              trust_remote_code=True, dtype='bfloat16', gpu_memory_utilization=0.90, seed=settings['seed'])
    sampling = SamplingParams(temperature=settings['temperature'], top_p=settings['top_p'],
                              max_tokens=settings['max_new_tokens'], seed=settings['seed'])
    for index, condition in enumerate(args.conditions):
        if all((inference / condition / task['id'] / 'sva.sv').exists() for task, _ in kept):
            print(condition, 'already generated', flush=True)
            continue
        request, provenance = None, {}
        if condition != 'base_qwen':
            root = Path(snapshot_download(ADAPTERS[condition], local_files_only=True,
                                          allow_patterns=['final_adapter/*']))
            adapter = root / 'final_adapter'
            request = LoRARequest(lora_name=condition, lora_int_id=index + 1, lora_path=str(adapter))
            provenance = {'adapter_repo': ADAPTERS[condition], 'adapter_revision': root.name,
                          'adapter_weights_sha256': sha(adapter / 'adapter_model.safetensors')}
        outputs = llm.generate(prompts, sampling, lora_request=request)
        for (task, tokens), output in zip(kept, outputs):
            case = inference / condition / task['id']
            case.mkdir(parents=True, exist_ok=True)
            (case / 'module.v').write_text(task['rtl'])
            completion = output.outputs[0]
            (case / 'metadata.json').write_text(json.dumps({
                'id': task['id'], 'condition': condition, 'model': BASE, 'top': task['top'],
                'reset_expression': task['reset_expression'], 'temperature': settings['temperature'],
                'max_new_tokens': settings['max_new_tokens'], 'prompt_tokens': tokens,
                'completion_tokens': len(completion.token_ids), 'finish_reason': completion.finish_reason,
                **provenance}, indent=2) + '\n')
            (case / 'sva.sv').write_text(completion.text)
        print(condition, 'saved', len(outputs), flush=True)


def generate_hf(args):
    """Generate with Hugging Face transformers (one prompt at a time, seeded sampling)."""
    import torch
    from huggingface_hub import snapshot_download
    from peft import PeftModel
    from transformers import AutoModelForCausalLM, AutoTokenizer
    package = args.package.resolve()
    manifest, tasks = load_tasks(package)
    settings = manifest['settings']
    system, make_user, prompt_hash = notebook_prompt()
    base = snapshot_download(BASE, revision=BASE_REVISION, local_files_only=True)
    tokenizer = AutoTokenizer.from_pretrained(base)
    inference = package / 'runs/inference'
    for condition in args.conditions:
        model = AutoModelForCausalLM.from_pretrained(base, torch_dtype=torch.bfloat16, device_map='auto')
        provenance = {}
        if condition != 'base_qwen':
            root = Path(snapshot_download(ADAPTERS[condition], local_files_only=True,
                                          allow_patterns=['final_adapter/*']))
            adapter = root / 'final_adapter'
            model = PeftModel.from_pretrained(model, str(adapter))
            provenance = {'adapter_repo': ADAPTERS[condition], 'adapter_revision': root.name,
                          'adapter_weights_sha256': sha(adapter / 'adapter_model.safetensors')}
        model.eval()
        skipped = []
        for task in tasks:
            case = inference / condition / task['id']
            if (case / 'metadata.json').exists():
                continue
            ids = tokenizer.apply_chat_template([{'role': 'system', 'content': system},
                                                 {'role': 'user', 'content': make_user(task['rtl'])}],
                                                add_generation_prompt=True, return_tensors='pt').to(model.device)
            tokens = int(ids.shape[-1])
            if tokens + settings['max_new_tokens'] > settings['max_model_len']:
                skipped.append({'id': task['id'], 'prompt_tokens': tokens})
                continue
            torch.manual_seed(int(hashlib.sha256(f"{settings['seed']}:{task['id']}".encode()).hexdigest()[:8], 16))
            with torch.inference_mode():
                output = model.generate(ids, max_new_tokens=settings['max_new_tokens'], do_sample=True,
                                        temperature=settings['temperature'], top_p=settings['top_p'], top_k=0,
                                        repetition_penalty=1.0, pad_token_id=tokenizer.eos_token_id)
            completion = output[0, tokens:]
            case.mkdir(parents=True, exist_ok=True)
            (case / 'module.v').write_text(task['rtl'])
            (case / 'sva.sv').write_text(tokenizer.decode(completion, skip_special_tokens=True))
            (case / 'metadata.json').write_text(json.dumps({
                'id': task['id'], 'condition': condition, 'model': BASE, 'top': task['top'],
                'reset_expression': task['reset_expression'], 'temperature': settings['temperature'],
                'top_p': settings['top_p'], 'max_new_tokens': settings['max_new_tokens'], 'prompt_tokens': tokens,
                'completion_tokens': int(completion.shape[-1]), 'engine': 'transformers',
                'finish_reason': 'length' if completion.shape[-1] >= settings['max_new_tokens'] else 'stop',
                **provenance}, indent=2) + '\n')
            print(condition, task['id'], tokens, int(completion.shape[-1]), flush=True)
        (package / f'generation-{condition}.json').write_text(json.dumps({
            'engine': 'transformers', 'prompt_cell_sha256': prompt_hash, 'base_revision': BASE_REVISION,
            'skipped_over_context': skipped, **provenance}, indent=2) + '\n')
        del model
        torch.cuda.empty_cache()


def checker_ports(source):
    """Port names of the first module header, with balanced parentheses."""
    clean = strip_comments(source)
    head = re.search(r'\bmodule\s+(?:automatic\s+)?(\w+)', clean)
    if not head:
        return None, []
    i, depth, start, groups = head.end(), 0, None, []
    while i < len(clean):
        ch = clean[i]
        if ch == '(':
            if depth == 0:
                start = i + 1
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                groups.append(clean[start:i])
        elif ch == ';' and depth == 0:
            break
        i += 1
    if not groups:
        return head.group(1), []
    ports, piece, depth = [], '', 0
    for ch in groups[-1] + ',':
        depth += ch in '([{'
        depth -= ch in ')]}'
        if ch == ',' and depth == 0:
            piece = re.sub(r'\[[^\]]*\]', ' ', piece.split('=')[0])
            names = re.findall(r'[A-Za-z_]\w*', piece)
            if names:
                ports.append(names[-1])
            piece = ''
        else:
            piece += ch
    return head.group(1), ports


def write_bind(rtl, top, sva, path):
    """Bind the checker to the top by signal name, as the original Tcl helper intends.

    The Tcl helper reads the checker port list with a regular expression that can
    run past the module header on longer files. This parses the header exactly.
    Ports with no same-named signal in the top module are left unconnected.
    """
    clean = strip_comments(sva)
    if re.search(r'(?m)^\s*bind\s+', clean):
        return 'existing'
    name, ports = checker_ports(sva)
    block = re.search(rf'\bmodule\s+{re.escape(top)}\b.*?\bendmodule\b', strip_comments(rtl), flags=re.S)
    signals = {}
    for identifier in re.findall(r'[A-Za-z_]\w*', block.group(0) if block else ''):
        if identifier not in KEYWORDS:
            signals.setdefault(identifier.lower(), identifier)
    links = [f'    .{p}({signals[p.lower()]})' for p in ports if p.lower() in signals]
    if not name or name == top or not links:
        return None
    path.write_text(f'bind {top} {name} auto_sva_inst (\n' + ',\n'.join(links) + '\n);\n')
    return 'written'


def cases(package, conditions):
    inference = package / 'runs/inference'
    return [(c, d) for c in conditions for d in sorted((inference / c).iterdir())
            if d.is_dir() and (d / 'sva.sv').is_file()]


RESULTS = 'verification_results'


def run_jasper(out, env, tcl, settings, condition, name):
    command = ['jaspergold', '-batch', '-allow_unsupported_OS', '-proj', str(out / 'jgproject'), '-tcl', str(tcl)]
    status = 'completed'
    with (out / 'run.log').open('w') as log:
        try:
            code = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT, cwd=out,
                                  timeout=settings['process_timeout_seconds']).returncode
        except subprocess.TimeoutExpired:
            code, status = None, 'process_timeout'
    subprocess.run(['rm', '-rf', str(out / 'jgproject')])
    (out / 'DONE').write_text(json.dumps({'status': status, 'exit_code': code}) + '\n')
    print(condition, name, status, code, flush=True)


def verify(args):
    package = args.package.resolve()
    manifest, _ = load_tasks(package)
    settings = manifest['settings']
    tcl = ROOT / 'scripts/jasper_verif_check.tcl'
    selected = [x for i, x in enumerate(cases(package, args.conditions)) if i % args.shards == args.shard]
    for condition, case in selected:
        out = package / 'runs/inference' / RESULTS / condition / 'ids' / case.name
        if (out / 'DONE').exists():
            continue
        out.mkdir(parents=True, exist_ok=True)
        meta = json.loads((case / 'metadata.json').read_text())
        sva = re.sub(r'\A\s*```[^\n]*\n|\n```\s*\Z', '', (case / 'sva.sv').read_text())
        (out / 'checker.sv').write_text(sva)
        files = [str(out / 'checker.sv')]
        bind = write_bind((case / 'module.v').read_text(), meta['top'], sva, out / 'auto_bind.sv')
        if bind is None:
            (out / 'run.log').write_text('No checker module with a port matching the top module; Jasper not run.\n')
            (out / 'DONE').write_text(json.dumps({'status': 'no_bind', 'exit_code': None}) + '\n')
            print(condition, case.name, 'no_bind', flush=True)
            continue
        if bind == 'written':
            files.append(str(out / 'auto_bind.sv'))
        env = dict(os.environ, DESIGN_ID=case.name, JG_TOP=meta['top'], JG_DESIGN=str(case / 'module.v'),
                   JG_SVA=' '.join(files), JG_STD='sv12', JG_NO_CLOCK='1', JG_OUT_DIR=str(out),
                   JG_RESET_EXPR=meta['reset_expression'])
        run_jasper(out, env, tcl, settings, condition, case.name)


def summarize(args):
    import sys
    sys.path.insert(0, str(ROOT / 'evaluation'))
    from collect_verdicts import inventory, parse_log
    package = args.package.resolve()
    manifest, tasks = load_tasks(package)
    rows, summary = [], {}
    for condition in args.conditions:
        total = Counter()
        for _, case in cases(package, [condition]):
            out = package / 'runs/inference' / RESULTS / condition / 'ids' / case.name
            log = (out / 'run.log').read_text(errors='replace') if (out / 'run.log').is_file() else ''
            done = json.loads((out / 'DONE').read_text()) if (out / 'DONE').is_file() else {'status': 'not_run'}
            names = inventory((out / 'property_list.txt').read_text()) if (out / 'property_list.txt').is_file() else []
            events, _ = parse_log(log)
            verdicts = Counter()
            for name in names:
                seen = events.get(name, set())
                verdicts['proven' if seen == {'proven'} else 'cex' if seen & {'cex', 'ar_cex'}
                         else 'other'] += 1
            if done['status'] != 'completed':
                stage = done['status']
            elif re.search(r'(?m)^\W*FAILED: compile/elab errors', log):
                stage = 'compile_error'
            elif re.search(r'(?m)^\W*FAILED: No properties found', log):
                stage = 'no_properties'
            elif names:
                stage = 'proof_ran'
            else:
                stage = 'error'
            written = len(re.findall(r'\bassert\s+property\b', strip_comments((case / 'sva.sv').read_text())))
            meta = json.loads((case / 'metadata.json').read_text())
            rows.append({'condition': condition, 'id': case.name, 'stage': stage, 'assertions_written': written,
                         'assertions_elaborated': len(names), 'proven': verdicts['proven'], 'cex': verdicts['cex'],
                         'other': verdicts['other'], 'finish_reason': meta.get('finish_reason')})
            total['designs'] += 1
            total['stage_' + stage] += 1
            total['assertions_written'] += written
            total['assertions_elaborated'] += len(names)
            total['proven'] += verdicts['proven']
            total['cex'] += verdicts['cex']
            total['other'] += verdicts['other']
            total['designs_with_proof'] += verdicts['proven'] > 0
            total['length_capped'] += meta.get('finish_reason') == 'length'
        summary[condition] = dict(total)
    suffix = ''
    with (package / f'proof_results{suffix}.csv').open('w', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    (package / f'proof_summary{suffix}.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('command', choices=['prepare', 'generate', 'generate-hf', 'verify', 'summarize'])
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--upstream', type=Path)
    parser.add_argument('--conditions', nargs='+', default=CONDITIONS,
                        choices=CONDITIONS + ['chatgpt_baseline', 'adapter_vert'])
    parser.add_argument('--shard', type=int, default=0)
    parser.add_argument('--shards', type=int, default=1)
    args = parser.parse_args()
    {'prepare': prepare, 'generate': generate, 'generate-hf': generate_hf, 'verify': verify, 'summarize': summarize}[args.command](args)


if __name__ == '__main__':
    main()
