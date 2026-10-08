# Decision log

Dated, numbered, append-only. Each entry: the problem, the choice, why.

## D-001 (2026-10-06) Species codes and sample ids

Upstream uses `Ptua`/`ptua` in file names and `Ptuh` in `counts.qmd`. This repo
uses `Ptuh` everywhere (it is the species, *P. tuahiniensis*; the genome is
*P. meandrina*). Canonical sample id is `{ACR|POR|POC}-{colony}-TP{n}`;
`norm_sample_id()` in `R/harmonize.R` accepts every upstream variant seen
(plate prefixes, underscores, BAM paths, readr dedup suffixes, `timepoint1`).

## D-002 (2026-10-06) Technical replicates in the Apul gene matrix

MOSAiC's `docs/corrected_sample_counts.md` reports 80 columns (technical
replicates) in the remote Apul gene matrix. On 2026-10-06 the remote file on
gannet is byte-identical (MD5 `6d9c7c720951658ab7c4a552c9bfc926`) to the
40-column copy in `MOSAiC/data/orthologs/`. The replicate issue is therefore
resolved upstream and no collapsing is done here. `harmonize_matrix()` stops
on duplicate sample ids, so a reappearance will fail loudly rather than
silently averaging.

## D-003 (2026-10-06) Gene id normalization

Apul ortholog ids carry a `-T\d+` transcript suffix; Peve and Ptuh count
matrices carry a `gene-` prefix. Both are stripped (`norm_gene_id()`). After
stripping, an Apul gene can appear in more than one ortholog group if two of
its transcripts were assigned separately; `genes_by_ortholog()` keeps the
first group per gene. Revisit if a hypothesis depends on isoform resolution.

## D-004 (2026-10-06) Where compute runs

GitHub Actions runs only the fetch, harmonize, reproduction gate, and report
render. Hypothesis analyses that need Bioconductor (DESeq2, variancePartition,
MOFA2) or the 25 MB CpG matrices run locally or on raven via
`targets::tar_make()`; their small outputs are committed. Revisit if Actions
runtime proves sufficient.

## D-005 (2026-10-06) What is committed under data/

`data/raw/` is never committed. `data/derived/` is committed except the CpG
matrices (ignored by pattern). `config/design.csv` is committed and is the
single sample-metadata table; colony-level site, nutrient, and haplotype are
taken from the physiology master. Samples present in molecular layers but
absent from the physiology master get `NA` for those fields rather than being
dropped.

## D-006 (2026-10-06) Timepoint dates

Exact collection dates per colony are not in any upstream table. The design
uses mid-month nominal dates (15 Jan, 15 Mar, 15 Sep, 15 Nov 2020), as
`temperature.qmd` in MOSAiC does. Hypotheses that compute thermal history
(H11) must treat the window as approximate.

## D-007 (2026-10-06) lncRNA sample counts differ from MOSAiC's documentation

MOSAiC `docs/corrected_sample_counts.md` lists 45 / 43 / 44 lncRNA samples
(Apul / Peve / Ptuh). The lncRNA files pinned in the lock on 2026-10-06 have
40 / 38 / 39 sample columns, identical to the gene matrices, plus the five
featureCounts metadata columns (Chr, Start, End, Strand, Length). The
documented numbers evidently came from an earlier upstream version. The
reproduction gate asserts the current values; if upstream changes again the
weekly drift check will catch it.

## D-008 (2026-10-06) CpG matrix sizes are very unequal across species

Sites passing the upstream filter (>= 10x in every sample): Apul 96,772;
Peve 242,100; Ptuh 1,991,606. The Ptuh matrix is 397 MB raw. Part of this is
fewer Ptuh samples (32) making the all-samples filter easier to pass, but a
20-fold difference suggests the upstream filtering may not be identical
across species. Methylation hypotheses (H04 to H06) must report per-species
site counts and should consider a common coverage filter applied here.

## D-009 (2026-10-07) lme4 pinned to 1.1-37

variancePartition 1.32.5 (Bioconductor 3.18, R 4.3) imports `lme4::findbars`,
which lme4 2.0 moved to the reformulas package; with lme4 2.0.6 every
`fitExtractVarPartModel` call fails. lme4 1.1-37 is installed from the CRAN
archive, from source so it matches the local Matrix ABI. Do not run
`update.packages()` on a machine that runs H01 or H04 without re-pinning:
`install.packages("https://cloud.r-project.org/src/contrib/Archive/lme4/lme4_1.1-37.tar.gz", repos = NULL, type = "source")`.
Revisit when moving to a Bioconductor release whose variancePartition supports lme4 2.

## D-010 (2026-10-07) H04 runs on raven; varpart is chunked

A desktop run of H04 (16 GB, 7 forked workers) swapped once it reached the
Ptuh CpGs: each worker grew to about 2 GB, 10.6 GB of swap was in use, and
the run was stopped after 8.5 h without finishing. `fit_varpart()` now fits
features in blocks of 100k with gc() between blocks (results verified
identical to a single call), and H04 reads `H04_WORKERS` to cap parallelism.
H04 runs on raven, as the README compute tier says. Ptuh accounts for about
85% of the CpG fits (see D-008).

