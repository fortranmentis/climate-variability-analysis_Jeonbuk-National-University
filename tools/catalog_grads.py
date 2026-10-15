"""Extract a static, line-numbered catalogue of archived GrADS scripts.

This is a source scanner, not a GrADS parser or execution/dependency validator.
Run from any directory: python tools/catalog_grads.py
"""
from collections import Counter
from pathlib import Path
import csv
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
HELPERS = {'basemap', 'cbarm', 'cbarm0', 'clevsjy', 'clevsjy2', 'clevsjy3',
           'dots', 'font', 'ltrend', 'qdims', 'rgbset', 'rgbset_mod', 'subplot', 'xcbar'}


def main():
    rows, references = [], []
    for path in sorted(ROOT.rglob('*')):
        if not path.is_file() or path.suffix.lower() not in {'.gs', '.gsf'}:
            continue
        if any(part in {'.git', '.local'} for part in path.relative_to(ROOT).parts):
            continue
        active = [(n, line.strip()) for n, line in enumerate(path.read_text(errors='replace').splitlines(), 1)
                  if line.strip() and not line.lstrip().startswith('*')]
        inputs, outputs, calls = [], [], []
        flags = set()
        for number, line in active:
            match = re.match(r"^'([^']*)'", line)
            if not match:
                continue
            command = match.group(1).strip()
            token = command.split()[0].lower() if command else ''
            if token in {'open', 'sdfopen', 'xdfopen'}:
                target = command[len(token):].strip()
                dynamic = bool(line[match.end():].strip())
                if dynamic:
                    status = 'dynamic_expression_requires_review'
                elif target.startswith('/') or re.match(r'^[A-Za-z]:', target):
                    status = 'absolute_path_requires_review'
                elif '%' in target or '://' in target:
                    status = 'template_or_remote_requires_review'
                else:
                    status = 'present_beside_script' if (path.parent / target).is_file() else 'missing_beside_script'
                inputs.append(f'{number}: {command}')
                references.append({'script': path.relative_to(ROOT).as_posix(), 'line': number,
                                   'command': token, 'target_expression': target,
                                   'status': status})
            if re.match(r'^set\s+fwrite\b', command, re.I):
                flags.add('binary_export')
                outputs.append(f'{number}: {command}')
            if token in {'printim', 'gxprint'}:
                flags.add('image_export')
                outputs.append(f'{number}: {command}')
            if token == 'run':
                parts = command.split()
                helper = parts[1].removesuffix('.gs') if len(parts) > 1 else ''
            else:
                helper = token
            if helper in HELPERS:
                calls.append(f'{number}: {command}')
            if 'maskout(' in command:
                flags.add('maskout')
            if 'modify ' in command and ' seasonal' in command:
                flags.add('seasonal_climatology')
            if 'aave(' in command:
                flags.add('area_average')
        if path.stem in HELPERS:
            role = 'helper'
        elif 'binary_export' in flags:
            role = 'data_export_or_mixed_workflow'
        else:
            role = 'analysis_or_display'
        rows.append({'path': path.relative_to(ROOT).as_posix(), 'extension': path.suffix,
                     'role_hint': role, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                     'features': ' | '.join(sorted(flags)), 'input_commands': ' | '.join(inputs),
                     'output_commands': ' | '.join(outputs), 'helper_calls': ' | '.join(calls)})
    for filename, data in [('grads_scripts.csv', rows), ('grads_input_references.csv', references)]:
        with (ROOT / 'docs' / filename).open('w', encoding='utf-8', newline='') as handle:
            writer = csv.DictWriter(handle, fieldnames=list(data[0]))
            writer.writeheader()
            writer.writerows(data)
    summary = {'scripts': len(rows), 'extensions': dict(Counter(r['extension'] for r in rows)),
               'role_hints': dict(Counter(r['role_hint'] for r in rows)),
               'input_command_occurrences': len(references),
               'input_reference_status': dict(Counter(r['status'] for r in references)),
               'scope': 'Static scan of leading single-quoted commands only. Paths are checked against each script directory, assuming that working directory. Dynamic script logic, unquoted expressions, GASCRP, and runtime behavior are not validated.'}
    (ROOT / 'docs' / 'grads_audit.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
