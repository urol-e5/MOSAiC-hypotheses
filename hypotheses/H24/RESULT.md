# H24 result

**Status:** inconclusive

**Run on:** 2026-10-08 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, DESeq2 1.42.1. Runtime about 7 min on a 16 GB / 8-core laptop.

**Samples used:** samples with both CpG and gene data, as in H05 and H23:
39 / 37 / 32 samples (Apul / Peve / Ptuh), 10 colonies per species, 5 per
site. Eligible orthologs per species: 706 / 638 / 9,311 (as H23).

| Pair | Orthologs | Strata used (smallest) |
|---|---|---|
| Apul–Peve | 91 | expression tertiles, 3 (30) |
| Apul–Ptuh | 678 | expression x length tertiles, 9 (36) |
| Peve–Ptuh | 610 | expression x length tertiles, 9 (36) |

**Headline numbers:** Spearman rho between the two species' per-gene GBM,
with a 95% colony-bootstrap CI (B = 1000) and a one-sided p against 2,000
permutations within matching strata (Holm across pairs).

| Pair | rho (95% CI) | Null mean | Excess over null | p (Holm) | Meets rule |
|---|---|---|---|---|---|
| Apul–Peve | 0.286 (0.251–0.312) | 0.070 | 0.217 | 0.019 (0.019) | no: rho <= 0.30 |
| Apul–Ptuh | 0.479 (0.467–0.481) | 0.091 | 0.388 | 0.0005 (0.0015) | yes |
| Peve–Ptuh | 0.369 (0.358–0.374) | 0.061 | 0.307 | 0.0005 (0.0015) | yes |

The two pairs with Ptuh meet every condition. Apul–Peve exceeds its matched
null (Holm p = 0.019) and has a CI above zero. Its rho, 0.286, is below the
pre-registered 0.30 minimum, so not all three pairs meet the rule and no
pair is reversed. The rule returns `inconclusive`. In all three pairs,
orthologs share GBM rank well beyond what matched expression, gene length
and CpG count give (null means 0.06–0.09).

Sensitivity checks (pre-registered, B = 500, 1,000 permutations;
descriptive, they do not change the verdict):

| Check | Apul–Peve | Apul–Ptuh | Peve–Ptuh | Rule on the check |
|---|---|---|---|---|
| C1 >= 20 CpGs | not run (9 orthologs) | 0.354 (0.335–0.368), n 97 | 0.383 (0.376–0.392), n 197 | inconclusive (2 pairs) |
| C2 well-annotated | −0.115 (−0.170 to −0.061), n 30 | 0.438 (0.419–0.443), n 271 | 0.313 (0.295–0.325), n 242 | not supported |
| C3 5 CpGs per gene (median, 2.5–97.5% over 100 draws) | 0.265 (0.223–0.318) | 0.326 (0.277–0.364) | 0.268 (0.207–0.310) | (no rule) |
| C4 88-ortholog joint set | 0.266 (0.234–0.292) | 0.395 (0.370–0.421) | 0.333 (0.303–0.350) | inconclusive |

C2's `not supported` comes from 30 Apul–Peve orthologs with rho −0.115. Its
colony-bootstrap CI excludes zero, but see the caveats on what that interval
covers.

**Caveats:** n is 10 colonies per species. The colony-bootstrap intervals
are narrow because per-gene GBM is very stable across colonies (H04, H05).
They hold the gene set fixed, so they do not include gene-sampling
uncertainty. For n = 91 orthologs that alone is roughly ±0.2 on rho (Fisher
SE about 0.11; not a pre-registered quantity). The Apul–Peve shortfall below
0.30 and the C2 Apul–Peve reversal on 30 genes should both be read in that
light. Apul–Peve is the weakest pair on every check, and it is also the pair
with the fewest CpGs per gene and the most truncated GBM range. The upstream
10x-in-all-samples filter (D-008) leaves 706 and 638 eligible genes in Apul
and Peve, against 9,311 in Ptuh, plausibly mostly methylated ones, which
would lower rho. With 5 CpGs per gene (C3), rho falls in every pair, as
expected from noisier GBM. Apul–Peve used only expression tertiles, so its
null removes less covariate-driven similarity than the 9-stratum nulls of
the Ptuh pairs. No coverage is available (D-015). Species is confounded with
reference quality (Peve N50 0.17 Mb; Ptuh mapped to *P. meandrina*). The
gene sets were changed from the proposal's joint set to per-pair sets before
analysis because of an eligibility count (see `hypothesis.md`). This is a
follow-up on the same data as H05, not an independent replication.

**Current Findings:** to be decided; see CLAUDE.md §6. The candidate is the
gene-body methylation synthesis
(<https://robertslab.github.io/current-findings/reports/coral-gene-body-methylation-stable-not-seasonal/>),
which covers H05 and H23.

**Outputs:** in `output/`
- `n_per_species.csv`: samples, orthologs and eligible genes per species
- `pair_sets.csv`: orthologs, strata level and smallest stratum per pair and check
- `per_gene.csv`: GBM, mean expression, CpG count and gene length per eligible gene
- `estimates.csv`: rho, CI, null mean, excess, p and Holm p per pair and check
- `verdicts.csv`: rule applied to the primary analysis and each check
- `bootstrap_replicates.csv`, `null_distributions.csv`: every bootstrap and permutation value
- `c3_equal_cpg_draws.csv`, `c3_equal_cpg_summary.csv`: C3 draws and summary
- `gbm_rank_pairs.png`, `gbm_rank_pairs.csv`: GBM percentiles of each ortholog in each pair
- `observed_vs_null.png` (data in `null_distributions.csv`, `estimates.csv`): observed rho against the matched null
