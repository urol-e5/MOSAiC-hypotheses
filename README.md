# MOSAiC-hypotheses

Pre-registered, re-runnable tests of biological hypotheses on the E5 MOSAiC
coral time series: three species (*Acropora pulchra*, *Porites evermanni*,
*Pocillopora tuahiniensis*), ten colonies each, four timepoints in 2020, three
Mo'orea sites, with gene, miRNA, lncRNA, CpG methylation, metabolomic,
lipidomic, physiology, ITS2, and temperature-logger layers.

The data portal [urol-e5/MOSAiC](https://github.com/urol-e5/MOSAiC) is a
**read-only upstream**. This repo pins the MOSAiC commit and every external
file it uses (`config/upstream.yml`, checksums in `config/upstream.lock.yml`),
harmonizes them into one sample vocabulary, and runs hypotheses against that.

Status board and QC report: <https://urol-e5.github.io/MOSAiC-hypotheses/>

## How it works

```
config/upstream.yml   what we depend on, pinned        -->  R/fetch.R      data/raw/ (never committed)
R/harmonize.R         one sample id, one gene id       -->  data/derived/  + config/design.csv
tests/                reproduction gate                -->  must match MOSAiC's published counts
hypotheses/Hxx/       hypothesis.md -> analysis.qmd -> RESULT.md
_targets.R            runs all of the above            -->  reports/ (Quarto site)
```

The rules are in [CLAUDE.md](CLAUDE.md). The short version: write the
decision rule before the analysis, keep colony as a random effect, keep
negative results, never edit MOSAiC.

## Quick start

```bash
git clone https://github.com/urol-e5/MOSAiC-hypotheses
cd MOSAiC-hypotheses
Rscript -e 'install.packages(c("targets","tarchetypes","yaml","digest","tidyverse","testthat","gt","matrixStats","quarto"))'
Rscript R/fetch.R          # ~150 MB from gannet and GitHub
Rscript R/harmonize.R      # writes data/derived/ and config/design.csv
Rscript tests/run.R        # reproduction gate
quarto render reports      # status board + QC
```

Or all at once: `Rscript -e 'targets::tar_make()'`.

## Adding a hypothesis

1. Open an issue with the **New hypothesis** template, or copy
   `hypotheses/_template/` to `hypotheses/Hxx-slug/`.
2. Fill `hypothesis.md` completely, including the decision rule. Commit it
   with `status: planned` before writing any code.
3. Write `analysis.qmd` using only `R/load.R` loaders. Add it to `_targets.R`.
4. Run it, write `RESULT.md`, set the status, open a PR.

## Hypothesis slate

| ID | Tier | Claim |
|---|---|---|
| H01 | 1 | Colony explains more expression variance than season |
| H02 | 1 | Temporal plasticity ranks Acropora > Pocillopora > Porites |
| H03 | 1 | Seasonal expression responses are conserved across species |
| H04 | 2 | Methylation is more stable within colony than expression |
| H05 | 2 | Gene-body methylation tracks high, stable expression |
| H06 | 2 | Seasonal methylation change tracks seasonal expression change |
| H07 | 2 | Homologous miRNAs share seasonal profiles |
| H08 | 2 | lncRNA–mRNA co-expression exceeds a permutation null |
| H09 | 3 | Symbiont state predicts host expression modules |
| H10 | 3 | ITS2 symbiont communities are colony-fixed |
| H11 | 3 | Thermal history predicts heat-stress gene expression |
| H12 | 3 | Nutrient context modulates seasonal physiology |
| H13 | 4 | One multi-omics latent factor separates summer from winter |
| H14 | 4 | Storage lipids track biomass and calcification |

Full planning document: [docs/plan.md](docs/plan.md). Decisions taken along
the way: [docs/decisions.md](docs/decisions.md).

## Layout

| Path | What |
|---|---|
| `config/upstream.yml`, `upstream.lock.yml` | Manifest and checksums of every upstream file |
| `config/design.csv` | One row per sample: species, colony, timepoint, site, nutrient, haplotype, `has_<layer>` |
| `R/` | `fetch.R`, `harmonize.R`, `load.R`, `status.R` |
| `data/raw/` | Fetched upstream files (gitignored) |
| `data/derived/` | Harmonized matrices (CpG ones gitignored for size) |
| `hypotheses/` | One directory per hypothesis |
| `reports/` | Quarto site: status board, QC, decision log |
| `tests/` | Reproduction gate |
| `.github/workflows/` | Weekly upstream-drift check; gate + render on push |

## Related

- [urol-e5/MOSAiC](https://github.com/urol-e5/MOSAiC): portal and genome browser (upstream)
- [urol-e5/timeseries_molecular](https://github.com/urol-e5/timeseries_molecular), [urol-e5/timeseries](https://github.com/urol-e5/timeseries): where the matrices are produced
- [RobertsLab/current-findings](https://github.com/RobertsLab/current-findings): where supported findings get written up
