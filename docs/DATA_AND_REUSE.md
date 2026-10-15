# Data, provenance, and reuse

[English overview](../README.md) · [한국어 개요](../README.ko.md)

## Preserved material

Research files retain their original bytes and directory organization. `.gitattributes` disables automatic text normalization for historical sources and data. New documentation and audit scripts use LF line endings. Compiled `.out` files and editor `.swp` files are excluded from Git; their original hashes remain in the inventory. The empty local `nonmunwnd/` directory contains no material for Git to track.

NetCDF, `.gdat`, and `.fwrite` content is stored through Git LFS. Identical content can share an LFS object even when several experiments retain their own copy. Files outside LFS are smaller than 4 MB in the original snapshot. The inventory records the SHA-256 of the actual file content, not its LFS pointer.

## Provenance supported by local evidence

- Inspected SST headers identify **NOAA Optimum Interpolation (OI) SST V2**, the NCEP Climate Modeling Branch, and the National Centers for Environmental Prediction. Their stored reference points to the NOAA PSL OI SST V2 dataset.
- Inspected sea-ice files also carry NOAA OI SST V2 metadata. Their history describes special land/missing-value handling. Check the `icec` variable attributes rather than interpreting the SST dataset title as the variable name.
- `partial_regression/mslp.mon.mean.nc` identifies **NCEP/DOE AMIP-II Reanalysis (Reanalysis-2)** in its source attributes.
- The 13 HDF-signature NetCDF files are retained and hashed, but their internal metadata was not parsed by the standard-library audit.
- Snow-index text and spreadsheet files are preserved. Station identifiers, acquisition dates, measurement definitions, and quality-control history are not consistently available in the inspected material.

These statements describe embedded archive metadata. They do not establish that the datasets match a current provider release. Full extracted classic-NetCDF metadata is in [netcdf_metadata.json](netcdf_metadata.json).

## Original and third-party code

Existing attribution comments are retained, including J.-Y. Park attributions in Fortran/GrADS utilities, GrADS map/colorbar helpers, and Torrence–Compo wavelet routines. MATLAB wavelet files contain their own reuse conditions and publication-acknowledgment text; some GrADS helpers contain GPL notices. Read the complete notice in each file before reuse.

No repository-wide permissive license has been assigned because authorship, third-party terms, and data rights are mixed. Public hosting alone does not grant unrestricted rights to every item. Cite the relevant datasets and methods, retain original notices, and verify the applicable terms for the particular files you use.

## Interpretation and reproducibility

- Preserve descriptor/data pairs and compare raw sizes, grid definitions, and variable ordering before numerical work.
- Confirm byte order, floating-point precision, record-length conventions, and missing-value handling. Four-byte record arithmetic in a program does not itself prove the encoding of every archived file.
- Seasonal time series can span calendar years. Identify whether a winter is indexed by its December or January year.
- Lagged filenames do not define causality or a universal lead/lag convention. Read the corresponding preprocessing script.
- Fields named `corr` may contain regression slopes. Units depend on the input index scaling and selected `reg` mode.
- Review detrending, climatological baseline, autocorrelation, effective sample size, and multiplicity before interpreting probability masks.
- Use copies for reruns: many scripts write output names already present in their working directory.

## 한국어 참고

원본 연구 파일은 줄바꿈을 포함한 내용을 보존하고, 대용량 기후 자료는 Git LFS로 관리합니다. 실행파일·편집기 임시파일은 공개 대상에서 제외하지만 원본 해시는 목록에 남깁니다. Git은 빈 폴더를 추적하지 않으므로 비어 있는 `nonmunwnd/`는 원격에 나타나지 않습니다.

자료 출처는 NetCDF 속성과 소스의 원저자 고지를 근거로 정리했습니다. 관측소 지수의 수집·검수 이력과 모든 자료의 버전은 확인되지 않았습니다. 공개 저장소라는 이유만으로 모든 코드·자료를 제한 없이 재사용할 수 있는 것은 아닙니다. 파일별 권리 고지와 제공기관 조건을 확인하고, 논문·보고서에 필요한 출처와 방법론을 명시하세요.
