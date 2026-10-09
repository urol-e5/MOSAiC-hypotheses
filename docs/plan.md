# Plan: a hypothesis-testing companion repo for MOSAiC

Prepared 2026-10-06 from a read-only review of `urol-e5/MOSAiC` at commit `86432e3`.

---

## Part 1. What MOSAiC is, and what it is not

### 1.1 Role of the repo

MOSAiC is a **data portal and genome browser**, not an analysis repo. It has two halves:

| Half | Where | What it does |
|---|---|---|
| JBrowse 2 build | repo root (`index.html`, `static/`, `config.json`, `data/`) | Serves three coral genomes with GFF gene tracks. Mirrored to gannet with `mirror.sh`. |
| Quarto site | `quarto/` | Pages that fetch count matrices, physiology, ITS2, and temperature data from upstream URLs and render summary tables and interactive plots. |

Every page in `quarto/` is descriptive. The most "analytical" page, `ortho.qmd`, computes per-timepoint means, SDs, and z-scores. There are no models, no inferential tests, no hypotheses. That is the gap the new repo fills.

### 1.2 Study design encoded in the data

- **Species (3)**: *Acropora pulchra* (Apul, samples `ACR-###`), *Porites evermanni* (Peve, `POR-###`), *Pocillopora tuahiniensis* (Ptuh/Ptua, `POC-###`, mapped to the *P. meandrina* genome).
- **Timepoints (4)**: TP1 Jan 2020, TP2 Mar 2020, TP3 Sep 2020, TP4 Nov 2020. Austral summer, late summer, winter/spring, spring.
- **Sites (3)**: Manava, Hilton, Mahana. Physiology metadata also carries a `nutrient` High/Low factor and `site_code`.
- **Colonies**: ~10 per species in the molecular data (Apul 10 colonies × 4 TP = 40 samples; Peve 38; Ptuh 39). Repeated measures on the same colonies.
- **Environment**: hourly-ish temperature loggers at all three sites, 2019-10-30 to 2020-11-07, in `data/temperature_timeseries.csv` (271k rows).

### 1.3 Data layers available (all per sample, all keyed on colony × timepoint)

| Layer | Source | Shape | Notes |
|---|---|---|---|
| Gene counts (RNA-seq, HISAT2/StringTie) | gannet + local copies in `data/orthologs/` | Apul 44,371 genes; Peve 40,389; Ptuh 31,840 | Remote Apul matrix has 80 columns (technical reps, duplicate names); local copy has 40. |
| miRNA counts (ShortStack) | GitHub raw, `timeseries_molecular` | 51 / 48 / 40 miRNAs | Column names carry plate prefix `1A1_ACR-173_TP1`. |
| lncRNA counts (featureCounts) | gannet / GitHub raw | filtered | Includes Chr/Start/End/Strand/Length columns; Apul columns are BAM paths. |
| CpG % methylation (EM-seq, Bismark) | gannet `metacarcinus/E5/` | 25 MB for Apul | Sites with ≥10× in **all** samples only. |
| Metabolomics | GitHub raw, `M-multi-species/output/metabolomics_count_matrix.csv` | compounds × 44 samples | All three species in one matrix. |
| Lipidomics | same dir, `lipid_count_matrix.csv` | 0.6 MB | Same. |
| Physiology master | `urol-e5/timeseries` `master_timeseries.csv` | 48 columns | Respiration, AFDW, chl a/c2, protein, symbiont cells, PI-curve params (Am, AQY, Rd, Ik, Ic), calcification, haplotype, site, nutrient. **This is the de facto sample metadata table.** |
| ITS2 profiles (SymPortal) | `urol-e5/timeseries` `ITS2_rel_abund_matrix.csv` | ~40 profile columns | Relative abundance; metadata columns match physiology. |
| Orthologs | `data/orthologs/ortholog_groups_*.csv` | 10,381 three-way groups; 4,054 with SwissProt names; GO + GO-slim | Plus pairwise groups (apul_peve 3,445; apul_ptua 1,884; peve_ptua 2,662). |
| Genomes + GFF | `data/Apul`, `data/Peve`, `data/Pmea` | Apul GFF has gene/mRNA/exon/CDS/tRNA | Needed for gene-body methylation and lncRNA–gene proximity. |

