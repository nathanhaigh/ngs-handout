#!/bin/bash
#######
# Obtain free memory from /proc:
# `sudo fgrep MemFree /proc/meminfo | awk '{print $2}'`
#######

#top_dir='/mnt/NGS_workshop'
#data_sub_dir='data'
#dl_sub_dir='downloads'
#working_dir='working_dir'
#trainee_user='ngstrainee'
#module_dir='de_novo'


##############
### Part 1 ###
##############

# Part 1.1
cd
pwd
mkdir -p NGS/velvet/{part1,part2,part3}
ls -R NGS;
cd NGS/velvet/part1; pwd;

# Part 1.2
cd ~/NGS/velvet/part1; pwd;
cp ~/NGS/Data/velvet_1.2.07.tgz . ;
tar xzf velvet_1.2.07.tgz;
ls -R; cd velvet_1.2.07;
make velveth velvetg;
./velveth

ls --color=always;

make clean; make velveth velvetg MAXKMERLENGTH=41 CATEGORIES=3;
./velveth

make clean; make MAXKMERLENGTH=41 CATEGORIES=3 color
./velveth_de

# Part 1.3
cd ~/NGS/velvet/part1
mkdir SRS004748 
cd SRS004748
pwd
ln -s ~/NGS/Data/SRR022825.fastq.gz . 
ln -s ~/NGS/Data/SRR022823.fastq.gz . 
ls -l

velveth run_25 25 -fastq.gz -short SRR022825.fastq.gz SRR022823.fastq.gz

cd run_25; 
ls -l;
head Sequences;
cat Log;

cd ..
time velvetg run_25

cd run_25; ls -l;

cp contigs.fa contigs.fa.0
gnx -min 100 -nx 25,50,75 contigs.fa

R
library(plotrix) 
x11()
data <- read.table("stats.txt", header=TRUE)
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
# create a PNG image file for inclusion in the tutorial
png(width=8,height=4,units='in',res=300)
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
dev.off()

q()
n

cd ~/NGS/velvet/part1/SRS004748
time velvetg run_25 -cov_cutoff 6
# Make a copy of the run
cp run_25/contigs.fa run_25/contigs.fa.1

time velvetg run_25 -exp_cov 14
cp run_25/contigs.fa run_25/contigs.fa.2

time velvetg run_25 -cov_cutoff 6 -exp_cov 14
cp run_25/contigs.fa run_25/contigs.fa.3

velvetg run_25 -cov_cutoff 6 -amos_file yes

bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg
#hawkeye run_25/velvet_asm.bnk

rm -r run_25/velvet_asm.bnk

velvetg run_25 -cov_cutoff 6 -exp_cov 14 -amos_file yes

bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg
#hawkeye run_25/velvet_asm.bnk

# Part 1.4
cd ~/NGS/velvet/part1/ 
mkdir MRSA252 
cd MRSA252

ln -s ~/NGS/Data/s_aureus_mrsa252.EB1_s_aureus_mrsa252.dna.chromosome.Chromosome.fa.gz .
ls -l

velveth_long run_25 25 -fasta.gz -long \
  s_aureus_mrsa252.EB1_s_aureus_mrsa252.dna.chromosome.Chromosome.fa.gz
velvetg_long run_25


##############
### Part 2 ###
##############
# Part 2.1
cd ~/NGS/velvet/part2 
mkdir SRS004748 
cd SRS004748

ln -s ~/NGS/Data/SRR022852_?.fastq.gz .

#top

velveth run_25 25 -fmtAuto -create_binary \
  -shortPaired -separate SRR022852_1.fastq.gz SRR022852_2.fastq.gz
time velvetg run_25

mv run_25/contigs.fa run_25/contigs.fa.0
time velvetg run_25 -cov_cutoff 16

mv run_25/contigs.fa run_25/contigs.fa.1
time velvetg run_25 -cov_cutoff 16 -exp_cov 26

mv run_25/contigs.fa run_25/contigs.fa.2
time velvetg run_25 -cov_cutoff 16 -exp_cov 26 -ins_length 350
mv run_25/contigs.fa run_25/contigs.fa.3

