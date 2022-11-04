#!/bin/bash

for f in $(aws s3 ls s3://prjna729801/ | \
               awk '{print $NF}' | \
               grep _all_viruses.sorted_bam.gz$ | \
               sed s/_all_viruses.sorted_bam.gz//); do
    in_gz="${f}_all_viruses.sorted_bam.gz"
    in="${f}_all_viruses.sorted_bam"
    in_b="${f}_all_viruses.sorted.bam"
    out="${f}_instrain"
    out_zip="${f}_instrain.zip"

    aws s3 cp "s3://prjna729801/$in_gz" $in_gz
    gunzip $in_gz
    mv $in $in_b

    inStrain profile $in_b -l 0.9 -p 30 all_virus_genomes.fna -o $out

    zip -r $out_zip $out
    aws s3 cp $out_zip s3://prjna729801/$out_zip

    rm $in_b
    rm $in_b.bai
    rm $out_zip
    rm -r $out
done
