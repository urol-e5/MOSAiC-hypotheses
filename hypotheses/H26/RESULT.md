# H26 result

**Status:** not supported

**Corrected run:** 2026-10-11 to 2026-10-12 on raven against MOSAiC commit
`86432e3` (see `config/upstream.lock.yml`). The full rerun completed at
04:19 PDT on 2026-10-12 with exit status 0, after about 20 h 30 min with
47 workers and one OpenBLAS thread per worker. R 4.3.3, DESeq2 1.42.1,
lme4 1.1-37; 1,000 permutations per species and all checks C1–C3 completed.

**Normalization correction:** held-out median-of-ratios size factors now
use the training geometric means and training scaling constant. For local
VST fits, the integration grid, noise term, and log-scale calibration are
also frozen on training data. The original implementation independently
recentered held-out factors and recalibrated local VST fits on held-out data.
The dated amendment in `hypothesis.md` records this implementation repair;
the registered selection procedure, resampling, and decision rule are
unchanged. The [original result](RESULT-original-2026-10-10.md) is preserved
as a historical record. The corrected verdict remains `not supported`. The frozen normalization
helpers were subsequently moved unchanged to `R/expression.R` for reuse by
H22; the MD5 below identifies the H26 notebook at the time of its rerun.

All 25 raw inputs matched the committed lock; 18 H26 input/helper checksums
matched the desktop checkout. The full reproduction gate passed with strict
failure handling on both desktop and raven. Code used for the rerun has MD5
`86a785c5d8e072834f4fdfdc9b51965b`. The isolated run, log, and species
checkpoints remain at `/home/sr320/h26-normalization-2026-10-11` on raven.

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
| Apul | −0.147 (−0.623, 0.330) | −0.582 (−0.378) | 0.001 (0.003) | below 5%; CI includes 0 |
| Peve | −0.359 (−0.739, 0.0009) | −0.543 (−0.318) | 0.105 (0.170) | upper bound < 0.05 |
| Ptuh | −0.447 (−0.839, −0.174) | −0.734 (−0.407) | 0.085 (0.170) | upper bound < 0.05 |

The upper bound is below the registered 5% threshold in Peve and Ptuh, so
`not supported` still holds. In every species, adding the selected lncRNA
made held-out prediction worse on average (negative I). Apul's observed I
is better than every permutation (null maximum −0.241), indicating some
reproducible association beyond chance pairing without a positive mean
prediction gain. Peve and Ptuh do not pass the adjusted permutation test.
Peve's interval now narrowly includes zero; the corrected result does not
establish worsening in Peve, but still bounds improvement below 5%.

Folds are highly variable: Apul ranges from −1.08 to +0.82, Peve from −1.10
to +0.80, and Ptuh from −2.25 to +0.17. Selection concentrates on few
lncRNAs: two Apul lncRNAs (`lncRNA_5502`, `lncRNA_31024`) supply 683 of
1,000 selected pairs, and only 48 distinct Apul lncRNAs are chosen (Peve
66, Ptuh 184).

Sensitivity checks (descriptive, not permuted):

| Check | Apul I (CI) | Peve I (CI) | Ptuh I (CI) |
|---|---|---|---|
| C1 expression-matched isolated genes as predictors | 0.535 (0.301, 0.741) | 0.254 (0.063, 0.445) | 0.355 (0.184, 0.488) |
| C2 composition outliers excluded | −0.085 (−0.525, 0.377) | −0.342 (−0.722, 0.025) | −0.514 (−0.892, −0.171) |
| C3 Peve locus kept (data as delivered) | | −0.226 (−0.589, 0.110) | |

The gene benchmark improves held-out prediction by 25–54% in every species,
with intervals above zero. The selected distal lncRNA associations do not
provide comparable prediction gains in this pipeline. C2 and C3 also retain
negative mean lncRNA improvements, although several intervals include zero
and C3 does not bound Peve improvement below 5%.

**Caveats:** n is about 10 colonies per species; each fold tests on 2–4
samples, and the bootstrap over 10 fold values is coarse. Training on about
36 samples with 297–1,317 candidate lncRNAs per target overfits (permutation
null means −0.54 to −0.73), which the held-out design exposes. A different
selection or shrinkage method would require a new hypothesis. The large
selected training correlations and concentration on few lncRNAs are
consistent with shared technical or broad expression structure; lncRNA and
gene counts come from the same libraries, and composition covariates are
proxies. lncRNA strand is unknown (D-014) and isolation relies on incomplete
gene models. The completed run logged two model-convergence warnings; fits
that errored were dropped under the registered implementation, while all
30 observed folds retained 100 target evaluations and all 3,000 null draws
were finite. This follows up H08 and H17 on the same data and is not an
independent replication. Species is confounded with reference quality
(Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*).

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-lncrna-cis-coexpression/>
(lncRNA co-expression synthesis, v0.3, with H08, H17, H25) covers the original
H26 run under CLAUDE.md §6(b) and (c). This corrected result supersedes its
H26 numbers; the synthesis should cite these updated estimates before
republication. Peve and Ptuh upper bounds remain below 5% (0.0009 and −0.174).

**Outputs:** in `output/`

- `n_per_species.csv`: samples, features and isolated lncRNAs actually used
- `feasibility/`: counts used to complete the pre-registration
- `decision_per_species.csv`: I, interval, permutation p and decision per species
- `fold_improvement.csv`, `selected_targets.csv`: per-fold I_c and selected pairs with held-out errors
- `permutation_null.csv`: the 1,000 permutation I values per species
- `improvement_vs_null.png`, `figure_observed.csv`: figure and its data
- `sensitivity_checks.csv`: C1–C3
- `verdicts.csv`: corrected verdict

not supported
