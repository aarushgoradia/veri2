#!/usr/bin/env python3
"""Size and composition of the three Veri2 variants (All, Syntax, Verified).

Reads veri2/<variant>/{train,validation,test}.jsonl and
prints the numbers used in the dataset statistics table of the paper. Read-only.
"""
import json
import re
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'veri2'
ASSERT = re.compile(r'\bassert\s+property\b')
SEQUENTIAL = re.compile(r'always\s*@\s*\(\s*(posedge|negedge)|always_ff')
# Constructs that make an assertion span more than one clock cycle.
MULTI_CYCLE = re.compile(r'\|=>|##\s*[\[\d]|\$past|\$rose|\$fell|\$stable|\$changed'
                         r'|\bs_eventually\b|\buntil\b|\bthroughout\b|\[\*|\[->|\[=')


def strip_comments(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    return re.sub(r'//[^\n]*', '', text)


def lines_of_code(text):
    return sum(1 for line in strip_comments(text).splitlines() if line.strip())


def assertions(sva):
    """Text of each `assert property (...);` statement in a checker file."""
    text = strip_comments(sva)
    starts = [m.start() for m in ASSERT.finditer(text)]
    out = []
    for i, start in enumerate(starts):
        chunk = text[start:starts[i + 1] if i + 1 < len(starts) else len(text)]
        end = chunk.find(');')
        out.append(chunk[:end + 2] if end >= 0 else chunk)
    return out


def main():
    for variant in ['all', 'syntax_pass', 'verified']:
        rows = [json.loads(line) for split in ['train', 'validation', 'test']
                for line in (ROOT / variant / f'{split}.jsonl').open() if line.strip()]
        rtl_loc = [lines_of_code(r['rtl']) for r in rows]
        sva_loc = [lines_of_code(r['sva']) for r in rows]
        per_pair = [assertions(r['sva']) for r in rows]
        flat = [a for pair in per_pair for a in pair]
        sequential = sum(bool(SEQUENTIAL.search(strip_comments(r['rtl']))) for r in rows)
        print(f'{variant}:')
        print(f'  pairs                      {len(rows)}')
        print(f'  assertions                 {len(flat)}')
        print(f'  assertions per pair (mean) {statistics.mean(map(len, per_pair)):.1f}')
        print(f'  RTL LoC mean / median / max {statistics.mean(rtl_loc):.1f} / '
              f'{statistics.median(rtl_loc):g} / {max(rtl_loc)}')
        print(f'  SVA LoC mean               {statistics.mean(sva_loc):.1f}')
        print(f'  sequential modules         {100 * sequential / len(rows):.1f}%')
        print(f'  assertions with implication {100 * sum("|->" in a or "|=>" in a for a in flat) / len(flat):.1f}%')
        print(f'  multi-cycle assertions     {100 * sum(bool(MULTI_CYCLE.search(a)) for a in flat) / len(flat):.1f}%')


if __name__ == '__main__':
    main()
