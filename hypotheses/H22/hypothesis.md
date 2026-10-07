---
id: H22
slug: held-out-molecular-forecast
title: Expression at one timepoint forecasts next-timepoint physiology at held-out sites better than physiology alone
status: planned
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

(Leave empty. Dated entries only, added if the decision rule has to change.)
