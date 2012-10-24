The ```setup_NGS_workshop.sh``` script is for downloading the documents and data required for
this NGS workshop. It also makes the workshop's working directory writable by the specified
user and creates some convieient symlinks to the data under the specified user's home and desktop.

First, ssh into the VM as user ```ubuntu``` and pull down the bash setup script from github:

    cd
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/workshop_setup/setup_NGS_workshop.sh

Execute the bash script (ignore any warnings from sudo about being ```unable to resolve host```
if you are running this script on the NeCTAR Research Cloud):

    bash setup_NGS_workshop.sh

See the script's help, for information about command line arguments and defaults used:
    
    bash setup_NGS_workshop.sh -h
    USAGE: setup_NGS_workshop.sh [-h] [-p <absolute path>] [-d <relative path>] [-w <relative path>]
           [-t <trainee username>] [-c | -r] 
      Downloads documents and data for the BPA NGS workshop, setting write permissions on the working
      directory for the specified user and creates convienient symlinks for said user.

      where:
        -h Show this help text
        -p Parent directory. Top level directory for all the workshop related content
           (default: /mnt/NGS_workshop)
        -d Data directory. Relative to the parent directory specified by -p
           (default: data)
        -w Working directory. Relative to the parent directory specified by -p
           (default: working_dir)
        -t Trainee's username. Symlinks, to the workshop content, will be created under this users
           home directory (default: ngstrainee)
        -r Removes all trace of the workshop from the VM
        -c Cleanup the working directory. Removes the working directory and rerun this script with
           the same arguments this script was called with

You may wish to see what's been setup and the total size of the NGS workshop data:

    ls -lhR /mnt/NGS_workshop/
    du -h --max-depth=2 /mnt/NGS_workshop/

Script Details
==============
By default, the ```setup_NGS_workshop.sh``` script will:
* Create a directory structure under ```/mnt/NGS_workshop```
* Create a data directory ```/mnt/NGS_workshop/data``` for storing the data required for the NGS tutorials
* Pull approx. 3.3 GBytes of data from the NeCTAR Cloud storage into ```/mnt/NGS_workshop/data```
* Create a working directory structure under ```/mnt/NGS_workshop/working_dir```
* Create symlinks, to the appropriate data, under ```/mnt/NGS_workshop/working_dir```
* Create symlinks to subdirectories of ```/mnt/NGS_workshop/working_dir``` in ngstrainee's home and desktop:

    /home/ngstrainee/
    /home/ngstrainee/Desktop/

Testing the VM
==============
Once the VM has been setup for the NGS workshop. You may also wish to test the VM by running 1 or more of
the tutorials test scripts on it.

The tutorial test scripts can be pulled from the NeCTAR Cloud Object Storage onto a VM using:

Connect to the VM using an NX Client as user: ```ngstrainee```
In a terminal, pull down the tutorial test scripts from cloud storage

    cd
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/ngs-qc/qc_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/alignment/alignment_tutorial.sh 
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/chip-seq/chip-seq_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/rna-seq/rna-seq_tutorial.sh
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/de_novo/velvet/de_novo_tutorial.sh

Run, and time, the tutorials while redirecting ```STDOUT``` and ```STDERR``` to files with something like:

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
and run the ```setup_NGS_workshop.sh``` script with the ```-c``` flag:

    cd
    bash setup_NGS_workshop.sh -c

Real Clean the VM
=================
ALL the NGS workshop data can be scrubbed from the VM by running the ```setup_NGS_workshop.sh``` script,
as the ```ubuntu``` user, with the ```-r``` flag:

    cd
    bash setup_NGS_workshop.sh -r
    