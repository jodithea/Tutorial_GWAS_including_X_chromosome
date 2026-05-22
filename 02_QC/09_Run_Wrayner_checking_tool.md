# Run the Wrayner shell script called Run-plink.sh

* In our previous step we ran the Wrayner checking tool perl script HRC-1000G-check-bim.pl which created a new shell script called Run-plink.sh

* Now we want to run this shell script which creates a series of command files to do the following:
	- Exclude SNPs that do not match on chromosome, position, and alleles (including multi-allelic variants)
	- Exclude SNPs not present in the reference panel \
	- Update chromosome and position to match the reference panel
	- Align the scaffold to the forward strand
	- Fix REF alleles to the reference panel
	- Remove A/T or G/C SNPs with MAF >40% in the reference panel (for the relevant ethnic group)
	- Remove all SNPs with an allele frequency difference >20% between the scaffold and reference panel (for the relevant ethnic group)
	- Remove duplicates that may be introduced with the chromosome and position update applied

* Copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

mkdir -p 02_QC/Wrayner_preimputation_checking/

cd 02_QC/Wrayner_preimputation_checking/

module load plink/1.90b7

chmod +rwx Run-plink.sh

./Run-plink.sh
```
