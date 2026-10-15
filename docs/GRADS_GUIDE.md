# GrADS script guide

**English** · [한국어](GRADS_GUIDE.ko.md) · [Repository overview](../README.md)

## 1. What a `.gs` file does here

GrADS scripts control both data analysis and graphics. In this archive, a script may transform NetCDF fields into Fortran inputs, calculate an index directly, display previously computed statistics, or provide a reusable plotting function. A `.gs` filename is therefore not evidence that its only output is a picture.

Read these components together:

| Component | Responsibility |
|---|---|
| `.gs` | Select inputs and dimensions, calculate expressions, control loops and graphics, export data or figures |
| `.gsf` | Script-level function; `snow/qdims.gsf` is used by `snow/ltrend.gs` |
| `.ctl` | Describe binary file location, grid, calendar, variables, and missing values |
| `.gdat` | Store numerical values; interpretation requires matching descriptor and producing code |
| `.f90` | Perform the archive's main numerical statistical analyses in many workflows |

The catalogue contains **231 `.gs` files and one `.gsf`**. It gives source line numbers for recognized input, export, and helper commands. Repeated helper filenames occur in multiple experiment directories; do not assume those copies have identical behavior.

## 2. Reading the scripting language

Consider these source patterns:

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

Single-quoted strings are commands sent to GrADS. `define` creates a GrADS field. Unquoted `iyr` and `while` belong to the script's control flow; concatenation builds each year's `set time` command. `d` abbreviates `display`: with graphical output selected it draws, but with `set gxout fwrite` selected it writes numerical data. Lines beginning with `*` are comments. The command response is available through `result`; script return status can be inspected through `rc`. See the [upstream scripting manual distributed with GrADS](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/script.html).

## 3. Walkthrough: SST → JFM anomaly fields

Source: [`nonmunJFM/make_data_sst.gs`](../nonmunJFM/make_data_sst.gs).

| Step | Source expression | Meaning |
|---|---|---|
| Open | `sdfopen ../nonmun/sst.mnmean.nc` | Load the archived SST field |
| Select | `set x 1 360`, `set y 1 180`, `set z 1` | Use the configured horizontal grid and level |
| Baseline | `define clim=ave(sst,t+0,time=mar2020,12)` | Average the same calendar-month positions at a 12-step interval, under the current time selection |
| Calendar behavior | `modify clim seasonal` | Allow the climatology to repeat seasonally |
| Anomaly | `define anom=sst-clim` | Subtract the monthly baseline |
| Seasonal mean | `define sanom=ave(anom,t-1,t+1)` | Center a three-month average on each selected month |
| Sample and write | February loop, 1983–2020 | Export January–March anomalies, one selected field per year |
| Output | `set fwrite sst_JFM_-12.gdat` | Write the configured binary output, then close with `disable fwrite` |

The loop produces 38 intended annual samples. At 360 × 180 values, one level, and four bytes per value, the intended stream length is **9,849,600 bytes**. This is a layout expectation derived from the code, not a runtime check. Confirm available dates, effective dimension ranges, byte order, and the downstream descriptor before relying on it. The `-12` label alone does not define how those 38 years align with a snow index.

Related examples differ: [`make_sst_jan/mk_data_sst.gs`](../make_sst_jan/mk_data_sst.gs) writes January anomalies without the three-month average; [`2001sst/make_data_sst.gs`](../2001sst/make_data_sst.gs) uses a different period and smooths anomalies before January sampling.

## 4. Walkthrough: a regional climate index

[`regression/mk_Nino_index.gs`](../regression/mk_Nino_index.gs) calculates `aave(sst,lon=190,lon=240,lat=-5,lat=5)`, then builds a monthly climatology, anomalies, and a centered three-month mean. Sampling December 1982–2018 forms the archived NDJ index (37 intended values). Its source currently opens an absolute `/home/.../Data/sst.mnmean.nc` path; adapt that path in a working copy before running.

[`regression/reg_btw2ts.gs`](../regression/reg_btw2ts.gs) opens the Niño and precipitation descriptors and evaluates a centered cross-product divided by the Niño sum of squares. It prints a slope through `say result`; it does not print the probability statistic supplied by the Fortran counterpart. [`draw_scatter.gs`](../regression/draw_scatter.gs) displays `nino.1;ind.2` as a scatterplot. No GrADS-to-Fortran numerical comparison has been executed.

## 5. Walkthrough: SST, wind, and significance layers

[`2001jjSSTwind/draw_reg_snow_sst.gs`](../2001jjSSTwind/draw_reg_snow_sst.gs) opens SST, zonal-wind, and meridional-wind descriptors in that order. Suffixes `.1`, `.2`, and `.3` refer to these dataset numbers; `set dfile` changes the default dataset.

- `corr.1` supplies shaded SST regression values. Read the producing Fortran `reg` setting: the name `corr` can hold a regression slope.
- `const(maskout(prob.1,0.1-prob.1),1)` prepares a spatial mask for the `dots` helper using the archived 0.1 cutoff. This is a display threshold, not an independent test of statistical assumptions.
- The vector display takes two semicolon-separated expressions from datasets 2 and 3. In this script those expressions use `prob.2` and `prob.3`, not the wind regression fields. Review this choice before describing or regenerating the vector layer as physical wind coefficients.
- `basemap`, `clevsjy`, `cbarm`, and `dots` provide masks, contour colors, a colorbar, and dotted overlays.
- `printim` names the PNG and requests 4000 × 3600 output pixels. `set parea` controls the plot area within the page.

