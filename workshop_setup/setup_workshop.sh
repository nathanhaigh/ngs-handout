#!/bin/bash

cleanup() {
  echo "Cleaning up the VM"
  # remove the working directory, this will be recreated shortly
  rm -rf "$top_dir/$working_dir"
  bash $0 -p "$top_dir" -d "$data_sub_dir" -w "$working_dir" -t "$trainee_user"
}
realclean() {
  echo "Removing all trace of this workshop from the VM"
  # remove the workshop directory
  rm -rf "$top_dir"
  # remove the module dirs from the user's home directory
  rm /home/$trainee_user/{QC,RNA-seq}
  # remove the module dirs from the user's Desktop
  rm /home/$trainee_user/Desktop/{QC,RNA-seq}
  rm $0
}

# default command line argument values
#####
#set -x
top_dir='/mnt/workshop'
data_sub_dir='data'
#dl_sub_dir='downloads'
working_dir='working_dir'
trainee_user='ngstrainee'

usage="USAGE: $(basename $0) [-h] [-p <absolute path>] [-d <relative path>] [-w <relative path>] [-t <trainee username>] [-c | -r] 
  Downloads documents and data for the Into. to Linux and RNA-Seq workshop, setting write permissions on the working directory for the specified user and creates convienient symlinks for said user.

  where:
    -h Show this help text
    -p Parent directory. Top level directory for all the workshop related content (default: /mnt/workshop)
    -d Data directory. Relative to the parent directory specified by -p (default: data)
    -w Working directory. Relative to the parent directory specified by -p  (default: working_dir)
    -t Trainee's username. Symlinks, to the workshop content, will be created under this users home directory (default: ngstrainee)
    -r Removes all trace of the workshop from the VM
    -c Cleanup the working directory. Removes the working directory and rerun this script with the same arguments this script was called with"

# parse any command line options to change default values
while getopts ":hp:d:w:t:rc" opt; do
  case $opt in
    h) echo "$usage"
       exit
       ;;
    p) top_dir=$OPTARG
       ;;
    d) data_sub_dir=$OPTARG
       ;;
    w) working_dir=$OPTARG
       ;;
    t) trainee_user=$OPTARG
       ;;
    r) realclean
       exit
       ;;
    c) cleanup
       exit
       ;;
    ?) printf "Illegal option: '-%s'\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo "$usage" >&2
      exit 1
      ;;
  esac
done

# Add $(hostname) to /etc/hosts
#sed -i -e "s/^\(127.0.0.1 localhost\)/\1 $(hostname)/" /etc/hosts

echo "Top level directory is: $top_dir"
if [ ! -d "$top_dir" ]; then
  echo "Creating top level directory: $top_dir"
  mkdir -p "$top_dir"
fi
if [ $(stat -c %U "$top_dir") != "$USER" ]; then
  echo "Making top level directory owned by $USER"
  chown "$USER" "$top_dir"
  chgrp "$USER" "$top_dir"
else
  echo "Top level directory already owned by $USER"
fi

# Create directory structure for data to be pulled from NeCTAR object storage
if [ ! -d "$top_dir/$data_sub_dir" ]; then
  echo "Creating raw data directory: $top_dir/$data_sub_dir"
  mkdir -p "$top_dir/$data_sub_dir"
else
  echo "Raw data directory already exists"
fi
#if [ ! -e "$top_dir/$dl_sub_dir" ]; then
#  echo "Creating directory for pre-downloaded tools: $top_dir/$dl_sub_dir"
#  mkdir -p "$top_dir/$dl_sub_dir"
#fi

if [ ! -d "$top_dir/$working_dir" ]; then
  echo "Creating working directory: $top_dir/$working_dir"
  mkdir -p "$top_dir/$working_dir"
else
  echo "Working directory already exists"
fi
if [ $(stat -c %U "$top_dir/$working_dir") != "$trainee_user" ]; then
  echo "Making working directory owned by $trainee_user"
  chown "$trainee_user" "$top_dir/$working_dir"
else
  echo "Working directory already owned by $trainee_user"
fi


