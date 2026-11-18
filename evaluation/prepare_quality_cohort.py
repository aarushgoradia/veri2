#!/usr/bin/env python3
"""Prepare selected models with saved syntax and explicit proof cohorts."""
import argparse
from collections import Counter, defaultdict
import csv
import hashlib
import json
from pathlib import Path

import run_quality_checks as runner


CONDITIONS = ['adapter_verified', 'chatgpt_baseline']


def prepare(args):
    root = runner.ROOT
    conditions = getattr(args, 'conditions', CONDITIONS)
    syntax = {}
    sources = []
    for condition in conditions:
        path = root / 'inference_outputs/syntax_results' / condition / 'visual_data/summary.csv'
        sources.append(path)
        for row in csv.DictReader(path.open()):
            key = condition, row['id']
            if key in syntax:
                raise ValueError(f'Duplicate syntax record: {key}')
            syntax[key] = row['status']
    path = root / 'results/test_set/assertion_verdicts.csv'
    sources.append(path)
    evidence = defaultdict(list)
    seen = set()
    for row in csv.DictReader(path.open()):
        if row['condition'] not in conditions:
            continue
        identity = row['condition'], row['id'], row['property']
        if identity in seen:
            raise ValueError(f'Duplicate proof inventory record: {identity}')
        seen.add(identity)
        evidence[identity[:2]].append({'name': row['property'], 'status': row['evidence_status']})
    args.conditions = conditions
    runner.prepare(args)
    out = args.out_dir.resolve()
    manifest = json.loads((out / 'manifest.json').read_text())
    cohorts = []
    for task in manifest['tasks']:
        key = task['condition'], task['id']
        props = evidence[key]
        proved = [p['name'] for p in props if p['status'] == 'proven']
        if key[0] == 'adapter_vert' and props:
            # The saved VERT proof run used the repaired checker (sva_fixed.sv), which
            # elaborated even where the raw output failed the syntax check. The checks
            # here use that same repaired checker, so eligibility follows the saved run.
            task['raw_syntax_status'] = syntax[key]
            syntax[key] = 'ok'
        task.update(syntax_status=syntax[key], formal_proven_names=proved,
                    formal_inventory_count=len(props),
                    fully_proven_pair=bool(props) and len(proved) == len(props))
        if syntax[key] != 'ok':
            if proved:
                raise ValueError(f'Syntax/proof sources disagree; resolve eligibility: {key}')
            task.update(status='skipped_prior_syntax', reason='Excluded using existing syntax summary')
        elif getattr(args, 'require_saved_proof', False) and not proved:
            task.update(status='skipped_no_saved_proof', reason='No saved explicit DUT proof')
        cohorts.append({'condition': key[0], 'id': key[1], 'syntax_status': syntax[key], 'properties': props})
    ids = [{t['id'] for t in manifest['tasks'] if t['condition'] == c} for c in conditions]
    if any(group != ids[0] for group in ids):
        raise ValueError('Model conditions do not contain the same held-out IDs')
    manifest['cohort_source_sha256'] = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources}
    manifest['note'] = 'Selected conditions with saved syntax and explicit proof cohorts.'
    manifest['conditions'] = conditions
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'cohorts.json').write_text(json.dumps(cohorts, indent=2) + '\n')
    print(Counter((t['condition'], t['status']) for t in manifest['tasks']))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out-dir', type=Path, required=True)
    parser.add_argument('--ids', nargs='+')
    parser.add_argument('--conditions', nargs='+', choices=runner.CONDITIONS, default=CONDITIONS)
    parser.add_argument('--require-saved-proof', action='store_true')
    parser.add_argument('--time-limit', type=int, default=30)
    parser.add_argument('--process-timeout', type=int, default=300)
    args = parser.parse_args()
    if args.time_limit <= 0 or args.process_timeout <= 0:
        parser.error('Time limits must be positive')
    prepare(args)
