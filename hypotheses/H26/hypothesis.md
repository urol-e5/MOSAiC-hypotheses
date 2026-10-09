---
id: H26
slug: distal-lncrna-heldout-prediction
title: Distal lncRNA–mRNA co-expression predicts gene expression in held-out colonies
status: proposed
tier: 2
layers: [lncrna, genes, annotation]
species: [Apul, Peve, Ptuh]
depends_on: [H08, H17]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Proposal from [docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md).
Not yet a complete pre-registration: see "Before moving to planned".

## Question

H08 found abundant strong lncRNA–mRNA edges, but shared libraries could
contribute. H17 showed that genomic proximity accounts for some
co-expression. Do distal associations reproduce outside the colonies used
to find them?

## Hypothesis and prediction

A subset of lncRNAs at least 10 kb from any annotated protein-coding gene
predicts expression of genes on other scaffolds in colonies not used to
select the associations, after accounting for season and measured library
composition.

## Data

Gene and lncRNA expression in each species, about 10 colonies. lncRNAs must
have at least 10 kb of assembled flanking sequence so scaffold ends do not
masquerade as isolation. Candidate partners lie on different scaffolds.

## Model

Outer leave-one-colony-out validation. Fixed expression filters;
normalization, transformations, nuisance coefficients, and pair selection
estimated from training samples only. Per fold, select up to 100 strongest
residual pairs with |r| >= 0.6 after adjusting for timepoint, colony, log
library size, and fraction of reads in the ten most abundant features
(composition proxies, not full RNA-quality measures). Compare held-out MSE
of a nuisance-only model with the same model plus the selected lncRNA,
marginalizing over the unseen colony effect. Equal weight per target gene
and per colony. Folds with no qualifying edges contribute zero improvement.
Null: repeat the entire selection pipeline after reassigning whole lncRNA
colony trajectories within site, preserving timepoint and missingness. Holm
correction across species.

## Decision rule

`supported`: in at least two species, >= 5% lower held-out MSE, a positive
improvement CI from a colony-block bootstrap, and Holm-adjusted permutation
p < 0.05. `not supported`: upper CI below 5% improvement in at least two
species. Otherwise `inconclusive`, including when matching leaves too few
distinct permutations.

## Known confounds and sensitivity checks

- Benchmark against expression-matched distant gene–gene pairs.
- Repeat after excluding composition-dominated libraries.
- Small training sets and scaffold fragmentation may leave few eligible
  pairs.
- Held-out success cannot rule out reproducible shared-library effects or
  prove trans regulation.

## Before moving to planned

- Fix the permutation and bootstrap counts and the minimum number of
  distinct permutations below which the result is inconclusive.
- Fix the rule for "composition-dominated" libraries.
- Compute estimate: the full selection pipeline is repeated per permutation;
  likely a raven target.

## Amendments
