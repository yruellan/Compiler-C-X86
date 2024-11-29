#!/bin/bash

c_file="${1:-file.c}"
json_file="${c_file%".c"}.json"
s_file="${c_file%".c"}.s"

echo ""  >> log.txt
echo "------------------------------------"  >> log.txt
echo "c file    : $c_file"  >> log.txt
echo "json file : $json_file"  >> log.txt


./bash/build-dune-finalproject.sh || (echo "Failed to build dune"; exit 1;)
./bash/build-finalproject-cpp.sh || (echo "Failed to build finalproject-cpp"; exit 1;)

./parser/expr2json.exe "$c_file"  >> log.txt || (echo "Failed to run expr2json"; exit 1;)
./src/build/main $json_file $2 || (echo "Failed to run finalproject-cpp"; exit 1;)