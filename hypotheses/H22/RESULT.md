# H22 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, glmnet 4.1.9 (newly added to `DESCRIPTION`). Runtime
6.5 min on a 16 GB / 8-core laptop (7 cores). Reproduction gate and test
suite passed on 2026-10-08 before the run. Analysis follows Amendment 1 in
`hypothesis.md`, written before any analysis. The Model assumed three sites,
but the expression colonies are at two (5 per site, site = nutrient). The
amendment therefore uses two outer folds, at most training rows − 1 PCs,
`glmnet` with the baseline unpenalized, raw-scale traits, and a
within-transition permutation null.

**Samples used:** colony × transition rows with expression at t and the
trait at t and t+1. 10 colonies per species, 5 per site; three-way orthologs.

| Species | Rows, AFDW (Mahana / Manava) | Rows, calcification (Mahana / Manava) | Ortholog genes |
|---|---|---|---|
| Apul | 29 (14 / 15) | 27 (12 / 15) | 9,820 |
| Peve | 26 (11 / 15) | 28 (13 / 15) | 9,282 |
| Ptuh | 29 (14 / 15) | 25 (10 / 15) | 9,946 |

**Headline numbers:** leave-one-site-out, out-of-sample R² pooled over the
two held-out sites. dR2 = molecular − baseline. p from 200 within-transition
permutations of training y[t+1]; q = BH across the two traits within species.
PCs: mean number with non-zero coefficients across folds (14 available).

| Species | Trait | R² baseline | R² + expression | dR2 | p | q | PCs selected |
|---|---|---|---|---|---|---|---|
| Apul | AFDW | −0.233 | −0.362 | −0.129 | 0.89 | 0.89 | 5.3 |
| Apul | calc | 0.032 | 0.032 | 0.0009 | 0.30 | 0.60 | 0 |
| Peve | AFDW | −1.353 | −1.494 | −0.141 | 0.70 | 0.70 | 2.3 |
| Peve | calc | 0.370 | 0.370 | 0.0002 | 0.50 | 0.70 | 0 |
| Ptuh | AFDW | −0.842 | −0.763 | 0.079 | 0.12 | 0.24 | 1.0 |
| Ptuh | calc | −0.393 | −0.232 | 0.161 | 0.24 | 0.24 | 6.4 |

No trait in any species has dR2 > 0 with q < 0.05, so `supported` is out.
`not supported` needs dR2 <= 0 for both traits in two species. No species
meets it, because the calcification dR2 is +0.0009 in Apul and +0.0002 in
Peve. The rule returns `inconclusive`.

**Important for reading the verdict:** those two positive values are
numerical, not predictive. In both cases the elastic net selected 0
expression PCs in every fold. The "molecular" model is then the baseline
refitted by `glmnet` rather than `lm`, and the two fits differ in the
fourth decimal. Had they been scored as exactly 0, Apul and Peve would meet
the `not supported` clause and the verdict would be `not supported`. The
verdict above is the one the pre-registered rule produced. No change was
made after seeing it; any change would need a dated amendment.

**Sensitivity checks (Amendment 1):** all `inconclusive`.

| Check | Result |
|---|---|
| Leave one colony out (10 folds) | Apul AFDW dR2 0.116, q = 0.030, the only trait passing in any species; all others q >= 0.10 |
| TP3→TP4 dropped | Ptuh calcification dR2 0.451, p = 0.040, q = 0.080; all others dR2 within ±0.21 and q >= 0.32 |

**Secondary, cross-species transfer (descriptive):** train on one species,
test on another, 9,017 shared orthologs, z-scored within species. dR2
ranges from −0.12 to +0.08 across the 12 train/test/trait combinations.
Expression adds nothing consistent across species.

**Current Findings:** not reported separately. Under CLAUDE.md §6 the
verdict is not `supported`, and with two folds of 5 colonies the result does
not bound an effect usefully.

**Caveats:** there are about 10 colonies per species, 5 per site, so each
outer fold trains on about 13–15 rows from 5 colonies. That is far too few to
estimate an expression-to-physiology map reliably, and out-of-sample R² is
very noisy. The most informative number may be the baseline itself: R² is
negative for AFDW in all three species and for calcification in Ptuh. Even
the trait's own previous value plus timepoint does not carry from one site
to the other, so site/nutrient shifts dominate whatever expression could
add. Site is confounded with nutrient, so "novel conditions" means the other
site and nutrient regime only. There is no independent cohort; held-out site
and held-out species are proxies. The only signals (Apul AFDW under
leave-one-colony-out, and Ptuh calcification without TP3→TP4) appear in
different species under different checks, and neither appears in the
primary analysis. Traits are on the raw scale because upstream AFDW has
negative values. Species is confounded with reference quality, which matters
for the transfer secondary.

**Outputs:** in `output/`
- `n_per_species.csv`: rows per species, trait and site
- `dr2_summary.csv`: primary R², dR2, null, p, q, PCs selected
- `predictions.csv`, `null_dr2.csv`: held-out predictions and all null draws
- `observed_vs_predicted.png`, `figure_data.csv`: figure and its data
- `sens_leave_one_colony_out.csv`, `sens_drop_tp3_tp4.csv`: sensitivity checks
- `cross_species_transfer.csv`: secondary
- `verdicts.csv`: verdict for each analysis

inconclusive