## D-011 (2026-10-07) miRNA libraries below 1,000 reads are dropped

The upstream miRNA count matrices contain near-empty libraries. Peve, eight
below 1,000 total reads against a median of about 20,000: POR-236-TP2 (0),
POR-74-TP4 (3), POR-262-TP3 (5), POR-262-TP4 (5), POR-69-TP2 (55),
POR-83-TP3 (69), POR-262-TP2 (241), POR-216-TP4 (351); the next lowest is
1,368. Ptuh, one: POC-52-TP1 (401, median about 72,000). DESeq2 cannot size-factor an all-zero sample and
the others are noise. Analyses using miRNA call `mirna_qc_samples()`
(R/expression.R), which keeps samples with >= 1,000 total reads. The design
table's `has_mirna` flags are unchanged, so the reproduction gate still
matches MOSAiC's published sample counts. Worth an upstream issue on
urol-e5/timeseries_molecular.

Peve miRNA depth is also confounded with timepoint among the libraries that
pass the 1,000-read filter (29 of 37): median total reads TP1 182k, TP2 82k,
TP3 52k, TP4 11k (n = 10 / 7 / 6 / 6; median poscounts size factors 3.5,
0.56, 0.57, 0.31). All eight failed libraries are TP2 to TP4. Peve miRNA
timepoint effects (H07, H13) should be read as possibly technical until this
is checked upstream.

## D-012 (2026-10-07) R environment on raven

Raven's system R is 4.3.3 with no project packages and no 4.3 user library.
Packages were installed into `~/R/x86_64-pc-linux-gnu-library/4.3` (R adds it
automatically once it exists) from Bioconductor 3.18, matching the desktop,
with lme4 pinned to 1.1-37 (D-009). Two workarounds were needed, neither a
system change:

- `fs`: raven has no libuv headers. Install with `USE_BUNDLED_LIBUV=1`.
- `Deriv` (needed by doBy -> pbkrtest -> lmerTest -> variancePartition): the
  current CRAN release requires R >= 4.5. Install the archived 4.2.0:
  `install.packages("https://cloud.r-project.org/src/contrib/Archive/Deriv/Deriv_4.2.0.tar.gz", repos = NULL, type = "source")`.

A fresh fetch on raven reproduced every md5 in `config/upstream.lock.yml`; only
`fetched_on` dates changed, and that diff was discarded. The reproduction gate
passed before H04 ran.

## D-013 (2026-10-07) H04 PERMANOVA bootstrap runs in parallel

In the first raven run the R2 bootstrap (200 resamples, one Euclidean
distance over up to 1.8 M CpGs each) ran serially and took about 1 h 45 min
of the 3 h 44 min total. `permanova_one()` now draws all bootstrap indices
serially in the main process, in the same order `replicate()` did, and forks
only the `adonis2` fits with `parallel::mclapply` (`H04_WORKERS` cores).
`adonis2(..., permutations = 0)` uses no random numbers, so the draws and the
RNG state afterwards are unchanged: rerunning the purled qmd for Apul
reproduced the committed `permanova.csv` rows exactly (tolerance 0). Each
Ptuh worker holds one resampled copy of the matrix, about 1 GB.

Open: variancePartition fits ran at about 0.24 s per feature per worker with
47 workers, against 0.026 s in a single-process benchmark. Check whether
threaded BLAS inside forked workers is the cause before the next large run.

## D-014 (2026-10-07) lncRNA features have no strand

`lncrna_<species>_features` comes from the featureCounts table header
(`Chr`, `Start`, `End`, `Strand`, `Length`) of the upstream
`*_lncRNA_counts.clean.filtered.txt` files, and `Strand` is `+` for every
lncRNA in all three species (15,559 / 8,319 / 11,236). Gene coordinates from
the GFFs are about half `-`, so this is a property of the lncRNA SAF/GTF
used upstream, not of harmonization. Treat lncRNA strand as unknown. H17
drops its orientation split and excludes all pairs within 2 kb in its
read-through check (H17 Amendment 1). Asked upstream whether stranded
lncRNA coordinates exist:
<https://github.com/urol-e5/timeseries_molecular/issues/139>.

## D-015 (2026-10-08) CpG matrices carry no coverage

`cpg_<species>` comes from `merged-WGBS-CpG-counts_filtered.csv`, which holds
percent methylation for CpGs with >= 10x in every sample, and no read counts.
Anything that needs per-sample coverage (binomial noise models, depth
filters above 10x, beta-binomial tests) cannot be done from the manifest as
it stands. H19 uses the 10x floor as a fixed noise bound (H19 Amendment 1).
If coverage becomes necessary, the per-sample Bismark coverage files would
have to be added to `config/upstream.yml`; they are large and should be
read on raven.

