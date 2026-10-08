# H10 result

**Status:** supported

**Run on:** 2026-10-07 against MOSAiC commit `86432e3` (see `config/upstream.lock.yml`).
R 4.3.2, vegan, lme4 1.1-37. Runtime about 2 min on a 16 GB / 8-core laptop.

**Samples used:** all ITS2 samples. ITS2 covers more colonies than the
molecular layers (about 10 colonies per species there); here:

| Species | Samples | Colonies | Colonies with >= 2 samples | Profiles present | Top profile (share of samples) |
|---|---|---|---|---|---|
| Apul | 120 | 50 | 38 | 7 | D1-D1u-D1jb (0.85) |
| Peve | 162 | 45 | 45 | 23 | C15-C15kl-C15he-C15vz (0.53) |
| Ptuh | 159 | 45 | 42 | 15 | C42g/C1/C42.2/C42a-... (0.32) |

Samples per timepoint (TP1-TP4): Apul 42 / 23 / 21 / 34, Peve 44 / 42 / 40 / 36,
Ptuh 40 / 42 / 39 / 38.

**Headline numbers:** PERMANOVA `bray ~ colony + timepoint` (sequential;
colony p unrestricted, timepoint p permuted within colony; 999 permutations;
R2 95% CI from 500 colony bootstraps) and paired within- vs between-colony
Bray-Curtis (one-sided Wilcoxon signed-rank across colonies, Hodges-Lehmann
shift with 95% CI).

| Species | R2 colony (95% CI) | R2 timepoint (95% CI), p | Within / between, median | Shift (95% CI) | p |
|---|---|---|---|---|---|
| Apul | 0.885 (0.754–0.962) | 0.003 (0.001–0.024), 0.68 | 0 / 0.195 | −0.189 (−0.207 to −0.161) | 6.7e-8 |
| Peve | 0.797 (0.690–0.882) | 0.006 (0.004–0.022), 0.30 | 0 / 0.619 | −0.480 (−0.596 to −0.402) | 9.2e-9 |
| Ptuh | 0.726 (0.645–0.801) | 0.009 (0.006–0.031), 0.26 | 0.5 / 0.798 | −0.504 (−0.588 to −0.398) | 1.3e-8 |

R2(colony) > 0.5, R2(timepoint) < 0.1 and within < between at p < 0.01 in
all three species, so the rule returns `supported`.

Secondary (reported only; does not change the status): dominant-genus
contrast possible only in Apul, *Durusdinium* (102 samples) vs *Symbiodinium*
(18), not the *Durusdinium* vs *Cladocopium* contrast predicted, because Peve
and Ptuh are entirely *Cladocopium*-dominated. `lmer(trait ~ genus +
timepoint + (1|colony))`: `cells.cm2` +51,756 cells per cm2 (95% CI −63,385
to 166,898, p = 0.38); `calc.umol.cm2.hr` −0.052 (−0.115 to 0.012, p = 0.11).
No detectable physiology difference.

**Caveats:** colony counts here are 45 to 50 per species, about 10 of which
are the molecular colonies used elsewhere. R2 for a factor with this many
levels has a large null expectation, roughly df / (n − 1) = 0.41 for Apul,
0.27 for Peve and 0.28 for Ptuh, so the 0.5 threshold is less stringent than
it reads, especially for Apul; the unrestricted permutation p (0.001) and the
paired distance test, which does not share this inflation, both still show
colony far above that baseline. Apul is close to the trivial case the
pre-registration flags: 85% of its samples carry one profile, so its colony
R2 mostly reflects which colonies host *Symbiodinium*; Peve and Ptuh are the
more informative tests. Ptuh is the least fixed (median within-colony
distance 0.5, so about half its colonies change dominant profile across the
year), but still far below between-colony distances. Coverage is uneven
(Apul TP2 and TP3 have about half the samples of TP1), and colonies sampled
once enter PERMANOVA but not the paired test. SymPortal profiles hide
within-profile shifts in ITS2 sequence abundance, and relative abundances are
compositional. The colony bootstrap ignores site. One secondary model gave a
near-singular convergence warning; the secondary result is descriptive.

**Outputs:** in `output/`
- `n_per_species.csv`, `samples_per_timepoint.csv`: samples, colonies, profile dominance
- `permanova.csv`: R2 with bootstrap CIs and permutation p
- `within_vs_between.csv`, `within_vs_between_per_colony.csv`: paired distance test
- `within_vs_between.png`: figure; data in `within_vs_between_per_colony.csv`
- `decision_per_species.csv`: rule components per species
- `secondary_genus_physiology.csv`: dominant genus vs physiology

supported
