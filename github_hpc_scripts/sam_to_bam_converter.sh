#!/bin/bash

for f in $(aws s3 ls s3://prjna729801/ | \
               awk '{print $NF}' | \
               grep _all_viruses.sam.gz$ | \
               sed s/_all_viruses.sam.gz//); do
    in_gz="${f}_all_viruses.sam.gz"
    in="${f}_all_viruses.sam"
    out="${f}_all_viruses.bam"
    out_gz="${f}_all_viruses.bam.gz"

    aws s3 cp "s3://prjna729801/$in_gz" $in_gz
    gunzip $in_gz

    samtools view -S $in -@ 30 -b > $out

    gzip $out
    aws s3 cp $out_gz s3://prjna729801/$out_gz

    rm $in
    rm $out_gz
done