gnx -min 100 -nx 25,50,75 run_25/contigs.fa*

# optional bonus
time velvetg run_25 -cov_cutoff 16 -exp_cov 26 -ins_length 350 \
  -amos_file yes -read_trkg yes 
time bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg         
#hawkeye run_25/velvet_asm.bnk
asmQC -b run_25/velvet_asm.bnk -scaff -recompute -update -numsd 2
#hawkeye run_25/velvet_asm.bnk


# Part 2.2
cd ~/NGS/velvet/part2 
mkdir SRX008042 
cd SRX008042

ln -s ~/NGS/Data/SRR023408_?.fastq.gz .

#fastqc &

gunzip < SRR023408_1.fastq.gz > SRR023408_1.fastq
gunzip < SRR023408_2.fastq.gz > SRR023408_2.fastq
fastx_trimmer -Q 33 -f 4 -l 32 \
  -i SRR023408_1.fastq -o SRR023408_trim1.fastq 
fastx_trimmer -Q 33 -f 3 -l 29 \
  -i SRR023408_2.fastq -o SRR023408_trim2.fastq

velveth run_21 21 -fmtAuto -create_binary \
  -shortPaired -separate SRR023408_1.fastq SRR023408_2.fastq
time velvetg run_21 
velveth run_21trim 21 -fmtAuto -create_binary \
  -shortPaired -separate SRR023408_trim1.fastq SRR023408_trim2.fastq
time velvetg run_21trim

R
library(plotrix) 
data <- read.table("run_21/stats.txt", header=TRUE) 
data2 <- read.table("run_21trim/stats.txt", header=TRUE) 
x11()
par(mfrow=c(1,2))
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
weighted.hist(data2$short1_cov, data2$lgth, breaks=0:50)
# create a PNG image file for inclusion in the tutorial
png(width=10,height=5,units='in',res=300)
par(mfrow=c(1,2))
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
weighted.hist(data2$short1_cov, data2$lgth, breaks=0:50)
dev.off()

q()
n
time velvetg run_21 -cov_cutoff 7 -exp_cov 13 -ins_length 92
time velvetg run_21trim -cov_cutoff 5 -exp_cov 9 -ins_length 92


##############
### Part 3 ###
##############
# Part 3.1
cd ~/NGS/velvet/part3
mkdir SRX000181
cd SRX000181

cd ~/NGS/velvet/part3/SRX000181
ln -s ~/NGS/Data/SRR000892.fastq.gz
ln -s ~/NGS/Data/SRR000893.fastq.gz
velveth run_25 25 -create_binary -fastq.gz -long *.fastq.gz
time velvetg run_25

R
library(plotrix) 
data <- read.table("run_25/stats.txt", header=TRUE) 
x11() 
weighted.hist(data$long_cov, data$lgth, breaks=0:50)
# create a PNG image file for inclusion in the tutorial
png(width=8,height=4,units='in',res=300)
weighted.hist(data$long_cov, data$lgth, breaks=0:50)
dev.off()

q()
n
cp run_25/contigs.fa run_25/contigs.fa.0

time velvetg run_25 -long_cov_cutoff 9
cp run_25/contigs.fa run_25/contigs.fa.1

time velvetg run_25 -long_cov_cutoff 9 -exp_cov 19
cp run_25/contigs.fa run_25/contigs.fa.2

gnx -min 100 -nx 25,50,75 run_25/contigs.fa.*

# Part 3.2
cd ~/NGS/velvet/part3
mkdir SRP001086
cd SRP001086
ln -s ~/NGS/Data/SRR022863_?.fastq.gz .
ln -s ~/NGS/Data/SRR022852_?.fastq.gz .

time velveth run_25 25 -fmtAuto -create_binary \
  -shortPaired -separate SRR022863_1.fastq.gz SRR022863_1.fastq.gz \
  -shortPaired2 -separate SRR022852_1.fastq.gz SRR022852_2.fastq.gz
time velvetg run_25

R
library(plotrix) 
data <- read.table("run_25/stats.txt", header=TRUE) 
weighted.hist(data$short1_cov+data$short2_cov, data$lgth, breaks=0:70)
# create a PNG image file for inclusion in the tutorial
png(width=8,height=4,units='in',res=300)
weighted.hist(data$short1_cov+data$short2_cov, data$lgth, breaks=0:70)
dev.off()

