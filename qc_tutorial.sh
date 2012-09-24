#!/bin/bash
# 25s tocomplete as a script
cd ~/QC
pwd
fastqc -h
fastqc -f fastq bad_example.fastq
fastqc -f fastq good_example.fastq

firefox bad_example_fastqc/fastqc_report.html good_example_fastqc/fastqc_report.html &

cd ~/QC
fastx_trimmer -h
time fastx_trimmer -Q 33 -f 1 -l 80 -i bad_example.fastq \
  -o bad_example_trimmed01.fastq
fastqc -f fastq bad_example_trimmed01.fastq
firefox bad_example_trimmed01_fastqc/fastqc_report.html &

cd ~/QC
fastq_quality_trimmer -h
time fastq_quality_trimmer \
  -Q 33 \
  -t 20 \
  -l 50 \
  -i bad_example.fastq \
  -o bad_example_quality_trimmed.fastq
fastqc -f fastq bad_example_quality_trimmed.fastq
firefox bad_example_quality_trimmed_fastqc/fastqc_report.html &

cd ~/QC
        fastx_clipper -h
time fastx_clipper -v -Q 33 -l 20 -M 15 \
  -a GATCGGAAGAGCGGTTCAGCAGGAATGCCGAG \
  -i bad_example.fastq -o bad_example_clipped.fastq
#fastqc -f fastq bad_example_clipped.fastq
#firefox bad_example_clipped_fastqc/fastqc_report.html &



# Picard not installed
#cd ~/QC
#java -jar MarkDuplicates.jar \
#  I=alignment_file.bam \
#  O=alignment_file.dup \
#  M=alignment_file.matric \
#  AS=true VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=Y/N