# function for downloading files from cloud storage
# call it like this:
# download_file $file
function download_file() {
  local url="$1"
  echo -n "    $url ... "
  
  http_status_code=$(curl $url --location --silent --remote-time -z $top_dir/$data_sub_dir/${url##*/} -o $top_dir/$data_sub_dir/${url##*/} --write-out %{http_code})
  if [[ "$http_status_code" == "304" ]]; then
    echo "SKIPPED - Local file is up-to-date"
  elif [[ "$http_status_code" == "200" ]]; then
    echo "DOWNLOADED"
  elif [[ "$http_status_code" == "404" ]]; then
    echo "FILE NOT FOUND"
  else
    echo "NOT SURE WHAT HTTP STATUS CODE $http_status_code MEANS"
  fi
}

###############
## QC module ##
###############
module_dir='QC'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataQC/bad_example.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataQC/good_example.fastq'
)
echo "Setting up module: $module_dir"
# Download the QC files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  download_file $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -d "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd "$top_dir/$working_dir/$module_dir"
  ln -s $top_dir/$data_sub_dir/bad_example.fastq 
  ln -s $top_dir/$data_sub_dir/good_example.fastq

  # make tutorial paths sync with shorter paths used used in tutorials
  if [[ ! -e /home/$trainee_user/QC ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/QC"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/QC ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/QC"
  fi
else
  echo "Already exists"
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi
####################


####################
## RNA-seq module ##
####################
module_dir='RNA-seq'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_1.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_2.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_1.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_2.fastq'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.spliceSites'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.1.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.2.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.3.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.4.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.rev.1.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/ZV9.rev.2.ebwt'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.dna.fa'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/Danio_rerio.Zv9.66.dna.fa.fai'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/globalDiffExprs_Genes_qval.01_top100.tab'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_genes.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_genes.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_isoforms.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_isoforms.fpkm_tracking'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/6h_transcripts.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/2cells_transcripts.gtf'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.sorted.bam'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/accepted_hits.sorted.bam.bai'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/junctions.bed'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/deletions.bed'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_809/NGSDataRNASeq/insertions.bed'
)
echo "Setting up module: $module_dir"
# Download the RNA-seq files from cloud object storage
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  download_file $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -d "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd $top_dir/$working_dir/$module_dir
  mkdir -p $top_dir/$working_dir/$module_dir/{data,annotation,genome}
  cd $top_dir/$working_dir/$module_dir/data
  ln -s $top_dir/$data_sub_dir/2cells_1.fastq
  ln -s $top_dir/$data_sub_dir/2cells_2.fastq
  ln -s $top_dir/$data_sub_dir/6h_1.fastq
  ln -s $top_dir/$data_sub_dir/6h_2.fastq
  cd $top_dir/$working_dir/$module_dir/annotation
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.spliceSites
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.gtf
  cd $top_dir/$working_dir/$module_dir/genome
  ln -s $top_dir/$data_sub_dir/ZV9.1.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.2.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.3.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.4.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.rev.1.ebwt
  ln -s $top_dir/$data_sub_dir/ZV9.rev.2.ebwt
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.dna.fa
  ln -s $top_dir/$data_sub_dir/Danio_rerio.Zv9.66.dna.fa.fai
  mkdir -p $top_dir/$working_dir/$module_dir/{tophat,cufflinks,cuffdiff}
  cd $top_dir/$working_dir/$module_dir/cuffdiff
  ln -s $top_dir/$data_sub_dir/globalDiffExprs_Genes_qval.01_top100.tab
  mkdir -p $top_dir/$working_dir/$module_dir/cufflinks/{ZV9_2cells,ZV9_6h}_gtf_guided
  cd $top_dir/$working_dir/$module_dir/cufflinks/ZV9_2cells_gtf_guided
  ln -s $top_dir/$data_sub_dir/2cells_genes.fpkm_tracking genes.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/2cells_isoforms.fpkm_tracking isoforms.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/2cells_transcripts.gtf transcripts.gtf
  touch skipped.gtf
  cd $top_dir/$working_dir/$module_dir/cufflinks/ZV9_6h_gtf_guided
  ln -s $top_dir/$data_sub_dir/6h_genes.fpkm_tracking genes.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/6h_isoforms.fpkm_tracking isoforms.fpkm_tracking
  ln -s $top_dir/$data_sub_dir/6h_transcripts.gtf transcripts.gtf
  touch skipped.gtf
  mkdir -p $top_dir/$working_dir/$module_dir/tophat/ZV9_2cells
  cd $top_dir/$working_dir/$module_dir/tophat/ZV9_2cells
  ln -s $top_dir/$data_sub_dir/accepted_hits.bam
  ln -s $top_dir/$data_sub_dir/accepted_hits.sorted.bam
  ln -s $top_dir/$data_sub_dir/accepted_hits.sorted.bam.bai
  ln -s $top_dir/$data_sub_dir/junctions.bed
  ln -s $top_dir/$data_sub_dir/deletions.bed
  ln -s $top_dir/$data_sub_dir/insertions.bed
  # make tutorial paths sync with shorter paths used by the EBI folks
  if [[ ! -e /home/$trainee_user/RNA-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/RNA-seq"
  fi
  if [[ ! -e /home/$trainee_user/Desktop/RNA-seq ]]; then
    su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/RNA-seq"
  fi
else
  echo "Already exists"
fi

# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi

#########################

#####
# Setup for the Software Carpentry Shell workshop
#####
module_dir='swc_shell'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_33065ff5c34a4652aa2fefb292b3195a/SWC/swc_shell.tar.gz'
)
echo "Setting up module: $module_dir"
# Download the files
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  download_file $file
done

if [[ ! -d "$top_dir/$working_dir/$module_dir" ]]; then
    mkdir -p "$top_dir/$working_dir/$module_dir"
    cd "$top_dir/$working_dir/$module_dir"
    tar xzf $top_dir/$data_sub_dir/swc_shell.tar.gz
        
    if [[ ! -e /home/$trainee_user/shell ]]; then
        su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/shell"
    fi
    if [[ ! -e /home/$trainee_user/Desktop/shell ]]; then
        su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/shell"
    fi
fi
if [[ ! -d "/data/backup" ]]; then
    mkdir -p "/data/backup"
    whoami > /data/access.log 
    ifconfig > /data/network.cfg 
    cat /proc/cpuinfo > /data/hardware.cfg
fi
if [[ ! -d "/users" ]]; then
    mkdir -p "/users"
    ln -s /home/$trainee_user /users/vlad
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi

#####
# Setup for Advanced shell excercises
#####
module_dir='adv_shell'
files=(
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_33065ff5c34a4652aa2fefb292b3195a/ACAD_Mon/Commandline.zip'
  'https://swift.rc.nectar.org.au:8888/v1/AUTH_33065ff5c34a4652aa2fefb292b3195a/ACAD_Mon/words.zip'
)
echo "Setting up module: $module_dir"
# Download the files
echo "  Downloading data files ... "
cd "$top_dir/$data_sub_dir"
for file in "${files[@]}"
do
  download_file $file
done
if [[ ! -d "$top_dir/$working_dir/$module_dir" ]]; then
    mkdir -p "$top_dir/$working_dir/$module_dir"
    
    unzip -nd $top_dir/$data_sub_dir $top_dir/$data_sub_dir/Commandline.zip
    unzip -nd $top_dir/$data_sub_dir $top_dir/$data_sub_dir/words.zip
    
    cd $top_dir/$working_dir/$module_dir
    ln -s $top_dir/$data_sub_dir/{words,CP07-ospC.fas,CQ25-ospC.fas,dnasequence.fas,Hinf_genes.gff,Hinf_genome.fasta,Hinf_reads.fastq,JB13-ospC.fas,JG16-ospC.fas,YM89-ospC.fas} ./
    
    
    if [[ ! -e /home/$trainee_user/adv_shell ]]; then
        su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/adv_shell"
    fi
    if [[ ! -e /home/$trainee_user/Desktop/adv_shell ]]; then
        su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir /home/$trainee_user/Desktop/adv_shell"
    fi
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  chown -R "$trainee_user:$trainee_user" "$top_dir/$working_dir/$module_dir"
fi


