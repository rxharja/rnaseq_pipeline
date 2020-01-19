#!/bin/sh
#Author: B151359-2019
#Pipeline taking RNA-seq data in fastq files and generates statistical mean of gene counts per lifecycle
declare -A arr=() #associative separated by type
declare -a totalFiles=() #list of total files to run

#function building two arrays, one "multidimensional" one with key: lifecycle, value: all files associated with that life cycle. Other array is just a total list of all the files
function buildDataStructure() {
  while read num typ fq1 fq2; do
    if [ -n "${arr[$typ]+1}" ]; then
      arr[$typ]+=" $fq1"
      arr[$typ]+=" $fq2"
    else
      arr+=([$typ]=$fq1)
      arr[$typ]+=" $fq2"
    fi
  done < $1
  
  for i in "${!arr[@]}"; do
    totalFiles+="${arr[$i]} "
  done
}

#make sure fqfiles and fastq path exists
if test -d "./fastq"; then
  if test -f "./fastq/fqfiles"; then
    #pass path of file containing all necessary files to process along with their lifecycle association
    buildDataStructure "./fastq/fqfiles"
     #make sure all necessary files exist in directory, terminate script if not
     for fil in ${totalFiles[@]}; do
       if test -f "./fastq/${fil}"; then
          continue
       else
          echo "File ${fil} not found in folder. Make sure all files are there and try again."
          exit 1
       fi
     done
    #Run fastqc for all files
    ./fq.sh "${totalFiles[@]}"
    #Assess and output fastqc data
    ./parse.sh
    #allow user to stop script if QC data unsatisfactory
    echo "After reviewing the QC, do you wish to continue?(y/yes to continue)"
    read answer
    if  test $answer == "y" || test $answer == "yes"; then
      #given answer corresponds to yes, run bowtie2 sequence alignment
      ./btDb.sh  
      #for each life cycle, generate a separate gene counts txt file
      for j in "${!arr[@]}"; do
        ./counts.sh "${j}"
      done
      #process each counts file generated and calculate statistical mean which outputs 
      ./geneStats.sh "${!arr[@]}"
    else
       echo "Script terminated."
    fi #user input
  else
    echo "Missing fqfiles. This file should be where you write your files to be processed."
  fi #check for fqfiles
else
  echo "Missing the fastq directory. This is where you should store your files to be processed."
fi #check for fastq directory
