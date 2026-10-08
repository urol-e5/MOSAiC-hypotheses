---
id: H08
slug: lncrna-mrna-coexpression-null
title: lncRNA-mRNA co-expression at a fixed correlation threshold exceeds a permutation null
status: supported
tier: 2
layers: [lncrna, genes]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

With about 40 samples per species, is the number of strongly correlated
lncRNA-mRNA pairs larger than noise alone produces?

## Hypothesis and prediction

Real co-regulation exists. Prediction: the observed count of pairs with
|r| >= threshold exceeds the 95th percentile of the null obtained by permuting
sample labels of the lncRNA matrix, at thresholds 0.8, 0.9, and 0.95.

## Data

`lncrna_<species>` and `genes_<species>`, samples with both layers. Features
filtered as in H01. Follows the framework in
`sr320/lncRNA-coexpression-explorer`, which found the published 0.99 cut sat
near the null with n = 5; here n is about 40.

## Model

Pearson r on vst values for all lncRNA x mRNA pairs. Null: 200 permutations of
sample order in the lncRNA matrix (preserving within-colony structure is NOT
possible for a full permutation; report also a within-timepoint permutation).
Observed vs null edge count at each threshold.

## Decision rule

`supported` if the observed count exceeds the null 95th percentile at all
three thresholds in all three species. `not supported` if the observed count
falls inside the null at |r| >= 0.9 in any species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Colony structure induces correlation. Sensitivity: residualize both layers
  on colony before computing r.
- lncRNA filtering already removed low-count features. Report counts.

## Amendments
