#!/usr/bin/env bash

in1="$1"
in2="$2"
out1="$3"
out2="$4"


args=(
    in=$in1
    in2=$in2
    ref=adapters,phix
    # kmer-trimming mode: remove matching kmer and anything following from
    # right end of reads
    ktrim=r
    # Allow shorter k-mers at the ends of the reads.  Recommended for
    # adapter trimming.
    mink=11
    # Hamming distance of 1: allow a single mismatch.  Recommended for
    # adapter trimming.
    hdist=1
    # Trim both ends of reads for quality, after the rest of the trimming
    # triggered by the other flags.
    qtrim=rl
    # PHRED quality 10, which is 90%.  Since this data only uses the
    # quality scores '#,:F' (2, 11, 25, and 37), this is saying to allow
    # ',:F' (92% and up) and disallow '#' (37%).
    trimq=10
    out=$out1
    out2=$out2
    stats=$stats
    refstats=$refstats
    # Trim both reads to the same length, even if the adapter was only
    # detected in one of them.  Recommended for adapter trimming on normal
    # paired-end fragment libraries.
    #
    # [JK] This wasn't obvious to me at first.  The only situation in which
    # you should be sequencing adapters is when fragments are shorter than
    # your read length.  The fragment looks like:
    #
    #    [adapter][fragment][rc adapter]
    #
    # and while the read begins at [fragment] it can continue off the end
    # and into [rc adapter] if it's not long enough.  The corresponding
    # paired-end read should be, for a fragment short like this:
    #
    #    [adapter][rc fragment][rc adapter]
    #
    # This means, if everything is working perfectly, we should identify
    # adapters in either (a) both reads or (b) no reads and in (a) both
    # reads should be the same length after trimming.  If this isn't the
    # case something has gone wrong, and since accuracy drops off near the
    # end of a read the best guess is that we just failed to recognize the
    # adapter.
    tpe
    # Trim adapters based on overlap detection.  Recommended for adapter
    # trimming on normal paired-end fragment libraries.  Doesn't require a
    # list of adapters.
    #
    # [JK] This is similar to tpe in that the situation in which you
    # sequence adapters is when your fragment is shorter than your read
    # length, and so you've sequenced the same fragment twice.
    tbo
    # Rothman doesn't include something like trimpolygright=7, and I think
    # probably should have?  Lots of reads end in poly-g tails due to the
    # color chemistry of the sequencer.
    threads=30
)

# To get the tool on Linux, run:
#
# wget https://sourceforge.net/projects/bbmap/files/\
#              BBMap_39.01.tar.gz/download \
#              -O BBMap_39.01.tar.gz
# tar -xvzf BBMap_39.01.tar.gz
#
# on Mac, brew install bbtools
bbduk.sh "${args[@]}"
