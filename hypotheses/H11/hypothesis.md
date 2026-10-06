---
id: H11
slug: thermal-history-stress-genes
title: Cumulative thermal exposure before sampling predicts expression of heat-stress orthologs
status: planned
tier: 3
layers: [genes, temperature]
species: [Apul, Peve, Ptuh]
depends_on: [H03]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Does the logger-measured temperature history at a colony's site explain
expression of heat-shock and chaperone genes beyond the timepoint label?

## Hypothesis and prediction

Thermal history, not just season, drives stress-gene expression. Prediction:
a positive slope of HSP / chaperone ortholog expression on accumulated
degree-days above the site's climatological mean in the 30 days before each
timepoint, strongest in Apul.

## Data

`temperature_daily` (Manava, Hilton, Mahana), `design.csv` site per colony,
`genes_<species>` restricted to three-way orthologs whose SwissProt name
matches heat-shock protein, chaperone, or HSF. Nominal timepoint dates are
mid-month (decision D-006).

## Model

Exposure metric: sum over the 30 days before the nominal date of
max(0, daily_mean - site_MMM), where site_MMM is the mean of the warmest
month in the logger record. `lmer(vst ~ exposure + (1|colony) + (1|gene))`
per species on the stress-gene set; also a gene-set score (mean z) version.

## Decision rule

`supported` if the exposure slope is positive with a CI excluding zero in all
three species and the Apul slope is the largest. `not supported` if the slope
is negative or zero in all species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Exposure is confounded with timepoint (only four values per site).
  Sensitivity: within-timepoint comparison across sites only.
- Nominal dates. Sensitivity: shift the window by +/- 15 days.
- Logger record ends 2020-11-07, before the nominal TP4 date. Use the last
  available 30 days and say so.

## Amendments
