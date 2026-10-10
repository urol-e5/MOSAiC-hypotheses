---
id: H27
slug: its2-profile-density-trajectories
title: Colonies with different stable ITS2 profiles follow different seasonal symbiont-density trajectories
status: withdrawn
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

### Withdrawal (2026-10-10), before the pre-registration was completed and before any cell-density data were analysed

**Status: withdrawn.** Under the proposal's own eligibility rule each species
has one eligible ITS2 profile, and two are required, so both species would be
`inconclusive` by construction. The profiles that are available also track
host lineage. Evidence from `feasibility_check.R` (ITS2 profile abundances,
site, host haplotype and whether `cells.cm2` is present; no cell-density
value read; outputs in `output/feasibility/`):

- Stable colonies (same dominant profile at every timepoint with ITS2 and
  `cells.cm2`, >= 3 such timepoints, dominant share >= 0.8 at each): Peve 27
  of 45, Ptuh 19 of 45. Most colonies are stable in identity (median
  dominant share 1.0); instability comes from colonies whose dominant profile
  changes (Peve 13, Ptuh 20 colonies with two or more dominant profiles).
- Eligible profiles (>= 5 stable colonies at >= 2 sites): Peve 1
  (`C15-C15kl-C15he-C15vz`, 16 colonies), Ptuh 1
  (`C42g/C1/C42.2/C42a-C42h-C1b-C42b-C1ew-C42br`, 10 colonies). Every other
  stable profile has 1 to 4 colonies.
- The pre-registered TP1-assignment check would give Peve 2 eligible
  profiles (19 and 6 colonies) and Ptuh 3 (9, 6, 13), but it was a
  sensitivity check, not the test, and it answers a different question
  (starting profile rather than stable identity).
- Profiles track host lineage. The 45 ITS2 colonies per species include
  other host species by haplotype: Peve colonies with *Porites lobata/lutea*
  and Ptuh colonies with *Pocillopora meandrina*. Peve's `C15-C15l-...`
  profiles occur mostly in *P. lobata/lutea* colonies; Ptuh's `C1d-...`
  profiles only in *P. tuahiniensis*. A profile-by-timepoint effect would be
  largely a host-lineage effect.

A successor would need profiles assigned at TP1 (or another rule fixed
without reference to later stability), host lineage as a stratum or
covariate (comparing profiles within one host lineage where possible), and
its own effect threshold and power simulation. That belongs in a new
hypothesis.
