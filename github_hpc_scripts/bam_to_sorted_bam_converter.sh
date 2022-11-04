#!/bin/bash

for f in $(aws s3 ls s3://prjna729801/ | \
               awk '{print $NF}' | \
               grep _all_viruses.bam.gz$ | \
               sed s/_all_viruses.bam.gz//); do
    in_gz="${f}_all_viruses.bam.gz"
    in="${f}_all_viruses.bam"
    out="${f}_all_viruses.sorted_bam"
    out_gz="${f}_all_viruses.sorted_bam.gz"

    aws s3 cp "s3://prjna729801/$in_gz" $in_gz
    gunzip $in_gz

    samtools sort $in -@ 30 > $out

    gzip $out
    aws s3 cp $out_gz s3://prjna729801/$out_gz

    rm $in
    rm $out_gz
done
