#!/bin/bash

if [ ! -e grch38_1kgmaj.1.bt2 ]; then
    if [ ! -e grch38_1kgmaj.zip ] ; then
        # per https://github.com/BenLangmead/bowtie2/issues/329
        wget https://genome-idx.s3.amazonaws.com/bt/grch38_1kgmaj.zip
    fi
    unzip grch38_1kgmaj.zip
fi

for f in $(aws s3 ls s3://prjna729801/ | \
               awk '{print $NF}' | \
               grep dedup.fastq.gz$ | \
               sed s/.dedup.fastq.gz//); do
    in="${f}.dedup.fastq.gz"
    out_human="${f}_human_reads.sam"
    out_base="${f}.dedup.nohuman.fastq.gz"
    out1="${f}.dedup.nohuman.fastq.1.gz"
    out2="${f}.dedup.nohuman.fastq.2.gz"

    aws s3 cp "s3://prjna729801/$in" $in

    ~/bowtie2-2.4.5-linux-x86_64/bowtie2 \
        -x grch38_1kgmaj -p 60 -S $out_human \
        --interleaved $in \
        --un-conc-gz $out_base

    aws s3 cp $out1 s3://prjna729801/$out1
    aws s3 cp $out2 s3://prjna729801/$out2

    rm $in
    rm $out1
    rm $out2
    rm $out_human
done
