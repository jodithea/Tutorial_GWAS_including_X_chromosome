# Tutorial to run GWAS including the X chromosome

* This tutorial will cover the following steps, all including the autosomes and the **X chromosome**:
	- Quality control of genotype data
	- Imputation of genotype data
	- Genome-wide association study (GWAS)
* Genotype data is provided to use with this tutorial, or you can run through it using your own genotype data


# Getting Started

## Clone the repository

* Clone this repository to get a local copy of all files

* In your terminal or HPC environment navigate to the location you would like to download a copy of all the files in this tutorial
* Then run the following code:

```bash
git clone https://github.com/jodithea/Tutorial_GWAS_including_X_chromosome.git
```

* You will now have a copy of all of the directories and files from this tutorial


## Software needed

* For this tutorial you will need the following software
	- Plink v1.9
	- R (v4.5.0 is used in this tutorial)
		- Make sure the R package 'tidyverse' is installed
	- vcftools (v0.1.16 used in this tutorial)
	- bcftools (v1.22 used in this tutorial)

## How to use this tutorial

* Follow through the directories and files in chronological order

### Markdown files

* Markdown files (files ending with .md) contain instructions and documentation
* You can view these files directly in the GitHub web interface
* Or, if you have a local clone of the repository, you can view them in the terminal using cat, e.g.:
```bash
 cat README.md
```

### Scripts

* Scripts (i.e. files ending with '.sh') are shell scripts that can be submitted to your HPC environment
* Again you can view these files directly in the GitHub web interface or in your local clone of the repository by using cat
* All scripts in this repository follow a similar layout:

1. Shebang and Scheduler Header
	- Every script starts with a shebang (#!/bin/bash) to indicate it is a bash script, followed by HPC scheduler directives. 
	- The schedular directives are written for PBS, for example:
```bash
#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1
```

If you use SLURM instead of PBS, you can replace these lines with SLURM directives, for example:

```bash
#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1GB
#SBATCH --cpus-per-task=1
```

To do this replacement, in your local clone of the repository, open the script with an editor, for example:

```bash
nano 01_Split_X_chromosome.sh
```

Then edit the scheduler directives in the file as needed

2. Script Description

	- A short comment explaining what the script does:
```bash
# This script ...
```

3. Environment

	- This section loads any required modules or software:
```bash
### Environment ###
module load plink/1.90b7
```

4. Preamble / User Variables

	- This section defines any directories, file paths, or parameters used in the script
	- You need to edit this section of the script as appropriate
	- For example, in each script the 'directory' variable is defined. Open the script using 'nano' (or a similar editor) and set the path to the location of where your local clone of the repository is

```bash
### Preamble ###
# Update to point to the location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
```

5. Commands / Submission Section

	- This section contains the actual commands that perform the work
	- For example:

```bash
### Submit script ###
cd ${directory}

# Split chromosome X
plink --bfile 01_Genotype_Data/Genotypes_chrX \
      --split-x b37 \
      --make-bed \
      --out 01_Genotype_Data/Genotypes_chrX_split
```

### Submitting scripts

* After viewing the script and making any edits as appropriate, submit the script

For PBS, submit using qsub, e.g.:

```bash
qsub 01_Split_X_chromosome.sh

```

For SLURM (and after you have edited the scheduler directives appropriately), submit using sbatch, e.g.:

```bash
sbatch 01_Split_X_chromosome.sh

```

* You can check the status of your jobs:

For PBS, using qstat:
```bash
qstat -u your_username
```

For SLURM, using squeue:

```bash
squeue -u your_username
```

### Job Arrays (PBS vs SLURM)

* Some scripts in this tutorial use job arrays, one job per chromosome:
	- 03_Imputation/04_Convert_and_filter_imputed_genotype_data.sh
	- 04_Ancestry_Checks/02_Tidy_1000G_data.sh
	- 04_Ancestry_Checks/03_Merge_1000G_with_tutorial_data_and_prune.sh

* The scripts are written using PBS job scheduling

#### PBS job arrays

* The PBS scheduler directive uses `#PBS -J` to define the range of array jobs:

```bash
#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l mem=80GB
#PBS -l ncpus=1
#PBS -J 1-22
```

* Within the script, the array index for the current task is accessed using PBS_ARRAY_INDEX, for example:

```bash
chr=${PBS_ARRAY_INDEX}
```

* Another example from this tutorial:

```bash
files=(${directory}03_Imputation/Genotype_imputation_results/chr_*.zip)
chr=$(basename "${files[$PBS_ARRAY_INDEX]}" .zip)
```

#### SLURM job arrays

* If your HPC system uses SLURM, you must modify these scripts

*  Open the script using 'nano' (or a similar editor) and replace the PBS array directive with:

```bash
#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mem=80GB
#SBATCH --cpus-per-task=1
#SBATCH --array=1-22
```

* And inside the script replace PBS_ARRAY_INDEX with the SLURM equivalent:

```bash
chr=${SLURM_ARRAY_TASK_ID}
```

```bash
files=(${directory}03_Imputation/Genotype_imputation_results/chr_*.zip)
chr=$(basename "${files[$SLURM_ARRAY_TASK_ID]}" .zip)
```
