---
id: H01
slug: colony-vs-season-variance
title: Colony identity explains more gene-expression variance than season in all three species
status: planned
tier: 1
layers: [genes]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

How is transcriptome variance partitioned among colony (genotype plus
microhabitat), timepoint (season), and site, in each species?

## Hypothesis and prediction

Colony is the dominant source of expression variance. If true, the median
fraction of variance attributed to colony across genes exceeds the median
fraction attributed to timepoint, in each species. If false, timepoint equals
or exceeds colony in at least one species.

## Data

`genes_<species>` for all three species; all samples with `has_genes`. Expected
n: Apul 40, Peve 38, Ptuh 39. Genes filtered to >= 10 counts in >= 25% of
samples. Variance-stabilized counts (DESeq2 `vst`).

## Model

`variancePartition::fitExtractVarPartModel` with
`~ (1|colony) + (1|timepoint) + (1|site)` per gene, per species. Site is
colony-level, so its share is bounded by colony's; report both. Bootstrap
genes (1000 resamples) for 95% intervals on the median fractions.

## Decision rule

`supported` if median(colony fraction) > median(timepoint fraction) with
non-overlapping bootstrap 95% CIs in all three species. `not supported` if
timepoint >= colony in any species with non-overlapping CIs. Otherwise
`inconclusive`.

## Known confounds and sensitivity checks

- Site is nested in colony; a large site share would appear as colony share.
  Sensitivity: refit with site dropped and compare colony fractions.
- Reference quality differs by species. Sensitivity: repeat on three-way
  orthologs only.
- Unequal timepoint coverage per colony. Report the design table per species.

## Amendments
