#!/usr/bin/env bash    
set -e

f=$1

in="$f.fastq.gz"
in_nogz="${f}.fastq"
out_nogz="${f}.hat.clean.fastq"
out="${out_nogz}.gz"

aws s3 cp "s3://prjna729801/$in" $in
gunzip $in

./holistic_adapter_trimmer.py $in_nogz $out_nogz

gzip $out_nogz
aws s3 cp $out "s3://prjna729801/$out"
rm $in_nogz
rm $out
