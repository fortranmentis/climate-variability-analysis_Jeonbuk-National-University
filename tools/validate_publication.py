"""Check documentation, images, and staged archive integrity before publication.

Requires Pillow for PNG decoding: python -m pip install Pillow
Run after git add: python tools/validate_publication.py
"""
from pathlib import Path
import csv
import hashlib
import json
import re
import subprocess
from urllib.parse import unquote, urlsplit
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def main():
    errors = []
    markdowns = sorted([*ROOT.glob('*.md'), *(ROOT / 'docs').rglob('*.md')])
    links = 0
    for path in markdowns:
        text = path.read_text(encoding='utf-8')
        if len(re.findall(r'^```', text, re.M)) % 2:
            errors.append(f'Unbalanced fences: {path.name}')
        targets = re.findall(r'(?<!!)\[[^\]]+\]\(([^\s]+)\)', text)
        targets += re.findall(r'!\[[^\]]*\]\(([^\s]+)\)', text)
        targets += re.findall(r'(?:src|href)="([^"]+)"', text)
        for target in targets:
            if target.startswith(('https:', 'http:', 'mailto:')):
                continue
            url = urlsplit(target)
            destination = path.parent / unquote(url.path) if url.path else path
            links += 1
            if not destination.exists():
                errors.append(f'Missing link in {path.name}: {target}')
            elif url.fragment and destination.suffix == '.md':
                headings = re.findall(r'^#+\s+(.+)', destination.read_text(encoding='utf-8'), re.M)
                slugs = {re.sub(r'[^\w\- ]', '', h.lower()).replace(' ', '-') for h in headings}
                if unquote(url.fragment) not in slugs:
                    errors.append(f'Missing anchor in {path.name}: {target}')
    ET.parse(ROOT / 'docs/assets/banner.svg')
    images = 0
    for path in ROOT.rglob('*.png'):
        if '.git' in path.parts or '.local' in path.parts:
            continue
        try:
            with Image.open(path) as img:
                img.verify()
            with Image.open(path) as img:
                img.load()
            images += 1
        except Exception as error:
            errors.append(f'PNG decode error: {path.relative_to(ROOT)}: {error}')

    staged = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT)
    objects = {}
    for entry in staged.split(b'\0'):
        if entry:
            header, name = entry.split(b'\t', 1)
            objects[name.decode('utf-8')] = header.split()[1].decode('ascii')
    rows = list(csv.DictReader((ROOT / 'docs/archive_inventory.csv').open(encoding='utf-8')))
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    preserved = lfs = 0
    try:
        for row in rows:
            if row['publication'] != 'included':
                if row['path'] in objects:
                    errors.append(f'Transient unexpectedly staged: {row["path"]}')
                continue
            sha = objects.get(row['path'])
            if not sha:
                errors.append(f'Archive file absent from index: {row["path"]}')
                continue
            process.stdin.write((sha + '\n').encode('ascii'))
            process.stdin.flush()
            header = process.stdout.readline().split()
            size = int(header[2])
            data = process.stdout.read(size)
            process.stdout.read(1)
            if row['storage'] == 'git-lfs':
                pointer = data.decode('ascii')
                if f'oid sha256:{row["sha256"]}\n' not in pointer or f'size {row["bytes"]}\n' not in pointer:
                    errors.append(f'LFS pointer mismatch: {row["path"]}')
                lfs += 1
            elif hashlib.sha256(data).hexdigest() != row['sha256']:
                errors.append(f'Original bytes changed in index: {row["path"]}')
            preserved += 1
    finally:
        process.stdin.close()
        process.wait()
    result = {'local_documentation_links_checked': links, 'png_files_decoded': images,
              'svg_parsed': True, 'archive_index_entries_checked': preserved,
              'lfs_pointers_checked': lfs, 'errors': errors,
              'scope': 'Documentation structure, media decoding, and staged content integrity; no scientific validation.'}
    print(json.dumps(result, indent=2, ensure_ascii=False))
    raise SystemExit(bool(errors))


if __name__ == '__main__':
    main()
