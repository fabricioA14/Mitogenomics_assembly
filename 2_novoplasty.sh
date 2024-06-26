#!/bin/bash

# Prompt user for input
read -p "Enter the project name: " project_name
read -p "Enter the NOVOPlasty directory: " novoplasty_dir
read -p "Enter the reference id: " reference_id
read -p "Enter the forward reads file: " forward_reads
read -p "Enter the reverse reads file: " reverse_reads
read -p "Enter the read length: " read_length
read -p "Enter the size: " insert_size
read -p "Enter the start kmer value: " kmer_start
read -p "Enter the end kmer value: " kmer_end
read -p "Enter the kmer step: " kmer_step

# Define the project name
#project_name="INPA19929"

# Define the base directory
base_dir=$(pwd)

# Define the NOVOPlasty directory
#novoplasty_dir="/mnt/c/users/fabricio/Desktop/Genomic/src/NOVOPlasty/NOVOPlasty-master"

# Step 1: Create directories
mkdir -p "$base_dir/2_ref"
mkdir -p "$base_dir/3_assembly"

# Define the parameters
#reference_id="GBOL1113-16"
#forward_reads="INPA19929_trimmed_1P.fastq"
#reverse_reads="INPA19929_trimmed_2P.fastq"
#read_length=132
#insert_size=264

# Define the kmer range
#kmer_start=29
#kmer_end=35
#kmer_step=1

# Download the reference file 
wget -O "$base_dir/2_ref/${reference_id}.fasta" "https://www.boldsystems.org/index.php/API_Public/sequence?ids=${reference_id}&format=fasta"

# Loop through each kmer value in the defined range
for kmer in $(seq $kmer_start $kmer_step $kmer_end); do
  echo "Running with kmer=${kmer}"

  # Define kmer specific output directory
  kmer_output_dir="${base_dir}/3_assembly/kmer_${kmer}"
  mkdir -p "$kmer_output_dir"

  # Create a temporary configuration file
  config_file=$(mktemp)

  # Step 6: Write the temporary configuration file with reduced paths
  cat > "$config_file" << EOL
Project:
-----------------------
Project name          = ${project_name}
Type                  = mito
Genome Range          = 12000-22000
K-mer                 = ${kmer}
Max memory            = 
Extended log          = 
Save assembled reads  = 
Seed Input            = ${base_dir}/2_ref/${reference_id}.fasta
Extend seed directly  = 
Reference sequence    = 
Variance detection    = 
Chloroplast sequence  = 

Dataset 1:
-----------------------
Read Length           = ${read_length}
Insert size           = ${insert_size}
Platform              = illumina
Single/Paired         = PE
Combined reads        = 
Forward reads         = ${base_dir}/1_trimmed/${forward_reads}
Reverse reads         = ${base_dir}/1_trimmed/${reverse_reads}
Store Hash            =

Heteroplasmy:
-----------------------
MAF                   = 
HP exclude list       = 
PCR-free              = 

Optional:
-----------------------
Insert size auto      = yes
Use Quality Scores    = no
Output path           = ${kmer_output_dir}/
EOL

  # Step 7: Navigate to the NOVOPlasty directory
  cd "$novoplasty_dir"

  # Step 8: Run NOVOPlasty with the specified configuration file
  perl ./*.pl -c "$config_file"
  
  # Check if any file contains "Circularized" in the name
  if ls "${kmer_output_dir}"/*Circularized* 1> /dev/null 2>&1; then
    echo "Circularized file found. Stopping the loop."
    rm -f "$config_file"
    break
  fi

  # Remove the temporary configuration file
  rm -f "$config_file"

  # Optional: Print a message indicating completion
  echo "Pipeline execution for kmer=${kmer} completed."
done

# Optional: Print a final message indicating all runs are completed
echo "All pipeline executions completed."