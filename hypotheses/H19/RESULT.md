# H19 result

**Status:** not supported

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 1 min on a 16 GB / 8-core laptop.
Reproduction gate (`tests/run.R`) passed on 2026-10-07; no upstream or
harmonization change since. Two amendments in `hypothesis.md`, both written
before any association between turnover and an outcome was seen:

- **Amendment 1:** the CpG layer has no coverage (D-015), so the noise
  correction is a fixed 10x bound. It also defines the lipid ratio.
- **Amendment 2:** the median over all CpGs turned out to be degenerate,
  because most coral CpGs are unmethylated. Turnover is the mean over CpGs
  with species-mean methylation of 10–90%. Outcome tables from the first run
  were deleted unread.

**Samples used:** colonies with CpG data at >= 3 timepoints, one row per
colony. About 10 colonies per species.

| Species | Colonies (4 timepoints) | CpGs, all / 10–90% | With AFDW, lipid ratio, Met/SAM |
|---|---|---|---|
| Apul | 10 (9) | 96,772 / 28,355 | 10, 10, 10 |
| Peve | 9 (8) | 242,100 / 47,014 | 9, 9, 9 |
| Ptuh | 7 (5) | 1,991,606 / 96,410 | 7, 7, 7 |

Pooled n = 26 colonies.

**Headline numbers:** `lm(z(AFDW) ~ z(turnover_meth) + species)`, z within
species, standardized slope with 95% CI; per-species Spearman rho with
colony-bootstrap CI (2000).

| | Slope (95% CI) | p |
|---|---|---|
| Pooled | −0.015 (−0.457 to 0.427) | 0.94 |

| Species | n | rho (95% CI) |
|---|---|---|
| Apul | 10 | 0.19 (−0.44 to 0.62) |
| Peve | 9 | −0.32 (−0.73 to 0.47) |
| Ptuh | 7 | −0.14 (−1 to 0.65) |

The pooled CI includes 0 and |slope| < 0.2 SD, so the rule returns
`not supported`. Two species have negative rho, but the pooled slope is
essentially zero.

**Secondary (BH across three):**

| Response | Predicted sign | Slope (95% CI) | q | Negative rho in |
|---|---|---|---|---|
| log storage:membrane lipid ratio | − | −0.31 (−0.73 to 0.11) | 0.41 | 3 of 3 |
| log(Methionine / SAM) | + | −0.06 (−0.50 to 0.38) | 0.78 | 1 of 3 |
| AFDW, adjusted for expression turnover | − | −0.08 (−0.55 to 0.40) | 0.78 | 2 of 3 |

**Sensitivity checks (pre-registered or per Amendments):** all
`not supported`.

| Check | Slope (95% CI) |
|---|---|
| TP1, TP3, TP4 only (n = 24) | −0.10 (−0.56 to 0.37) |
| Site covariate | −0.10 (−0.50 to 0.29) |
| AFDW per protein | 0.24 (−0.19 to 0.67) |
| Uncorrected variance | 0.04 (−0.40 to 0.49) |
| Median over 10–90% CpGs | 0.06 (−0.39 to 0.50) |
| cells.cm2 covariate | 0.09 (−0.31 to 0.49) |

The 10x-floor correction barely changes colony rankings: within-species
Spearman of corrected vs uncorrected turnover is 0.87 / 0.90 / 0.93.
Corrected turnover is mostly negative, meaning real coverage is above 10x
and the floor over-subtracts. That is a uniform shift and does not affect
within-species standardized scores.

**Current Findings:** not reported separately. Under CLAUDE.md §6, the
verdict is not `supported`, and with n = 26 the result bounds the effect only
loosely (|slope| below about 0.45 SD). It also answers a different question
from the methylation synthesis.

**Caveats:** n is about 10 colonies per species (26 pooled; 7 for Ptuh). As
stated before the run, the 95% CI half-width is about 0.4–0.45 SD, so only a
large effect could have been detected. The result rules out a strong
negative association, not a modest one. The noise correction could not use
real coverage (D-015), so colony differences in sequencing depth remain
uncorrected and add noise to turnover. The 10–90% CpG set was chosen after
seeing that the median over all CpGs is degenerate, but before any outcome
was examined. The only hint in the predicted direction is the lipid ratio
(negative in all three species, CI includes 0, q = 0.41). Methylation
turnover and expression turnover are only loosely related across colonies
(within-species Spearman 0.16 / 0.30 / 0.71), so they are not one
"plasticity" axis. The storage and membrane classes are heuristic: TG + DG +
CE against LPC + Cer, with no PC or PE in the lipidome (`lipid_class_map.csv`).
H14 should adopt or amend this. Turnover over three or four timepoints is a
coarse summary of remodeling, and seasonal AFDW also reflects reproduction
and skeletal morphology. CpG sets differ about 20-fold across species
(D-008); scores are standardized within species before pooling, and no
cross-species ranking is claimed.

**Outputs:** in `output/`
- `n_per_species.csv`, `colony_table.csv`: colonies, CpG sets, and every colony-level variable used
- `lipid_class_map.csv`: lipid name to class and storage/membrane group
- `primary.csv`, `primary_per_species_rho.csv`: primary decision numbers
- `afdw_vs_turnover.png`, `figure_data.csv`: figure and its data
- `secondary.csv`, `secondary_per_species_rho.csv`: secondary responses with BH
- `sensitivity.csv`: sensitivity checks with verdicts
- `species_means.csv`: descriptive species means (no ranking claim)
- `verdicts.csv`: verdict for each analysis

not supported
