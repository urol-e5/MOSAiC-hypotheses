---
id: H20
slug: transcriptome-temperature-mismatch
title: Colonies whose transcriptome lags current temperature lose biomass and calcification by the next timepoint
status: planned
tier: 3
layers: [genes, temperature, physiology]
species: [Apul, Peve, Ptuh]
depends_on: [H02, H11]
created: 2026-10-07
author: Steven Roberts (plan drafted with Claude)
---

## Question

Source question Q8 (mismatch threshold). If molecular state carries memory
of past conditions, it will be mismatched to the present when temperature
changes quickly. Is mismatch measurable, does it scale with the rate of
temperature change, and is it costly?

The threshold itself (the rate at which memory tips from adaptive to
maladaptive) is not estimable here: there are only 9 site × interval
temperature-change values. This hypothesis tests the two ingredients a
threshold needs; any threshold estimate is descriptive.

## Hypothesis and prediction

Part A (memory): mismatch between a colony's expression state and the state
expected for its current temperature increases with the rate of
temperature change over the preceding 30 days, with the sign of lag (state
still resembles the earlier temperature).

Part B (cost): larger |mismatch| at time t predicts lower Host AFDW and
calcification at t+1, given their values at t.

If false: mismatch does not track rate of change (no memory), or mismatch
has no association with later performance (memory is not costly at these
rates).

## Data

- `genes_<species>` vst, three-way orthologs; `temperature_daily` 30-day
  site means and slopes (degC per 30 days) before each nominal date
  (D-006); `physiology` colony×timepoint means.
- Rows: colony × timepoint with expression and temperature; Part B needs
  physiology at t and t+1. Expected about 25–30 transitions per species.

## Model

1. Thermal axis per species: ridge regression of vst (top 2000 variable
   orthologs) on 30-day mean temperature, fit leave-one-colony-out; each
   sample's expression state S is its LOCO prediction (in degC units).
2. Mismatch m = S − T_current (degC). Lag sign: m should have the sign of
   (T_past − T_current).
3. Part A: `lmer(m ~ dTdt + (1|colony))`. Prediction: negative slope (when
   temperature is rising, state reads cooler than current).
4. Part B: `lmer(y[t+1] ~ y[t] + abs(m[t]) + interval + (1|colony))` for
   y = log Host_AFDW and calc rate. BH across the two traits.
5. Descriptive threshold: plot the Part B effect within |dTdt| tertiles.

## Decision rule

- `supported` if Part A slope < 0 with 95% CI excluding 0 and Part B slope
  < 0 with BH q < 0.05 for at least one trait, both in at least two species.
- `not supported` if Part A slope CI includes 0 in at least two species
  (no memory signal), or Part B slope >= 0 for both traits in at least two
  species.
- `inconclusive` otherwise (e.g. memory present but no detectable cost).

## Known confounds and sensitivity checks

- Temperature and season are confounded: dTdt is nearly the same for all
  colonies at a site and timepoint. Part A therefore rests on between-site
  and between-timepoint contrasts. State this; site-level clustering is
  addressed by refitting with `(1|site:timepoint)`.
- The thermal axis also captures non-thermal seasonal signals (light,
  reproduction). Sensitivity: residualize expression on photoperiod (day
  length at nominal date) before fitting the axis.
- Spawning in *Acropora* falls around TP4; biomass loss at TP4 can reflect
  reproduction, not mismatch. Sensitivity: drop the TP3→TP4 transition.
- Physiology has replicate fragments per colony; colony means are used.
- n is about 10 colonies per species.

## Amendments

(Leave empty. Dated entries only, added if the decision rule has to change.)
