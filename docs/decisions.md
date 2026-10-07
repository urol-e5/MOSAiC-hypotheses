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
