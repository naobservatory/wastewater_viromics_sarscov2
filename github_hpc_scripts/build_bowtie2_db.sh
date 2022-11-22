#!/usr/bin/env bash

if [ ! -e all_virus_genomes.fna ]; then
    curl https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/ -sS | \
        grep -E -o 'viral[.][0-9.]+[.]genomic.fna.gz' | \
        sort | uniq | \
        xargs -P 32 -I {} wget \
              https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/{}
    gunzip *.genomic.fna.gz
    cat *.fna > all_virus_genomes.fna
fi

if [ ! -e all_virus_genomes_bowtie_db ]; then
    ~/bowtie2-2.4.5-linux-x86_64/bowtie2-build all_virus_genomes.fna \
         all_virus_genomes_bowtie_db -f --threads 30
fi