### 1.4 Rough edges the new repo must absorb (not fix upstream)

1. **Sample ID formats differ by layer.** `ACR-139-TP1`, `1A1_ACR-173_TP1`, `ACR-139_TP1`, BAM paths, `timepoint1`. A single normalizer to `{COLONY}-TP{n}` is the first thing to build.
2. **Gene ID formats differ between count matrices and ortholog table.** Apul orthologs carry `-T1` transcript suffixes; Peve and Ptuh count matrices carry a `gene-` prefix. `ortho.qmd` already has the mapping logic; port it.
3. **Technical replicates** in the remote Apul gene matrix (documented in `docs/corrected_sample_counts.md`). Decide: sum, average, or use the local 40-column copy.
4. **Species is confounded with reference quality.** Peve N50 0.17 Mb; Ptuh is mapped to a sister species. Cross-species claims need ortholog-restricted comparisons and sensitivity checks.
5. **Small n per species** (≈10 colonies). Every model must treat colony as a random effect or blocking factor; TP is a repeated measure, not an independent group.
6. **No explicit design table in MOSAiC.** Derive one from the physiology master and verify every molecular sample maps to it.
7. **Upstream URLs can move** (several already live under three different gannet paths). Pin them with checksums.

---

## Part 2. The new repo

### 2.1 Name and stance

Suggested: `urol-e5/MOSAiC-hypotheses` (or `mosaic-discovery`). Stance:

- MOSAiC is a **read-only upstream**. The new repo records the MOSAiC commit it was built against and every upstream URL with an MD5 and fetch date. It never writes to MOSAiC. If a fix is needed upstream, it opens a MOSAiC issue.
- Each hypothesis is a **pre-registered unit**: question, prediction, data, model, decision rule, and status, written **before** the analysis is run.
- The repo is **re-runnable end to end** from a fresh clone, on a schedule, and reports when upstream data change.

### 2.2 Layout

```
MOSAiC-hypotheses/
├── README.md                 # purpose, status board, how to add a hypothesis
├── CLAUDE.md                 # operating rules for agents (see 2.6)
├── config/
│   ├── upstream.yml          # MOSAiC commit + every URL, md5, fetched-on
│   └── design.csv            # harmonized sample metadata (sample_id, species, colony, tp, date, site, nutrient, haplotype)
├── R/                        # shared package-style functions
│   ├── fetch.R               # download by manifest, verify checksums
│   ├── harmonize.R           # ID normalizers for every layer
│   ├── load.R                # load_genes("Apul"), load_cpg(), load_phys(), ...
│   ├── models.R              # standard model formulas and helpers
│   └── report.R              # writes RESULT.md and status JSON
├── data/
│   ├── raw/                  # gitignored; fetched by manifest
│   └── derived/              # small harmonized tables, committed if < 10 MB, else written to gannet
├── hypotheses/
│   ├── _template/
│   │   ├── hypothesis.md     # pre-registration template
│   │   └── analysis.qmd
│   ├── H01-season-vs-colony-variance/
│   │   ├── hypothesis.md
│   │   ├── analysis.qmd
│   │   ├── output/           # figures, tables
│   │   └── RESULT.md         # auto-generated: status, effect sizes, caveats
│   └── H02-.../
├── pipelines/
│   └── _targets.R            # or Snakefile; defines fetch → harmonize → QC → H01..Hnn → dashboard
├── reports/                  # Quarto site: status board + one page per hypothesis
├── tests/
│   └── test-reproduce.R      # reproduction gate (see 2.4)
└── .github/workflows/
    ├── upstream-check.yml    # weekly: re-fetch, compare md5, open issue on drift
    └── render.yml            # on push: run light targets, render reports to gh-pages
```

### 2.3 Toolchain

