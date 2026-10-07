# H07 result

**Status:** inconclusive

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`);
miRNA family annotation from ShortStack `Results.txt` at `timeseries_molecular`
commit `900110b`. R 4.3.2, DESeq2 1.42.1. Runtime under 1 min.

**Samples used:** about 10 colonies per species; samples with >= 1,000 total
miRNA reads (decision D-011).

| Species | Samples | Dropped (< 1,000 reads) | Colonies | Confirmed loci | Loci with a miR family |
|---|---|---|---|---|---|
| Apul | 40 | 0 | 10 | 51 | 12 |
| Peve | 29 | 8 | 10 | 48 | 6 |
| Ptuh | 38 | 1 | 10 | 40 | 7 |

Shared families: miR-100, miR-2022, miR-2023, miR-2025, miR-2030, miR-2036,
miR-2037, miR-2050.

**Headline numbers:** Pearson r between z-scored per-timepoint colony-mean
profiles (DESeq2 `poscounts`-normalized counts) for cross-species locus pairs;
homologous = sharing a numbered miR family. Median difference with 95%
bootstrap CI; two-sided Wilcoxon rank-sum.

| Pair | Homologous pairs | Median r, homologous | Median r, non-homologous | Difference (95% CI) | p | Holm p | Passes |
|---|---|---|---|---|---|---|---|
| Apul–Peve | 6 | −0.334 | −0.037 | −0.297 (−0.835 to 0.121) | 0.114 | 0.228 | no |
| Apul–Ptuh | 7 | 0.842 | −0.017 | 0.860 (0.524–0.963) | 0.0037 | 0.011 | yes |
| Peve–Ptuh | 5 | −0.099 | −0.024 | −0.075 (−0.837 to 0.328) | 0.459 | 0.459 | no |

One species pair passes (difference > 0.3, p < 0.05); the rule needs two, and
homologous pairs are higher than the null in one pair, so neither `supported`
nor `not supported` applies: `inconclusive`.

Apul–Ptuh homologous r: miR-2036 0.99, miR-2023 0.92, miR-2050 0.89,
miR-2025 0.84, miR-2037 0.78, miR-2030 0.52, miR-100 −0.21.

Additional check, not pre-registered (log2 profiles): differences −0.538 /
0.775 / −0.139, p 0.071 / 0.0079 / 0.377; `inconclusive`.

**Caveats:** n is about 10 colonies per species, and each profile has only
four timepoints, so every r has 2 degrees of freedom; with 5 to 7 homologous
pairs per species pair, the test can only detect large effects. Within that
limit, Apul and *Pocillopora* show strongly conserved seasonal miRNA
regulation: six of seven shared families have r > 0.5, with miR-2036,
miR-2023 and miR-2050 near-identical across the year. *Porites* is the reason
the rule is not met, and its miRNA data are unlikely to reflect season: eight
Peve libraries failed (0 to 351 reads, all at TP2 to TP4), and among the
remaining libraries median depth falls 16-fold from TP1 to TP4 (182k, 82k,
52k, 11k reads; median size factors 3.5, 0.56, 0.57, 0.31). Nearly every Peve
family shows the same TP3-high, TP4-low shape, consistent with a library or
batch effect that normalization over 48 loci cannot remove. Read as: conserved
between Apul and Ptuh, Peve not interpretable until its miRNA libraries are
checked upstream. The Wilcoxon p-values are approximate because each locus
enters many null pairs. Family assignment depends on ShortStack's database
matching; novel and lab-named loci are excluded by design. Species is
confounded with reference quality (Peve N50 0.17 Mb; Ptuh mapped to
*P. meandrina*).

**Outputs:** in `output/`
- `n_per_species.csv`: samples, dropped libraries, loci
- `families_per_locus.csv`: family assignment per locus
- `pair_correlations.csv`: r and homology for every cross-species pair
- `homologous_vs_null.csv`: decision-rule numbers per species pair
- `r_homologous_vs_null.png`: figure; data in `pair_correlations.csv`
- `profiles_shared_families.png`, `profiles_shared_families.csv`: z-profiles per shared family
- `sens_log2_homologous_vs_null.csv`: log2 check (not pre-registered)
- `verdicts.csv`: verdict for each analysis

inconclusive
