---
id: H14
slug: seasonal-energetics
title: Seasonal shifts in storage lipids and central metabolites track host biomass and calcification
status: inconclusive
tier: 4
layers: [lipidomics, metabolomics, physiology]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Do colonies that lose or gain tissue biomass across the year show matching
changes in storage lipids (triacylglycerols, wax esters) and energy
metabolites?

## Hypothesis and prediction

Energetic state is readable from the lipidome. Prediction: the ratio of
storage to membrane lipid classes correlates positively with
`Host_AFDW.mg.cm2` and `calc.umol.cm2.hr` within colony over time.

## Data

`lipidomics` (class assigned from lipid names), `metabolomics`, `physiology`;
samples with all three. Report n.

## Model

Lipid class totals per sample; storage:membrane ratio.
`lmer(ratio ~ scale(trait) + (1|colony))` per species and trait, plus a
within-colony (demeaned) correlation. Metabolites: PLS regression of
metabolite matrix on AFDW with permutation-tested Q2.

## Decision rule

`supported` if the storage:membrane slope on AFDW is positive with CI
excluding zero in at least two species, and PLS Q2 exceeds the permutation
95th percentile in those species. `not supported` if the slope is non-positive
in all species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Lipid class assignment from names is heuristic; publish the mapping table.
- Normalization of lipid intensities (per sample total vs per protein).
  Sensitivity: both.

## Amendments

### Amendment 1 (2026-10-08), before any H14 analysis was run

**Problem.** "Storage:membrane ratio" and the lipid classes were never
defined. The lipidome has TG, DG, CE, FA, LPC and Cer, with no wax esters,
PC or PE. H19 (Amendment 1) has since used a definition and asked H14 to
adopt or amend it. A within-sample ratio does not change with per-sample
normalization (per total or per protein), so the normalization sensitivity
check cannot differ from the primary. The PLS step leaves preprocessing,
cross-validation, number of components and the permutation scheme open.

**Change.** The original text above is kept; these replace it where they
conflict. The decision rule is unchanged.

- *Ratio*: log((TG + DG + CE) / (LPC + Cer)), summed intensities per
  sample, as in H19 (`output/lipid_class_map.csv`). FA is in neither.
- *Normalization sensitivity*: replaced by storage as a fraction of total
  lipid intensity, (TG + DG + CE) / all classes, logit-transformed. This is
  the per-sample-total normalized storage index.
- *Slope*: `lmer(ratio ~ scale(trait) + (1|colony))`, REML, Wald 95% CI
  (log-ratio units per SD of trait). Traits are on the raw scale (AFDW has
  negative values upstream). The decision uses AFDW; calcification is
  reported.
- *Within-colony correlation*: Pearson r of colony-demeaned ratio and trait,
  pooled; 95% CI from 2000 colony bootstraps. Reported, not in the
  decision.
- *PLS*: metabolites with > 20% missing values in the species are dropped;
  remaining missing values are set to half the metabolite's minimum;
  log2 transform; autoscale. `pls::plsr` with AFDW (centered and scaled) as
  response. Q2 = 1 − PRESS / SS from leave-one-colony-out cross-validation,
  taking the best Q2 over 1–3 components. Null: AFDW permuted across
  samples 1000 times, with the same procedure (including the best-of-1–3
  choice) on each permutation. "Exceeds the permutation 95th percentile" is
  judged on that null.

