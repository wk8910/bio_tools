# bio_tools

A collection of bioinformatics scripts for population genomics, phylogenetics, gene annotation, and functional analysis. Scripts are primarily written in Perl, with additional Python, R, and Shell components.

---

## Repository Structure

```
bio_tools/
├── utils/                    General-purpose utilities
│   ├── fasta/                FASTA/FASTQ file operations
│   ├── vcf/                  VCF file operations
│   ├── gff/                  GFF/CDS/gene structure utilities
│   └── misc/                 Miscellaneous tools (BAM stats, dXY, ROH, etc.)
├── population_genetics/      Population history and structure
│   ├── dadi_fsc/             Demographic inference (dadi + fastsimcoal2)
│   ├── psmc/                 PSMC population size history
│   ├── smcpp/                SMC++ population size history
│   ├── stairway_plot/        Stairway Plot population history
│   ├── treemix/              TreeMix population structure
│   ├── beagle_hwe/           BEAGLE phasing + HWE filtering
│   ├── ibd_analysis/         Identity-by-descent analysis
│   ├── saguaro/              SAGUARO genome-wide hidden Markov model
│   └── fastEPRR/             Recombination rate estimation
├── selection/                Selection pressure analysis
│   ├── ihs/                  Integrated haplotype score (iHS)
│   ├── kaks_calculator/      Ka/Ks ratio calculation
│   ├── hyphy/                HyPhy aBSREL / BUSTED selection tests
│   └── paml/                 PAML branch/branch-site models (from MAF)
├── functional_annotation/    GO/KEGG enrichment and pathway analysis
│   ├── go_analysis/          GO annotation and enrichment (Perl)
│   ├── kegg_analysis/        KEGG pathway analysis (Perl)
│   ├── kegg_enrichment/      KEGG enrichment with multiple testing (Perl)
│   ├── panther/              PANTHER functional annotation
│   └── enrichment_python/    GO + KEGG enrichment (Python, Fisher's exact test)
├── gene_annotation/          Gene structure prediction and annotation
│   ├── prediction/           Gene prediction pipeline (trans/protein/GeneWise)
│   ├── gene_structure/       Gene structure statistics (exon, intron, CDS)
│   ├── merge_gff/            Merge GFF files, convert Augustus output
│   ├── manual_check/         Manual gene verification (BLAST + GeneWise)
│   ├── novel_gene/           Novel gene identification
│   ├── chloroplast/          Chloroplast GenBank → TBL conversion
│   └── tm_predictor/         Transmembrane domain prediction
├── orthology/                Ortholog detection and comparative genomics
│   ├── inparanoid/           InParanoid ortholog clustering (with Ghostz)
│   ├── rbh/                  Reciprocal best hit (BLAST / DIAMOND)
│   └── mutation_number/      Mutation number counting (BASEML-based)
├── phylogenetics/            Phylogenetic reconstruction and dating
│   ├── tree_reconstruction/  MPEST, ASTRAL, RAxML, ExaML, DensiTree
│   └── divergence_time/      MCMCTree divergence time estimation
├── genome_analysis/          Genome sequence analysis and MAF utilities
│   ├── maf_related/          MAF format utilities (distance, coordinates, synteny)
│   ├── maf_extract_gene/     Extract genes from MAF alignments
│   ├── assembly/             Reference-based genome assembly from MAF
│   ├── pseudogene/           Pseudogene detection
│   └── ensembl_extract/      Extract gene symbols and GO from Ensembl .dat files
├── transcriptomics/          Transcriptome and expression analysis
│   ├── transcriptome/        CDS extraction, read counting
│   ├── deg/                  Differentially expressed gene analysis
│   └── kmeans/               K-means clustering of expression data
├── gwas/                     Genome-wide association studies
│   ├── plink/                PLINK-based GWAS pipeline
│   ├── emmax/                EMMAX mixed-model GWAS
│   └── gemma/                GEMMA GWAS
├── reseq_pipeline/           Complete whole-genome resequencing pipeline
│   ├── mappability/          Mappability track generation
│   ├── bwa_mem/              BWA-MEM alignment, dedup, realignment
│   ├── call_snp/             GATK HaplotypeCaller SNP calling
│   ├── call_snp_haplotypeCaller/ GATK HC pipeline (alternative)
│   ├── samtools_callSNP/     Samtools/bcftools SNP calling pipeline
│   ├── basicAnalysis/        NJ tree, PCA, ADMIXTURE, kinship, ROH
│   ├── angsd/                ANGSD-based SFS and FST calculation
│   ├── population_history/   PSMC, Stairway Plot, SMC++ (within pipeline)
│   ├── linkage_disequilibrium/ LD decay calculation
│   ├── recombination/        Recombination rate (fastEPRR within pipeline)
│   ├── genome_island/        Divergence island detection (HMM-based)
│   └── window_scan/          Generic window-based statistics
└── resources/
    └── housekeeping_genes/   Curated housekeeping gene list
```

