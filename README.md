The setup_NGS_workshop script is for setting up a Cloud Biolinux VM (running on the NeCTAR research cloud or locally)
ready for running the NGS workshop.

The script is run on the VM using the ```ubuntu``` user. A copy of this script is available in Cloud storage
so the following commands can be executed on a Cloud BioLinux VM to prepare it for the NGS workshop:

First, ssh into the VM as user ```ubuntu```
pull down the bash setup script from cloud storage

    cd ~/
    wget https://raw.github.com/nathanhaigh/ngs_workshop/master/shell_scripts/setup_NGS_workshop.sh

Execute the bash script, ignore any warnings from sudo about being ```unable to resolve host```

    bash setup_NGS_workshop.sh

You may wish to see what's been setup and the total size of the NGS workshop data

    ls -lhR /mnt/NGS_workshop/
    du -h --max-depth=2 /mnt/NGS_workshop/

Script Details
==============
The ```setup_NGS_workshop.sh``` script will:
* Create a directory structure under ```/mnt/NGS_workshop```
* Create a data directory ```/mnt/NGS_workshop/data``` for storing the data required for the NGS tutorials
* Pull approx. 3.3GBytes of data from the NeCTAR Cloud storage into ```/mnt/NGS_workshop/data```
* Create a working directory structure under ```/mnt/NGS_workshop/working_dir```
* Create symlinks, to the appropriate data, under ```/mnt/NGS_workshop/working_dir```
* Create symlinks to subdirectories of ```/mnt/NGS_workshop/working_dir``` in ngstrainee's home and desktop

    /home/ngstrainee/
    /home/ngstrainee/Desktop/

Testing the VM
==============
Once the VM has been setup for the NGS workshop. You may also wish to test the VM by running 1 or more of
the tutorials test scripts on it.

The tutorial test scripts can be pulled from the NeCTAR Cloud Object Storage onto a VM using:

Connect to the VM using an NX Client as user: ```ngstrainee```
In a terminal, pull down the tutorial test scripts from cloud storage

    cd ~/
    wget https://github.com/nathanhaigh/ngs_workshop/edit/master/shell_scripts/qc_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/edit/master/shell_scripts/alignment_tutorial.sh 
    wget https://github.com/nathanhaigh/ngs_workshop/edit/master/shell_scripts/chip-seq_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/edit/master/shell_scripts/rna-seq_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/edit/master/shell_scripts/de_novo_tutorial.sh

Run, and time, the tutorials and redirect ```STDOUT``` and ```STDERR``` to files with something like:

    time bash qc_tutorial.sh > qc_stdout.log 2> qc_stderr.log
    time bash alignment_tutorial.sh > alignment_stdout.log 2> alignment_stderr.log
    time bash chip-seq_tutorial.sh > chip-seq_stdout.log 2> chip-seq_stderr.log
    time bash rna-seq_tutorial.sh > rna-seq_stdout.log 2> rna-seq_stderr.log
    time bash de_novo_tutorial.sh > de_novo_stdout.log 2> de_novo_stderr.log

Once testing is complete, delete the test files and logs

    rm *_tutorial.sh
    rm *_std{out,err}.log



Clean the VM For Another Workshop
=================================
If another workshop is to be run, then the NGS workshop working directory on the VM can be cleaned and
reinitialised without pulling down all the workshop data again. To do this, login to the VM as the ```ubuntu``` user
and execute the following commands:

    cd
    rm setup_NGS_workshop.sh
    sudo rm -rf /mnt/NGS_workshop/working_dir/
    sudo rm /home/ngstrainee/{ChIP-seq,NGS,QC,RNA-seq}
    sudo rm /home/ngstrainee/Desktop/{ChIP-seq,NGS,QC,RNA-seq}
    wget https://raw.github.com/nathanhaigh/ngs_workshop/master/shell_scripts/setup_NGS_workshop.sh
    bash setup_NGS_workshop.sh

Real Clean the VM
=================
ALL the NGS workshop data can be scrubbed from the VM by running the following commands as the ```ubuntu``` user:

    sudo rm /home/ngstrainee/{ChIP-seq,NGS,QC,RNA-seq}
    sudo rm /home/ngstrainee/Desktop/{ChIP-seq,NGS,QC,RNA-seq}
    sudo rm -rf /mnt/NGS_workshop
    rm ~/setup_NGS_workshop.sh
    