q()
n
cp run_25/contigs.fa run_25/contigs.fa.0

time velvetg run_25 -cov_cutoff 20 
cp run_25/contigs.fa run_25/contigs.fa.1

time velvetg run_25 -cov_cutoff 20 -exp_cov 36 
cp run_25/contigs.fa run_25/contigs.fa.2

time velvetg run_25 -cov_cutoff 20 -exp_cov 36 \
  -ins_length 170 \
  -ins_length2 350
cp run_25/contigs.fa run_25/contigs.fa.3

gnx -min 100 -nx 25,50,75 run_25/contigs.fa.*

# optional bonus
ls ~/NGS/velvet/part2/SRX008042/SRR023408_trim?.fastq
# precomputed files available in necessary
ls ~/NGS/Data/SRR023408_trim?.fastq
tar xzf ~/NGS/Data/velvet_1.2.07.tgz;
cd velvet_1.2.07;
make velveth velvetg CATEGORIES=3
./velveth

cd ~/NGS/velvet/part3/SRP001086
time ./velvet_1.2.07/velveth run_25 25 -fmtAuto -create_binary \
  -shortPaired -separate SRR022863_1.fastq.gz SRR022863_1.fastq.gz \
  -shortPaired2 -separate SRR022852_1.fastq.gz SRR022852_2.fastq.gz \
  -shortPaired3 -separate ~/NGS/velvet/part2/SRX008042/SRR023408_trim1.fastq ~/NGS/velvet/part2/SRX008042/SRR023408_trim2.fastq
time ./velvet_1.2.07/velvetg run_25
R
library(plotrix)
data <- read.table("run_25/stats.txt", header=TRUE)
weighted.hist(data$short1_cov+data$short2_cov, data$lgth, breaks=0:70)
q()
n
cp run_25/contigs.fa run_25/contigs.fa.4
time ./velvet_1.2.07/velvetg run_25 -cov_cutoff 20 -exp_cov 43 \
  -ins_length 170 \
  -ins_length2 350 \
  -ins_length3 92
cp run_25/contigs.fa run_25/contigs.fa.5
gnx -min 100 -nx 25,50,75 run_25/contigs.fa.*

# Part 3.3
cd ~/NGS/velvet/part3
mkdir SRR000892-SRR022863 
cd SRR000892-SRR022863
ln -s ~/NGS/Data/SRR00089[2-3].fastq.gz .
ln -s ~/NGS/Data/SRR022863_?.fastq.gz .

time velveth run_25 25 -fmtAuto -create_binary \
  -long SRR00089?.fastq.gz \
  -shortPaired -separate SRR022863_1.fastq.gz SRR022863_2.fastq.gz
time velvetg run_25 
time velvetg run_25 -cov_cutoff 7 -long_cov_cutoff 9








