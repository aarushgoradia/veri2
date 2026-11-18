#!/usr/bin/env python3
"""Reconcile selected-model checks with saved syntax and explicit proof cohorts."""
import argparse
from collections import Counter, defaultdict
import csv
from datetime import datetime
import json
from pathlib import Path
import re


def short_name(name):
    return name.rsplit('.', 1)[-1]


def classify_proven(name, properties, result):
    """Partition every original explicit proof, retaining missing evidence."""
    label = short_name(name)
    if sum(short_name(p['name']) == label for p in properties) != 1:
        return 'ambiguous_label'
    if result is None:
        return 'pending'
    status = result['status']
    if status in {'unsupported', 'skipped_prior_syntax'}:
        return status
    tautology = result.get('tautology', {})
    if tautology.get('status') != 'completed':
        return 'tautology_' + tautology.get('status', 'not_run')
    events = [e for e in tautology.get('events', []) if e['phase'] == 'tautology'
              and e.get('source_type', 'assert') == 'assert' and short_name(e['name']) == label]
    if len(events) != 1:
        return 'unmatched_tautology'
    if events[0]['validity_status'] == 'proven':
        return 'tautological'
    if events[0]['validity_status'] != 'cex':
        return 'unresolved_tautology'
    redundancy = result.get('redundancy', {})
    if redundancy.get('status') != 'completed':
        return 'redundancy_' + redundancy.get('status', 'not_run')
    events = [e for e in redundancy.get('events', []) if e['phase'] == 'redundancy_step'
              and e.get('source_type', 'assert') == 'assert' and short_name(e['name']) == label]
    if len(events) != 1:
        return 'unmatched_redundancy'
    verdict = events[0]['validity_status']
    if verdict == 'proven':
        return 'redundant'
    if verdict == 'cex':
        return 'retained'
    return 'unresolved_redundancy'


def error_cause(case, result):
    codes = set()
    for name in ['tautology', 'redundancy']:
        stage = result.get(name, {})
        if stage.get('status') != 'error':
            continue
        path = Path(stage.get('stage_dir', case / name)) / 'console.log'
        if path.exists():
            codes.update(re.findall(r'ERROR \(([^)]+)\)', path.read_text(errors='replace')))
    if {'ENL098', 'ENL171'} & codes:
        cause = 'global_clock_elaboration'
    elif 'ECK112' in codes:
        cause = 'clock_edge_model'
    elif {'ERS028', 'ESW018'} & codes:
        cause = 'formal_reset_setup'
    elif 'VERI-1128' in codes:
        cause = 'undeclared_identifier'
    elif {'VERI-1158', 'VERI-1172'} & codes:
        cause = 'missing_macro_or_external_reference'
    elif {'VERI-2072', 'EOBS006'} & codes:
        cause = 'unsupported_language_feature'
    elif any(c.startswith(('VERI-', 'ENL', 'VDB-')) for c in codes):
        cause = 'other_frontend_error'
    elif 'EPM016' in codes:
        cause = 'property_mapping'
    else:
        cause = 'other_execution_error'
    return cause, ';'.join(sorted(codes))


