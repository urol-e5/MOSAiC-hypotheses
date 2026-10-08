# H09 result

**Status:** not supported

**Run on:** 2026-10-08 on raven against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.3, WGCNA 1.74, lmerTest 3.2.1, lme4 1.1-37, DESeq2 1.42.1. Runtime
10 min with 47 WGCNA threads, single block per species (`H09_MAX_BLOCK` =
25000, the valid setting). Reproduction gate passed in the same pipeline run.

**Samples used:** about 10 colonies per species; samples with both gene counts
and physiology.

| Species | Samples | Colonies | Genes (H01 filter) | Genes with GO-slim | n cells | n chla | n calc | n AFDW |
|---|---|---|---|---|---|---|---|---|
| Apul | 39 | 10 | 21,066 | 4,775 | 39 | 39 | 38 | 39 |
| Peve | 38 | 10 | 20,841 | 4,269 | 38 | 38 | 38 | 37 |
| Ptuh | 39 | 10 | 20,796 | 4,333 | 39 | 39 | 37 | 39 |

**Networks.** Soft threshold from the scale-free fit in every species (signed
R² >= 0.8): power 10 (Apul, R² 0.86), 12 (Peve, 0.87), 18 (Ptuh, 0.80).
Modules (excluding grey): Apul 14 (3,963 genes unassigned), Peve 51 (2,227),
Ptuh 39 (5,327).

**Headline numbers.** `lmer(ME ~ scale(trait) + timepoint + (1|colony))`,
BH within species over module × trait (416 tests in total).

| Species | Tests | Significant slopes (FDR < 0.05, CI excludes 0) | Smallest FDR (module, trait, slope per SD [95% CI]) |
|---|---|---|---|
| Apul | 56 | 0 | 0.155 (M9, calcification, 0.081 [0.028, 0.134]) |
| Peve | 204 | 0 | 0.994 (all traits) |
| Ptuh | 156 | 0 | 0.437 (M10, AFDW, 0.077 [0.023, 0.132]) |

No module passes in any species, so the verdict is `not supported`. Nominal
p < 0.05 occurred in 23 of 416 tests, against 21 expected by chance. The
pre-registered prediction named symbiont density and chlorophyll; their
smallest FDRs were 0.22 (Apul cells) and 0.44 (Ptuh chla).

Sensitivity check (pre-registered): refit without timepoint, so shared
seasonal signal can count toward the trait.

| Species | Significant slopes | Modules passing (slope + GO-slim term FDR < 0.1) | Verdict input |
|---|---|---|---|
| Apul | 2: M1 calcification +0.083 [0.037, 0.129], M8 calcification −0.081 [−0.127, −0.036], both FDR 0.037 | 1 (M1: 11 terms; top transporter activity, carbohydrate derivative metabolic process, FDR 1.5e-5) | passes |
| Peve | 0 (smallest FDR 0.24) | 0 | fails |
| Ptuh | 0 (smallest FDR 0.18) | 0 | fails |

Verdict without timepoint: `inconclusive` (Apul only). The M1 enrichment
details were recomputed from `module_membership.csv` with the analysis's own
`enrich_module()`; the notebook prints but does not save them.

**Caveats:** n is about 10 colonies per species, with about 40 samples per
eigengene model, and BH runs over 56 to 204 correlated tests per species, so
modest trait effects would be missed. The one association that appears
without timepoint (Apul calcification with M1 and M8) disappears once
timepoint is in the model, so it cannot be separated from season with four
timepoints; it is consistent with calcification and a large
transport/carbohydrate-metabolism module (4,717 genes) both tracking season
rather than with symbiont state driving host expression. Symbiont density and
chlorophyll, the traits the prediction named, show nothing in either model.
WGCNA modules depend on soft threshold and tree-cut settings and were not
resampled; Ptuh's threshold (power 18, R² 0.80) only just met the
criterion. Physiology comes from a separate fragment of the same colony. Only
about a fifth of network genes carry GO-slim terms, favouring conserved
genes. Species is confounded with reference quality (Peve N50 0.17 Mb; Ptuh
mapped to *P. meandrina*). Process note: `hypothesis.md` and
`analysis.qmd` were added in the same commit (`7b54192`) rather than in
sequence as CLAUDE.md section 2 asks; the decision rule in the analysis
matches `hypothesis.md` verbatim and was not edited.

**Current Findings:** not reported separately. Under CLAUDE.md §6 the
verdict is not `supported`, there was no pre-registered power check, and
the result does not bound an effect size; it belongs to no existing synthesis.

**Outputs:** in `output/`
- `n_per_species.csv`: samples and trait n actually used
- `networks.csv`, `soft_threshold_fit.csv`, `module_membership.csv` (1.9 MB): network construction
- `eigengene_trait_models.csv`, `decision_per_species.csv`: primary models and decision
- `goslim_enrichment_significant_modules.csv`: primary enrichment (empty; no significant modules)
- `eigengene_trait_volcano.png`: figure; data are in `eigengene_trait_models.csv`
- `sens_no_timepoint_models.csv`, `sens_no_timepoint_decision.csv`: sensitivity check
- `verdicts.csv`: verdict for each analysis

not supported
