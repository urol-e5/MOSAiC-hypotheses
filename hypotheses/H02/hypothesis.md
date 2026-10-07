---
id: H02
slug: species-temporal-plasticity
title: Transcriptional plasticity across the year ranks Acropora > Pocillopora > Porites
status: supported
tier: 1
layers: [genes]
species: [Apul, Peve, Ptuh]
depends_on: [H01]
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Do the three species differ in how much of their transcriptome changes across
the four seasonal timepoints, and does the order match life-history strategy
(competitive/weedy *Acropora*, intermediate *Pocillopora*, stress-tolerant
*Porites*)?

## Hypothesis and prediction

Faster-growing, less stress-tolerant species show more seasonal transcriptome
change. Prediction: number of timepoint-DE ortholog groups and the spread of
|log2 fold change| rank Apul > Ptuh > Peve.

## Data

Three-way ortholog groups only (so gene sets are the same size, 10,381 before
filtering), expression from `genes_by_ortholog()`. All samples with `has_genes`.

## Model

DESeq2 per species: `~ colony + timepoint`, likelihood-ratio test against
`~ colony`. Genes filtered as in H01. Benjamini-Hochberg FDR 0.05.
Secondary: for each ortholog group the maximum |LFC| among pairwise timepoint
contrasts; compare distributions across species with a Kruskal-Wallis test and
pairwise Wilcoxon with Holm correction.

## Decision rule

`supported` if the count of DE groups and the median max-|LFC| both follow
Apul > Ptuh > Peve, and the pairwise Wilcoxon tests for adjacent species are
significant at Holm-adjusted 0.05. `not supported` if either ordering is
reversed between any pair with a significant test. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Mapping rate and annotation completeness differ by species; Ptuh is mapped
  to *P. meandrina*. Sensitivity: restrict to ortholog groups with
  `avg_identity >= 60` and to groups with a SwissProt protein name.
- Sequencing depth differs. Report library-size distributions; sensitivity:
  downsample to the smallest species' median depth.
- Unequal n per timepoint. Report the design table.

## Amendments
