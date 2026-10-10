# H26 result

**Status:** not supported

**Run on:** 2026-10-09 to 2026-10-10 on raven against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.3, DESeq2 1.42.1, lme4 1.1-37. Runtime 22 h 57 min with 47 cores (1,000
permutations per species, each re-running the full leave-one-colony-out
pipeline). The pre-registration was completed and committed first
(`49a4e5b`), then the analysis (`c897c17`). The analysis code was
smoke-tested only on Poisson-noise counts before that commit; that test led
to the metric change recorded in `hypothesis.md` (the per-target ratio was
replaced by the pooled variance-scaled form) before any real H26 statistic
was computed. Reproduction gate and test suite passed the same day.

**Samples used:** about 10 colonies per species, 5 per site; each fold trains
on 9 colonies and tests on the held-out colony's 2–4 samples.

| Species | Samples | Colonies | Genes | lncRNAs | Isolated lncRNAs | Composition outliers (C2) |
|---|---|---|---|---|---|---|
| Apul | 40 | 10 | 21,108 | 15,559 | 656 | 2 |
| Peve | 38 | 10 | 20,837 | 8,314 | 297 | 1 |
| Ptuh | 39 | 10 | 20,796 | 11,236 | 1,317 | 2 |

Peve excludes the scaffold_167 locus (D-017). Every fold in every species had
100 qualifying targets (|r| >= 0.6; median selected |r| 0.92–0.94).

**Headline numbers.** I = mean over folds of 1 − Σ scaled MSE(full) / Σ
scaled MSE(nuisance) on the held-out colony; 95% colony-block bootstrap
interval; permutation p against 1,000 within-site reassignments of lncRNA
colony trajectories (14,399 possible).

| Species | I (95% CI) | Permutation null: mean (95th pct) | p (Holm) | Rule outcome |
|---|---|---|---|---|
| Apul | −0.21 (−0.71, 0.30) | −0.62 (−0.40) | 0.001 (0.003) | below 5%; CI includes 0 |
| Peve | −0.55 (−0.91, −0.18) | −0.77 (−0.47) | 0.13 (0.13) | upper bound < 0.05 |
| Ptuh | −0.40 (−0.79, −0.14) | −0.71 (−0.40) | 0.051 (0.10) | upper bound < 0.05 |

The upper bound is below the 5% threshold in Peve and Ptuh, so the rule's
`not supported` clause holds. In every species, adding the selected lncRNA
made held-out prediction worse on average than the nuisance-only model
(negative I). Apul's observed I is better than every permutation (null
maximum −0.24), so its selected pairs carry some reproducible association
beyond chance pairing, but not enough to improve prediction; Ptuh's is
borderline (p 0.051) and Peve's indistinguishable from the null.

Folds are highly variable: Apul has four folds at +0.72 to +0.80 and six at
−0.61 to −1.39 (both groups contain colonies from both sites); Peve ranges
−1.31 to +0.77 and Ptuh −2.18 to +0.19. Selection concentrates on few
lncRNAs: in Apul two lncRNAs (`lncRNA_5502`, `lncRNA_31024`) supply 68% of
the 1,000 selected pairs, and only 48 distinct lncRNAs are ever chosen (Peve
67, Ptuh 185). Pairs on `lncRNA_5502` give a net held-out gain; the
remaining two thirds of Apul's pairs lose more than that.

Sensitivity checks (descriptive, not permuted):

| Check | Apul I (CI) | Peve I (CI) | Ptuh I (CI) |
|---|---|---|---|
| C1 expression-matched isolated genes as predictors | 0.52 (0.28, 0.73) | 0.25 (0.07, 0.43) | 0.39 (0.23, 0.52) |
| C2 composition outliers excluded | −0.16 (−0.60, 0.31) | −0.53 (−0.90, −0.15) | −0.44 (−0.80, −0.12) |
| C3 Peve locus kept (data as delivered) | | −0.40 (−0.75, −0.07) | |

The benchmark is the clearest contrast: the same pipeline with isolated
genes as predictors improves held-out prediction by 25–52% in every species,
with intervals above 0. Distal lncRNA associations do not generalize the way
gene–gene associations do. Dropping composition outliers (C2) or keeping the
Peve locus (C3) does not change the picture.

**Caveats:** n is about 10 colonies per species; each fold tests on 2–4
samples, so per-fold I is noisy and the bootstrap over 10 fold values is
coarse. Selection on about 36 training samples with 297–1,317 predictors per
target overfits (the permutation null sits at −0.6 to −0.8), which the
held-out design is meant to expose; a less aggressive selection (higher
|r|, fewer targets, shrinkage) might give a different answer and would be a
new hypothesis. The median selected |r| of about 0.93 after nuisance
adjustment, concentrated on a few lncRNAs, is consistent with a shared
technical or broad expression axis rather than specific trans regulation;
lncRNA and gene counts come from the same libraries and the composition
covariates are proxies. lncRNA strand is unknown (D-014) and isolation relies
on incomplete gene models. This is follow-up on the same data as H08 and
H17, not an independent replication. Species is confounded with reference
quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*).

**Current Findings:** qualifies under CLAUDE.md §6 (b) and (c): the result
bounds the effect (held-out improvement upper bounds −0.18 and −0.14 in Peve
and Ptuh, against +0.07 to +0.73 for the gene benchmark) and answers the same
question as the lncRNA co-expression synthesis
(<https://robertslab.github.io/current-findings/reports/coral-lncrna-cis-coexpression/>,
H08, H17; H25 pending). Adding H26 to that report is pending.

**Outputs:** in `output/`
- `n_per_species.csv`: samples, features and isolated lncRNAs actually used
- `feasibility/`: counts used to complete the pre-registration
- `decision_per_species.csv`: I, interval, permutation p and decision per species
- `fold_improvement.csv`, `selected_targets.csv`: per-fold I_c and every selected pair with its held-out errors
- `permutation_null.csv`: the 1,000 permutation I values per species
- `improvement_vs_null.png`, `figure_observed.csv`: figure and its data (null in `permutation_null.csv`)
- `sensitivity_checks.csv`: C1–C3
- `verdicts.csv`: verdict

not supported
