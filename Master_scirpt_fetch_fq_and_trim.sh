#!/bin/bash

## data at https://www.ebi.ac.uk/ena/browser/view/PRJNA327112

##conda install -c bioconda fastqc -y
##conda install -c bioconda fastp -y
##pip install multiqc

# Create directories for raw and processed data
RAW_DIR="fastq_data/raw"
TRIMMED_DIR="fastq_data/trimmed"
FASTQC_DIR="fastq_data/fastqc"
FASTQC_TRIMMED_DIR="fastq_data/fastqc_trimmed"
MULTIQC_DIR="fastq_data/multiqc"

mkdir -p $RAW_DIR $TRIMMED_DIR $FASTQC_DIR $FASTQC_TRIMMED_DIR $MULTIQC_DIR

# URL to download the FASTQ file
# FASTQ_URL=$1

# Extract the filename from the URL
FILE_NAME=$(basename $FASTQ_URL)

# Fetch the FASTQ file using curl
echo "Fetching FASTQ file from $FASTQ_URL"
curl -o $RAW_DIR/$FILE_NAME $FASTQ_URL

# Perform trimming with fastp
echo "Running fastp for $FILE_NAME"
fastp -i $RAW_DIR/$FILE_NAME \
      -o $TRIMMED_DIR/${FILE_NAME%.fastq.gz}_trimmed.fastq.gz \
    --cut_front --cut_tail --cut_right --cut_mean_quality 25 \
      --length_required 30 \
      -h $TRIMMED_DIR/${FILE_NAME%.fastq.gz}_fastp_report.html -j $TRIMMED_DIR/${FILE_NAME%.fastq.gz}_fastp_report.json

# Perform quality control with FastQC
echo "Running FastQC for raw FASTQ file"
fastqc -o $FASTQC_DIR $RAW_DIR/$FILE_NAME

echo "Running FastQC for trimmed FASTQ file"
fastqc -o $FASTQC_TRIMMED_DIR $TRIMMED_DIR/${FILE_NAME%.fastq.gz}_trimmed.fastq.gz

# # Summarize results with MultiQC
echo "Running MultiQC to summarize FastQC reports"
multiqc -o $MULTIQC_DIR $FASTQC_DIR $FASTQC_TRIMMED_DIR

echo "Pipeline complete"
