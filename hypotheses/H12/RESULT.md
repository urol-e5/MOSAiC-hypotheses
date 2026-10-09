# H12 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, lme4 1.1-37. Runtime about 15 s on a 16 GB / 8-core laptop.
Reproduction gate and test suite passed on 2026-10-08. No amendment: the
pre-registered model and rule were applied as written.

**Samples used:** the physiology layer, which covers many more colonies than
the molecular layers (about 10 colonies per species there, at two sites).
One row per colony × timepoint sample; colonies were sampled at 2–4
timepoints (115–167 samples from 45–50 colonies per species).

Design balance (first deliverable): every cell is far above the
pre-registered minimum of 3, so all species were fitted.

| Species | Hilton / Medium | Mahana / Low | Manava / High |
|---|---|---|---|
| Apul | 15 | 19 | 16 |
| Peve | 15 | 16 | 15 |
| Ptuh | 15 | 15 | 15 |

Site and nutrient are perfectly confounded (one nutrient level per site),
so the timepoint × nutrient interaction is equally a timepoint × site
interaction.

**Headline numbers:** likelihood-ratio test of `timepoint × nutrient` in
`lmer(log(trait) ~ timepoint * nutrient + (1|colony))`, 6 df, with BH across
the three traits within species. Effect size: the ratio of the TP1→TP3
fold change at high vs low nutrient, with a Wald 95% CI.

| Species | Trait | n | χ² | FDR | TP1→TP3 change, high vs low (95% CI) |
|---|---|---|---|---|---|
| Apul | cells.cm2 | 115 | 14.6 | 0.057 | 1.81 (1.25–2.64) |
| Apul | chla.ug.cm2 | 114 | 13.4 | 0.057 | 1.28 (0.87–1.88) |
| Apul | Host_AFDW | 114 | 5.5 | 0.48 | 0.76 (0.51–1.15) |
| Peve | cells.cm2 | 167 | 5.8 | 0.67 | 1.12 (0.74–1.69) |
| Peve | chla.ug.cm2 | 167 | 2.6 | 0.86 | 1.00 (0.66–1.52) |
| Peve | Host_AFDW | 159 | 10.4 | 0.33 | 0.93 (0.65–1.31) |
| Ptuh | cells.cm2 | 161 | 18.3 | 0.0054 | 1.29 (0.81–2.06) |
| Ptuh | chla.ug.cm2 | 163 | 27.2 | 0.0002 | 0.96 (0.66–1.40) |
| Ptuh | Host_AFDW | 163 | 37.6 | 4e-6 | 0.61 (0.47–0.80) |

Ptuh has three traits at FDR < 0.05, Apul has none (two at 0.057), and Peve
has none, so one species meets the `supported` condition. Apul has
interactions at FDR < 0.2, so `not supported` does not apply either. The
rule returns `inconclusive`.

**Reading the trajectories** (`trajectories.png`):

- **Peve:** high-nutrient (Manava) colonies have more symbionts and
  chlorophyll all year, but the seasonal trajectories are parallel. This is
  a level effect, not an interaction.
- **Ptuh:** the trajectories diverge. Biomass at the high-nutrient site
  dips at TP3 and rebounds by TP4, and at TP3 it is 0.61 times its TP1 level
  relative to the low site (CI 0.47–0.80). Symbiont density keeps falling
  at the low-nutrient site.
- **Apul:** symbiont density falls less from TP1 to TP3 at the high site
  than at the low site (ratio 1.81, CI 1.25–2.64). Part of the overall
  interaction comes from the medium site (Hilton), whose chlorophyll is out
  of nutrient order at TP1. Site idiosyncrasy, not a nutrient gradient,
  likely contributes.

**Descriptive check (not in the verdict):** restricted to the two sites that
also carry the molecular layers (Mahana low, Manava high; 3-df test), the
pattern is similar: Ptuh AFDW (FDR 8e-6) and cells (0.024), and Apul cells
(0.002). Peve has nothing.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-nutrient-site-seasonal-physiology/>
(reported under CLAUDE.md §6 rule (b): 45–50 colonies per species, so the
effect intervals are informative even though the verdict is inconclusive).

**Caveats:** physiology n is 45–50 colonies per species (15–19 per site),
much larger than the molecular layers. Each colony was sampled at 2–4
timepoints, not all four; *Acropora* sampling is uneven (42 / 24 / 21 / 29).
Site and nutrient are perfectly confounded, so any site difference (depth,
flow, light, microhabitat) is indistinguishable from nutrient enrichment, and
the medium site does not always sit between low and high. Non-positive or
missing values were excluded before the log transform (0 to 8 samples per
model; see `interaction_tests.csv`). Two Peve models had singular colony
variance. The interaction is tested jointly over 6 df, and the TP1→TP3
ratio summarizes only one contrast of it. The pre-registration named no
sensitivity analysis beyond the balance table; the two-site check is
descriptive.

**Outputs:** in `output/`
- `design_balance.csv`: colonies per species × site × nutrient
- `interaction_tests.csv`: χ², p, FDR, n, exclusions, effect ratio with CI
- `decision.csv`: per-species counts and verdict
- `fitted_means.csv`, `trajectories.png`, `figure_data.csv`: fitted trajectories with CIs and the figure
- `sens_two_sites.csv`: descriptive two-site check

inconclusive
