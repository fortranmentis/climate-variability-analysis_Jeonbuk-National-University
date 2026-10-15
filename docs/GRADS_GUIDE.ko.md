# GrADS .gs 파일 상세 가이드

[English](GRADS_GUIDE.md) · **한국어** · [저장소 소개](../README.ko.md)

## 1. 이 저장소에서 .gs가 담당하는 일

GrADS 스크립트는 시각화와 자료 계산을 함께 제어합니다. 이 폴더의 `.gs`는 NetCDF를 Fortran 입력으로 변환하거나, 지수를 직접 계산하거나, 저장된 통계 결과를 표시하거나, 다른 스크립트가 사용하는 함수를 제공합니다. 따라서 확장자만 보고 그림을 만드는 파일로 분류하면 실제 분석 과정을 놓치게 됩니다.

| 구성 요소 | 역할 |
|---|---|
| `.gs` | 입력과 차원 선택, 수식 계산, 반복문, 화면 구성, 자료·그림 출력 |
| `.gsf` | 스크립트 함수 제공; `snow/qdims.gsf`는 `snow/ltrend.gs`에서 사용 |
| `.ctl` | 바이너리의 위치, 격자, 시간축, 변수, 결측값 설명 |
| `.gdat` | 실제 수치값 저장; 대응하는 CTL과 생성 코드를 함께 확인해야 함 |
| `.f90` | 여러 실험에서 주요 수치 통계 계산 수행 |

전체 목록은 **`.gs` 231개와 `.gsf` 1개**입니다. 파일별 입력·출력·보조 함수 명령의 소스 줄 번호를 목록으로 제공합니다. 같은 이름의 보조 함수가 여러 폴더에 있으므로 복사본이 모두 같은 구현이라고 가정하면 안 됩니다.

## 2. 명령문과 스크립트 변수 구분

```grads
'set time jan1983 mar2020'
'define anom=sst-clim'
iyr=1982
while(iyr<2020)
  iyr=iyr+1
  'set time feb'iyr
  'd sanom'
endwhile
```

작은따옴표 안의 문자열은 GrADS에 전달하는 명령입니다. `define`은 GrADS 자료장을 정의하고, 따옴표 밖의 `iyr`·`while`은 스크립트 변수와 반복문을 제어합니다. `'set time feb'iyr`는 문자열과 연도를 이어 연도별 명령을 만듭니다. `d`는 `display`의 약어로, 출력 형식이 그림이면 그리기를 하고 `set gxout fwrite` 상태이면 수치값을 파일에 씁니다. `*`로 시작하는 줄은 주석입니다. 명령 응답은 `result`, 반환 상태는 `rc`로 확인할 수 있습니다. 문법은 [GrADS 배포본의 스크립팅 설명서](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/script.html)를 참고하세요.

## 3. 예제: SST에서 JFM 편차장 만들기

대상: [`nonmunJFM/make_data_sst.gs`](../nonmunJFM/make_data_sst.gs).

| 단계 | 실제 코드 | 해석 |
|---|---|---|
| 원자료 열기 | `sdfopen ../nonmun/sst.mnmean.nc` | 저장된 SST 자료 읽기 |
| 격자 선택 | `set x 1 360`, `set y 1 180`, `set z 1` | 수평 격자와 수직 위치 지정 |
| 기준 평균 | `define clim=ave(sst,t+0,time=mar2020,12)` | 현재 선택된 월에서 12시점 간격으로 같은 달의 값 평균 |
| 계절 반복 | `modify clim seasonal` | 월별 기준장이 계절적으로 반복되도록 설정 |
| 편차 계산 | `define anom=sst-clim` | 원자료에서 월별 기준 평균 빼기 |
| 3개월 평균 | `define sanom=ave(anom,t-1,t+1)` | 현재 월의 앞뒤 한 달을 포함해 평균 |
| 연도별 추출 | 1983–2020년 2월 반복 | 2월 중심이므로 실제 평균 기간은 1–3월 |
| 자료 저장 | `set fwrite sst_JFM_-12.gdat` | 선택한 자료장을 쓰고 `disable fwrite`로 닫기 |

코드상 의도한 표본은 연도별 **38개**입니다. 360 × 180 격자, 한 층, 값당 4바이트의 스트림이라면 예상 용량은 **9,849,600바이트**입니다. 이는 코드에서 계산한 예상 형식이며 실행 검증 결과가 아닙니다. 실제 자료 기간·유효 차원·바이트 순서와 후속 CTL을 확인해야 합니다. `-12`라는 이름만으로 강설 지수와의 연도 대응이 확정되지는 않습니다.

[`make_sst_jan/mk_data_sst.gs`](../make_sst_jan/mk_data_sst.gs)는 3개월 평균 없이 1월 편차를 저장합니다. [`2001sst/make_data_sst.gs`](../2001sst/make_data_sst.gs)는 다른 기간을 사용하며 3개월 평균 후 1월을 추출합니다. 비슷한 파일명이 같은 전처리를 의미하지 않습니다.

