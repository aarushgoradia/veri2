#!/usr/bin/env python3
"""Collect one verdict per assertion from saved JasperGold verification logs.

Reads <root>/inference_outputs/verification_results/<model>/ids/<id>/ as written by
scripts/check_all.sh and writes a CSV with one row per assertion:
condition, id, property, evidence_status. An assertion is `proven` only when the log
has an explicit proof event for it; a counterexample gives `cex`; anything else is
`no_explicit_verdict`. Absence of a counterexample is never counted as a proof.
"""
import argparse
from collections import defaultdict
import csv
from pathlib import Path
import re


PROOF_EVENT = re.compile(r'^\s*INFO \(IPF057\):.*The property "([^"]+)" was proven\b')
CEX_EVENT = re.compile(r'^\s*INFO \(IPF055\):.*counterexample.*property "([^"]+)"')
SUMMARY_HEADER = re.compile(r'=*\s*SUMMARY\s*=*')
SUMMARY_COUNT = re.compile(r'^\s*-\s*([a-z_]+(?:\s+\([^)]*\))?)\s*:\s*(\d+)')
LABEL = re.compile(r'\b(\w+)\s*:\s*assert\s*(?:property\s*)?\(')


def strip_comments(code):
    return re.sub(r'/\*.*?\*/|//[^\n]*', '', code, flags=re.S)


def normalize_name(name):
    return re.sub(r'^<[^>]+>::', '', name.strip())


def inventory(text):
    assertions = []
    section = None
    for line in text.splitlines():
        line = line.strip()
        if line == 'ASSERT PROPERTIES:':
            section = 'assert'
        elif line.endswith('PROPERTIES:'):
            section = None
        elif section == 'assert' and line and not line.startswith(':'):
            assertions.append(normalize_name(line))
    return assertions


def parse_log(text):
    """Keep distinct explicit events and the last printed assertion summary."""
    events = defaultdict(set)
    summaries = []
    current = None
    in_summary = False
    in_assertions = False
    for line in text.splitlines():
        match = PROOF_EVENT.search(line)
        if match:
            events[normalize_name(match.group(1))].add('proven')
        match = CEX_EVENT.search(line)
        if match:
            events[normalize_name(match.group(1))].add('cex')
        if SUMMARY_HEADER.fullmatch(line.strip()):
            if current is not None:
                summaries.append(current)
            current = None
            in_summary = True
            in_assertions = False
        elif in_summary:
            match = re.match(r'^\s*assertions\s*:\s*(\d+)', line)
            if match:
                current = {'assertions': int(match.group(1))}
                in_assertions = True
            elif re.match(r'^\s*(?:covers|assumptions)\s*:', line):
                in_assertions = False
            elif line.lstrip().startswith('[') and '%' in line:
                in_summary = False
                in_assertions = False
            elif in_assertions:
                match = SUMMARY_COUNT.match(line)
                if match:
                    current[match.group(1)] = int(match.group(2))
    if current is not None:
        summaries.append(current)
    return dict(events), summaries[-1] if summaries else None


def classify(verdicts):
    if len(verdicts) > 1:
        return 'conflicting_evidence'
    return next(iter(verdicts)) if verdicts else 'no_explicit_verdict'


def design_verdicts(directory, condition):
    def read(name):
        path = directory / name
        return path.read_text(errors='replace') if path.is_file() else ''

    events, _ = parse_log(read('run.log'))
    for line in read('cex_details.txt').splitlines():
        parts = [part.strip() for part in line.split('|')]
        if len(parts) >= 2 and parts[1] in {'cex', 'ar_cex'}:
            events.setdefault(normalize_name(parts[0]), set()).add('cex')
    return [{'condition': condition, 'id': directory.name, 'property': name,
             'evidence_status': classify(events.get(name, set()))}
            for name in sorted(set(inventory(read('property_list.txt'))))]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--out', type=Path, required=True, help='CSV file to write')
    args = parser.parse_args()
    rows = []
    results = args.root.resolve() / 'inference_outputs/verification_results'
    for model in sorted(p for p in results.iterdir() if (p / 'ids').is_dir()):
        for directory in sorted((model / 'ids').iterdir()):
            if directory.is_dir():
                rows.extend(design_verdicts(directory, model.name))
    with args.out.open('w', newline='') as output:
        writer = csv.DictWriter(output, fieldnames=['condition', 'id', 'property', 'evidence_status'])
        writer.writeheader()
        writer.writerows(rows)
    print(f'{len(rows)} assertions written to {args.out}')


if __name__ == '__main__':
    main()
