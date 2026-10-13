---
id: H22
slug: held-out-molecular-forecast
title: Expression at one timepoint forecasts next-timepoint physiology at held-out sites better than physiology alone
status: not supported
tier: 4
layers: [genes, physiology]
species: [Apul, Peve, Ptuh]
depends_on: [H09]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q10 (held-out predictive performance). Can a molecular
signature trained on one set of colonies forecast performance in colonies
it never saw, under conditions it never saw?

There is no independent cohort in MOSAiC. Two proxies are used: a held-out
site (different nutrient and thermal regime, different colonies), and a
held-out species via three-way orthologs. Both are weaker than a true
independent cohort; RESULT.md must say so.

## Hypothesis and prediction

Expression carries information about future performance beyond current
physiology. Prediction: in leave-one-site-out validation, a model using
current physiology plus expression predicts next-timepoint Host AFDW and
calcification better (higher out-of-sample R²) than current physiology
plus timepoint alone.

If false: the molecular model adds nothing out of sample (dR2 <= 0).

## Data

- `genes_<species>` vst, three-way orthologs (so the same features exist
  in all species); `physiology` colony×timepoint means of
  `Host_AFDW.mg.cm2` and `calc.umol.cm2.hr`.
- Rows: colony × transition (t → t+1) with expression at t and physiology
  at t and t+1. Expected about 25–30 rows per species, from three sites.

## Model

1. Baseline: `y[t+1] ~ y[t] + timepoint`, OLS.
2. Molecular: baseline + top 20 PCs of expression (PCA fit on training
   folds only) with elastic net (alpha 0.5; lambda chosen by inner
   leave-one-colony-out CV within the training sites).
3. Outer CV: leave one site out. All rows of a held-out colony are in the
   test fold. Out-of-sample R² pooled over the three folds; dR2 = R²_mol −
   R²_base.
4. Null: permute y[t+1] among colonies within the training data and refit
   (200 permutations); p = proportion of null dR2 >= observed.
5. Secondary (cross-species transfer): train on one species, test on each
   other, same features. Descriptive; no decision.

Multiple testing: two traits per species, BH within species.

## Decision rule

- `supported` if dR2 > 0 with BH q < 0.05 for at least one trait in at
  least two species.
- `not supported` if dR2 <= 0 for both traits in at least two species.
- `inconclusive` otherwise.

## Known confounds and sensitivity checks

- Three sites means three folds of 3–4 colonies; out-of-sample R² is noisy.
  Report fold-level R² and a leave-one-colony-out version as sensitivity.
- Site is confounded with nutrient and temperature regime, which is the
  point of using it as "novel conditions", but site imbalance (Apul 32 /
  44 / 46 physiology samples) changes fold sizes. Report per fold n.
- Data leakage checks: PCA, scaling and lambda all fit inside training
  folds only; a test asserts this in `analysis.qmd`.
- Spawning around TP4 may dominate the TP3→TP4 change in Apul.
  Sensitivity: drop that transition.
- Species confounded with reference quality, which matters for the
  cross-species transfer secondary.
- n is about 10 colonies per species.

## Amendments

### Amendment 1 (2026-10-08), before any H22 analysis was run

**Problem.** The Model assumed three sites. The colonies with expression
data are at two sites, 5 colonies each per species (Mahana and Manava;
H11 withdrawal), and site is confounded with nutrient (Manava high, Mahana
low). A training fold therefore has about 15 rows from 5 colonies, which
cannot support 20 principal components, and several details were not fixed.

**Change.** The original text above is kept; these replace it where they
conflict. The decision rule is unchanged.

- *Outer CV*: two folds (hold out one site, train on the other). Holding
  out a site is also holding out a nutrient regime.
- *Features*: three-way ortholog vst (H01 filter, vst on all samples with
  `has_genes`), centered on the training rows; PCA on the training rows
  only, k = min(20, training rows − 1) components; test rows projected.
- *Molecular model*: `glmnet`, alpha 0.5, with y[t] and timepoint dummies
  unpenalized (penalty factor 0) and the PCs penalized; lambda = lambda.min
  from leave-one-colony-out CV within the training site.
- *Responses*: colony×timepoint means of `Host_AFDW.mg.cm2` and
  `calc.umol.cm2.hr` on the raw scale (AFDW has negative values, so no log).
- *Out-of-sample R²*: pooled over the two test folds,
  1 − SSE / Σ(y − mean of all test y)²; dR2 = R²_mol − R²_base.
- *Null*: within each transition, permute y[t+1] among the training
  colonies (independently per transition and fold), refit both models,
  score on the unpermuted test fold; 200 permutations;
  p = (1 + #{null dR2 >= observed}) / 201.
- *Sensitivities*: leave-one-colony-out outer CV (inner CV leave-one-colony-
  out among the remaining 9), and dropping the TP3→TP4 transition.
- *Cross-species transfer*: genes z-scored within species and y z-scored
  within species before training on one species and testing on another.

### Amendment 2 (2026-10-12): fit all predictive preprocessing on training data

The original results are known. Amendment 1's all-samples expression filter
and VST allowed held-out predictors to influence the fitted preprocessing.
This methodological correction supersedes that feature-preparation clause
before the corrected rerun. The original text and decision rule are retained.

- Start from unfiltered, rounded three-way ortholog counts. In each outer
  fold, apply the H01 count filter to the unique training sample IDs only,
  estimate size factors and the DESeq2 dispersion trend from those samples,
  and apply the frozen training scale and VST to held-out samples. The
  shared frozen transformation uses the full training feature set for the
  dispersion fit. Centering, any gene standardization, and PCA also use
  training samples only; k is capped by 20, training rows − 1, and retained
  feature count. Rows lacking paired physiology remain excluded.
- Inner leave-one-colony-out validation repeats this preprocessing using
  its own training colonies. Since feature sets and PCs may differ among
  inner folds, select a penalty **fraction** rather than reuse one PCA
  representation: 100 fractions logarithmically spaced from 1 to a minimum
  of 0.01 when the outer training design has more variables than rows,
  otherwise 0.0001 (the original glmnet default). Apply this same fraction
  grid to each fit's own training-derived maximum lambda. Use glmnet's
  interpolated predictions on its corresponding path, pool squared errors over inner
  validation rows (as in the original `grouped = FALSE` choice), and choose
  the fraction with lowest MSE; ties choose the largest fraction. Apply that
  fraction to the outer training fit. Alpha remains 0.5 and nuisance terms
  remain unpenalized. Outer held-out responses never inform tuning; inner
  validation responses are used only to score training-fitted models.
- Preprocessing is deterministic and independent of the response, so it
  is cached per fold and reused under the 200 response permutations. Both
  baseline and molecular models and inner penalty selection are refitted
  for every permutation. This retains the registered null and p-value rule.
- Cross-species transfer remains descriptive. Align raw ortholog IDs,
  then filter, normalize, transform, and standardize genes using the source
  species' training rows only. Standardize both response columns with the
  source training mean and SD and apply those constants to target rows.
  Target species data no longer fit their own gene or response scaling.
- Save fold sample/feature counts and penalty fractions with predictions.
  Regression tests perturb held-out counts and responses to verify that
  training representations and selected penalty fractions stay unchanged.

The corrected primary, both sensitivity analyses, and descriptive transfer
are rerun before updating `RESULT.md`. The original result is retained as
a historical record. This is a correction on an already analysed dataset,
not an independent replication or a new pre-registration.

The corrected full run completed on 2026-10-12 with exit status 0. The
primary verdict is `not supported`; both sensitivity verdicts remain
`inconclusive`. Updated estimates and the archived original report are
linked from `RESULT.md`.
