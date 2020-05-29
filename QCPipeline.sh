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

## Logfile
logfile=/home/Reports/QCPipelinelog.txt
rundate=`date +"%Y%m%d"`

## Location of raw demultiplexed .fastq.gz files (lanes merged per sample)
fastq=/home/Fastq

## Runid
runid="HHNGWDMXX"

## Directory for FastQC reports
## Raw reads:
mkdir -p /home/Reports/FASTQCReports_raw
report1=/home/Reports/FASTQCReports_raw
## Processed reads:
mkdir -p /home/Reports/FASTQCReports_preprocessed
report2=/home/Reports/FASTQCReports_preprocessed

#############################
## Generate FastQC reports ##
#############################

echo "STEP 1:Generating FastQC reports for raw reads" | tee -a ${logfile}

for file in `ls ${fastq}/*R[1,2].fastq.gz`
do
	echo "Processing ${file}" | tee -a ${logfile}
	fastqc ${file} --outdir=${report1}/
done

########################################
## Trim reads and filter contaminants ##
########################################

echo "STEP 2: Trim reads and filter contaminants with trimFilterPE (FastqPuri)" | tee -a ${logfile}

mkdir -p ${fastq}/${rundate}_PreProcessed
echo "Storing processed files at ${fastq}/${rundate}_PreProcessed"

cat IndexPairs.txt | while read line
do
	i7=`awk '{print $1}' FS=" " <<< ${line}`
	i5=`awk '{print $2}' FS=" " <<< ${line}`
	pair="${i7}-${i5}"
	
	## N.B The first three nucleotides on R2 readss have been previously converted to 'N' to allow for
	## trimming of Pico v2 SMART adapters using --trimN below
	sampleR1=`ls ${fastq}/*.fastq.gz | grep "${pair}_R1.fastq.gz"`
	sampleR2=`ls ${fastq}/NNNR2/*.fastq.gz | grep "${pair}_R2_NNN.fastq.gz"`

	printf "Processing\n${sampleR1} and\n${sampleR2}\n" | tee -a ${logfile}

	### Run trimFilterPE

	trimFilterPE --ifq ${sampleR1}:${sampleR2} \
	--length 100 \
	--output ${fastq}/${rundate}_PreProcessed/${rundate}_${runid}_${pair}_R -z no \
	--method TREE \
	--ifa human_rRNA.fasta:0.4:30 \
	--adapter adapter_read1.fa:adapter_read2.fa:2:5 \
	--trimQ ENDSFRAC -q 30 -p 10 \
	--trimN ENDS \
	--minL 30 \
	2>&1 | tee ${fastq}/${rundate}_PreProcessed/${rundate}_${runid}_${pair}_trimFilterPElog.txt

done

#################################################
## Generate FastQC reports from processed data ##
#################################################

echo "STEP 3: Generating FastQC reports for trimmed and filtered reads" | tee -a ${logfile}

for file in `ls ${fastq}/${rundate}_PreProcessed/*_good.fq`
do
        echo "Processing ${file}" | tee -a ${logfile}
        fastqc ${file} --outdir=${report2}/
done

