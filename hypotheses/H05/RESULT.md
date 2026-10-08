# H05 result

**Status:** supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 1 min on a 16 GB / 8-core laptop.

**Samples used:** about 10 colonies per species; samples with both CpG and
gene data (same as H04).

| Species | Samples | Colonies | CpG sites | Genes with >= 5 CpGs | Genes passing expression filter | Genes used | Median CpGs per gene |
|---|---|---|---|---|---|---|---|
| Apul | 39 | 10 | 96,772 | 2,113 | 21,046 | 1,641 | 10 |
| Peve | 37 | 10 | 242,100 | 3,089 | 20,807 | 1,796 | 15 |
| Ptuh | 32 | 10 | 1,991,606 | 19,970 | 20,975 | 16,600 | 31 |

**Headline numbers:** Spearman rho between mean gene-body methylation (GBM)
and mean vst expression (95% bootstrap CI over genes), and the standardized
GBM coefficient from `lm(cv ~ ns(mean_expr, 3) + gbm)` (95% CI), where CV is
across the four per-timepoint colony means.

| Species | rho (95% CI) | GBM coefficient on CV (95% CI) | Meets rule |
|---|---|---|---|
| Apul | 0.303 (0.258–0.350) | −0.077 (−0.126 to −0.027) | yes |
| Peve | 0.212 (0.164–0.259) | −0.123 (−0.169 to −0.078) | yes |
| Ptuh | 0.372 (0.358–0.385) | −0.129 (−0.145 to −0.114) | yes |

All three species have rho > 0.2 and a negative GBM coefficient with a CI
excluding zero, so the rule returns `supported`.

Sensitivity check (pre-registered), genes with >= 2 CpGs (2,960 / 2,347 /
17,705 genes): rho 0.243 / 0.211 / 0.355; GBM coefficient −0.061 / −0.138 /
−0.129, all CIs below zero; `supported`.

**Caveats:** n is about 10 colonies per species. Peve passes the rho > 0.2
threshold on its point estimate only (0.212, CI 0.164–0.259), so its half of
the expression criterion is borderline. The CV effect is modest (one SD more
GBM is 0.08 to 0.13 SD less CV); the association with expression level is
the stronger signal. In Ptuh the decile view is a step rather than a slope:
expression jumps and CV drops between GBM deciles 5 and 6, consistent with
the bimodal unmethylated/methylated gene classes typical of invertebrates;
Apul and Peve rise more gradually. Gene counts differ ten-fold because the
upstream 10x-in-all-samples CpG filter yields very different CpG densities
(decision D-008), so the Apul and Peve estimates rest on fewer, likely
better-covered and more methylated genes. Species is confounded with
reference quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*). CV over
four timepoint means is noisy and on the vst (log) scale is tied to mean
level, which the spline term addresses. Bootstrap intervals resample genes,
not colonies.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/> (gene-body methylation synthesis, with H04–H06, H15, H16, H18).

**Outputs:** in `output/`
- `n_per_species.csv`: samples, CpGs and genes at each step
- `per_gene.csv`: n CpGs, GBM, mean expression and CV per gene and species
- `estimates.csv`: rho and GBM coefficient with CIs, per species
- `gbm_deciles.png`, `gbm_deciles.csv`: decile figure and the data behind it
- `sens_mincpg2_n.csv`, `sens_mincpg2_estimates.csv`: >= 2 CpG check
- `verdicts.csv`: verdict for each analysis

supported