- **R + Quarto** as the main stack, matching the lab's existing MOSAiC, `current-findings`, and `project-template` conventions. `renv` lockfile for reproducibility.
- **Pipeline**: the R `targets` package. It gives dependency tracking, caching of expensive steps, and a DAG that makes "re-run only what changed upstream" cheap. Snakemake is the fallback if Python-heavy steps dominate.
- **Core packages**: DESeq2 / edgeR / limma-voom (counts), lme4 / glmmTMB (mixed models), vegan (PERMANOVA, distance-based), variancePartition, WGCNA, MOFA2 (multi-omics integration), clusterProfiler or topGO on the GO-slim table.
- **Compute**: light steps (DE, variance partition, PERMANOVA) fit in a GitHub Actions runner. WGBS matrices and MOFA may not. Plan for heavy targets to run on a lab machine (raven) by cron, with results pushed back; GitHub Actions only verifies and renders.

### 2.4 Phase 0: foundation (do before any hypothesis)

1. Scaffold the repo from the layout above.
2. Write `config/upstream.yml` with every URL from `counts.qmd`, `physiology.qmd`, `its.qmd`, plus the local MOSAiC files (orthologs, GFFs, temperature). Record MD5 and date.
3. Write `fetch.R` and the harmonizers. Target output is one long-format or one wide matrix per layer, with columns renamed to `{COLONY}-TP{n}`, and a `design.csv` derived from the physiology master.
4. **Reproduction gate** (`tests/test-reproduce.R`): the harmonized data must reproduce MOSAiC's published sample-count table (Apul 40/40/45/39, Peve 38/37/43/37, Ptuh 39/39/44/32) and the ortholog count (10,381 three-way). Fails loudly if not. This is modeled on the `06_validate.py` gate in `lncRNA-coexpression-explorer`.
5. **QC report**: library sizes, PCA per layer colored by colony / TP / site, sample overlap matrix across layers (which colony × TP has which layers), and the temperature history preceding each TP per site. This report is a deliverable in itself and will shape the hypothesis order.
6. **Decision log** for the known rough edges (technical reps, `-T1` suffixes, `gene-` prefixes, ITS2 metadata join key).

### 2.5 Hypothesis registry (initial slate)

Each entry below is a candidate `hypotheses/Hxx/hypothesis.md`. They are ordered so that early results inform later ones. Statuses start as `planned`.

**Tier 1: establish the variance structure (needed by everything else)**

- **H01. Colony identity explains more expression variance than season.** Variance partitioning (`variancePartition`) of gene expression into colony, timepoint, site, residual, per species. Prediction: colony > timepoint in all three; species differ in the timepoint share. Decision: report the median fraction per component with bootstrap CIs.
- **H02. Species differ in temporal plasticity in the order Acropora > Pocillopora > Porites.** Count of genes DE across timepoints (DESeq2 with `~ colony + timepoint`, LRT), restricted to three-way orthologs so gene-set size is equal. Prediction follows life-history strategy (competitive / weedy / stress-tolerant). Decision: ordered DE counts and distribution of |LFC| differ by species at the stated order.
- **H03. Seasonal expression responses are conserved across species.** For three-way orthologs, correlate TP1-vs-TP3 (summer vs winter) log fold changes across species pairs. Prediction: positive Spearman rho, enriched in GO-slim terms related to metabolism and stress response. Decision: rho > 0 with permutation p < 0.01, plus concordant GO-slim enrichment.

**Tier 2: epigenetic and regulatory layers**

- **H04. DNA methylation is more stable than expression within colonies over time.** Intraclass correlation of colony for CpG % methylation vs for expression; PERMANOVA of the CpG matrix with colony and TP. Prediction: ICC(colony) higher for methylation; TP explains little methylation variance.
- **H05. Gene-body methylation is positively associated with expression level and negatively with temporal expression variability.** Aggregate CpGs to genes using the GFFs. Prediction: classic invertebrate pattern (high GBM, high and stable expression). Decision: spline or binned regression of CV(expression over TP) on mean GBM, controlling for expression level.
- **H06. Seasonal changes in methylation track seasonal changes in expression at the same genes.** Per-gene ΔmCpG vs ΔExpression between TP1 and TP3. Prediction: weak but positive association. This is the core E5 epigenetic-linkage test.
- **H07. miRNA temporal profiles are conserved across species.** Cluster miRNA profiles; test whether homologous miRNAs (shared names from the cnidarian miRBase set) show correlated TP patterns across species.
- **H08. lncRNA–mRNA co-expression exceeds a null expectation.** Reuse the threshold-with-null framework from `lncRNA-coexpression-explorer`. Prediction: observed edge count at a given |r| exceeds the permutation null. Explicitly note the n ≈ 10 per TP limit.

