#!/bin/bash


if [ ! -e flag.db_downloaded ]; then
    curl https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/ -sS | \
        grep -E -o 'viral[.][0-9.]+[.]genomic.fna.gz' | \
        sort | uniq | \
        xargs -P 32 -I {} wget \
              https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/{}
    touch flag.db_downloaded
fi

if [ ! -e flag.gunzipped ]; then
    gunzip *.genomic.fna.gz
    touch flag.gunzipped
fi

if [ ! -e all_virus_genomes_bowtie_db ]; then
    ~/bowtie2-2.4.5-linux-x86_64/bowtie2-build $(ls *.fna | tr '\n' ',') \
         all_virus_genomes_bowtie_db -f --threads 30
   rm *.fna
fi


