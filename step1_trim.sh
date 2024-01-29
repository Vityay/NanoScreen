#!/bin/bash

for f in *.fastq.gz
do
    java -jar trimmomatic-0.33.jar SE -phred33 -trimlog "$f".trimlog "$f" "$f"_trimmed.fq.gz ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:20
done