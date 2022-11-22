#!/usr/bin/env bash
for f in $(\
           # https://github.com/jeffkaufman/kmer-egd
           cat ~/kmer-egd/rothman.unenriched_samples | \
               awk '{print $1}' | \
               sed 's/_.*//' | \
               sort -u); do
    in1="${f}_1.fastq.gz"
    in2="${f}_2.fastq.gz"
    out1="${f}_1.clean.fastq.gz"
    out2="${f}_2.clean.fastq.gz"
    stats="${f}_bbduk_stats1.txt"
    refstats="${f}_bbduk_ref_stats1.txt"
    aws s3 cp "s3://prjna729801/$in1" $in1
    aws s3 cp "s3://prjna729801/$in2" $in2

    ./bbduk_clean_helper.sh $in1 $in2 $out1 $out2
    
    aws s3 cp $out1 s3://prjna729801/$out1
    aws s3 cp $out2 s3://prjna729801/$out2
    rm $in1 $in2 $out1 $out2
done
