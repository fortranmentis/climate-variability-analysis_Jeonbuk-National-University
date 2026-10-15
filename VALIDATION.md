# Validation and publication evidence

[English README](README.md) · [한국어 README](README.ko.md)

Audit date: **2026-10-15 (Asia/Seoul)**. This report separates archive inspection from numerical execution and scientific validation.

## Archive inspection

| Check | Evidence and result |
|---|---|
| Original inventory | 2,160 files, 5,719,476,216 bytes; SHA-256 recorded for each |
| Publication scope | 2,126 research files, 5,718,398,120 bytes; 32 `.out` and 2 `.swp` files excluded |
| GrADS descriptor references | 613/613 `DSET` references resolve to an existing file relative to the descriptor |
| NetCDF headers | 15 classic CDF-1 files parsed; 13 files have HDF signature and need a suitable NetCDF4/HDF5 reader |
| Storage | 901 NetCDF/binary LFS paths; 589 distinct payloads totaling 3,841,563,066 bytes |
| Portability | Historical `/home/...` paths remain in several scripts; source locations are recorded in the audit JSON |

Reference existence does not validate file length, variable semantics, time alignment, or numerical contents. SHA-256 provides integrity evidence, not proof of provenance or scientific accuracy. An unlimited NetCDF dimension is recorded with size zero in the header; the `records` field supplies the current record count.

Machine-readable evidence:

- [archive_inventory.csv](docs/archive_inventory.csv): original path, size, SHA-256, inclusion decision, and storage mode.
- [archive_audit.json](docs/archive_audit.json): counts, reference status, and absolute-path locations.
- [ctl_references.csv](docs/ctl_references.csv): every descriptor and its `DSET` target.
- [netcdf_metadata.json](docs/netcdf_metadata.json): dimensions, variable attributes, and provenance from supported headers.

## Compiler inspection

Environment: **GNU Fortran (tdm64-1) 10.3.0 on Windows**.

Each of the 49 `.f90` files was checked using `gfortran -fsyntax-only` without executing its analysis. **48 passed** with default line-length handling. `spectral analysis/Code4SpectralAnalysis/correlogram.f90` contains an overlength free-form source line; its syntax check passes with `-ffree-line-length-none`. The source was preserved rather than reformatted.

[fortran_syntax.json](docs/fortran_syntax.json) contains per-file exit codes and compiler diagnostics. Compiler success does not establish correctness, input compatibility, or safe execution of all experiments.

## Limited numerical execution

The `regression/reg_btw2ts.f90` example was copied with its two inputs to an ignored temporary working directory. The checked executable did not overwrite the archived inputs or output files.

```text
Compiler flags: -O0 -fcheck=all -static
Inputs:
  Nino_index_NDJ_1982-2018.gdat
  precip_Jeonju_DEC_1982-2018.gdat
Compile exit code: 0
Run exit code: 0
Reported regression coefficient: 6.73314047
Reported probability: 5.26655605E-03
```

A dynamic-runtime build did not run successfully in this environment; the static build above did. The recorded result verifies that one existing program can read its archived inputs and complete under runtime checks. It does not independently validate the regression implementation, probability formula, missing-value handling, or inferential assumptions. The output quantity is the program's configured regression result, not a correlation coefficient.

Exact output is retained in [regression_smoke.json](docs/regression_smoke.json).

## Repeating the checks

```bash
# Python 3; standard library only. Reads all original files, including large data.
python tools/audit_archive.py

# Representative compiler checks, from the repository root.
gfortran -fsyntax-only regression/reg_btw2ts.f90
gfortran -ffree-line-length-none -fsyntax-only "spectral analysis/Code4SpectralAnalysis/correlogram.f90"

# Check the LFS objects in a complete checkout.
git lfs fsck
```

Publication checks also passed for 90 local documentation links, 261 decoded PNG files, the SVG banner, 2,126 staged archive entries, and all 901 LFS pointer hashes/sizes. Original bytes matched the committed inventory. No high-confidence GitHub-token, AWS-access-key, or private-key patterns were found in the scanned source and text files; this targeted scan is not a comprehensive security audit. `git diff --cached --check` passed for the added documentation, tooling, and Git configuration files.

The recorded results are in [publication_checks.json](docs/publication_checks.json). To repeat the link, media, and staged-content checks, install Pillow and run `python tools/validate_publication.py` after staging files.

The original inventory includes excluded transient files that will not exist in a fresh clone. Regenerating the audit from a clone therefore describes the published subset and will produce smaller original-file counts. Keep the committed inventory when comparing against the initial local archive.

## Boundaries

The following remain unverified:

- End-to-end operation across all directories and all source/input combinations.
- GrADS execution, figure regeneration, plotting helper availability, and MATLAB/Octave execution.
- Internal data arrays and metadata of HDF-backed NetCDF files.
- Complete scientific provenance of station indices and every supplied climate product.
- Grid/record-size compatibility for every `.ctl`/binary pair, lag/season definitions, and agreement between titles and filenames.
- Independent replication of coefficients, probability fields, EOF modes, and scientific conclusions.

## 한국어 요약

원본 2,160개 파일의 해시와 용량을 기록했으며, 실행파일 32개·편집기 임시파일 2개를 제외한 연구 자료 2,126개를 공개 대상으로 정리했습니다. CTL 613개의 대상 파일은 모두 존재합니다. classic NetCDF 15개는 헤더를 읽었고 HDF 서명의 13개는 내부 메타데이터를 추가로 검증해야 합니다.

Fortran 49개 중 48개는 기본 문법 검사를 통과했으며, 나머지 1개는 긴 소스 줄을 허용하는 옵션으로 통과했습니다. 회귀 예제 1개는 정적 링크 및 런타임 점검 옵션으로 컴파일·실행에 성공했습니다. 전체 분석 재현, 통계적 타당성, GrADS 그림 재생성, MATLAB 실행까지 검증한 것은 아닙니다.
