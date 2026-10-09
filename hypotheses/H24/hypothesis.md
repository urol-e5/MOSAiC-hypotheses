---
id: H24
slug: ortholog-gbm-rank-conservation
title: Orthologs retain similar gene-body methylation ranks across species
status: proposed
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H05]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Proposal from [docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md).
Not yet a complete pre-registration: see "Before moving to planned".

## Question

H05 supported the same GBM–expression relationship in all three species, but
did not establish whether the same genes occupy the methylated portion of
each genome.

## Hypothesis and prediction

Matched orthologs have more similar GBM ranks across species than unrelated
genes matched for expression, gene length, and CpG count. This tests
conservation of gene identity, not the GBM–expression correlation again.

## Data

The common three-way ortholog set used by H23; about 10 colonies per species.

## Model

Mean GBM per gene = average within colony, then equally across colonies.
Spearman correlation of GBM ranks for all three species pairs. Null: 2,000
ortholog-label permutations constrained within prespecified bins of mean
expression, gene length, and CpG count. CIs by resampling whole colonies
within species and site. Holm correction across the three pairwise
permutation p-values.

## Decision rule

`supported`: rho > 0.30, colony-bootstrap CI above zero, and Holm-adjusted
p < 0.05 for all three species pairs. `not supported`: any pair with its CI
entirely below zero (contradicts universal conservation). Otherwise
`inconclusive`. The 0.30 threshold is a proposed minimum effect, not an
estimate from these data.

## Known confounds and sensitivity checks

- Repeat with at least 20 CpGs, high-identity annotated orthologs, and equal
  numbers of sampled CpGs per gene.
- The methylation matrices carry no coverage (D-015), so sequencing depth
  cannot be equalized.
- Rank conservation would not establish conservation of a causal regulatory
  mechanism.

## Before moving to planned

- Define the matching bins and the bin-merging rule for sparse strata.
- Fix the bootstrap replicate count.

## Amendments
