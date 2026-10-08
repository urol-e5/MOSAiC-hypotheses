---
id: H10
slug: its2-colony-fixed
title: Symbiodiniaceae ITS2 community composition is fixed by colony and does not shift seasonally
status: supported
tier: 3
layers: [its2, physiology]
species: [Apul, Peve, Ptuh]
depends_on: []
created: 2026-10-06
author: Steven Roberts (plan drafted with Claude)
---

## Question

Are symbiont communities a colony trait (stable across the year) or do they
shuffle with season?

## Hypothesis and prediction

Colony identity dominates. Prediction: PERMANOVA R2 for colony is much larger
than for timepoint, and within-colony Bray-Curtis dissimilarity across
timepoints is lower than between-colony dissimilarity at the same timepoint.
Secondary: colonies hosting *Durusdinium* (D-profiles) differ in physiology
(`cells.cm2`, `calc.umol.cm2.hr`) from *Cladocopium*-dominated colonies.

## Data

`its2` profile relative abundances, all samples; `physiology` for the
secondary test.

## Model

`vegan::adonis2(bray ~ colony + timepoint, strata = colony)` per species,
999 permutations. Paired comparison of within- vs between-colony distances
(Wilcoxon). Secondary: `lmer(trait ~ dominant_genus + timepoint + (1|colony))`.

## Decision rule

`supported` if R2(colony) > 0.5 and R2(timepoint) < 0.1 in all species, and
within-colony distance is lower than between-colony with p < 0.01.
`not supported` if R2(timepoint) >= R2(colony) in any species. Otherwise
`inconclusive`. Secondary test reported but does not change the status.

## Known confounds and sensitivity checks

- Profile-level data (SymPortal) can hide within-profile variation.
- Species with a single dominant profile make the test trivial. Report the
  profile count per species.

## Amendments