Similarly, [`icec_day/draw_reg_snow_sst.gs`](../icec_day/draw_reg_snow_sst.gs) combines sea-ice shading and air-temperature contours in a north-polar projection (`set mproj nps`). It specifies an absolute font path and contains a sea-ice unit label `[%/cm]` despite a snow-day title; check the regression index units before publishing a regenerated figure.

## 6. Helper functions and dependencies

| Helper | Role and dependency |
|---|---|
| `basemap.gs` | Land/ocean polygon overlays; uses companion `lpoly_*.asc` / `opoly_*.asc` assets |
| `cbarm.gs`, `cbarm0.gs`, `xcbar.gs` | Colorbar layout; arguments vary by helper |
| `clevsjy*.gs` | Contour levels and colors; inspected versions call external `rgbset_mod` |
| `dots.gs` | Sample a two-dimensional field as dots; arguments control scale, spacing, and colors |
| `subplot.gs` | Multi-panel placement, used by `EOF/draw_eof.gs` |
| `ltrend.gs` + `qdims.gsf` | Trend fitting and dimension queries; preserve function lookup when moving files |

There is no `rgbset_mod.gs` in this archive. The presence of `gisang/rgbset.gs` does not establish that it is an equivalent replacement. GrADS searches the working directory and configured `GASCRP` locations for scripts; `.gsf` function lookup needs its own environment review. Preserve the original author/license headers in copied helpers. See [script lookup documentation](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/script.html).

## 7. Running an inspected display example

Prerequisites: a GrADS installation, restored LFS data, and the local `EOF` descriptor/data pairs. GrADS was not available on the audited PATH, so these are documented commands, not a verified runtime recipe.

```bash
cd EOF
grads -l
```

At the GrADS prompt:

```text
run draw_eof.gs
q files
q dims
```

This script displays saved EOF modes, PC time series, and eigenvalue percentages. It has no `printim` command, so it does not automatically save a PNG. To export the current completed page to a new path, issue `printim eof-preview.png white` after inspection.

A batch invocation is `grads -b -l -x -c "run draw_eof.gs"`: it suppresses the graphics window and exits after the command, but this script still needs an explicit image-export command in a working copy to retain a picture. Flag meanings are documented in the [GrADS executable reference](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/gradcomdgrads.html).

For other experiments, work in a copy, resolve input and helper paths, inspect `q files` / `q dims`, check export options with `q fwrite`, and capture the command log. Record dataset versions, baseline, selected months, index years, and lag direction alongside outputs.

## 8. Binary export and common failure points

GrADS supports stream/sequential output and explicit byte order through `set fwrite`. Its documented defaults include stream output and replacement of an existing target. The archive usually omits explicit format/endian flags; verify the actual settings with `q fwrite`. Use the [upstream fwrite reference packaged by Debian](https://sources.debian.org/data/main/g/grads/3:2.2.1-5/doc/gradcomdsetfwrite.html) when choosing options for a new workflow. Sequential record markers must not be silently introduced into a stream expected by a direct-access Fortran reader.

| Symptom or finding | Inspect before rerunning |
|---|---|
| Cannot open a file | Relative path is resolved from the working directory; check it separately from CTL `DSET` resolution |
| Sea-ice preparation fails | Two `*_reg_sea_ice/mk_data_ice.gs` scripts refer to absent `../sea_ice/`; select the scientifically intended input before changing the path |
| Spectral preprocessing fails | Both nested spectral `mk_Nino_index_monthly.gs` scripts use `../Data/`, which is absent relative to those nested directories |
| Missing color command | Resolve `rgbset_mod` and relevant `GASCRP`; do not assume `rgbset.gs` is interchangeable |
| Figure has wrong units or layers | Compare `corr`/`prob`, dataset numbers, vector expressions, index normalization, and title text |
| Correct-looking file with wrong season | Inspect the month used inside the annual loop and cross-year alignment; comments and filenames can disagree |
| Archive output overwritten | Change `set fwrite` and `printim` targets in a copy before execution |

## 9. Catalogue and validation limits

[`grads_scripts.csv`](grads_scripts.csv) lists every script with its hash, role hint, recognized commands, and helper calls. [`grads_input_references.csv`](grads_input_references.csv) contains **147 input-command occurrences: 97 present relative targets, 40 absolute paths, and 10 absent relative targets**. These are command occurrences, not counts of distinct files or broken workflows. Existence is checked under the explicit assumption that each script is run from its own directory.

Regenerate with `python tools/catalog_grads.py` from the repository root. The scanner skips comment lines and recognizes leading single-quoted commands. It does not fully parse GrADS, inspect all generated commands, prove variable/period compatibility, resolve installed helper libraries, or execute scripts. Its 119 helper / 47 export-or-mixed / 66 analysis-or-display role hints cover `.gs` and `.gsf` together.

The **613 successful CTL `DSET` checks** in [VALIDATION.md](../VALIDATION.md) concern a different link: descriptor → binary data. They do not establish script → descriptor correctness. All original `.gs` / `.gsf` files remain unchanged.
