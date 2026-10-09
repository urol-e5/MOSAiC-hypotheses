# H23 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, lme4 1.1-37. Runtime about 20 min on a 16 GB /
8-core laptop (1000 + 6 x 500 colony-bootstrap fits).

**Samples used:** samples with both CpG and gene data, as in H05; 10 colonies
per species, 5 per site.

| Species | Samples | Colonies | Orthologs expressed | Genes with >= 5 CpGs | Eligible orthologs | Median CpGs per gene |
|---|---|---|---|---|---|---|
| Apul | 39 | 10 | 9,805 | 2,113 | 706 | 9 |
| Peve | 37 | 10 | 9,278 | 3,089 | 638 | 14 |
| Ptuh | 32 | 10 | 9,958 | 19,970 | 9,311 | 33 |

**Headline numbers:** the gate and primary contrast named by the decision
rule, with 95% colony-bootstrap CIs (B = 1000, 0 failed fits). Amplitude is
the SD of the four colony-adjusted timepoint means, in vst units.

| Quantity | Estimate (95% CI) |
|---|---|
| Gate E: Apul mean amplitude minus mean of Peve, Ptuh | 0.110 (0.019 to 0.152) |
| Primary contrast Δ(25) − Δ(75) | −0.003 (−0.024 to 0.020) |
| Same, divided by pooled SD of amplitude (0.190) | −0.015 (−0.117 to 0.090) |

The gate passes: the eligible genes carry an Acropora excess. The primary
contrast CI includes zero, so the rule returns `inconclusive`. The interval
does bound the effect: the Acropora excess at the 25th GBM percentile differs
from that at the 75th by no more than about 0.024 vst units, roughly a fifth
of the 0.110 excess itself. Fitted Δ is 0.102 at percentile 0 and 0.108 at
percentile 100. Within this gene set, the excess is spread across the GBM
range rather than concentrated at the low end.

Sensitivity checks (pre-registered, B = 500, 0 failed fits; descriptive, they
do not change the verdict):

| Check | Genes (Apul / Peve / Ptuh) | Contrast (95% CI) | Rule applied to the check alone |
|---|---|---|---|
| S1 joint set (>= 5 CpGs in all three) | 88 / 88 / 88 | −0.068 (−0.113 to −0.012) | not supported |
| S2 well-annotated (`avg_identity >= 60`, SwissProt name) | 277 / 252 / 3,285 | 0.034 (0.007 to 0.056) | supported |
| S3 >= 20 CpGs | 115 / 232 / 6,435 | −0.027 (−0.072 to 0.013) | inconclusive |
| S4 no covariates | 706 / 638 / 9,311 | −0.030 (−0.050 to −0.012) | not supported |
| S5 GBM ranked within expression quintiles | 706 / 638 / 9,311 | −0.005 (−0.022 to 0.014) | inconclusive |
| S6 eligible in Apul and >= 1 other | 681 / 91 / 678 | −0.002 (−0.038 to 0.032) | inconclusive (gate CI −0.008 to 0.137) |

As `hypothesis.md` requires: S2's CI lies entirely on the opposite side of
zero from the primary estimate. S1 and S4 lie entirely below zero, the
direction opposite to the prediction.

**Caveats:** n is 10 colonies per species, and amplitude rests on four
timepoint means per gene, so per-gene amplitudes are noisy. The bootstrap
holds the vst and the eligible gene set fixed. The sensitivity checks point
in both directions. The 88-gene joint set and the covariate-free model put
more of the excess in high-GBM genes. The well-annotated subset puts more in
low-GBM genes, as predicted. So the null primary result is not robust in
sign, only in being small. Expression-level adjustment matters (S4 vs
primary), as expected given that GBM tracks expression (H05). The upstream
10x-in-all-samples CpG filter (D-008) leaves 706 and 638 eligible orthologs
in Apul and Peve against 9,311 in Ptuh. Those genes are plausibly enriched
for methylated genes, so "low-GBM" in Apul and Peve may not mean
unmethylated, and the percentile scales are not comparable in absolute
methylation. In S6 the gate fails because Peve keeps only 91 genes. Species
is confounded with reference quality (Peve N50 0.17 Mb; Ptuh mapped to
*P. meandrina*). The gene set was changed from the proposal's joint set to
per-species sets before analysis because of an eligibility count (see
`hypothesis.md`). This is a follow-up on the same data as H02 and H05, not an
independent replication.

**Current Findings:** qualifies under CLAUDE.md §6(b): the `inconclusive`
primary contrast bounds an effect size. A report has not yet been written.
The candidates are a short H23 report, or adding H23 to the gene-body
methylation synthesis
(<https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/>),
which covers H05.

**Outputs:** in `output/`
- `n_per_species.csv`: samples, orthologs and eligible genes per species
- `per_gene.csv`: amplitude, GBM, mean expression, CpG count and gene length per eligible gene
- `estimates.csv`: E, primary contrast (raw and standardized), pooled SD, Δ(0), Δ(100), with CIs, per check
- `verdicts.csv`: rule applied to the primary analysis and to each check
- `bootstrap_replicates.csv`: every bootstrap replicate per check
- `amplitude_by_gbm_decile.png`, `amplitude_by_gbm_decile.csv`: amplitude by within-species GBM decile
- `contrast_by_check.png`, `contrast_by_check.csv`: primary contrast with CIs across checks
