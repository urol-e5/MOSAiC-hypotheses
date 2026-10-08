---
id: H09
slug: symbiont-state-expression-modules
title: Symbiont density and chlorophyll predict host gene-expression modules
status: not supported
tier: 3
layers: [genes, physiology]
species: [Apul, Peve, Ptuh]
depends_on: [H01]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Does variation in symbiont state (cell density, chlorophyll, calcification
rate) explain coordinated host expression beyond what colony and season
explain?

## Hypothesis and prediction

Host transcriptome modules track symbiont physiology. Prediction: at least one
WGCNA module per species whose eigengene is associated with `cells.cm2` or
`chla.ug.cm2` in a mixed model with colony random effect, enriched for
metabolic GO-slim terms.

## Data

`genes_<species>` and `physiology`, samples with both. Physiology traits:
`cells.cm2`, `chla.ug.cm2`, `calc.umol.cm2.hr`, `Host_AFDW.mg.cm2`.

## Model

WGCNA signed network on vst expression (soft threshold chosen by scale-free
fit), modules with minimum size 30. For each module eigengene:
`lmer(ME ~ scale(trait) + timepoint + (1|colony))`, one model per trait,
BH FDR across module x trait tests. Enrichment of GO-slim terms per
significant module by Fisher test.

## Decision rule

`supported` if, in all three species, at least one module has a trait slope
with FDR < 0.05 and CI excluding zero, and that module shows at least one
enriched GO-slim term (FDR < 0.1). `not supported` if no module in any species
passes. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Symbiont traits are seasonal; timepoint is in the model to separate them,
  which also removes shared seasonal signal. Sensitivity: refit without
  timepoint and report both.
- Physiology missingness. Report n per species after intersection.

## Amendments
