#! /usr/bin/bash
# usage: ./find_perfect_matches.sh <query file> <subject file> <output file>

# BLAST command matches the CRISPR sequence with assemblies in 
# subject files and  outputs the standard 12 columns and aligned subsequence.
# Use awk for column-based filtering to extract rows which match 100%
# and all 28 characters in CRISPR sequence and redirect to output file 
blastn -query $1 -subject $2 -task blastn-short -outfmt '6 std qlen' |
awk '{if ($3 == 100.000 && $4 == $13) print $0;}' > op.txt

# To extract matched sequence begin and end positions and 
# convert into BED format
cut -f 9,10 op.txt > op1.txt 
sed 's/\t/\n/g' op1.txt > op2.txt | head
wc -l op2.txt

# Remove first and last elements
sed -i '1d' op2.txt ; sed -i '$d' op2.txt
end=$(wc -l op2.txt | cut -d ' ' -f 1)
end=$((end/2))
echo $end
yes "chr1" | head -n $end > col1.txt
cat op2.txt | paste col1.txt - - > spacer.bed
#head spacer.bed
awk '{$2=$2+1 ; $3=$3-1 ; print $0}' OFS='\t' spacer.bed
#head spacer.bed

# Count the number of lines in output file to obtain number of perfect matches
#wc -l $3 