---

## Module Details

### utils/

| Directory | Description | Language |
|-----------|-------------|----------|
| `fasta/` | FASTA/FASTQ quality check, format conversion, splitting, Nanopore filtering, sequence reading utilities | Perl |
| `vcf/` | VCF splitting, thinning, BED extraction, individual removal, Beagle/Chromopainter conversion | Perl |
| `gff/` | GFF→CDS extraction, gene length statistics, 0-fold/4-fold site detection, pick longest transcript, CDS→protein translation | Perl, Python |
| `misc/` | BAM statistics, dXY calculation, distance matrix, IBD statistics, ROH extraction, read count, server monitoring, task splitting | Perl |

### population_genetics/

| Directory | Description | Language |
|-----------|-------------|----------|
| `dadi_fsc/` | Demographic inference using dadi (one-pop and two-pop models: isolation, migration, exponential growth, bottleneck) and fastsimcoal2. Includes bootstrap and gene flow model comparisons. | Python, Perl |
| `psmc/` | Pairwise Sequentially Markovian Coalescent (PSMC) for inferring historical Ne from individual diploid genomes | Shell, Perl |
| `smcpp/` | SMC++ Ne inference; converts VCF to SMC++ input, runs estimation and plotting | Perl, Shell |
| `stairway_plot/` | Stairway Plot Ne inference from SFS; prepares blueprint files and runs Step 1 & 2 | Perl, Shell |
| `treemix/` | Converts VCF to TreeMix format for population graph estimation | Perl |
| `beagle_hwe/` | Haplotype phasing with BEAGLE; Hardy-Weinberg Equilibrium filtering and REF/ALT correction | Perl, Shell |
| `ibd_analysis/` | Identity-by-Descent segment detection and population-level IBD statistics | Perl |
| `saguaro/` | SAGUARO genome-wide HMM for local phylogeny inference; tree building and chromosome visualization | Perl, Shell |
| `fastEPRR/` | FastEPRR recombination rate estimation from phased VCF data | Perl |

### selection/

| Directory | Description | Language |
|-----------|-------------|----------|
| `ihs/` | iHS (integrated haplotype score) via selscan; converts phased VCF to haplotype format, computes and normalizes iHS | Perl, Shell |
| `kaks_calculator/` | Ka/Ks calculation using KaKs_Calculator; collects and summarizes dN, dS, dN/dS results | Perl |
| `hyphy/` | HyPhy aBSREL and BUSTED episodic and gene-wide selection tests; includes stop codon filtering and result extraction | Perl |
| `paml/` | Positive selection with PAML branch, branch-site, and free-ratio models from MAF-derived alignments | Perl |

### functional_annotation/

| Directory | Description | Language |
|-----------|-------------|----------|
| `go_analysis/` | GO term assignment, hierarchical up-leveling, and GO enrichment analysis | Perl |
| `kegg_analysis/` | KEGG pathway standardization and enrichment | Perl |
| `kegg_enrichment/` | KEGG enrichment with Fisher's test, FDR, and Bonferroni corrections | Perl |
| `panther/` | PANTHER functional annotation via direct API and InterProScan output parsing | Perl, Shell |
| `enrichment_python/` | GO and KEGG enrichment using Python (pandas, scipy); sample annotation file included | Python |

### gene_annotation/

| Directory | Description | Language |
|-----------|-------------|----------|
| `prediction/` | Gene prediction pipeline: Trinity transcriptome assembly, BLAT protein/transcript alignment, GeneWise evidence integration | Perl, Shell |
| `gene_structure/` | Gene structure statistics from GFF3: CDS length, exon count, intron length, mRNA length; visualization with R | Perl, R |
| `merge_gff/` | Merge multiple GFF files; convert Augustus GFF output to standard format | Perl |
| `manual_check/` | Manual gene model verification using BLAST and GeneWise; converts GeneWise output to GFF | Shell, Perl |
| `novel_gene/` | Novel gene detection based on MAF alignments or Ghostz all-vs-all comparison | Perl |
| `chloroplast/` | Convert chloroplast GenBank records to NCBI TBL format for submission | Perl |
| `tm_predictor/` | Transmembrane domain prediction using a scoring matrix approach | Perl |

### orthology/

