---
id: H12
slug: nutrient-site-physiology
title: Site nutrient context modulates the seasonal trajectory of host physiology
status: planned
tier: 3
layers: [physiology]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Do colonies at high-nutrient sites follow a different seasonal physiology
trajectory than those at low-nutrient sites?

## Hypothesis and prediction

Nutrient enrichment changes symbiont density and host energetics. Prediction:
a timepoint x nutrient interaction for `cells.cm2`, `chla.ug.cm2`, and
`Host_AFDW.mg.cm2`.

## Data

`physiology`, all samples. First deliverable is the design balance table
(colonies per species x site x nutrient); if any cell has fewer than three
colonies this hypothesis is marked `inconclusive` for that species without
fitting.

## Model

`lmer(log(trait) ~ timepoint * nutrient + (1|colony))` per species and trait;
likelihood-ratio test for the interaction; BH across traits.

## Decision rule

`supported` if the interaction is significant (FDR < 0.05) for at least two
of three traits in at least two species. `not supported` if no interaction
reaches FDR < 0.2 in any species. Otherwise `inconclusive`.

## Known confounds and sensitivity checks

- Nutrient is a site attribute; site and nutrient may be perfectly
  confounded. Report the crosstab before anything else.
- This is the weakest hypothesis in the slate and may be withdrawn after the
  balance check.

## Amendments
