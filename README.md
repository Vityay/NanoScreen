# NanoScreen
Code reposaitory for the manuscript "Analysis of data from genome-wide forward screening to identify receptors and proteins mediating nanoparticle
uptake and intracellular processing" by Montizaan et al, 2024.

**Dependencies:**
Samtools (https://github.com/samtools/samtools);
Bowtie2 (https://bowtie-bio.sourceforge.net/bowtie2);
Trimmomatic (https://github.com/usadellab/Trimmomatic);
Perl module Statistics::ChisqIndep (https://metacpan.org/pod/Statistics::ChisqIndep)

**Preparations:**
1. Download genome reference, e.g. from Ensembl(http://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz)
2. Download gene annotation, e.g. from Ensembl(http://ftp.ensembl.org/pub/current_gtf/homo_sapiens/Homo_sapiens.GRCh38.111.gtf.gz)
3. Unpack and index genome reference: gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz; bowtie2-build Homo_sapiens.GRCh38.dna.primary_assembly.fa GRCh38

**Running the pipeline**
1. Trimmming: Place fastq files (*.fastq.gz) data to the same folder and run step1_trim.sh script, this will create trimmed version of fastq files (*_trimmed.fq.gz)
2. Aligning: If you are using a reference different from GRCh38 (pr gave it a different name during Preparations step 3), change it (line 5) and run script step2.align.sh The step should produce sorted BAM file for each library (*_srt.bam)
3. Quantify inserts coverage: Run script step3_quantify_coverage.pl. this should files with insert coverage profiles (*_peaks.bed)
4. Annotate peaks with gene names: Change the name of gene annotatation (GTF) file in line 4, if neccessary and run script step4_annotate.pl The step should produce annotated file (*_anno.txt)
5. Remove redundant 'neighboring' inserts: Run script step5_remove_neighbors.pl, it will create filtered annotated sets ready for the final analysis (*_anno_filtered.txt)
6. Run testing of screen vs background libraries: step6_test.pl <screen_anno_filtered.txt> <background_anno_filtered.txt> The resulting file will contain stats on insert numbers and statistics tests (Chi Square text, nominal p-values)




