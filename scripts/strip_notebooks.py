#!/usr/bin/env python3
import json
from pathlib import Path

NOTEBOOKS = [
    'fine_tuning/sva_inference.ipynb',
    'fine_tuning/sva_qlora_finetune.ipynb',
]

for nb_path in NOTEBOOKS:
    p = Path(nb_path)
    if not p.exists():
        print(f"Skipping missing: {nb_path}")
        continue

    data = json.loads(p.read_text(encoding='utf-8'))

    # Minimal top-level metadata
    data['metadata'] = {}

    cells = data.get('cells', [])
    for cell in cells:
        # preserve language if present in existing metadata
        lang = None
        if isinstance(cell.get('metadata'), dict):
            lang = cell['metadata'].get('language')
        # reset metadata but keep language
        cell['metadata'] = {}
        if lang:
            cell['metadata']['language'] = lang

        # clear outputs and execution count for code cells
        if cell.get('cell_type') == 'code':
            cell['outputs'] = []
            cell['execution_count'] = None

        # remove attachments if any
        if 'attachments' in cell:
            cell.pop('attachments', None)

    data['cells'] = cells

    # write back with indentation
    p.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"Stripped: {nb_path}")