def write_csv(path, rows, fields):
    with path.open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def summarize(package, supplement=None):
    package = Path(package).resolve()
    manifest = json.loads((package / 'manifest.json').read_text())
    cohorts = {(c['condition'], c['id']): c for c in json.loads((package / 'cohorts.json').read_text())}
    models = defaultdict(lambda: {'cases': Counter(), 'proven_assertions': Counter(),
                                  'fully_proven_pairs': Counter(), 'errors': Counter()})
    assertions, cases = [], []
    supplemental = {}
    if supplement:
        supplement = Path(supplement).resolve()
        for t in json.loads((supplement / 'manifest.json').read_text())['tasks']:
            supplemental[t['condition'], t['id']] = t
    for task in manifest['tasks']:
        key = task['condition'], task['id']
        cohort = cohorts[key]
        props = cohort['properties']
        model = models[key[0]]
        counts = model['cases']
        case = package / task['case']
        path = case / 'result.json'
        result = json.loads(path.read_text()) if path.exists() else None
        if key in supplemental:
            extra = supplemental[key]
            if extra['source_sha256'] != task['source_sha256']:
                raise ValueError(f'Supplement changed original checker source: {key}')
            extra_case = supplement / extra['case']
            extra_result = extra_case / 'result.json'
            if extra_result.exists():
                result = json.loads(extra_result.read_text())
                case = extra_case
        if result is None and task['status'] in {'unsupported', 'skipped_prior_syntax', 'skipped_no_saved_proof'}:
            result = {'status': task['status']}
        counts['held_out_ids'] += 1
        counts['syntax_pass' if cohort['syntax_status'] == 'ok' else 'prior_syntax_fail'] += 1
        state = result['status'] if result else 'pending'
        # Syntax failures are excluded by the manifest, even before their shard
        # writes the explicit skipped result.
        if task['status'] == 'skipped_prior_syntax':
            state = 'skipped_prior_syntax'
        if cohort['syntax_status'] == 'ok':
            counts[state] += 1
        proven = [p for p in props if p['status'] == 'proven']
        if proven:
            counts['has_at_least_one_proof'] += 1
        counts['reused_completed'] += bool(result and result.get('reused_from'))
        cause, codes = error_cause(case, result) if result and state == 'error' else ('', '')
        if cause:
            model['errors'][cause] += 1
        outcomes = Counter()
        for p in proven:
            outcome = classify_proven(p['name'], props, result)
            outcomes[outcome] += 1
            model['proven_assertions'][outcome] += 1
            assertions.append({'condition': key[0], 'id': key[1], 'property': p['name'],
                               'original_verdict': 'proven', 'syntax_status': cohort['syntax_status'],
                               'quality_outcome': outcome})
        fully_proven = bool(props) and len(proven) == len(props)
        if fully_proven:
            if outcomes['retained'] == len(props):
                pair_outcome = 'all_assertions_survive'
            elif outcomes['tautological'] or outcomes['redundant']:
                pair_outcome = 'contains_tautology_or_redundancy'
            else:
                pair_outcome = 'pending_or_blocked'
            model['fully_proven_pairs'][pair_outcome] += 1
        cases.append({'condition': key[0], 'id': key[1], 'syntax_status': cohort['syntax_status'],
                      'original_inventoried_assertions': len(props), 'original_proven_assertions': len(proven),
                      'all_original_assertions_proven': int(fully_proven), 'new_check_status': state,
                      'error_cause': cause, 'error_codes': codes,
                      'retained_proven_assertions': outcomes['retained'],
                      'tautological_proven_assertions': outcomes['tautological'],
                      'redundant_proven_assertions': outcomes['redundant'],
                      'other_proven_assertions': len(proven) - outcomes['retained'] - outcomes['tautological'] - outcomes['redundant']})
    for c, data in models.items():
        expected = sum(p['status'] == 'proven' for key, row in cohorts.items() if key[0] == c for p in row['properties'])
        assert sum(data['proven_assertions'].values()) == expected
        data['original_proven_assertion_total'] = expected
        data['original_fully_proven_pair_total'] = sum(data['fully_proven_pairs'].values())
    summary = {'snapshot_time': datetime.now().astimezone().isoformat(), 'models': models,
               'definitions': {'retained': 'Original DUT proof + checker-only tautology CEX + greedy redundancy CEX',
                 'fully_proven_pair': 'Nonempty original assertion inventory with every named assertion explicitly proven',
                 'other_outcomes': 'Pending, blocked, unresolved, and unmatched remain in the original proof denominator'},
               'scope': f'{", ".join(models)}; saved syntax failures excluded'}
    (package / 'cohort_summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    write_csv(package / 'proven_assertion_quality.csv', assertions,
              ['condition', 'id', 'property', 'original_verdict', 'syntax_status', 'quality_outcome'])
    write_csv(package / 'case_quality.csv', cases, list(cases[0]))
    return summary


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--supplement', type=Path)
    args = parser.parse_args()
    print(json.dumps(summarize(args.package, args.supplement), indent=2))
