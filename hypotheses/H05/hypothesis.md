---
id: H05
slug: gene-body-methylation-expression
title: Gene-body methylation is positively associated with expression level and negatively with its temporal variability
status: supported
tier: 2
layers: [cpg, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H04]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Does the classic invertebrate gene-body methylation (GBM) pattern hold in these
corals: heavily methylated genes are highly, stably expressed?

## Hypothesis and prediction

GBM marks housekeeping-like genes. Prediction: mean GBM correlates positively
with mean expression and negatively with the coefficient of variation of
expression across timepoints, after controlling for expression level.

## Data

CpG matrices aggregated to gene bodies using the GFF files in the manifest
(`gff_<species>`; gene features). Genes with >= 5 covered CpGs. Expression
from `genes_<species>`, same samples as H04.

## Model

Per species, per gene: mean GBM (%), mean vst expression, CV of per-timepoint
colony-mean expression. Spearman rho(GBM, mean expression). Then
`lm(cv ~ ns(mean_expr, 3) + gbm)` and report the standardized GBM coefficient
with 95% CI. Also a binned view (GBM deciles).

## Decision rule

`supported` if rho(GBM, mean expression) > 0.2 and the GBM coefficient on CV
is negative with a CI excluding zero, in all three species. `not supported` if
either sign is reversed with a CI excluding zero in any species. Otherwise
`inconclusive`.

## Known confounds and sensitivity checks

- CpG coverage filter enriches for already-methylated regions. Sensitivity:
  rerun with a lower per-gene CpG threshold (>= 2).
- GFF gene models differ in quality by species. Report genes-with-GBM counts.

## Amendments
