#!/usr/bin/env bash

# switch to this script's directory, to make relative paths consistent
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

for accession in \
    $(cat ../metadata/parsed_metadata.tsv | \
          awk -F'\t' '$3=="HTP"&&$4==0{print $1}' | \
          awk -F_ '{print $1}' | sort | uniq); do

    echo $accession

    in1="${accession}_1.fastq.gz"
    in2="${accession}_2.fastq.gz"

    if [ ! -e $in1 ] ; then
        aws s3 cp "s3://prjna729801/$in1" $in1
    fi
    if [ ! -e $in2 ] ; then
        aws s3 cp "s3://prjna729801/$in2" $in2
    fi

    # bbclean with Rothman settings
    bb_r_out1="${accession}_1.bb.r.clean.fastq.gz"
    bb_r_out2="${accession}_2.bb.r.clean.fastq.gz"

    if [ ! -e "$bb_r_out1" ] ; then
        ../github_hpc_scripts/bbduk_clean_helper.sh \
            $in1 $in2 $bb_r_out1 $bb_r_out2
    fi

    # holistic adapter trimming
    for accession_fr in ${accession}_1 ${accession}_2; do
        hat_out="${accession_fr}.hat.clean.fastq.gz"
    
        if [ ! -e "$hat_out" ]; then
            in_nogz="${accession_fr}.fastq"

            if [ ! -f $in_nogz ] ; then
                gunzip --keep "${in_nogz}.gz"
            fi

            hat_nogz_out="${accession_fr}.hat.clean.fastq"
        
            ./holistic_adapter_trimmer.py "$in_nogz" "$hat_nogz_out"

            gzip $hat_nogz_out
        fi

        break
    done

    break
done
