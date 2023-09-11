#! /usr/bin/bash
# usage: ./find_perfect_matches.sh <query file> <subject file> <output file>

# BLAST command matches the CRISPR sequence with assemblies in 
# subject files and  outputs the standard 12 columns and aligned subsequence.
# Use awk for column-based filtering to extract rows which match 100%
# and all 28 characters in CRISPR sequence and redirect to output file 
blastn -query $1 -subject $2 -task blastn-short -outfmt '6 std qlen' |
awk '{if ($3 == 100.000 && $4 == $13) print $0;}' > $3

cut -f 9,10 op.txt > op1.txt 
sed 's/\t/\n/g' op1.txt > op2.txt
cat op2.txt

# Count the number of lines in output file to obtain number of perfect matches
#wc -l $3 