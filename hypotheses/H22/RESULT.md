# H22 result

**Status:** not supported

**Assay QC addendum — 2026-10-12:** the [calcification follow-up](../../docs/qc/2026-10-12/QC-follow-up.md)
confirms that delivered TP1/TP4 calculations use minute denominators and
TP2/TP3 use hour denominators, all labeled per hour. Nonpositive incubation
durations also occur, including eight distinct TP2 molecular samples.
Calcification estimates and any decision or adjusted p-value depending on
them await validated upstream recalculation and reanalysis. The registered
verdict and delivered measurements are preserved; no guessed rescaling is
applied.

**Corrected run:** 2026-10-12 on raven against MOSAiC commit `86432e3`
(see `config/upstream.lock.yml`). R 4.3.3, DESeq2 1.42.1, glmnet 4.1.9
(the original H22 model version, installed in an isolated library). Runtime
about 13 min 30 s with 24 workers and one OpenBLAS thread per worker; the
full run completed at 06:50 PDT with exit status 0. It included the primary,
both sensitivities (200 permutations per species/trait/analysis), and all
12 descriptive cross-species transfer comparisons.

**Methodological correction:** Amendment 2 (2026-10-12) replaces Amendment
1's all-samples expression preprocessing. Filtering, normalization, VST,
centering, PCA, and gene scaling are now learned separately in every outer
and inner training fold. Held-out samples use the frozen training scale.
Inner colony validation selects a penalty fraction using models with their
own training-derived PCs, rather than validating one PCA fitted across all
inner folds. Source-only gene and response scaling also replace target
species standardization in the descriptive transfer analysis. The shared
VST uses the full training feature set for its dispersion fit. These changes
are documented before the rerun; the original text and decision rule remain.
The [original result](RESULT-original-2026-10-08.md) is preserved. This is a
methodological correction on an already analysed dataset, not independent
replication; changes in scores cannot be attributed solely to one component
of the revised preprocessing and tuning procedure.

The reproduction gate passed all 22 tests on desktop and raven, including
perturbation tests for outer and inner leakage and a raw-count loading
regression. Eight input/configuration checksums matched the desktop.
Notebook MD5: `b9354448e71582d1e9fdae9f71c39cb2`; shared expression helper
MD5: `7b8ab107a74c3f8419e82c1a4bbd8a43`. Logs, checkpoints, and the isolated
library are retained at `/home/sr320/h22-preprocessing-2026-10-12` on raven.
All 3,600 permutation draws and saved predictions were verified finite;
reported scores, p-values, BH corrections, and verdicts were recomputed.
Sample cohorts and baseline scores match the original run in all analyses.

**Samples used:** colony × transition rows with expression at t and the
trait at t and t+1. About 10 colonies per species, 5 per site; three-way
orthologs. Raw mapped groups are unfiltered; retained genes vary by training
fold and trait. Inner validation refits its own filters as well.

| Species | Rows, AFDW (Mahana / Manava) | Rows, calcification (Mahana / Manava) | Raw mapped groups | Genes in primary outer folds |
|---|---|---|---|---|
| Apul | 29 (14 / 15) | 27 (12 / 15) | 10,223 | 9,789–9,887 |
| Peve | 26 (11 / 15) | 28 (13 / 15) | 10,346 | 9,142–9,497 |
| Ptuh | 29 (14 / 15) | 25 (10 / 15) | 10,346 | 9,916–9,979 |

**Headline numbers:** leave-one-site-out, out-of-sample R² pooled over the
two held-out sites. dR2 = molecular − baseline. p from 200 within-transition
permutations of training y[t+1]; q = BH across the two traits within species.
The PCs-selected summary is weighted by held-out prediction rows, as in the
output calculation; 9–14 PCs are available depending on the training fold.

| Species | Trait | R² baseline | R² + expression | dR2 | p | q | PCs selected |
|---|---|---|---|---|---|---|---|
| Apul | AFDW | −0.233 | −0.365 | −0.132 | 0.781 | 0.781 | 7.3 |
| Apul | calc | 0.032 | −0.036 | −0.067 | 0.582 | 0.781 | 4.9 |
| Peve | AFDW | −1.353 | −1.442 | −0.089 | 0.652 | 0.736 | 1.2 |
| Peve | calc | 0.370 | 0.361 | −0.009 | 0.736 | 0.736 | 0.5 |
| Ptuh | AFDW | −0.842 | −0.810 | 0.032 | 0.189 | 0.189 | 4.8 |
| Ptuh | calc | −0.393 | −0.249 | 0.143 | 0.174 | 0.189 | 7.8 |

