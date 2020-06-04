#!/bin/bash
#PBS -N SReport
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=10g
#PBS -j oe
#PBS -o /home/hansona/TCRgdProject/Containers/RunFiles/20200604-Sreport.log

######################################
## Generate SReport for all samples ##
######################################

echo "Generating final sample report for all pre-processed samples"

source /etc/profile.d/modules.sh

module load atg/singularity/3.1.1

cd /home/hansona/TCRgdProject/Containers/rnaseqreadqc

rundate=20200603

singularity exec -B /home/hansona/TCRgdProject/ReadProcessing/MergedFastq:/home/Fastq docker://immunobioinf/rnaseqreadqc:latest Sreport -i /home/Fastq/${rundate}_PreProcessed -t P -o /home/Fastq/${rundate}_PreProcessed/${rundate}_SReport