## 4. 예제: Niño 지수와 회귀 확인

[`regression/mk_Nino_index.gs`](../regression/mk_Nino_index.gs)는 `aave(sst,lon=190,lon=240,lat=-5,lat=5)`로 영역 평균을 계산합니다. 이어 월별 기후 평균, 편차, 중심 3개월 평균을 만들고 1982–2018년 12월을 추출합니다. 의도한 결과는 37개의 NDJ 지수입니다. 현재 입력에는 `/home/.../Data/sst.mnmean.nc` 절대경로가 들어 있으므로 작업 복사본에서 경로를 맞춰야 합니다.

[`regression/reg_btw2ts.gs`](../regression/reg_btw2ts.gs)는 Niño와 강수량 CTL을 열어 중심화한 교차곱의 합을 Niño 제곱편차합으로 나눈 기울기를 계산하고 `say result`로 출력합니다. 이 스크립트는 Fortran 예제에서 출력한 확률 통계량을 출력하지 않습니다. [`draw_scatter.gs`](../regression/draw_scatter.gs)는 `nino.1;ind.2` 산점도를 표시합니다. GrADS와 Fortran의 수치 결과를 서로 비교 실행한 것은 아닙니다.

## 5. 예제: SST·바람·유의성 레이어

[`2001jjSSTwind/draw_reg_snow_sst.gs`](../2001jjSSTwind/draw_reg_snow_sst.gs)는 SST, 동서풍, 남북풍의 CTL을 순서대로 엽니다. `.1`·`.2`·`.3`은 이 파일 번호를 뜻합니다. `set dfile`은 기본 파일을 바꿉니다.

- `corr.1`을 음영으로 표시합니다. 생성 Fortran의 `reg` 설정에 따라 `corr`에도 상관계수 대신 회귀계수가 저장됩니다.
- `const(maskout(prob.1,0.1-prob.1),1)`로 점 표시용 마스크를 준비합니다. `0.1`은 해당 코드의 표시 기준이며 통계 가정이 적절하다는 독립 검증은 아닙니다.
- 벡터 표시는 세미콜론으로 구분한 두 수식을 사용합니다. **이 스크립트는 바람 회귀장 대신 `prob.2`와 `prob.3`을 수식에 사용합니다.** 이를 물리적인 바람 회귀벡터로 설명하거나 그림을 재생성하기 전에 해당 선택을 검토해야 합니다.
- `basemap`, `clevsjy`, `cbarm`, `dots`는 지도 마스크, 색상 구간, 컬러바, 점 표시를 담당합니다.
- `printim`은 출력 PNG 이름과 4000 × 3600 픽셀 크기를 지정하며, `set parea`는 페이지 안의 그림 영역을 정합니다.

[`icec_day/draw_reg_snow_sst.gs`](../icec_day/draw_reg_snow_sst.gs)는 `set mproj nps`로 북극 중심 투영을 사용하고 해빙 음영과 기온 등치선을 겹칩니다. 절대경로 글꼴을 사용하며, 강설일수 제목과 함께 해빙 단위를 `[%/cm]`로 표기하고 있습니다. 새 그림을 발표하기 전에 회귀 지수의 단위와 맞는지 확인해야 합니다.

## 6. 보조 함수와 의존 자료

| 파일 | 역할·확인 사항 |
|---|---|
| `basemap.gs` | 육지·해양 다각형 덮기; `lpoly_*.asc`·`opoly_*.asc` 자료 사용 |
| `cbarm.gs`, `cbarm0.gs`, `xcbar.gs` | 컬러바 위치·모양; 함수별 인자 차이 확인 |
| `clevsjy*.gs` | 등치선 구간과 색상; 확인한 구현은 외부 `rgbset_mod` 호출 |
| `dots.gs` | 2차원 장을 점으로 표시; 크기·간격·색상 인자 사용 |
| `subplot.gs` | 다중 패널 배치; `EOF/draw_eof.gs`에서 사용 |
| `ltrend.gs`와 `qdims.gsf` | 선형 추세와 차원 조회; 이동 시 함수 탐색 경로도 유지 |

저장소에 `rgbset_mod.gs`는 없습니다. `gisang/rgbset.gs`가 있다는 사실만으로 대체 가능하다고 판단할 수 없습니다. GrADS의 스크립트 탐색은 현재 작업 폴더와 `GASCRP` 설정을 확인해야 하며, `.gsf` 함수 탐색은 별도로 점검해야 합니다. 보조 함수를 복사할 때 원저자·라이선스 고지를 유지하세요. [스크립트 탐색 설명](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/script.html)을 참고하세요.

