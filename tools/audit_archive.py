"""Inventory and inspect the preserved research archive using Python's standard library.

Run from the repository root: python tools/audit_archive.py
The output describes archive integrity, not scientific correctness.
"""
from pathlib import Path
from collections import Counter
import csv
import hashlib
import json
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
ARCHIVE_DIRS = {'2001air', '2001geo', '2001gsgeoair', '2001gsSSTwind',
 '2001jjgeoair', '2001jjSSTwind', '2001sst', '2001wind', 'auto_correlation',
 'composite', 'correlation', 'Data', 'EOF', 'FInal', 'gisang', 'gragh',
 'homework', 'homework_3', 'homework2', 'icec', 'icec_day', 'icec_depth',
 'icec_snowday', 'icec_snowdepth', 'jet', 'JFM', 'make_sst_jan', 'mean',
 'nonmun', 'nonmun2', 'nonmunDJF', 'nonmunJFM', 'nonmunNDJ', 'nonmunwnd',
 'partial_regression', 'regression', 'snow', 'snow2', 'snow3', 'snowday_comp',
 'snowday_reg', 'snowday_reg_sea_ice', 'snowdepth_comp', 'snowdepth_reg',
 'snowdepth_reg_sea_ice', 'spectral analysis', 'test', 'test111', 'test2'}
EXCLUDED = {'.out', '.swp', '.swo', '.exe', '.o', '.mod'}


class NCHeader:
    """Read CDF-1/CDF-2 metadata only; never load climate arrays."""
    def __init__(self, handle):
        self.f = handle

    def u32(self):
        return struct.unpack('>I', self.f.read(4))[0]

    def string(self):
        n = self.u32()
        value = self.f.read(n)
        self.f.read((-n) % 4)
        return value.decode('utf-8', errors='replace')

    def items(self, expected):
        tag, count = self.u32(), self.u32()
        if tag == 0 and count == 0:
            return 0
        if tag != expected:
            raise ValueError(f'Unexpected header tag {tag}; expected {expected}')
        return count

    def attrs(self):
        attrs = {}
        for _ in range(self.items(12)):
            name = self.string()
            kind, n = self.u32(), self.u32()
            fmt, width = {1: ('b', 1), 2: ('c', 1), 3: ('h', 2),
                          4: ('i', 4), 5: ('f', 4), 6: ('d', 8)}[kind]
            value = self.f.read(n * width)
            self.f.read((-n * width) % 4)
            if kind == 2:
                attrs[name] = value.decode('utf-8', errors='replace').rstrip('\x00')
            else:
                numbers = list(struct.unpack('>' + str(n) + fmt, value))
                attrs[name] = numbers[0] if n == 1 else numbers
        return attrs

    def read(self):
        signature = self.f.read(4)
        if signature not in (b'CDF\x01', b'CDF\x02'):
            return {'format': signature.hex(), 'status': 'unsupported_header'}
        records = self.u32()
        dimensions = []
        for _ in range(self.items(10)):
            dimensions.append({'name': self.string(), 'size': self.u32()})
        attrs = self.attrs()
        variables = []
        for _ in range(self.items(11)):
            name = self.string()
            dims = [self.u32() for _ in range(self.u32())]
            va = self.attrs()
            kind, size = self.u32(), self.u32()
            offset = struct.unpack('>Q', self.f.read(8))[0] if signature[-1] == 2 else self.u32()
            variables.append({'name': name, 'dimensions': [dimensions[d]['name'] for d in dims],
                              'type': kind, 'stored_bytes': size, 'offset': offset,
                              'attributes': va})
        return {'format': f'CDF-{signature[-1]}', 'status': 'header_read',
                'records': records, 'dimensions': dimensions,
                'global_attributes': attrs, 'variables': variables}


def main():
    DOCS.mkdir(exist_ok=True)
    files = sorted(f for f in ROOT.rglob('*') if f.is_file() and
                   (f.relative_to(ROOT).parts[0] in ARCHIVE_DIRS or
                    (f.parent == ROOT and f.suffix.lower() == '.png')))
    published = [f for f in files if f.suffix.lower() not in EXCLUDED]
    inventory = []
    for f in files:
        digest = hashlib.sha256()
        with f.open('rb') as handle:
            for block in iter(lambda: handle.read(4 * 1024 * 1024), b''):
                digest.update(block)
        inventory.append({'path': f.relative_to(ROOT).as_posix(), 'bytes': f.stat().st_size,
                          'sha256': digest.hexdigest(),
                          'publication': 'excluded_transient' if f.suffix.lower() in EXCLUDED else 'included',
                          'storage': 'git-lfs' if f.suffix.lower() in {'.nc', '.gdat', '.fwrite'} else 'git'})
    with (DOCS / 'archive_inventory.csv').open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=inventory[0].keys())
        writer.writeheader()
        writer.writerows(inventory)

    ctl = []
    for f in published:
        if f.suffix.lower() != '.ctl':
            continue
        content = f.read_text(errors='replace')
        match = re.search(r'^\s*dset\s+(.+)', content, re.I | re.M)
        target = match.group(1).strip().strip('"\'') if match else ''
        if not target:
            status = 'no_dset'
        elif '%' in target:
            status = 'template_requires_runtime'
        elif target.startswith('/') or re.match(r'^[A-Za-z]:', target):
            status = 'absolute_path_requires_review'
        else:
            # GrADS ^ paths are descriptor-relative. Bare paths depend on cwd.
            resolved = f.parent / target.lstrip('^')
            status = ('present' if resolved.is_file() else 'missing') if target.startswith('^') else (
                'cwd_relative_present_beside_ctl' if resolved.is_file() else 'cwd_relative_not_beside_ctl')
        ctl.append({'path': f.relative_to(ROOT).as_posix(), 'dset': target, 'status': status})
    with (DOCS / 'ctl_references.csv').open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=['path', 'dset', 'status'])
        writer.writeheader()
        writer.writerows(ctl)

    nc = {}
    for f in published:
        if f.suffix.lower() == '.nc':
            try:
                with f.open('rb') as handle:
                    nc[f.relative_to(ROOT).as_posix()] = NCHeader(handle).read()
            except (ValueError, KeyError, struct.error, UnicodeError) as error:
                nc[f.relative_to(ROOT).as_posix()] = {'status': 'error', 'error': str(error)}
    (DOCS / 'netcdf_metadata.json').write_text(json.dumps(nc, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    paths = []
    for f in published:
        if f.suffix.lower() in {'.f90', '.gs', '.gsf', '.m', '.ctl'}:
            for number, line in enumerate(f.read_text(errors='replace').splitlines(), 1):
                if '/home/' in line:
                    paths.append({'path': f.relative_to(ROOT).as_posix(), 'line': number})
    summary = {'original_files': len(files), 'original_bytes': sum(f.stat().st_size for f in files),
               'published_archive_files': len(published),
               'published_archive_bytes': sum(f.stat().st_size for f in published),
               'excluded_transient_files': len(files) - len(published),
               'extensions': dict(sorted(Counter(f.suffix.lower() for f in published).items())),
               'ctl_reference_status': dict(Counter(row['status'] for row in ctl)),
               'netcdf_status': dict(Counter(row['status'] for row in nc.values())),
               'absolute_home_path_lines': paths,
               'scope': 'File hashes, descriptor paths, and NetCDF headers only; no scientific validation.'}
    (DOCS / 'archive_audit.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in summary.items() if k != 'absolute_home_path_lines'}, indent=2))


if __name__ == '__main__':
    main()