cd $top_dir/$working_dir/$module_dir
mkdir -p velvet/{part1,part2,part3}
ls -R
cd velvet/part1; pwd;
cd $top_dir/$working_dir/$module_dir/velvet/part1; pwd;
wget http://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.07.tgz;
tar xzf velvet_1.2.07.tgz;
ls -R; cd velvet_1.2.07;
make velveth velvetg;
./velveth
ls --color=always;
make clean; make velveth velvetg MAXKMERLENGTH=41 CATEGORIES=3;
./velveth
make clean; make MAXKMERLENGTH=41 CATEGORIES=3 color
./velveth_de
# Single-ended assembly
cd $top_dir/$working_dir/$module_dir/velvet/part1
mkdir SRS004748
cd SRS004748
pwd
ln -s $top_dir/$working_dir/$module_dir/Data/SRR022825.fastq.gz 
ln -s $top_dir/$working_dir/$module_dir/Data/SRR022823.fastq.gz
ls -l
velveth run_25 25 -fastq.gz -short SRR022825.fastq.gz SRR022823.fastq.gz      # 1m15s
cd run_25; 
ls -l;
less Roadmaps
q
head Sequences;
cat Log;
cd ../
time velvetg run_25                                                           # 1m15s
cd run_25; ls -l;
cp contigs.fa contigs.fa.0
gnx -min 100 -nx 25,50,75 contigs.fa
R
library(plotrix) 
x11()
data = read.table("stats.txt", header=TRUE)
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
q()
n
cd $top_dir/$working_dir/$module_dir/velvet/part1/SRS004748
time velvetg run_25 -cov_cutoff 6                                             # 9s
cp run_25/contigs.fa run_25/contigs.fa.1
time velvetg run_25 -exp_cov 14                                               # 50s
cp run_25/contigs.fa run_25/contigs.fa.2
time velvetg run_25 -cov_cutoff 6 -exp_cov 14                                 # 20s
cp run_25/contigs.fa run_25/contigs.fa.3
velvetg run_25 -cov_cutoff 6 -amos_file yes                                   # 9s
time bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg
hawkeye run_25/velvet_asm.bnk
rm -r run_25/velvet_asm.bnk
velvetg run_25 -cov_cutoff 6 -exp_cov 14 -amos_file yes                       # 20s
time bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg       # 5m
hawkeye run_25/velvet_asm.bnk
tablet run_25/velvet_asm.afg                                                  # 5m

# part 1.4
cd $top_dir/$working_dir/$module_dir/velvet/part1/ 
mkdir MRSA252 
cd MRSA252
ln -s $top_dir/$working_dir/$module_dir/Data/s_aureus_mrsa252.EB1_s_aureus_mrsa252.dna.chromosome.Chromosome.fa.gz
time velveth_long run_25 25 -fasta.gz -long \
  s_aureus_mrsa252.EB1_s_aureus_mrsa252.dna.chromosome.Chromosome.fa.gz       # 20s
time velvetg_long run_25                                                      # 7s

# Paired-end assembly
cd $top_dir/$working_dir/$module_dir/velvet/part2 
mkdir SRS004748 
cd SRS004748
ln -s $top_dir/$working_dir/$module_dir/Data/SRR022852_1.fastq.gz
ln -s $top_dir/$working_dir/$module_dir/Data/SRR022852_2.fastq.gz
ls -lHh SRR022852_?.fastq.gz

time velveth run_25 25 -fmtAuto -shortPaired -separate SRR022852_1.fastq.gz SRR022852_2.fastq.gz  # 4m30s

# ignores paired-ends
time velvetg run_25                                                 # 3m
mv run_25/contigs.fa run_25/contigs.fa.0

time velvetg run_25 -cov_cutoff 16                                  # 18s
mv run_25/contigs.fa run_25/contigs.fa.1

# consider paired-ends
time velvetg run_25 -cov_cutoff 16 -exp_cov 26                      # 2m
mv run_25/contigs.fa run_25/contigs.fa.2

# run in paired-end mode
time velvetg run_25 -cov_cutoff 16 -exp_cov 26 -ins_length 350      # 50s
mv run_25/contigs.fa run_25/contigs.fa.3

gnx -min 100 -nx 25,50,75 run_25/contigs.fa*






time velvetg run_25 -cov_cutoff 16 -exp_cov 26 -ins_length 350 -amos_file yes   # 2m
time bank-transact -c -b run_25/velvet_asm.bnk -m run_25/velvet_asm.afg         # 5m30s
hawkeye run_25/velvet_asm.bnk

asmQC -b run_25/velvet_asm.bnk -scaff -recompute -update -numsd 2               # 2m30s
hawkeye run_25/velvet_asm.bnk

# Part 2.2 - Data Quality
cd $top_dir/$working_dir/$module_dir/velvet/part2
mkdir SRX008042 
cd SRX008042
ln -s $top_dir/$working_dir/$module_dir/Data/SRR023408_?.fastq.gz .
fastqc
exit
# pipe gunzip output into a modified version of trimFastqReads.pl
gunzip < SRR023408_1.fastq.gz > SRR023408_1.fastq
gunzip < SRR023408_2.fastq.gz > SRR023408_2.fastq
time fastx_trimmer -Q 33 -f 4 -l 32 \
  -i SRR023408_1.fastq -o SRR023408_trim1.fastq 
