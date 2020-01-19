#!/bin/sh
#generates statistical mean for each group and gene and outputs it into a text tab delimited file
#assign input parameter array, contains lifecycle names
lifeCycles=("$@"); declare -A means=();count=0;bool=true

#make table header with every available lifecycle/type
printf "Gene\t" >> lifecycleGeneMeans.txt; for x in ${lifeCycles[@]}; do printf "%-s Mean Count\t" "$x" >> lifecycleGeneMeans.txt; done; printf "\n" >> lifecycleGeneMeans.txt

#generate arrays for genes, and one for all of the means
for i in ${lifeCycles[@]}; do
  #build genes array only once, use for loop for convenience in referencing file
  [[ $bool ]] && genes=($(awk -F $'\t' '{print $4}' ./countsFiles/${i}_geneCounts.txt))
  #build the means multidimensional array by looping through all lifecycle files and appending the means as sub arrays with an index
  means[$count]+=$(awk -F $'\t' -v typ="$i" '{
  n=(NF-6); sum=0; for (i=7; i<=NF; i++) {sum+=$i;}
  printf("%.2f\n",(sum/n));}' ./countsFiles/${i}_geneCounts.txt)
  #turn off our boolean and increment count variable which we will use to keep track of nested for loop logic
  bool=false; count=$((count+1))
done

#output table using 2 for loops, one using the index of the genes array due to it being standard
echo "Generating statistical means for each life cycle group and gene."
for j in "${!genes[@]}"; do
  printf "%-s\t" "${genes[j]}" >> lifecycleGeneMeans.txt
  #the second being a multidimensional array requires moving horizontally between all arrays inside the associative array before progressing to the next index
  for ((ind=0;ind<$count;ind++)); do
    internalArr=(${means[$ind]})
    printf "%-s\t" ${internalArr[j]} >> lifecycleGeneMeans.txt
  done
  printf "\n" >> lifecycleGeneMeans.txt
done

echo "Process complete. Complete results located in 'lifecycleGeneMeans.txt' in this directory. Here are the first 10 lines."
head -n10 lifecycleGeneMeans.txt