**Tier 3: linking molecules to phenotype and environment**

- **H09. Symbiont density and chlorophyll predict host expression modules.** WGCNA modules per species; module eigengenes regressed on `cells.cm2`, `chla.ug.cm2`, `calc.umol.cm2.hr` with colony as random effect. Prediction: at least one module per species tracks symbiont state, enriched for metabolic GO-slim terms.
- **H10. ITS2 symbiont community composition is colony-fixed, not seasonal.** PERMANOVA on ITS2 profiles; prediction: colony R² ≫ TP R². Secondary: colonies hosting *Durusdinium* differ in physiology from *Cladocopium*-dominated colonies.
- **H11. Cumulative thermal history predicts stress-gene expression.** From the logger data, compute degree-heating weeks or days above the site MMM for the 30 days before each TP per site. Regress expression of HSP / chaperone orthologs on this exposure with colony random effect. Prediction: positive slope, strongest in Acropora.
- **H12. Nutrient / site context modulates seasonal physiology.** Mixed model of physiology traits with `timepoint * nutrient` and colony random effect. First check design balance; this may be underpowered and should be flagged as exploratory if so.

**Tier 4: integration**

- **H13. A single latent factor explains covariation across omics layers and aligns with season.** MOFA2 on gene, miRNA, lncRNA, methylation, metabolome, lipidome for overlapping samples. Prediction: factor 1 separates TP1/TP2 from TP3/TP4; a second factor separates colonies.
- **H14. Seasonal lipid and metabolite shifts reflect energetic state.** Lipid class ratios (storage vs membrane) and key metabolites vs AFDW and calcification. Ties to the E5 energetic framework.

### 2.5b Second slate (2026-10-07): field-wide open questions

Ten open questions on environmental epigenetic memory (Q1–Q10) were checked
against H01–H14. None was already covered; eight map onto MOSAiC data as new
pre-registrations:

| Q | Question | Hypothesis | What the data can and cannot say |
|---|---|---|---|
| Q1 | Persistence and decay of marks | H15 | Persistence over about 2 months (TP3→TP4) only |
| Q2 | Soma-to-germline transmission | none | No gamete or larval samples. Not testable |
| Q3 | Causal direction | H16 | Temporal precedence, not causation |
| Q4 | F0–F1 methylation rebound | none (H15 secondary) | No offspring. H15 reports within-generation overshoot past baseline as a descriptive analog |
| Q5 | ncRNA functional validation | H17 | Cis correlation above a null and its size; not functional validation |
| Q6 | Channel integration | H18 | Methylation and lncRNA only; miRNA needs target predictions added to the manifest |
| Q7 | Energetic cost of plasticity | H19 | Colony-level association, n about 27 pooled |
| Q8 | Mismatch threshold | H20 | Memory signal and its cost; the threshold itself is not estimable (9 site × interval rates) |
| Q9 | Cross-taxa generality of plasticity–frontloading trade-off | H21 | Three coral genera only; code goes in `R/` for reuse on bivalve data |
| Q10 | Held-out predictive performance | H22 | Held-out site and held-out species as proxies; no independent cohort |

Q2 and Q4 need a parent–offspring design (e.g. a spawning or larval-rearing
experiment) and are left for a different dataset.

### 2.5c Third slate (2026-10-08): follow-ups from supported results

Five follow-ups built on H02, H05, H08, H10, and H17. Details and evidence
criteria: [follow-up-hypotheses.md](follow-up-hypotheses.md). Each has a
`hypothesis.md` at `status: proposed` (D-016) listing what must be fixed
before it moves to `planned`.

