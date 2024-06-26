#!/bin/bash

# Define variables
read -p "Enter the trimmed directory name: " trimmed_dir
read -p "Enter the path to the Trimmomatic jar file: " trimmomatic_jar
read -p "Enter the input R1 file name: " input_R1
read -p "Enter the input R2 file name: " input_R2
read -p "Enter the minimum length (MINLEN): " MINLEN
read -p "Enter the head crop length (HEADCROP): " HEADCROP
read -p "Enter the base output name: " baseout_name

#trimmed_dir="1_trimmed"
#trimmomatic_jar="/mnt/c/users/fabricio/Desktop/Genomic/src/Trimmomatic-0.39/trimmomatic-0.39.jar"
#input_R1="INPA19929_R1_adp_removed.fastq"
#input_R2="INPA19929_R2_adp_removed.fastq"
#MINLEN=70
#HEADCROP=20 # Modify as needed based on the "Per base sequence content" graph in FastQC
#baseout_name="INPA19929_trimmed.fastq" # Define baseout name

# Step 1: Check if the directory exists
if [ ! -d "$trimmed_dir" ]; then
    # Directory does not exist, create it
    mkdir -p "$trimmed_dir"
    echo "Directory $trimmed_dir created."
else
    # Directory exists, skip creation
    echo "Directory $trimmed_dir already exists. Skipping creation."
fi

# Step 2: Run Trimmomatic
java -jar "$trimmomatic_jar" PE \
    "$input_R1" \
    "$input_R2" \
    -baseout "${trimmed_dir}/${baseout_name}" \
    HEADCROP:"$HEADCROP" \
    SLIDINGWINDOW:10:20 \
    MINLEN:"$MINLEN"

# Step 3: Remove unpaired read files
rm -f $trimmed_dir/*_1U.fastq
rm -f $trimmed_dir/*_2U.fastq

# Optional: Print a message indicating completion
echo "Trimming completed and unpaired read files removed."
