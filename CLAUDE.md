# MOSAiC-hypotheses: operating rules

This repo tests biological hypotheses on the E5 MOSAiC coral time-series data.
These rules apply to every contributor, human or agent. They exist so that the
repo stays re-runnable and so that results are pre-registered rather than
discovered after the fact.

## 1. Upstream is read-only

- `urol-e5/MOSAiC` and the `urol-e5/timeseries*` repos are never modified from
  here. If you find an upstream problem, open an issue on that repo and record
  the workaround in `docs/decisions.md`.
- Every external file is listed in `config/upstream.yml` and checksummed in
  `config/upstream.lock.yml`. Do not read URLs that are not in the manifest.
  Add the entry, run `Rscript R/fetch.R`, commit the lock.
- Analyses read only through `R/load.R`, never from `data/raw/`.

## 2. Pre-registration is mandatory

- A hypothesis lives in `hypotheses/Hxx-slug/`. Copy `hypotheses/_template/`.
- `hypothesis.md` must be complete (question, prediction, data, model,
  decision rule, status: `planned`) **before** `analysis.qmd` is written.
  The PR that adds the analysis must not edit the decision rule. If the rule
  turns out to be wrong, add a dated "Amendment" section explaining why and
  keep the original text.
- `RESULT.md` is written after the analysis runs and ends with exactly one of
  `supported`, `not supported`, `inconclusive`, plus the sample sizes actually
  used and one paragraph of caveats. Update `status:` in `hypothesis.md` to match.
- Negative and inconclusive results are kept. Never delete a hypothesis
  directory; mark it `withdrawn` with a reason if it is abandoned.

## 3. Statistical defaults

- Colony is a random effect or blocking factor in every model. Timepoint is a
  repeated measure on the same colonies, never an independent group.
- Report effect sizes with intervals. P-values alone are not a result.
- Multiple-testing correction is applied per hypothesis and stated in
  `hypothesis.md`.
- Cross-species comparisons use three-way orthologs (`load_orthologs()`)
  unless the hypothesis is explicitly about species-specific genes.
- Species is confounded with reference-genome quality (Peve N50 0.17 Mb; Ptuh
  mapped to *P. meandrina*). Any species-ranking claim needs a sensitivity
  check restricted to well-annotated orthologs.
- n is about 10 colonies per species. Say so in every RESULT.md.

## 4. Repo mechanics

- Pipeline: `Rscript -e 'targets::tar_make()'` runs fetch, harmonize, the
  reproduction gate, and renders `reports/`. Hypothesis analyses are added as
  `tar_quarto` targets in `_targets.R` once they have a `hypothesis.md`.
- Reproduction gate: `Rscript tests/run.R` must pass before any hypothesis
  is run or any PR is merged.
- Outputs go in `hypotheses/Hxx/output/`. Figures as PNG and the data behind
  them as CSV. Nothing over 10 MB is committed; put it on gannet and record the
  URL in `RESULT.md`.
- Shared helpers go in `R/`. If two hypotheses need the same function, move
  it there instead of copying.
- Commit messages: imperative, one line, mention the hypothesis id if relevant.

## 5. Vocabulary

| Term | Meaning |
|---|---|
| `Apul`, `Peve`, `Ptuh` | *A. pulchra* (ACR), *P. evermanni* (POR), *P. tuahiniensis* (POC) |
| sample id | `ACR-139-TP1`: prefix, colony number, timepoint |
| TP1..TP4 | Jan, Mar, Sep, Nov 2020 |
| layer | one data type: genes, mirna, lncrna, cpg, metabolomics, lipidomics, physiology, its2 |
| design | `config/design.csv`, one row per sample with `has_<layer>` flags |

## 6. Publishing findings

A supported or clearly informative result gets a short report in
`RobertsLab/current-findings` via that repo's `new-report.sh`. This repo stays
the working record; the finding links back to the hypothesis directory and the
MOSAiC commit in `config/upstream.yml`.
