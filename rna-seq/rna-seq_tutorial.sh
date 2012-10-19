#!/bin/bash
# Approx 75-80m to complete as a script
cd ~/RNA-seq
ls -l data

tophat --help

head -n 20 data/2cells_1.fastq

time tophat --solexa-quals \
       -g 2 \
       --library-type fr-unstranded \
       -j annotation/Danio_rerio.Zv9.66.spliceSites\
       -o tophat/ZV9_2cells \
       genome/ZV9 \
       data/2cells_1.fastq data/2cells_2.fastq                  # 17m30s

time tophat --solexa-quals \
       -g 2 \
       --library-type fr-unstranded \
       -j annotation/Danio_rerio.Zv9.66.spliceSites\
       -o tophat/ZV9_6h \
       genome/ZV9 \
       data/6h_1.fastq data/6h_2.fastq                          # 17m30s

samtools index tophat/ZV9_2cells/accepted_hits.bam
samtools index tophat/ZV9_6h/accepted_hits.bam

cufflinks --help
time cufflinks  -o cufflinks/ZV9_2cells_gff \
 		 -G annotation/Danio_rerio.Zv9.66.gtf \
           -b genome/Danio_rerio.Zv9.66.dna.fa \
           -u \
           --library-type fr-unstranded \
           tophat/ZV9_2cells/accepted_hits.bam                  # 2m


time cufflinks  -o cufflinks/ZV9_6h_gff \
                 -G annotation/Danio_rerio.Zv9.66.gtf \
           -b genome/Danio_rerio.Zv9.66.dna.fa \
           -u \
           --library-type fr-unstranded \
           tophat/ZV9_6h/accepted_hits.bam                      # 2m

# guided assembly
time cufflinks  -o cufflinks/ZV9_2cells \
                 -g annotation/Danio_rerio.Zv9.66.gtf \
           -b genome/Danio_rerio.Zv9.66.dna.fa \
           -u \
           --library-type fr-unstranded \
           tophat/ZV9_2cells/accepted_hits.bam                  # 16m


time cufflinks  -o cufflinks/ZV9_6h \
                 -g annotation/Danio_rerio.Zv9.66.gtf \
           -b genome/Danio_rerio.Zv9.66.dna.fa \
           -u \
           --library-type fr-unstranded \
           tophat/ZV9_6h/accepted_hits.bam                      # 13m


time cuffdiff -o cuffdiff/ \
	    -L ZV9_2cells,ZV9_6h \
	    -T \
         -b genome/Danio_rerio.Zv9.66.dna.fa \
         -u \
         --library-type fr-unstranded \
         annotation/Danio_rerio.Zv9.66.gtf \
         tophat/ZV9_2cells/accepted_hits.bam \
         tophat/ZV9_6h/accepted_hits.bam                        # 7m

head -n 20 cuffdiff/gene_exp.diff

sort -t$'\t' -g -k 13 cuffdiff/gene_exp.diff \
  > cuffdiff/gene_exp_qval.sorted.diff

head -n 20 cuffdiff/gene_exp_qval.sorted.diff


