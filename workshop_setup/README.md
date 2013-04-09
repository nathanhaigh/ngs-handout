The ```setup_workshop.sh``` script is for downloading the documents and data required for
this workshop. It also makes the workshop's working directory writable by the specified
user and creates some convenient symlinks to the data under the specified user's home and desktop.

First, ssh into the VM as user ```ubuntu``` and pull down the bash setup script from GitHub:

    cd
    wget https://github.com/nathanhaigh/ngs_workshop/raw/Intro_to_Linux_and_RNA-Seq/workshop_setup/setup_workshop.sh

Execute the bash script (ignore any warnings from sudo about being ```unable to resolve host```
if you are running this script on the NeCTAR Research Cloud):

    bash setup_workshop.sh

See the script's help, for information about command line arguments and defaults used:
    
    bash setup_workshop.sh -h

You may wish to see what's been setup and the total size of the workshop data:

    ls -lhR /mnt/NGS_workshop/
    du -h --max-depth=2 /mnt/NGS_workshop/

Script Details
==============
By default, the ```setup_workshop.sh``` script will:
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
    wget https://github.com/nathanhaigh/ngs_workshop/raw/master/rna-seq/rna-seq_tutorial.sh

Run, and time, the tutorials while redirecting ```STDOUT``` and ```STDERR``` to files with something like:

    time bash qc_tutorial.sh > qc_stdout.log 2> qc_stderr.log
    time bash rna-seq_tutorial.sh > rna-seq_stdout.log 2> rna-seq_stderr.log

Once testing is complete, delete the test files and logs

    rm *_tutorial.sh
    rm *_std{out,err}.log



Clean the VM For Another Workshop
=================================
If another workshop is to be run, then the NGS workshop working directory on the VM can be cleaned and
reinitialised without pulling down all the workshop data again. To do this, login to the VM as the ```ubuntu``` user
and run the ```setup_workshop.sh``` script with the ```-c``` flag:

    cd
    bash setup_workshop.sh -c

Real Clean the VM
=================
ALL the NGS workshop data can be scrubbed from the VM by running the ```setup_workshop.sh``` script,
as the ```ubuntu``` user, with the ```-r``` flag:

    cd
    bash setup_workshop.sh -r
    