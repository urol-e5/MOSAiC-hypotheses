# H04 result

**Status:** inconclusive

**Run on:** 2026-10-07 on raven against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.3, variancePartition 1.32.5, lme4 1.1-37, vegan 2.7.6, DESeq2 1.42.1.
Runtime 3 h 44 min with 47 workers (PERMANOVA bootstraps about 1 h 45 min of that,
serial; variance partition about 2 h, parallel).

**Samples used:** about 10 colonies per species; only samples with both CpG and
expression data.

| Species | Samples | Colonies | Genes kept | CpGs delivered (>= 10x in all) | CpGs with nonzero variance (used) |
|---|---|---|---|---|---|
| Apul | 39 | 10 | 21,046 | 96,772 | 94,445 |
| Peve | 37 | 10 | 20,807 | 242,100 | 238,957 |
| Ptuh | 32 | 10 | 20,975 | 1,991,606 | 1,797,003 |

Missing colony-timepoints: Apul ACR-225 TP1; Peve POR-236 TP3/TP4, POR-73 TP2;
Ptuh POC-201 TP3/TP4, POC-222 TP2, POC-255 TP4, POC-259 TP3/TP4, POC-42 TP1/TP3.

**Headline numbers.** PERMANOVA R2 for colony (95% bootstrap interval over
features, 200 resamples) and median colony fraction from variancePartition
(95% bootstrap CI over features, 1000 resamples).

| Species | R2 colony, expression | R2 colony, methylation | Median colony fraction, expression | Median colony fraction, methylation | Rule outcome |
|---|---|---|---|---|---|
| Apul | 0.374 (0.369–0.378) | 0.690 (0.688–0.693) | 0.079 (0.075–0.083) | 0.155 (0.151–0.159) | both parts favour methylation |
| Peve | 0.523 (0.520–0.528) | 0.620 (0.619–0.622) | 0.136 (0.133–0.140) | 0.059 (0.058–0.061) | R2 favours methylation, varpart favours expression |
| Ptuh | 0.446 (0.442–0.449) | 0.664 (0.662–0.665) | 0.089 (0.085–0.093) | 0.000 (0–0) | R2 favours methylation, varpart favours expression |

The rule needs both parts in all three species for `supported`, and both parts
reversed in at least one species for `not supported`. Apul supports; Peve and
Ptuh are split, so the verdict is `inconclusive`.

The secondary prediction holds in every species: timepoint explains less of
the methylome than of the transcriptome. PERMANOVA R2(timepoint) is 0.04–0.05
for methylation against 0.09–0.25 for expression, and the median timepoint
fraction for methylation is about 0 in all three (expression: Apul 0.102,
Peve 0.004, Ptuh 0.014; difference CIs exclude 0).

Sensitivity check (pre-registered): CpGs split into terciles of mean
methylation within species, each compared against the same expression layer.

| Tercile | Mean methylation range, Apul / Peve / Ptuh (%) | Apul | Peve | Ptuh | Verdict |
|---|---|---|---|---|---|
| 1 (lowest) | 0.02–0.60 / 0.02–0.51 / 0.01–0.28 | reverses | reverses | reverses | not supported |
| 2 | 0.60–7.9 / 0.51–3.6 / 0.28–0.55 | supports | reverses | reverses | not supported |
| 3 (highest) | 7.9–94 / 3.6–100 / 0.55–96 | supports (colony 0.547 vs 0.079) | supports (0.420 vs 0.136) | split (R2 up, varpart 0) | inconclusive |

**Caveats:** n is about 10 colonies per species (Ptuh has 32 samples with both
layers and five colonies missing timepoints), and the intervals resample
features rather than colonies, so they are far narrower than the true
uncertainty. The two halves of the rule measure different things: Euclidean
PERMANOVA on percent methylation is dominated by the few high-variance,
methylated CpGs, while the median variance fraction describes the typical
CpG. Most CpGs here are close to 0% (median mean methylation 2.1% Apul, 0.95%
Peve, 0.39% Ptuh), where between-sample variance is read-sampling noise
(median residual fraction 0.81, 0.89, 1.00), and the colony fraction is
exactly 0 for 36%, 43% and 72% of CpGs. Among methylated CpGs (top
tercile), colony identity is much stronger in methylation than in expression
in Apul and Peve, so the hypothesis looks right for the methylated
fraction of the genome and the primary verdict is driven by the unmethylated
background. Ptuh cannot answer this: even its top tercile starts at 0.55% and
has a median colony fraction of about 0, consistent with D-008's suspicion that the
upstream Ptuh CpG filter differs from the other two species (1.8 M CpGs
against 0.1–0.24 M). Ptuh is also mapped to *P. meandrina* and Peve has a
low-contiguity reference (N50 0.17 Mb). A follow-up hypothesis with a common
coverage-and-methylation filter across species, pre-registered before
looking, would be the clean test.

**Outputs:** in `output/`
- `n_per_species.csv`, `design_per_colony.csv`: samples and design actually used
- `permanova.csv`: R2 with bootstrap intervals and p-values, per layer and term
- `varpart_by_layer.png`, `varpart_summary.csv`: figure and the data behind it
- `decision_per_species.csv`: primary decision-rule numbers
- `sens_tercile_decision.csv`: tercile sensitivity check
- `verdicts.csv`: verdict for each analysis
- `varpart_per_feature.csv.gz` (60 MB, md5 `917798640e005007624ffebae3f5dafc`):
  per-feature variance fractions, not committed. Gannet URL: TODO (upload
  pending; on raven at `hypotheses/H04/output/`).

inconclusive
