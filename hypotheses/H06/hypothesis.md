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

### Amendment 1 (2026-10-07), before any H06 analysis was run

**Problem.** The Model section pairs a colony-averaged statistic (rho between
per-gene delta-GBM and delta-expression, each averaged over colonies) with a
null that shuffles colony labels. A mean over colonies does not depend on how
colonies are paired, so every permutation reproduces the observed rho and the
test cannot reject. Two terms were also undefined: how per-colony
delta-expression is obtained (the H02/H03 DESeq2 fits give only pooled
fold changes, and are restricted to three-way orthologs) and what
"differentially methylated" means.

**Change.** The original text above is kept; these replace it where they
conflict.

- *Deltas.* For each colony with TP1 and TP3 in both layers:
  dGBM_c = GBM(TP3) − GBM(TP1) per gene (gene-body mean percent, >= 5 CpGs,
  as H05), and dExpr_c = vst(TP3) − vst(TP1) per gene (H01 filter, vst on
  samples with both layers). All genes with GBM, not only orthologs.
- *Statistic.* Per-colony coupling: rho_c = Spearman(dGBM_c, dExpr_c) across
  genes, and T = mean over colonies of rho_c. In the decision rule, "rho"
  means T.
- *Null.* Pair each colony's dGBM with another colony's dExpr: permute colony
  labels in the expression layer (1000 permutations), recompute T. One-sided
  p = (1 + #{T_perm >= T}) / 1001. This tests within-colony coupling beyond
  the seasonal shift that all colonies share.
- *DM genes.* The top 10% of genes by |mean over colonies of dGBM_c|, per
  species. Used for the "stronger in DM genes" comparison and for the mixed
  model, which is fit on TP1 and TP3 samples of the paired colonies.
- The originally stated colony-averaged rho is reported as a descriptive
  number with a bootstrap CI; it does not enter the decision.

The decision rule text is unchanged.
