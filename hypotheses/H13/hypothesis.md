---
id: H13
slug: multiomics-latent-factors
title: A single latent factor spanning all omics layers separates summer from winter samples
status: not supported
tier: 4
layers: [genes, mirna, lncrna, cpg, metabolomics, lipidomics]
species: [Apul, Peve, Ptuh]
depends_on: [H01, H04]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

When all molecular layers are modeled jointly, is season or colony the first
axis of shared variation, and which layers load on it?

## Hypothesis and prediction

Season is the dominant shared signal across layers. Prediction: MOFA2 factor 1
separates TP1/TP2 from TP3/TP4 (AUC > 0.8) with non-trivial variance explained
in at least three layers; a later factor separates colonies.

## Data

All six molecular layers per species, samples present in all of them (the
`has_*` flags). Expected n is small for the full intersection; report it and
run MOFA2 with missing views allowed as the primary analysis, full
intersection as sensitivity.

## Model

MOFA2, 10 factors, top 5000 most variable features per layer (all miRNAs).
Per factor: variance explained per layer; AUC of factor value for
summer-vs-winter; ICC for colony.

## Decision rule

`supported` if, in all three species, the factor with the highest total
variance explained has summer/winter AUC > 0.8 and loads (> 5% variance) on
at least three layers. `not supported` if the top factor is colony-dominated
(ICC > 0.7) with AUC < 0.6 in all species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Different sample sets per layer. Report the overlap matrix from the QC
  report.
- Metabolomics and lipidomics are pooled across species; split by sample id.

## Amendments
