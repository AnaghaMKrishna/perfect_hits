#! /usr/bin/bash
# usage: ./extract_spacers.sh <query file> <subject file> <output file>

# BLAST command matches the CRISPR sequence with assemblies in 
# subject files and  outputs the standard 12 columns and query length.
# Use awk for column-based filtering to extract rows which match 100%
# and all 28 characters in CRISPR sequence and redirect to temp output file 
blastn -query $1 -subject $2 -task blastn-short -outfmt '6 std qlen' |
awk '{if ($3 == 100.000 && $4 == $13) print $0;}' > blast_output.txt

# To extract matched sequence start and end positions 
cut -f 9,10 blast_output.txt > spacer_seq_manipulation.txt 

# Steps to create BED file
# Collapse the 2 columns into 1 for manipulating the start and end 
# positions of repeats
sed -i 's/\t/\n/g' spacer_seq_manipulation.txt

# Remove first and last elements
sed -i '1d' spacer_seq_manipulation.txt 
sed -i '$d' spacer_seq_manipulation.txt

# Get the number of rows in the BED file to be created
end=$(wc -l spacer_seq_manipulation.txt | cut -d ' ' -f 1)
end=$((end/2))

# Add header from matched file to the 1st column "end" number of times
#yes $(grep -Po -m 1 "(?<=>).*" $2) | head -n $end > col1.txt
#yes "NODE_18_length_84619_cov_36.005061" | head -n $end > col1.txt
cut -f 2 blast_output.txt | head -n $(($end - 2)) > col1.txt

# Form 2 columns of the start and end positions
cat spacer_seq_manipulation.txt | paste col1.txt - - > spacer.bed

# Make adjustments to 2nd and 3rd columns to get 
# the start and end positions of spacers
awk -i inplace '{$2=$2+1 ; $3=$3-1 ; print $0}' OFS='\t' spacer.bed 

#Alternatively, we can also use single-line awk to create BED file with spacer co-ordinates
#awk 'BEGIN {last=-1000} $9<last+50 {print $2, last, $9-1}; {last=$10}' blast_output.txt > $spacer.bed

# Using seqtk to extract spacer sequences
seqtk subseq $2 spacer.bed > $3

# Output spacer sequences to STDOUT after removing header lines 
#cat $3 | grep -v ">" 