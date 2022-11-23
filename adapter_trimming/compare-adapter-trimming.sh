#!/usr/bin/env bash

# switch to this script's directory, to make relative paths consistent
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

cat ../metadata/parsed_metadata.tsv | \
    awk -F'\t' '$3=="HTP"&&$4==0{print $1}' | \
    sed s/.fastq.gz// | \
    xargs -P8 -I {} ./compare-adapter-trimming-single.sh {}
