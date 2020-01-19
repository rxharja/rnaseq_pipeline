#!/bin/sh
#Script processing alignment of read pairs and then converting the SAM files into BAM format while also sorting and indexing them

#move to folder containing our .fasta.gz files
cd Tbb_genome

#unzip all gz fasta files
gunzip *.fasta.gz

#build database using bowtie2
echo "Building Database"
bowtie2-build *.fasta db --quiet

#get total number of cores
numCores=$(grep -c ^processor /proc/cpuinfo)

#make directory for sam files
mkdir ./samFiles

#Align the read pairs
while read num type f1 f2; do
  echo -e "Aligning $type files $f1 and $f2"
  bowtie2 -x db -1 ../fastq/$f1 -2 ../fastq/$f2 -S ./samFiles/${type}_${f1::-6}.sam --very-fast -p $numCores --no-unal
done < ../fastq/fqfiles

#convert from sam to bam file
echo "Sorting and indexing alignment maps."
samFiles=$(ls ./samFiles/*.sam)
for file in $samFiles; do
  samtools sort -@ $numCores $file > ${file::-4}_sorted.bam
  samtools index ${file::-4}_sorted.bam
done