## 7. 저장된 EOF 결과 표시하기

GrADS 설치, LFS 데이터 복원, `EOF/`의 CTL·데이터 쌍이 필요합니다. 점검한 PATH에서 GrADS 실행파일을 찾지 못했으므로 아래는 실행 절차 설명이며, 이 환경에서 검증한 실행 명령은 아닙니다.

```bash
cd EOF
grads -l
```

GrADS 프롬프트에서 입력합니다.

```text
run draw_eof.gs
q files
q dims
```

이 스크립트는 저장된 EOF 공간장, PC 시계열과 고유값 비율을 표시합니다. EOF 계산 자체를 실행하지 않습니다. `printim` 명령이 없으므로 PNG가 자동 저장되지 않으며, 완성된 페이지를 확인한 뒤 `printim eof-preview.png white`로 별도 저장할 수 있습니다.

배치 실행 예시는 `grads -b -l -x -c "run draw_eof.gs"`입니다. 그래픽 창 없이 명령을 실행하고 종료하므로, 그림을 남기려면 작업 복사본에 명시적인 출력 명령을 추가해야 합니다. 옵션은 [GrADS 실행파일 설명서](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/gradcomdgrads.html)에 근거했습니다.

다른 실험도 복사본에서 경로·보조 함수를 정리한 뒤 `q files`·`q dims`로 입력과 차원을, `q fwrite`로 저장 옵션을 확인합니다. 실행 기록에는 자료 버전, 기준 평균 기간, 추출 월, 지수의 연도, 지연 방향을 남기는 것이 좋습니다.

## 8. 바이너리 출력과 자주 만나는 문제

`set fwrite`는 스트림·순차 형식과 바이트 순서 등을 지정할 수 있습니다. 배포 문서에 명시된 기본 동작은 스트림 출력과 기존 대상 파일 교체입니다. 원본 코드는 대체로 형식·엔디언 옵션을 생략하므로 `q fwrite`로 실제 설정을 확인해야 합니다. 새 작업의 옵션은 [GrADS fwrite 설명서](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/gradcomdsetfwrite.html)를 참고하세요. direct-access Fortran이 읽는 스트림에 순차 레코드 마커가 추가되면 레코드 구조가 달라집니다.

| 증상·발견 사항 | 점검 내용 |
|---|---|
| 입력을 열지 못함 | 실행 폴더 기준 경로를 확인; CTL의 `DSET` 경로와 구분 |
| 해빙 전처리 실패 | 두 `*_reg_sea_ice/mk_data_ice.gs`의 `../sea_ice/`가 없음; 의도한 자료를 확인하고 수정 |
| 스펙트럼 전처리 실패 | 두 중첩 폴더의 `mk_Nino_index_monthly.gs`에 있는 `../Data/`는 해당 위치 기준으로 없음 |
| 색상 함수 오류 | `rgbset_mod`·`GASCRP` 확인; `rgbset.gs`로 임의 대체하지 않기 |
| 단위·레이어가 이상함 | `corr`·`prob`, 파일 번호, 벡터 수식, 지수 정규화와 제목 확인 |
| 계절이 예상과 다름 | 연도 반복문에서 실제 선택한 월과 연도 대응 확인; 주석·파일명만으로 판단하지 않기 |
| 원본 결과 덮어쓰기 | 실행 전에 복사본의 `set fwrite`·`printim` 대상명을 변경 |

## 9. 정적 목록과 검증 한계

[`grads_scripts.csv`](grads_scripts.csv)는 모든 스크립트의 해시, 역할 추정, 입력·출력·보조 함수 명령을 제공합니다. [`grads_input_references.csv`](grads_input_references.csv)는 인식한 입력 명령 **147건: 상대 대상 존재 97건, 절대경로 40건, 없는 상대 대상 10건**을 기록합니다. 이는 서로 다른 파일 수나 실패한 실험 수가 아니라 명령 발생 건수입니다. 모든 상대경로 확인은 해당 스크립트 폴더에서 실행한다는 가정에 근거합니다.

저장소 루트에서 `python tools/catalog_grads.py`로 다시 만들 수 있습니다. 점검기는 주석을 제외하고 작은따옴표로 시작하는 명령을 인식합니다. GrADS 전체 언어, 동적 생성 명령, 변수·기간 호환성, 설치된 보조 라이브러리, 실제 실행 성공은 검증하지 않습니다. 역할 추정 119개 보조 함수·47개 저장/혼합 작업·66개 분석/표시는 `.gs`와 `.gsf`를 합한 분류입니다.

[VALIDATION.md](../VALIDATION.md)의 **CTL 613개 참조 성공**은 CTL → 바이너리 데이터의 연결 확인입니다. `.gs` → CTL의 연결이 맞다는 의미는 아닙니다. 원본 `.gs`·`.gsf`는 수정하지 않았습니다.
