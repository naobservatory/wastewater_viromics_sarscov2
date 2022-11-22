#!/usr/bin/env bash

./build_bowtie2_db.sh

for f in $(aws s3 ls s3://prjna729801/ | \
               awk '{print $NF}' | \
               grep .nohuman.fastq.1.gz$ | \
               sed s/.nohuman.fastq.1.gz//); do
    in1="${f}.nohuman.fastq.1.gz"
    in2="${f}.nohuman.fastq.2.gz"
    out="${f}_all_viruses.sam"
    out_gz="${f}_all_viruses.sam.gz"

    aws s3 cp "s3://prjna729801/$in1" $in1
    aws s3 cp "s3://prjna729801/$in2" $in2

    ~/bowtie2-2.4.5-linux-x86_64/bowtie2 \
        -x all_virus_genomes_bowtie_db \
        -1 $in1 -2 $in2 \
        -p 32 \
        -S $out \
        --no-unal

    gzip $out

    aws s3 cp $out_gz s3://prjna729801/$out_gz

    rm $in1
    rm $in2
    rm $out_gz
done
