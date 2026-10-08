# H03 result

**Status:** not supported

**Run on:** 2026-10-06 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1, apeglm 1.24.0. Runtime about 1 min on a 16 GB /
8-core laptop.

**Samples used:** about 10 colonies per species; 9,017 three-way ortholog
groups common to all species after the H01 filter (same set as H02).

| Species | Samples | Colonies | TP1 | TP3 | Tested (TP3 vs TP1) | DE, FDR < 0.05 (up / down in TP3) |
|---|---|---|---|---|---|---|
| Apul | 40 | 10 | 10 | 10 | 9,017 | 3,457 (1,846 / 1,611) |
| Peve | 38 | 10 | 10 | 9 | 7,618 | 791 (291 / 500) |
| Ptuh | 39 | 10 | 10 | 10 | 8,492 | 224 (122 / 102) |

**Headline numbers:** Spearman rho of apeglm-shrunken TP3-vs-TP1 log2 fold
changes, 95% bootstrap CI over groups, one-sided permutation p (1000
permutations of ortholog assignment).

| Pair | rho (95% CI) | Permutation p | Meets rho > 0.2, p < 0.01 |
|---|---|---|---|
| Apul–Peve | 0.180 (0.160–0.198) | 0.001 | no |
| Apul–Ptuh | −0.075 (−0.095 to −0.056) | 1.0 | no (rho < 0) |
| Peve–Ptuh | 0.235 (0.215–0.254) | 0.001 | yes |

GO-slim enrichment among concordantly DE groups (same sign, FDR < 0.05 in
both species), universe = groups tested in both with at least one GO-slim
term, 136 terms, BH within pair:

| Pair | Concordant groups | Universe | Terms at FDR < 0.05 |
|---|---|---|---|
| Apul–Peve | 91 | 3,243 | 0 |
| Apul–Ptuh | 21 | 3,516 | 0 |
| Peve–Ptuh | 7 | 3,182 | 0 |

Terms enriched in all three pairs: none. The rule returns `not supported` on
both of its conditions independently: Apul–Ptuh rho <= 0, and no term is
shared.

Sensitivity check (`avg_identity >= 60`, 7,252 groups): rho 0.176 / −0.077 /
0.238 for the same pairs, concordant sets 75 / 16 / 4, no enriched terms;
`not supported`.

**Caveats:** n is about 10 colonies per species. The two failure conditions
differ in strength. The negative Apul–Ptuh correlation is a real effect at
this n: its interval excludes zero and it is unchanged on high-identity
orthologs, so ortholog misassignment does not explain it. The enrichment
failure is mostly a power problem: with 224 Ptuh and 791 Peve DE groups the
concordant sets are 7 to 91 groups, too small to reach FDR < 0.05 across 136
terms (best nominal p = 0.009, Apul–Ptuh, transcription regulator activity),
and only about 40% of groups carry GO-slim annotation, inherited from
SwissProt hits. The strongest pair, Peve–Ptuh, is also the one with the
fewest DE genes; its scatter is a tight cross around zero, so its rho
reflects many small co-directional shifts that could come from a shared
non-biological factor (collection day, extraction or sequencing batch) as
easily as from a shared program. TP1 (January) and TP3 (September) differ in
temperature, light, nutrients and reproductive timing, so no response here
can be attributed to temperature. Groups are not independent, so the
permutation and Fisher p-values are optimistic. Read with H02: the large
*Acropora* seasonal response looks species-specific rather than a shared
cnidarian program, and partly runs opposite to *Pocillopora*.

**Current Findings:** <https://robertslab.github.io/current-findings/reports/coral-seasonal-transcriptome-plasticity/> (seasonal transcriptome plasticity synthesis, with H01–H03).

**Outputs:** in `output/`
- `n_per_species.csv`: samples and groups used
- `tp3_vs_tp1_per_group.csv`: MLE and shrunken LFC, Wald p and padj per group and species
- `lfc_scatter.png`, `lfc_scatter_data.csv`: pairwise scatter and the data behind it
- `rho_per_pair.csv`: rho, bootstrap CI, permutation p
- `goslim_enrichment.csv`, `goslim_shared_terms.csv`: per-pair Fisher tests and shared terms (empty)
- `sens_ident_rho_per_pair.csv`, `sens_ident_goslim_enrichment.csv`: `avg_identity >= 60` check
- `verdicts.csv`: verdict for each analysis

not supported
