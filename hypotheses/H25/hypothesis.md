---
id: H25
slug: distal-coexpression-class-equivalence
title: Beyond 2 kb, local co-expression is practically equivalent for lncRNA–gene and gene–gene pairs
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

H17 supported cis co-expression, but its descriptive gene–gene comparison
showed similar correlations for lncRNA–gene pairs beyond 2 kb. H08
established abundant co-expression without showing lncRNA specificity. Is
local co-expression beyond 2 kb a property of transcript class at all?

## Hypothesis and prediction

At matched distances from 2–100 kb, lncRNA–gene and gene–gene pairs have
practically equivalent correlations. Shared local transcriptional structure
is one possible explanation; chromatin domains are not measured here.

This formalizes a pattern already seen in H17's secondary results, so it is
exploratory follow-up on the same data. Confirmation needs independent
colonies or a new year.

## Data

Gene and lncRNA expression and coordinates in each species (38–40 samples;
about 10 colonies). Exclude overlapping pairs and pairs within 2 kb.

## Model

Residualize both layers on colony and timepoint. Within the 2–10, 10–50, and
50–100 kb bins, match the two pair classes for distance, expression mean and
variance, and scaffold where possible. Statistic: equally weighted across
bins, difference in median residual correlation (lncRNA–gene minus
gene–gene). Intervals from a whole-colony bootstrap; genomic dependence
assessed separately with a scaffold-block bootstrap. Equivalence margin
−0.05 to +0.05; two one-sided tests per species, Holm-corrected across
species.

## Decision rule

`supported`: both one-sided equivalence tests pass after Holm correction in
every species. `not supported`: in any species, an interval wholly beyond
either margin. Otherwise `inconclusive` (failure to establish equivalence is
not evidence for a transcript-class difference).

## Known confounds and sensitivity checks

- Repeat without timepoint residualization.
- Restrict to longer scaffolds.
- Require concordant conclusions under colony and scaffold resampling.
- lncRNA strand is unknown (D-014) and gene models are incomplete.

## Before moving to planned

- Fix the matching procedure (calipers, ratio) and bootstrap replicate counts.
- Fix the scaffold-length cutoff for the restricted check.

## Amendments
