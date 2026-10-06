---
id: H14
slug: seasonal-energetics
title: Seasonal shifts in storage lipids and central metabolites track host biomass and calcification
status: planned
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
