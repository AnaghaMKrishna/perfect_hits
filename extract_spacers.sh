#! /usr/bin/bash
# usage: ./extract_spacers.sh <query file> <subject file> <output file>

# BLAST command matches the CRISPR sequence with assemblies in 
# subject files and  outputs the standard 12 columns and aligned subsequence.
# Use awk for column-based filtering to extract rows which match 100%
# and all 28 characters in CRISPR sequence and redirect to output file 
blastn -query $1 -subject $2 -task blastn-short -outfmt '6 std qlen' |
awk '{if ($3 == 100.000 && $4 == $13) print $0;}' > blast_output.txt

# To extract matched sequence start and end positions 
cut -f 9,10 blast_output.txt > spacer_seq_manipulation.txt 

# convert into BED format
# Collapse the 2 columns into 1 for manipulating the start and end 
# positions of repeats
sed -i 's/\t/\n/g' spacer_seq_manipulation.txt
#wc -l op2.txt

# Remove first and last elements
sed -i '1d' spacer_seq_manipulation.txt 
sed -i '$d' spacer_seq_manipulation.txt

# Get the number of rows in the BED file to be created
end=$(wc -l spacer_seq_manipulation.txt | cut -d ' ' -f 1)
end=$((end/2))
# echo $end

# Add header from matched file to the 1st column "end" number of times
yes "NODE_1_length_922990_cov_42.400140" | head -n $end > col1.txt

# FOrm 2 columns of the start and end positions
cat spacer_seq_manipulation.txt | paste col1.txt - - > spacer.bed
#head spacer.bed

# Make adjustment start and end columns to get 
# the start and end positions of spacers
awk -i inplace '{$2=$2+1 ; $3=$3-1 ; print $0}' OFS='\t' spacer.bed 
#head spacer.bed

# Using seqtk to extract spacer sequences
seqtk subseq $2 spacer.bed > $3

# Output spacer sequences to STDOUT
#wc -l $3 
cat $3