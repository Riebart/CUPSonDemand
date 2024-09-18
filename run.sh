#!/bin/bash

script_dir=$(dirname "$0")

mkdir -p etc/cups 2>/dev/null

docker run --rm -v "$script_dir/etc:/etc/cups" -v "$script_dir/input:/input" cups:latest
#echo docker run --rm -it -p 16631:631 -v "$script_dir/etc:/etc/cups" -v "$script_dir/input:/input" cups:latest
#docker run --rm -it -p 16631:631 -v `pwd`/etc:/etc/cups cups:latest
