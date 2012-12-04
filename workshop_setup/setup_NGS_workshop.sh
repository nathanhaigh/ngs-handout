#!/bin/bash

cleanup() {
  echo "Cleaning up the VM"
  # remove the working directory, this will be recreated shortly
  sudo rm -rf "$top_dir/$working_dir"
  bash $0 -p "$top_dir" -d "$data_sub_dir" -w "$working_dir" -t "$trainee_user"
}
realclean() {
  echo "Removing all trace of this workshop from the VM"
  # remove the workshop directory
  sudo rm -rf "$top_dir"
  # remove the module dirs from the user's home directory
  sudo rm /home/$trainee_user/{QC,RNA-seq}
  # remove the module dirs from the user's Desktop
  sudo rm /home/$trainee_user/Desktop/{QC,RNA-seq}
  rm $0
}

# default command line argument values
#####
#set -x
top_dir='/mnt/BioInfoSummer'
data_sub_dir='data'
#dl_sub_dir='downloads'
working_dir='working_dir'
trainee_user='ngstrainee'

usage="USAGE: $(basename $0) [-h] [-p <absolute path>] [-d <relative path>] [-w <relative path>] [-t <trainee username>] [-c | -r] 
  Downloads documents and data for the BioInfoSummer NGS workshop, setting write permissions on the working directory for the specified user and creates convienient symlinks for said user.

  where:
    -h Show this help text
    -p Parent directory. Top level directory for all the workshop related content (default: /mnt/BioInfoSummer)
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

cloud_storage_url_prefix='https://swift.rc.nectar.org.au:8888/v1/AUTH_809'

# Add $(hostname) to /etc/hosts
#sudo sed -i -e "s/^\(127.0.0.1 localhost\)/\1 $(hostname)/" /etc/hosts

echo "Top level directory is: $top_dir"
if [ ! -e "$top_dir" ]; then
  echo "Creating top level directory: $top_dir"
  sudo mkdir -p "$top_dir"
fi
if [ $(stat -c %U "$top_dir") != "$USER" ]; then
  echo "Making top level directory owned by $USER"
  sudo chown "$USER" "$top_dir"
  chgrp "$USER" "$top_dir"
else
  echo "Top level directory already owned by $USER"
fi

# Create directory structure for data to be pulled from NeCTAR object storage
if [ ! -e "$top_dir/$data_sub_dir" ]; then
  echo "Creating raw data directory: $top_dir/$data_sub_dir"
  mkdir -p "$top_dir/$data_sub_dir"
else
  echo "Raw data directory already exists"
fi
#if [ ! -e "$top_dir/$dl_sub_dir" ]; then
#  echo "Creating directory for pre-downloaded tools: $top_dir/$dl_sub_dir"
#  mkdir -p "$top_dir/$dl_sub_dir"
#fi

if [ ! -e "$top_dir/$working_dir" ]; then
  echo "Creating working directory: $top_dir/$working_dir"
  mkdir -p "$top_dir/$working_dir"
else
  echo "Working directory already exists"
fi
if [ $(stat -c %U "$top_dir/$working_dir") != "$trainee_user" ]; then
  echo "Making working directory owned by $trainee_user"
  sudo chown "$trainee_user" "$top_dir/$working_dir"
else
  echo "Working directory already owned by $trainee_user"
fi


# function for downloading files from cloud storage
# call it like this:
# dl_file_from_cloud_storage $file
function dl_file_from_cloud_storage() {
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

## download the trainee's handout
#cd "$top_dir/$data_sub_dir"
#dl_file_from_cloud_storage http://cloud.github.com/downloads/nathanhaigh/ngs_workshop/trainee_handout_latest.pdf
#dl_file_from_cloud_storage http://cloud.github.com/downloads/nathanhaigh/ngs_workshop/trainer_handout_latest.pdf
#ln -s $top_dir/$data_sub_dir/trainee_handout_latest.pdf  $top_dir/$working_dir/handout.pdf
#ln -s $top_dir/$data_sub_dir/trainee_handout_latest.pdf  $top_dir/$working_dir/handout.pdf
## make tutorial paths sync with shorter paths used in tutorials
#if [[ ! -e ~/handout.pdf ]]; then
#  sudo su $trainee_user -c "ln -s $top_dir/$working_dir/handout.pdf ~/handout.pdf"
#fi
#if [[ ! -e ~/Desktop/handout.pdf ]]; then
#  sudo su $trainee_user -c "ln -s $top_dir/$working_dir/handout.pdf ~/Desktop/handout.pdf"
#fi

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
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
  mkdir -p "$top_dir/$working_dir/$module_dir"
  echo "DONE"
  cd "$top_dir/$working_dir/$module_dir"
  ln -s $top_dir/$data_sub_dir/bad_example.fastq 
  ln -s $top_dir/$data_sub_dir/good_example.fastq

  # make tutorial paths sync with shorter paths used used in tutorials
  if [[ ! -e ~/QC ]]; then
    sudo su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir ~/QC"
  fi
  if [[ ! -e ~/Desktop/QC ]]; then
    sudo su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir ~/Desktop/QC"
  fi
else
  echo "Already exists"
fi
# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  sudo chown -R "$trainee_user" "$top_dir/$working_dir/$module_dir"
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
  dl_file_from_cloud_storage $file
done
# Setup working directory and symlinks as expected by the tutorial
echo -n "  Creating working directory $top_dir/$working_dir/$module_dir ... "
if [ ! -e "$top_dir/$working_dir/$module_dir" ]; then
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
  if [[ ! -e ~/RNA-seq ]]; then
    sudo su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir ~/RNA-seq"
  fi
  if [[ ! -e ~/Desktop/RNA-seq ]]; then
    sudo su $trainee_user -c "ln -s $top_dir/$working_dir/$module_dir ~/Desktop/RNA-seq"
  fi
else
  echo "Already exists"
fi

# last thing to run for this module
if [ $(stat -c %U "$top_dir/$working_dir/$module_dir") != "$trainee_user" ]; then
  echo "  Making module's working directory ($top_dir/$working_dir/$module_dir) owned by $trainee_user"
  sudo chown -R "$trainee_user" "$top_dir/$working_dir/$module_dir"
fi

#########################
