#!/bin/bash

##================================================================================##
####################################################################################
##										  ##
## 	Title:	TestTrim							  ##	
## 	Author: Aimee L. Hanson							  ##
## 	Date:	25-05-2020							  ##
##										  ##
## 	A pipeline to test adapter trimming and contaminant filtering using	  ##
##	FastqPuri trimFilterPE function (for paired-end reads).      		  ##
##										  ##
####################################################################################
##================================================================================##

## Location of raw demultiplexed .fastq.gz files (lanes merged per sample)
fastq=/home/TESTFastq

########################################
## Trim reads and filter contaminants ##
########################################

echo "Trim reads and filter contaminants with trimFilterPE (FastqPuri)"

mkdir -p ${fastq}/`date +"%Y%m%d"`_PreProcessed

trimFilterPE --ifq ${fastq}/20200518_HHNGWDMXX_D701-D501_R1_TRIM.fastq.gz:${fastq}/NNNR2/20200518_HHNGWDMXX_D701-D501_R2_TRIM_3N.fastq.gz \
--length 100 \
--output ${fastq}/`date +"%Y%m%d"`_PreProcessed/testout -z no \
--method TREE \
--ifa human_rRNA_joined.fasta:0.4:30 \
--adapter adapter_read1.fa:adapter_read2.fa:2:5 \
--trimQ ENDSFRAC -q 30 -p 10 \
--trimN ENDS \
--minL 30 \
2>&1 | tee ${fastq}/`date +"%Y%m%d"`_PreProcessed/trimFilterPElog.txt
