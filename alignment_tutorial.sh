#!/bin/bash
# 10m to complete as a script 
# All commands take < 10s unless otherwise stated

cd ~/ChIP-seq
bowtie --help
time bowtie-build bowtie_index/mm9.fa bowtie_index/mm9               # 8m20s
ls -l bowtie_index
time bowtie bowtie_index/mm9 -S Oct4.fastq > Oct4.sam                # 30s
head -n 10 Oct4.sam
samtools view -bSo Oct4.bam Oct4.sam
samtools flagstat Oct4.bam
samtools sort Oct4.bam Oct4.sorted
samtools index Oct4.sorted.bam
genomeCoverageBed -bg -ibam Oct4.sorted.bam \
  -g bowtie_index/mouse.mm9.genome > Oct4.bedgraph
bedGraphToBigWig Oct4.bedgraph \
  bowtie_index/mouse.mm9.genome Oct4.bw
# open Oct4.sorted.bam and Oct4.bw in IGV


time bowtie bowtie_index/mm9 -S gfp.fastq > gfp.sam                  # 30s
head -n 10 gfp.sam
samtools view -bSo gfp.bam gfp.sam
samtools flagstat gfp.bam
samtools sort gfp.bam gfp.sorted
samtools index gfp.sorted.bam
genomeCoverageBed -bg -ibam gfp.sorted.bam \
  -g bowtie_index/mouse.mm9.genome > gfp.bedgraph
bedGraphToBigWig gfp.bedgraph \
  bowtie_index/mouse.mm9.genome gfp.bw
# open gfp.sorted.bam and gfp.bw in IGV

