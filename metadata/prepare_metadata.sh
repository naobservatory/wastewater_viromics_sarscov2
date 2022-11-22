#!/usr/bin/env bash

ENDPOINT="https://www.ebi.ac.uk/ena/portal/api/filereport"
ACCESSION="PRJNA729801"
FIELDS="fastq_ftp,sample_alias"
PARAMS="?accession=${ACCESSION}&fields=${FIELDS}&format=tsv"
PARAMS="${PARAMS}&result=read_run&download=true&limit=0"

RAW_METADATA=raw_metadata.tsv
PARSED_METADATA=parsed_metadata.tsv

if [[ ! -e $RAW_METADATA ]]; then
    wget "${ENDPOINT}${PARAMS}" -O raw_metadata.tsv
fi

if [[ ! -e "$PARSED_METADATA" ]]; then
    ./parse_metadata.py $RAW_METADATA $PARSED_METADATA
fi

echo "Parsed output in $PARSED_METADATA"
