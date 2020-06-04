#!/bin/bash
#PBS -N rnaseqreadqc
#PBS -l walltime=20:00:00
#PBS -l select=2:ncpus=5:mem=20g
#PBS -j oe
#PBS -o /home/hansona/TCRgdProject/Containers/RunFiles/20200603-rnaseqreadqc-^array_index^.log
#PBS -M aimee.hanson@qut.edu.au
#PBS -m e
#PBS -J 1-32

source /etc/profile.d/modules.sh

module load atg/singularity/3.1.1

cd /home/hansona/TCRgdProject/Containers/rnaseqreadqc

## Local sample files
fastq=/home/hansona/TCRgdProject/ReadProcessing/MergedFastq
indexlist=${fastq}/IndexPairs.txt

index=`sed -n "$PBS_ARRAY_INDEX p" ${indexlist}`

i7=`cut -d " " -f1 <<< ${index}`
i5=`cut -d " " -f2 <<< ${index}`
pair="${i7}-${i5}"

sampleR1=`ls ${fastq}/*.fastq.gz | grep "${pair}_R1.fastq.gz" | xargs basename`
sampleR2=`ls ${fastq}/NNNR2/*.fastq.gz | grep "${pair}_R2_NNN.fastq.gz" | xargs basename`

singularity exec -B /home/hansona/TCRgdProject/ReadProcessing/MergedFastq:/home/Fastq -B /home/hansona/TCRgdProject/ReadProcessing/Reports:/home/Reports docker://immunobioinf/rnaseqreadqc:latest /bin/bash QCPipeline.sh /home/Fastq/${sampleR1} /home/Fastq/NNNR2/${sampleR2} ${pair}
