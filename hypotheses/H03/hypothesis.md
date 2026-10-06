---
id: H03
slug: conserved-seasonal-response
title: Seasonal expression responses are conserved across the three species at orthologous genes
status: planned
tier: 1
layers: [genes]
species: [Apul, Peve, Ptuh]
depends_on: [H02]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

When a gene goes up or down between austral summer (TP1) and winter (TP3) in
one species, does its ortholog do the same in the others?

## Hypothesis and prediction

A shared cnidarian seasonal program exists. Prediction: TP1-vs-TP3 log2 fold
changes at three-way orthologs are positively correlated between every species
pair, and the concordant genes are enriched for a consistent set of GO-slim
terms (expected: metabolism, stress response, cell cycle).

## Data

Three-way orthologs; DESeq2 contrasts TP3 vs TP1 from the H02 fits (same
filtering, same colony blocking). GO-slim terms from `orthologs_three_way`.

## Model

Spearman rho of shrunken LFCs (apeglm) for each of the three species pairs.
Null distribution by permuting ortholog assignments (1000 permutations).
Enrichment: Fisher exact test of GO-slim terms among groups concordantly DE
(same sign, FDR < 0.05 in both species) vs all tested groups; BH FDR.

## Decision rule

`supported` if rho > 0.2 with permutation p < 0.01 in all three pairs and at
least three GO-slim terms are enriched (FDR < 0.05) in all three pairwise
concordant sets. `not supported` if any rho <= 0 or no term is shared.
Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Ortholog assignment errors dilute correlation toward zero. Sensitivity:
  restrict to `avg_identity >= 60`.
- TP1 and TP3 differ in more than temperature (light, nutrients). This test
  cannot attribute cause; say so in RESULT.md.

## Amendments
