#!/usr/bin/env bash
#--------------------------SBATCH settings------

#SBATCH --job-name=bbduk_dedupe      ## job name
#SBATCH -A katrine_lab     ## account to charge
#SBATCH -p standard          ## partition/queue name
#SBATCH --nodes=1            ## (-N) number of nodes to use
#SBATCH --ntasks=1           ## (-n) number of tasks to launch
#SBATCH --cpus-per-task=60    ## number of cores the job needs
#SBATCH --mem-per-cpu=5G	## requested memory (6G = max)
#SBATCH --error=slurm-%J.err ## error log file
#SBATCH --output=slurm-%J.out ##output info file

for f in $(\
           # https://github.com/jeffkaufman/kmer-egd
           cat ~/kmer-egd/rothman.unenriched_samples | \
               awk '{print $1}' | \
               sed 's/_.*//' | \
               sort -u); do
    in1="${f}_1.clean.fastq.gz"
    in2="${f}_2.clean.fastq.gz"
    out="${f}.dedup.fastq.gz"

    if aws s3 ls s3://prjna729801/$out ; then
        continue
    fi

    aws s3 cp "s3://prjna729801/$in1" $in1
    aws s3 cp "s3://prjna729801/$in2" $in2

    ~/bbmap/dedupe.sh \
        in=$in1 \
        in2=$in2 \
        out=$out \
        threads=32
    aws s3 cp $out s3://prjna729801/$out
    rm $in1 $in2 $out
done