| ID | Builds on | Claim |
|---|---|---|
| H23 | H02, H05 | Acropora's excess seasonal plasticity is concentrated in low-GBM orthologs (`inconclusive`) |
| H24 | H05 | Orthologs retain similar GBM ranks across species (`inconclusive`) |
| H25 | H08, H17 | Beyond 2 kb, lncRNA–gene and gene–gene co-expression are practically equivalent (exploratory: pattern first seen in H17) |
| H26 | H08, H17 | Distal lncRNA–mRNA edges predict expression in held-out colonies |
| H27 | H10 | Stable ITS2 profiles differ in seasonal symbiont-density trajectories (Peve, Ptuh) |

Suggested order: H23, H24, then H25; H26 needs careful validation and H27
an eligibility count on the joined data first. None is an independent
replication of the results it builds on.

### 2.6 Operating rules (go in `CLAUDE.md`)

These rules make the repo safe to run with an agent in the loop:

1. Never modify MOSAiC. Read via pinned URLs and commit hash only.
2. A hypothesis directory must contain a completed `hypothesis.md` with prediction and decision rule **before** `analysis.qmd` is written. The PR that adds the analysis must not change the decision rule.
3. Colony is always a random or blocking effect. Timepoint is a repeated measure.
4. Report effect sizes with intervals, not p-values alone. Multiple-testing correction is per hypothesis and stated.
5. Cross-species comparisons use three-way orthologs only, unless the hypothesis explicitly concerns species-specific genes.
6. Every `RESULT.md` ends with one of: `supported`, `not supported`, `inconclusive`, with a one-paragraph reason and the sample sizes actually used.
7. Negative and inconclusive results are kept, not deleted.
8. Anything that would be a finding worth sharing gets a summary pushed to `current-findings` via the existing report flow. The hypothesis repo stays the working record.

### 2.7 Systematic running

- **Weekly `upstream-check`** GitHub Action: re-download by manifest, compare MD5s, open an issue titled "Upstream data changed: <layer>" when drift is found. Nothing re-runs automatically on drift; a human decides.
- **On push `render`**: run the light targets, render the Quarto status board, publish to gh-pages. The status board is a table of hypotheses with status, last run date, headline effect size, and link.
- **Heavy targets** on raven via cron, writing outputs to `data/derived/` on gannet; the repo stores only the small result tables and figures.
- **New hypotheses enter through GitHub issues** using an issue template that mirrors `hypothesis.md`. An agent (Copilot or Claude Code) can pick up the issue, scaffold the directory, implement the analysis under the rules in 2.6, and open a PR. Review is human.

### 2.8 Sequencing and effort

| Step | What | Rough effort |
|---|---|---|
| 0a | Scaffold, manifest, fetch, harmonize, design table | 1–2 days |
| 0b | Reproduction gate + QC report | 1 day |
| 1 | H01–H03 | 2–3 days |
| 2 | H04–H08 (H05/H06 need gene-level methylation aggregation; budget extra) | 4–6 days |
| 3 | H09–H12 | 3–4 days |
| 4 | H13–H14 | 2–3 days |
| ∞ | Automation, status board, issue template, CLAUDE.md | 1 day, done alongside step 0 |

Phase 0 is the only step that must happen in order. After that, hypotheses within a tier are independent and can be parallelized across people or agents.

---

## Part 3. Open decisions for you

1. **Repo name and org** (`urol-e5` vs personal).
2. **Technical replicate policy** for the remote Apul gene matrix: sum, mean, or use the 40-column local copy.
3. **Heavy compute location**: GitHub Actions only (limits WGBS and MOFA work) vs raven cron.
4. **Which hypotheses to drop or add.** The slate above is a starting proposal, deliberately biased toward the E5 energetic–epigenetic framing; H12 is the weakest and may not be worth the effort.
5. **Python alongside R?** Needed only if MOFA2 or tensor methods (your `workflow-stdm` repo) are brought in.
