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

[Full data QC review (2026-10-07)](docs/qc/2026-10-07/QC-review.md),
including species/timepoint abnormalities, supporting tables, and figures.

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

Or all at once: `Rscript -e 'targets::tar_make()'`. Hypothesis targets wait
for the reproduction gate and rerun when harmonized inputs change.

Normal fetches (including `--force`) verify files against the committed lock
and fail on checksum mismatches or unrecorded inputs. To intentionally accept
reviewed upstream changes, run `Rscript R/fetch.R --force --refresh-lock`,
rerun harmonization and the reproduction gate, and commit the updated lock.
Use `--refresh-lock` without `--force` to record reviewed local files or new
manifest entries.

## Adding a hypothesis

1. Open an issue with the **New hypothesis** template, or copy
   `hypotheses/_template/` to `hypotheses/Hxx-slug/`.
2. Fill `hypothesis.md` completely, including the decision rule. Commit it
   with `status: planned` before writing any code.
3. Write `analysis.qmd` using only `R/load.R` loaders. Add it to `_targets.R`.
4. Run it, write `RESULT.md`, set the status, open a PR.

## Hypothesis slate

| ID | Tier | Claim | Compute |
|---|---|---|---|
| H01 | 1 | Colony explains more expression variance than season | desktop |
| H02 | 1 | Temporal plasticity ranks Acropora > Pocillopora > Porites | desktop |
| H03 | 1 | Seasonal expression responses are conserved across species | desktop |
| H04 | 2 | Methylation is more stable within colony than expression | raven |
| H05 | 2 | Gene-body methylation tracks high, stable expression | desktop |
| H06 | 2 | Seasonal methylation change tracks seasonal expression change | desktop |
| H07 | 2 | Homologous miRNAs share seasonal profiles | desktop |
| H08 | 2 | lncRNA–mRNA co-expression exceeds a permutation null | raven |
| H09 | 3 | Symbiont state predicts host expression modules | raven |
| H10 | 3 | ITS2 symbiont communities are colony-fixed | desktop |
| H11 | 3 | Thermal history predicts heat-stress gene expression | desktop |
| H12 | 3 | Nutrient context modulates seasonal physiology | desktop |
| H13 | 4 | One multi-omics latent factor separates summer from winter | desktop |
| H14 | 4 | Storage lipids track biomass and calcification | desktop |
| H15 | 2 | Methylation changes persist after temperature reverses; expression reverts | desktop |
| H16 | 2 | Expression change precedes methylation change | desktop |
| H17 | 2 | lncRNAs co-vary with cis neighbors above an expression-matched null | desktop |
| H18 | 4 | Methylation and cis-lncRNA explain independent parts of expression change | desktop |
| H19 | 4 | Higher methylome turnover goes with lower biomass and lipid reserves | desktop |
| H20 | 3 | Transcriptome–temperature mismatch predicts later loss of biomass | desktop |
| H21 | 3 | Frontloading–plasticity trade-off in stress orthologs | desktop |
| H22 | 4 | Expression forecasts next-timepoint physiology at held-out sites | desktop |
| H23 | 2 | Acropora's excess plasticity sits in low-methylation orthologs | desktop |
| H24 | 2 | Orthologs keep similar gene-body methylation ranks across species | desktop |
| H25 | 2 | Beyond 2 kb, lncRNA–gene and gene–gene co-expression are equivalent | desktop |
| H26 | 2 | Distal lncRNA–mRNA edges predict expression in held-out colonies | raven |
| H27 | 3 | Stable ITS2 profiles differ in seasonal symbiont-density trajectories (withdrawn) | desktop |

Compute: **desktop** runs on a laptop (16 GB, 8 cores) in under an hour.
**raven** needs more memory or hours of per-feature model fits: H04 fits a
variance partition per CpG (about 2 M sites for Ptuh), H08 correlates every
lncRNA x mRNA pair (about 3 x 10^8 per species) under 200 permutations, and
H09 builds a WGCNA TOM on about 20 k genes, and H26 repeats its full
leave-one-colony-out selection under every permutation. **klone** is the
fallback if any raven target exceeds a day; none is expected to. See D-004 in
[docs/decisions.md](docs/decisions.md).

Full planning document: [docs/plan.md](docs/plan.md). Decisions taken along
the way: [docs/decisions.md](docs/decisions.md).

[Five proposed follow-up hypotheses (H23–H27)](docs/follow-up-hypotheses.md)
build on supported findings, with predictions, test designs, and evidence
criteria. Each sits on the board with `status: proposed` until its
`hypothesis.md` is complete enough to move to `planned`. H23 and H24 have
been pre-registered and run (both `inconclusive`), as has H25 (`inconclusive`);
H26 has been run (`not supported`); H27 was withdrawn before
pre-registration (too few eligible ITS2 profiles).

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
