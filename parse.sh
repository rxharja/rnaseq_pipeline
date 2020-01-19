#!/bin/sh
#Script parsing data.txt and summaries.txt for important QC information

#cd into directory containing txt files we need
cd fastq/zips
IFS=$'\t'
count=0
echo -e "ID\tFilename\tTotal Sequences\tSequence Length\t%GC\tPoor Quality Sequences" >> assessment.txt

#for each line in data.txt, split into 2 columns. Case decides which variable to set $col2 as, then push to table
while read col1 col2; do
  #last item in case is unique identifier for each file, which is why it outputs all variables as text tab delimited line
  case $col1 in "Filename"*) fname=$col2;; "Total Sequences"*) totSeq=$col2;; "Sequence length"*) seqLen=$col2;; "%GC"*) gc=$col2;; *"poor"*) poor=$col2;; ">>Per base sequence quality")
    count=$((count+1)); echo -e "$count\t$fname\t$totSeq\t$seqLen\t$gc\t$poor" >> assessment.txt
  ;;
  esac
done < data.txt

#variables keeping track of count, pass, warn, and fail flags. fname is the first file name in summaries.txt. newFile will be used later to keep track of file being processed
count=0;pass=0;warn=0;fail=0;newFile="default";fname=$(head -n1 summaries.txt | cut -f3)
#write header
echo -e "\nID\tFilename\t# Module Pass\t# Module Fail\t# Module Warn" >> assessment.txt

#for each line in summaries.txt, split into 3 columns, then enumerate passes, fails, and warns for each filename
while read col1 col2 col3; do
  #if the file being processed, newFile, is equal to our file being held in the variable fname, then increment one of our flag counters depending on the flag
  newFile=$col3
  if test $fname == $newFile ; then    
    case $col1 in *PASS*) pass=$((pass+1));; *WARN*) warn=$((warn+1));; *FAIL*) fail=$((fail+1));; esac
  #otherwise, we've moved onto the next file, so write the information we've generated for those counts to file and reset our variables
  else
    count=$((count+1))
    echo -e "$count\t$fname\t$pass\t$fail\t$warn" >> assessment.txt
    newFile=$col3;fname=$newFile;pass=0;warn=0;fail=0
    case $col1 in *PASS*) pass=$((pass+1));; *WARN*)  warn=$((warn+1));; *FAIL*) fail=$((fail+1));; esac
  fi
done < summaries.txt

#last line needed to be outside of loop
count=$((count+1))
echo -e "$count\t$newFile\t$pass\t$fail\t$warn" >> assessment.txt
#Header for modules flagged with not PASS
echo -e "\n Here are your modules flagged with a WARN or FAIL: " >> assessment.txt

#filter files flagged as warn or fail, maybe future update can ask if user wants to see all or just flagged modules
grep "WARN\|FAIL" summaries.txt | sort -k1 >> assessment.txt

#echo information for user and display tables
echo -e "Fastq complete. Assessment data generated in /fastq/zips/assessment.txt\nFull data can be found in data.txt and summaries.txt in the same folder.\n"
more assessment.txt
