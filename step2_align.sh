#!/bin/bash

for f in *_trimmed.fq.gz
do
    bowtie2 -x GRCh38 -U "$f" | samtools view -bS - >"$f"_uns.bam
    samtools sort -o "$f"_srt.bam "$f"_uns.bam
    samtools index "$f"_srt.bam 
done