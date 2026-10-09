---
id: H20
slug: transcriptome-temperature-mismatch
title: Colonies whose transcriptome lags current temperature lose biomass and calcification by the next timepoint
status: withdrawn
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

### Withdrawal (2026-10-08), before any expression or physiology data were analysed

**Status: withdrawn.** Both temperature predictors collapse to the timepoint
label, and the pre-registered Part A pipeline produces the predicted negative
slope when there is no memory at all, so neither the memory test nor the cost
test it feeds can be interpreted. Evidence from `temperature_check.R`
(temperature, nominal dates and the design table only; outputs in `output/`):

- 30-day windows before each nominal date (as H11). Mean temperature at
  Mahana / Manava: TP1 27.58 / 27.59, TP2 29.35 / 29.39, TP3 27.05 / 26.99,
  TP4 27.68 / 27.63 C. The thermal axis can only learn "TP2 vs the rest".
- dT/dt (C per 30 days): TP1 0.15 / 0.16, TP2 0.59 / 0.57, TP3 0.30 / 0.27,
  TP4 0.71 / 0.63. It is positive at every timepoint, so the lag-sign check
  has no cooling period, and the two sites differ by at most 0.08, so the
  between-site contrast the confounds section relies on is absent. Part A is a
  four-level timepoint contrast. Logger coverage is 16 of 30 days at TP1 and
  23 to 24 at TP2 and TP4.
- Simulation with synthetic expression that tracks current temperature with
  no lag (true Part A slope 0), 10 colonies x 4 timepoints at the observed
  site temperatures, 2000 features, LOCO ridge as pre-registered, 100 runs
  per signal level (temperature R^2 0.05, 0.2, 0.5): the Part A slope was
  negative with a 95% CI excluding 0 in 100% of runs at every level (median
  -0.81, -0.28, -0.12). LOCO ridge predictions shrink toward the mean
  temperature, so m = S - T is strongly negative where T is high (median
  correlation of m with T -0.98 to -0.90), and T and dT/dt are both high at
  TP2. Part B's |m| inherits the same artefact.

Testing thermal memory needs sites or loggers whose temperature histories
differ at the same timepoint, or more timepoints with cooling and warming
periods, and a mismatch measure whose null is not biased by shrinkage (for
example, compare against axes refitted with timepoint labels permuted within
colony). That belongs in a new hypothesis. Source question Q8 stays open.