time fastx_trimmer -Q 33 -f 4 -l 32 \
  -i SRR023408_2.fastq -o SRR023408_trim2.fastq 
time perl /usr/bin/trimFastqReads.pl 4 32 SRR023408_trim1.fastq SRR023408_1.fastq             # 1m30s
time perl /usr/bin/trimFastqReads.pl 3 29 SRR023408_trim2.fastq SRR023408_2.fastq             # 1m30s

velveth run_21 21 -fastq -shortPaired -separate SRR023408_1.fastq SRR023408_2.fastq                 # 3m30s
time velvetg run_21                                                                                 # 7m
velveth run_21trim 21 -fastq -shortPaired -separate SRR023408_trim1.fastq SRR023408_trim2.fastq     # 3m15s
time velvetg run_21trim                                                                             # 2m40s

R
library(plotrix)
data <- read.table("run_21/stats.txt", header=TRUE) 
data2 <- read.table("run_21trim/stats.txt", header=TRUE)
x11()
#pdf() 
par(mfrow=c(1,2))
weighted.hist(data$short1_cov, data$lgth, breaks=0:50)
weighted.hist(data2$short1_cov, data2$lgth, breaks=0:50)
#dev.off()
q()
n

time velvetg run_21 -cov_cutoff 7 -exp_cov 13 -ins_length 92        # 5m50
time velvetg run_21trim -cov_cutoff 5 -exp_cov 9 -ins_length 92     # 2m

#SRR022852
#SRR023408
#SRR023408.trimmed

# Part 3.1
cd ~/NGS/velvet/part3
mkdir SRX000181
cd SRX000181

cd ~/NGS/velvet/part3/SRX000181
ln -s ~/NGS/Data/SRR000892.fastq.gz
ln -s ~/NGS/Data/SRR000893.fastq.gz
time velveth run_25 25 -fastq.gz -long *.fastq.gz
time velvetg run_25

R
library(plotrix)
data <- read.table("run_25/stats.txt", header=TRUE)
x11() 
weighted.hist(data$long_cov, data$lgth, breaks=0:50)
q()
n
cp run_25/contigs.fa run_25/contigs.fa.0
time velvetg run_25 -long_cov_cutoff 9
cp run_25/contigs.fa run_25/contigs.fa.1
time velvetg run_25 -long_cov_cutoff 9 -exp_cov 19
cp run_25/contigs.fa run_25/contigs.fa.2

gnx -min 100 -nx 25,50,75 run_25/contigs.fa.*

# Part 3.2
cd ~/NGS/velvet/part3
mkdir SRP001086
cd SRP001086
ln -s ~/NGS/Data/SRR022863_?.fastq.gz .
ln -s ~/NGS/Data/SRR022852_?.fastq.gz .

time velveth run_25 25 -fmtAuto \
  -shortPaired -separate SRR022863_1.fastq.gz SRR022863_1.fastq.gz \
  -shortPaired2 -separate SRR022852_1.fastq.gz SRR022852_2.fastq.gz			# 6m
time velvetg run_25									# 4m

R
library(plotrix) 
data <- read.table("run_25/stats.txt", header=TRUE) 
weighted.hist(data$short1_cov+data$short2_cov, data$lgth, breaks=0:70)
q()
n
cp run_25/contigs.fa run_25/contigs.fa.0

time velvetg run_25 -cov_cutoff 20 
cp run_25/contigs.fa run_25/contigs.fa.1

time velvetg run_25 -cov_cutoff 20 -exp_cov 36 
cp run_25/contigs.fa run_25/contigs.fa.2

time velvetg run_25 -cov_cutoff 20 -exp_cov 36 \
  -ins_length 170 \
  -ins_length2 350
cp run_25/contigs.fa run_25/contigs.fa.3

gnx -min 100 -nx 25,50,75 run_25/contigs.fa.*

# Part 3.3
cd ~/NGS/velvet/part3
mkdir SRR000892-SRR022863 
cd SRR000892-SRR022863
ln -s ~/NGS/Data/SRR00089[2-3]_?.fastq.gz .   
ln -s ~/NGS/Data/SRR022863_?.fastq.gz .