| Directory | Description | Language |
|-----------|-------------|----------|
| `inparanoid/` | Ortholog clustering with InParanoid algorithm; supports BLAST and Ghostz input; one-to-one ortholog extraction | Perl |
| `rbh/` | Reciprocal best hit ortholog identification with BLAST and DIAMOND backends | Perl |
| `mutation_number/` | Count lineage-specific mutations using BASEML ancestral reconstruction and MEGA | Perl, Shell |

### phylogenetics/

| Directory | Description | Language |
|-----------|-------------|----------|
| `tree_reconstruction/` | Full phylogenetic pipeline: tree rooting, MPEST species tree, ASTRAL coalescent tree, RAxML/ExaML ML trees, bootstrap analysis, DensiTree window trees, tree topology classification | Perl, Shell |
| `divergence_time/` | Bayesian divergence time estimation with MCMCTree (PAML); includes BASEML gradient/Hessian approximation step | Perl, MCMCTree CTL |

### genome_analysis/

| Directory | Description | Language |
|-----------|-------------|----------|
| `maf_related/` | MAF format utilities: pairwise distance calculation, coordinate conversion, synteny plotting, VCF/list conversion, multiz/roast wrappers | Perl, Shell |
| `maf_extract_gene/` | Extract gene sequences from MAF alignments keyed on GFF annotations; coordinate conversion across assemblies | Perl |
| `assembly/` | Reference-based genome assembly: generate consensus sequences from MAF blocks | Perl |
| `pseudogene/` | Pseudogene detection from MAF projections | Perl, Shell |
| `ensembl_extract/` | Extract gene symbols, sequences, and GO terms from Ensembl GenBank flat files | Perl |

### transcriptomics/

| Directory | Description | Language |
|-----------|-------------|----------|
| `transcriptome/` | CDS extraction and alignment (MAFFT, Gblocks), RNA-seq read counting per gene | Perl |
| `deg/` | Differentially expressed gene analysis and cross-sample correlation | Perl, R |
| `kmeans/` | K-means clustering of TPM expression data across tissues; cluster visualization | Python |

### gwas/

Three GWAS backends: **PLINK** (basic association, Manhattan plot), **EMMAX** (mixed model, kinship matrix via KING), **GEMMA** (LMM association).

### reseq_pipeline/

A complete whole-genome resequencing analysis pipeline. Start from raw reads and proceed through alignment → SNP calling → population genetics. Key modules:

- **bwa_mem/** — Alignment, duplicate removal, local realignment, depth statistics
- **call_snp/** — GATK HaplotypeCaller per-sample gVCF, joint genotyping, hard filtering
- **samtools_callSNP/** — Alternative bcftools-based SNP calling with depth/quality filtering
- **basicAnalysis/** — NJ tree, PCA, ADMIXTURE, kinship/relatedness, inbreeding, ROH, heterozygosity
- **angsd/** — ANGSD-based SFS (one-pop, two-pop, three-pop), θ estimation, FST
- **population_history/** — PSMC, Stairway Plot, SMC++ integrated into the pipeline
- **linkage_disequilibrium/** — LD r² calculation and decay fitting
- **genome_island/** — FST/dXY window scans with HMM-based divergence island detection

---

## Quick Reference by Analysis Type

| Analysis | Directory |
|----------|-----------|
| Population size history (Ne) | `population_genetics/psmc`, `smcpp`, `stairway_plot` |
| Demographic modeling | `population_genetics/dadi_fsc` |
| Population structure | `population_genetics/treemix`, `reseq_pipeline/basicAnalysis` |
| Recombination rate | `population_genetics/fastEPRR`, `reseq_pipeline/recombination` |
| IBD / relatedness | `population_genetics/ibd_analysis`, `reseq_pipeline/basicAnalysis` |
| Positive selection (iHS) | `selection/ihs` |
| Positive selection (dN/dS) | `selection/kaks_calculator`, `selection/paml`, `selection/hyphy` |
| GWAS | `gwas/` |
| SNP calling | `reseq_pipeline/call_snp`, `reseq_pipeline/samtools_callSNP` |
| Alignment | `reseq_pipeline/bwa_mem` |
| Gene prediction | `gene_annotation/prediction` |
| Gene structure stats | `gene_annotation/gene_structure` |
| Ortholog detection | `orthology/inparanoid`, `orthology/rbh` |
| Phylogenetic tree | `phylogenetics/tree_reconstruction` |
| Divergence time | `phylogenetics/divergence_time` |
| GO enrichment | `functional_annotation/go_analysis`, `enrichment_python` |
| KEGG enrichment | `functional_annotation/kegg_enrichment`, `enrichment_python` |
| Transcriptome / expression | `transcriptomics/` |
| MAF alignment utilities | `genome_analysis/maf_related`, `maf_extract_gene` |
| FASTA / VCF / GFF utilities | `utils/fasta`, `utils/vcf`, `utils/gff` |