Both traits have dR2 <= 0 in Apul and Peve, so the registered rule returns
`not supported` (previously `inconclusive`). Ptuh improves on both traits,
but neither improvement passes BH q < 0.05. The corrected calcification
models select expression PCs in at least one fold in both Apul and Peve;
their negative dR2 values are not the original zero-PC refitting artifact.
The raw AFDW baseline R² remains negative in every species. Expression does
not provide consistent gains when transferred to the other site/nutrient
regime in this analysis.

**Sensitivity checks:** both `inconclusive`; no trait passes q < 0.05.

| Check | Apul dR2: AFDW / calc | Peve dR2: AFDW / calc | Ptuh dR2: AFDW / calc | Smallest q |
|---|---|---|---|---|
| Leave one colony out | 0.057 / −0.150 | −0.121 / −0.008 | −0.021 / 0.013 | 0.100 (Apul AFDW) |
| TP3→TP4 dropped | 0.095 / −0.190 | −0.242 / −0.062 | −0.417 / 0.333 | 0.129 (Ptuh calc) |

The original colony-validation Apul AFDW signal (q = 0.030) no longer passes
correction. Dropping TP3→TP4 still gives the largest positive sensitivity
estimate for Ptuh calcification, but it remains nonsignificant after BH.

**Secondary, cross-species transfer (descriptive):** filtering and gene/
response scaling are learned from source training rows only. Retained
features vary by source species and trait (9,233–9,849). dR2 ranges from
−5.066 to 0.269 over the 12 comparisons; only two are positive. Baseline
R² also often becomes strongly negative under transfer. These scores now
include species differences in levels and expression distributions that
the original target-specific standardization removed. Neither transfer
approach is an independent cohort, and reference quality and physiological
scale differences limit interpretation.

**Current Findings:** not reported separately. Under CLAUDE.md §6 the
verdict is not `supported`, and with two outer folds of 5 colonies the
negative performance point estimates do not provide a useful effect bound
or an adequately powered exclusion of a biological association.

**Caveats:** about 10 colonies per species and 5 per site; each primary
training fold uses only 10–15 paired rows from 5 colonies. Inner models use
fewer colonies, so penalty selection and out-of-sample R² remain noisy even
with correct separation of training and validation data. Site is confounded
with nutrient, and there is no independent cohort. The `not supported`
verdict describes the registered performance rule for this pipeline, not
proof that expression contains no predictive biology. Traits remain on the
raw scale. The prior QC audit's calcification timepoint-scale warning remains
unresolved; this correction does not validate assay units or rescale those
measurements. Species is confounded with reference quality (Peve N50 0.17 Mb;
Ptuh mapped to *P. meandrina*), especially affecting cross-species transfer.
The transfer stage logged 12 warnings. A targeted audit reproduced DESeq2's
"all genes have equal values" warning when constructing a one-sample
validation dataset; the transfer design contains 12 such constructions
(six source/trait singleton colony folds, each used for two target species).
These apply a training-fitted VST and do not fit a differential-expression
model to the single held-out sample. All scores and predictions remain finite.

**Outputs:** in `output/`

- `n_per_species.csv`: rows, colonies, site balance and raw mapped groups
- `dr2_summary.csv`: primary R², dR2, null, p, q and feature/PC counts
- `predictions.csv`: primary predictions, fold IDs, gene counts, training counts, selected PCs and penalties
- `null_dr2.csv`: all primary null draws; full analysis checkpoints retain sensitivity nulls
- `observed_vs_predicted.png`, `figure_data.csv`: figure and its data
- `sens_leave_one_colony_out.csv`, `sens_drop_tp3_tp4.csv`: sensitivity results
- `cross_species_transfer.csv`: descriptive transfer comparisons
- `verdicts.csv`: corrected verdicts for all three analyses

not supported
