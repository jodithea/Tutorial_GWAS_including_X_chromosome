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
		- Make sure the R package 'tidyverse' in installed
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

	- If you use SLURM instead of PBS, you can replace these lines with SLURM directives, for example:

```bash
#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1GB
#SBATCH --cpus-per-task=1
```
