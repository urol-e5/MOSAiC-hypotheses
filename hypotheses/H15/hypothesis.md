---
id: H15
slug: methylation-persistence
title: Seasonal gene-body methylation changes persist after temperature reverses, while expression changes revert
status: inconclusive
tier: 2
layers: [cpg, genes, temperature, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H04, H05, H06]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q1 (persistence and decay of marks). When the reef warms
again after winter, does an induced methylation state wash out at the pace
of the environment, or does it persist (hysteresis)? How does that compare
with expression measured in the same colonies?

## Hypothesis and prediction

Methylation is a slower, more persistent channel than transcription.
Between TP1 (Jan, summer) and TP3 (Sep, winter) genes shift in both layers.
By TP4 (Nov) temperature has partly returned toward summer. Prediction: the
fraction of the TP1→TP3 shift still present at TP4 (persistence, P) is
larger for gene-body methylation than for expression of the same genes, and
larger than the fraction of the temperature shift still present at TP4.

If false: P for methylation is no larger than P for expression, meaning the
two layers decay together and methylation carries no extra memory on this
timescale.

Secondary (relates to Q4): the fraction of shifted genes whose TP4 value
overshoots the TP1 baseline in the opposite direction (P < 0, "rebound"),
per layer. Descriptive only.

## Data

- Gene-level GBM as in H05 (gene-body mean percent methylation, >= 5 CpGs
  at >= 10x), `cpg_<species>` + `gene_coords_<species>`.
- `genes_<species>`, vst on samples with both layers.
- Colonies with TP1, TP3 and TP4 in both layers. From `config/design.csv`
  expected about 9 (Apul), 9 (Peve), 6–7 (Ptuh). Report actual n.
- `temperature_daily`: 30-day site mean before each nominal date (D-006),
  giving temperature persistence P_T = (T4 − T1) / (T3 − T1) per site.

## Model

Per species, per layer (GBM, expression), on the same gene set (genes with
both a GBM value and passing the H01 expression filter):

1. Gene selection without regression-to-the-mean: for each colony c, select
   "shifted" genes as the top 10% by |mean over the *other* colonies of
   (x_TP3 − x_TP1)| (leave-one-colony-out, LOCO). Call that LOCO mean D_g.
2. For colony c on its selected genes: b31_c = slope of (x_TP3 − x_TP1) on
   D_g, and b41_c = slope of (x_TP4 − x_TP1) on D_g (OLS through origin).
   Both slopes share the same predictor, so its noise attenuates them
   equally.
3. Persistence P = mean over colonies of b41_c / mean over colonies of
   b31_c. P = 0 is full reversion, 1 is full persistence, < 0 is rebound.
4. Contrast: dP = P_GBM − P_expr. 95% CI by colony bootstrap (2000
   resamples, resampling colonies and recomputing LOCO selection inside
   each resample).
5. Context: P_T per site, averaged over the species' colonies.

Multiple testing: one primary contrast per species; no per-gene tests.
p-values (bootstrap) are Holm-corrected across the three species for
reporting; the decision uses CIs.

## Decision rule

- `supported` if dP > 0 with 95% CI excluding 0 in at least two species,
  and in those species P_GBM > mean P_T.
- `not supported` if the dP point estimate is <= 0 in at least two species.
- `inconclusive` otherwise, including when b31 for GBM has a CI that
  includes 0 (no detectable seasonal methylation shift to persist) in two
  or more species.

## Known confounds and sensitivity checks

- Per-gene GBM change is small and coverage-limited; noisier methylation
  inflates neither P (shared predictor) but does widen its CI. Sensitivity:
  restrict to genes with >= 20 CpGs.
- TP4 is two months after TP3 and is not a full return to summer; P is
  timescale-specific (about 2 months). State this.
- Selection threshold: repeat with top 5% and top 20%.
- Ptuh n is about 6–7 colonies and is mapped to *P. meandrina*; Peve
  reference N50 0.17 Mb. Repeat on three-way orthologs only.
- n is about 10 colonies per species at most; fewer here.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
