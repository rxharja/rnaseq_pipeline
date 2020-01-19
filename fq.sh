#!/bin/sh
#Script processing fastq files
#take parameter from runme.sh and assign to array
allFiles=("$@")

#function extracting specific files from zip files generated from fastqc
unzip_txt() {
  for zip in *.zip; do
    unzip -p ${zip} ${zip::-4}/$1 >> $2
  done
}

#run fastqc for every file in array pased 
cd fastq
echo "Processing fastqc for files."
for file in ${allFiles[@]}; do
  echo "Working on: ${file}"
  fastqc $file -q
done
#delete unnecessary html files
rm -f *html
  
#make sure no folder with zips name exists, then make one
if test -d "./zips"; then
  continue
else
  mkdir "./zips"
fi
  
#move all extracted .zip files into zips folder
mv *.zip ./zips
cd zips
 
#extract just text data from zip files into compilation texts summaries and data
unzip_txt "summary.txt" "summaries.txt"
unzip_txt "fastqc_data.txt" "data.txt"
  
#cleanup unnecessary zip files
rm -f *.zip

