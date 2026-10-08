---
id: H11
slug: thermal-history-stress-genes
title: Cumulative thermal exposure before sampling predicts expression of heat-stress orthologs
status: withdrawn
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

### Withdrawal (2026-10-07), before any expression data were analysed

**Status: withdrawn.** The exposure metric cannot vary independently of the
timepoint label in this data set, so the question ("beyond the timepoint
label") cannot be answered. Evidence from `exposure_check.R` (temperature and
nominal dates only; outputs in `output/`):

- The molecular colonies are at two sites, Mahana and Manava. Their monthly
  mean temperatures agree within 0.1 C all year; both have the warmest month
  in March 2020 (MMM 29.72 and 29.73 C).
- With the pre-registered MMM threshold, 30-day exposure is 0 at TP1, TP3
  and TP4 at both sites, and 0.19 (Mahana) vs 0.04 (Manava) degree-days at
  TP2. The +15-day shift gives 1.46 vs 1.37 at TP2 and 0 elsewhere; the
  −15-day shift gives 0.18 vs 0 at TP2 and 0 elsewhere.
- The Prediction's wording (degree-days above the climatological mean, 28.2 C
  at both sites) differs from the Model's MMM; it gives the same pattern: 0
  at TP1, TP3, TP4 and 27.5 vs 28.1 degree-days at TP2.
- Under any of these, exposure is a TP2 indicator, and the pre-registered
  within-timepoint check (across sites at the same timepoint) has no
  contrast. Logger coverage is also short at TP1 (16 of 30 days) and TP2 (24
  of 30).

Testing thermal history beyond season would need sites that differ
thermally, colony-level loggers, or a design with more timepoints; that
belongs in a new hypothesis. The stress-gene set was not used, but for any
successor: matching "heat shock", "heat-shock" or "chaperon" anywhere in the
three-way ortholog SwissProt name gives 21 groups (abbreviations HSP / HSF
were dropped because they match unrelated alternative names, e.g. hSFMBT,
CRHSP-24, hSPP2).
