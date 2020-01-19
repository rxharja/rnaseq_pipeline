#!/bin/sh
#generates counts data using bedtools given a bed file and a series of bam.bai files
cd Tbb_genome/samFiles
#check if this folder exists, if it doesnt make it
if test -d "../../countsFiles"; then
  continue
else
  mkdir ../../countsFiles
fi

#run bedtools and generate gene counts for each lifecycle
echo "Generating gene counts for ${1}. Please wait."
bedtools multicov -bams ${1}*.bam -bed "../../Tbbgenes.bed" > ../../countsFiles/${1}_geneCounts.txt
echo "Counts for ${1} are located in the countsFiles directory in this directory."
