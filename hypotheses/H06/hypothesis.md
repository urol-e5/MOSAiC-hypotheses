---
id: H06
slug: seasonal-methylation-expression-coupling
title: Seasonal change in gene-body methylation tracks seasonal change in expression at the same genes
status: planned
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H04, H05]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

This is the core E5 epigenetic-linkage test: when a gene's methylation moves
between summer and winter, does its expression move with it?

## Hypothesis and prediction

Within-colony methylation change is weakly but positively coupled to
expression change. Prediction: per-gene delta-GBM (TP3 minus TP1, averaged
over colonies) correlates positively with delta-expression; the correlation is
stronger for genes that are differentially methylated.

## Data

Gene-level GBM from H05; colonies with both TP1 and TP3 in both layers.
Expected n is small (report it). Expression deltas from the H02/H03 fits.

## Model

Spearman rho(delta-GBM, delta-expression) per species with a colony-permutation
null (shuffle colony labels within species, 1000 times). Secondary: mixed model
`expr ~ gbm + (1|colony) + (1|gene)` on long-format data for the DM gene set.

## Decision rule

`supported` if rho > 0 with permutation p < 0.05 in at least two species and
the mixed-model GBM slope is positive with CI excluding zero in those species.
`not supported` if rho <= 0 in all three. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Very few colonies have all layers at both timepoints; power is the main
  risk. Report n before running and state in RESULT.md whether the test was
  adequately powered (simulate at the observed n).
- Methylation changes may be in cis-regulatory regions, not gene bodies.
  Sensitivity: repeat with 2 kb upstream windows.

## Amendments
