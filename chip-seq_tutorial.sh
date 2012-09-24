#!/bin/bash
cd ~/ChIP-seq
macs --help
time macs -t Oct4.bam -c gfp.bam \
  --format=BAM --name=Oct4 --gsize=138000000 \
  --tsize=26 --diag --wig                                          # 2m20s

libreoffice Oct4_diag.xls Oct4_peaks.xls &

cd ~/ChIP-seq/PeakAnalyzer_1.4/
java -jar PeakAnalyzer.jar &

#firefox http://meme.sdsc.edu/meme/cgi-bin/meme.cgi &
firefox http://meme.ebi.edu.au/meme/cgi-bin/meme.cgi &

