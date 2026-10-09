---
id: H27
slug: its2-profile-density-trajectories
title: Colonies with different stable ITS2 profiles follow different seasonal symbiont-density trajectories
status: proposed
tier: 3
layers: [its2, physiology]
species: [Peve, Ptuh]
depends_on: [H10]
created: 2026-10-08
author: Steven Roberts (plan drafted with Claude)
---

Proposal from [docs/follow-up-hypotheses.md](../../docs/follow-up-hypotheses.md).
Not yet a complete pre-registration: see "Before moving to planned".

## Question

H10 supported colony-associated ITS2 composition in all species. Its
secondary genus comparison tested average physiology, not profile-specific
seasonal trajectories. Can stable symbiont identity coexist with different
seasonal responses?

## Hypothesis and prediction

Colonies retaining different ITS2 profiles differ in their seasonal change
in symbiont cell density.

## Data

Porites and Pocillopora (Acropora has too little profile diversity). ITS2
and physiology joined through the loaders. H10 used 45 colonies per species;
the usable joint subset must be counted before analysis.

Stable colony: same dominant profile at every observed timepoint, at least
three paired timepoints, dominant relative abundance >= 0.8 at each.
Eligible profile: at least five stable colonies, present at both of at least
two sites. A species needs at least two eligible profiles. Rare profiles are
not pooled.

## Model

`log1p(cells.cm2) ~ profile * timepoint + site * timepoint + (1|colony)` on
nonnegative cell-density observations. Compare with the model omitting only
`profile:timepoint` by parametric-bootstrap likelihood-ratio test. Report
fitted profile trajectories and the range among profiles of TP3-minus-TP1
change with colony-bootstrap CIs. Holm correction across the two species.

## Decision rule

`supported`: estimable interaction with Holm-adjusted p < 0.05 in both
species. A species failing eligibility or giving a rank-deficient model is
`inconclusive`. Nonsignificance alone is not called `not supported`; that
needs the effect threshold and power simulation below.

## Known confounds and sensitivity checks

- Profiles assigned at TP1, avoiding conditioning on future stability.
- Colonies observed at all four timepoints only.
- Site-by-timepoint differences; profile–host haplotype confounding where
  metadata permit.
- Profile effects are between-colony associations and may reflect host
  genotype; no symbiont causation is inferred.

## Before moving to planned

- Count the eligible joint subset per species.
- Fix a meaningful effect threshold on the cell-density scale and run power
  simulations, then write the `not supported` branch of the decision rule.
- Fix bootstrap replicate counts.

## Amendments
