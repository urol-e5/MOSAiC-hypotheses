---
id: H04
slug: methylation-stability
title: DNA methylation is more stable within colonies over time than gene expression
status: inconclusive
tier: 2
layers: [cpg, genes]
species: [Apul, Peve, Ptuh]
depends_on: [H01]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Is the CpG methylome a colony-specific, temporally stable signal, or does it
track season the way expression does?

## Hypothesis and prediction

Methylation carries colony identity more strongly than expression does.
Prediction: the intraclass correlation for colony is higher for percent
methylation than for expression, and timepoint explains a smaller share of
methylome than transcriptome variance.

## Data

`cpg_<species>` (sites with >= 10x in all samples) and `genes_<species>`,
restricted to samples with both `has_cpg` and `has_genes`. Report n per
species after intersection.

## Model

Per species: PERMANOVA (`vegan::adonis2`, Bray-Curtis on expression vst,
Euclidean on methylation percent) with `~ colony + timepoint`, 999
permutations, strata = colony for the timepoint term. Variance partition as in
H01 on both layers; compare median colony fraction between layers with a
paired bootstrap over features.

## Decision rule

`supported` if PERMANOVA R2(colony) is higher for methylation than expression
in all three species and median colony fraction (variancePartition) is higher
for methylation with non-overlapping 95% CIs. `not supported` if the reverse
holds in any species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Methylation filter (10x in all samples) biases toward well-covered,
  high-methylation gene bodies. Sensitivity: repeat on CpGs stratified by
  mean methylation tercile.
- Fewer CpG samples (Ptuh 32). Sensitivity: subsample expression to the same
  sample set, which the intersection already enforces.

## Amendments
