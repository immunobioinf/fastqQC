#!/bin/bash

##================================================================================##
####################################################################################
##										  ##
## 	Title:	QCPipeline							  ##	
## 	Author: Aimee L. Hanson							  ##
## 	Date:	22-05-2020							  ##
##										  ##
## 	A pipeline to generate QC reports from raw .fastq.gz files using FastQC,  ##
##	followed by read trimming and removal of rRNA reads with FastqPuri.       ##
##										  ##
####################################################################################
##================================================================================##

if [[ ! $1 =~ .(fastq.gz|fastq|fq.gz|fq)$ ]] || [[ ! $2 =~ .(fastq.gz|fastq|fq.gz|fq)$ ]]; then
        echo "Please provide sample .fastq/.fastq.gz files for reads 1 and 2"
        exit 1
else
        echo "Provided files: $1 and $2"
fi

if [[ ! $3 =~ ^D7[0-9]{2}-D5[0-9]{2}$ ]]; then
	echo "Please provide index pair in format D7XX-D5XX"
	exit 1
else
	echo "Index pair: $3"
fi

rundate=`date +"%Y%m%d"`
start_time=`date -u +%s`

## Runid
runid="HHNGWDMXX"

## Directory for preprocessed reads
fastq=/home/Fastq

## Directory for FastQC reports
## Raw reads:
mkdir -p /home/Reports/FASTQCReports_raw
report1=/home/Reports/FASTQCReports_raw
## Pre-processed reads:
mkdir -p /home/Reports/FASTQCReports_preprocessed
report2=/home/Reports/FASTQCReports_preprocessed

sampleR1=$1
sampleR2=$2
indexpair=$3

#############################
## Generate FastQC reports ##
#############################

echo "STEP 1:Generating FastQC reports for raw reads"

# READ1
fastqc ${sampleR1} --outdir=${report1}
# READ 2
fastqc ${sampleR2} --outdir=${report1}

########################################
## Trim reads and filter contaminants ##
########################################

echo "STEP 2: Trim reads and filter contaminants with trimFilterPE (FastqPuri)"

mkdir -p ${fastq}/${rundate}_PreProcessed
echo "Storing processed files at ${fastq}/${rundate}_PreProcessed"
	
## N.B The first three nucleotides on R2 reads have been previously converted to 'N' to allow for
## trimming of Pico v2 SMART adapters using --trimN below

printf "Processing\n${sampleR1} and\n${sampleR2}\n"

### Run trimFilterPE

trimFilterPE --ifq ${sampleR1}:${sampleR2} \
--length 100 \
--output ${fastq}/${rundate}_PreProcessed/${rundate}_${runid}_${indexpair}_R -z no \
--method TREE \
--ifa human_rRNA_joined.fasta:0.4:30 \
--adapter adapter_read1.fa:adapter_read2.fa:2:5 \
--trimQ ENDSFRAC -q 30 -p 15 \
--trimN ENDS \
--minL 30 \
2>&1 | tee ${fastq}/${rundate}_PreProcessed/${rundate}_${runid}_${indexpair}_trimFilterPElog.txt

#################################################
## Generate FastQC reports from processed data ##
#################################################

echo "STEP 3: Generating FastQC reports for trimmed and filtered reads"

for file in `ls ${fastq}/${rundate}_PreProcessed/*_good.fq`
do
        echo "Processing ${file}"
        fastqc ${file} --outdir=${report2}/
done

end_time=`date -u +%s`
elapsed=$((end_time-start_time))

echo "Total of $((elapsed/3600)) hours, $(((elapsed/60)%60)) mins to complete"
