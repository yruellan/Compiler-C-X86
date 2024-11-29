#!/bin/bash

c_file="${1:-file.c}"
temp_file="${c_file%".c"}__tmp.c"
s_file="${c_file%".c"}.s"

echo "#include <stdlib.h>" > $temp_file
echo "#include <stdio.h>" >> $temp_file
echo "#include <stdbool.h>" >> $temp_file
echo "void print_int(int x){ printf(\"%d\n\",x);}" >> $temp_file
echo "void print_char(char x){ printf(\"%c\n\",x);}" >> $temp_file
echo "" >> $temp_file
cat $c_file >> $temp_file
gcc -S -O3 $temp_file -o $s_file
rm $temp_file