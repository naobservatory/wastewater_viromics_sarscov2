#!/usr/bin/env python3

import re
import sys

from collections import Counter
from Bio import Align
from Bio.SeqIO.QualityIO import FastqGeneralIterator

# Minimum trailing bases to trim if the contig ends with something trimmable.
# We don't want to say no contigs can end with "CT" just because the adapters
# start with CT.
TRIM_THRESHOLD=6

PRIMER1_RC="CTGTCTCTTATACACATCTGACGCTGCCGACGA"
PRIMER2_RC="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC"

P5_RC="GTGTAGATCTCGGTGGTCGCCGTATCATT"
P7_RC="ATCTCGTATGCCGTCTTCTGCTTG"

FWD_BC_REGEX=re.compile("%s([ACGT]{10})%s" % (PRIMER2_RC, P7_RC))
REV_BC_REGEX=re.compile("%s([ACGT]{10})%s" % (PRIMER1_RC, P5_RC))

def determine_barcode(fname, handle, regex):
    n_records = 0
    barcodes = Counter()
    for title, seq, qal in FastqGeneralIterator(handle):
        n_records += 1
        matches = regex.findall(seq)
        if matches:
            match, = matches
            barcodes[match] += 1

    if not barcodes:
        raise Exception("%s: no matches for %s" % (
            fname, regex))

    barcode_top, count_top = barcodes.most_common(n=2)[0]
    barcode_ntop, count_ntop = barcodes.most_common(n=2)[1]

    if count_top/count_ntop < 15:
        raise Exception(
            "%s: most common barcode (%s, %s) appears only %.2fx as often as "
            "next most common (%s, %s)." % (
                fname,
                barcode_top, count_top,
                count_top/count_ntop,
                barcode_ntop, count_ntop))

    return barcode_top, n_records

def align(a, b):
    aligner = Align.PairwiseAligner()
    # These are the scoring settings porechop uses by default.
    # https://github.com/rrwick/Porechop/blob/master/porechop/porechop.py#L145
    aligner.end_gap_score = 0
    aligner.match_score = 3
    aligner.mismatch_score = -6
    aligner.internal_open_gap_score = -5
    aligner.internal_extend_gap_score = -2

    return aligner.align(a, b)[0]

def adapter_index(contig, adapter):
    alignment = align(contig, adapter)
    if alignment.score <= TRIM_THRESHOLD * 3 - 1: return None

    contig_locs, adapter_locs = alignment.aligned
    contig_index_start, contig_index_end = contig_locs[0]

    return contig_index_start

def trim_ends(seq, qal):
    while qal.endswith("#"):
        seq = seq[:-1]
        qal = qal[:-1]

    while qal.startswith("#"):
        seq = seq[1:]
        qal = qal[1:]

    return seq, qal

def run(fname_in, inf, outf, adapter_rc, n_records):
    for n_record, (title, seq, qal) in enumerate(FastqGeneralIterator(inf)):
        if False and n_record % 1000 == 0:
            print("\rprogress: ... %.0f%% (%s/%s)" % (
                n_record/n_records*100, n_record, n_records), end="")
        if True and n_record % 10000 == 0:
            print("%s: %.0f%% (%s/%s)" % (
                fname_in, n_record/n_records*100, n_record, n_records))

        loc = adapter_index(seq, adapter_rc)
        if loc is not None:
            seq = seq[:loc]
            qal = qal[:loc]

        seq, qal = trim_ends(seq, qal)

        outf.write("@%s\n%s\n+\n%s\n" % (title, seq, qal))
    print("\n %s complete" % fname_in)

def start(fname_in, fname_out):
    is_fwd = "_1." in fname_in
    is_rev = "_2." in fname_in

    fwd_rev = {
        (True, False): "fwd",
        (False, True): "rev",
    }[is_fwd, is_rev]

    regex = {
        "fwd": FWD_BC_REGEX,
        "rev": REV_BC_REGEX,
    }[fwd_rev]

    with open(fname_in) as inf:
        barcode, n_records = determine_barcode(fname_in, inf, regex)

    print ("%s: %s (%s)" % (fname_in, barcode, n_records))
        
    adapter_rc = {
        "fwd": "%s%s%s" % (PRIMER2_RC, barcode, P7_RC),
        "rev": "%s%s%s" % (PRIMER1_RC, barcode, P5_RC),
    }[fwd_rev]

    # Because we're using a two-color system, reads that go off the end will
    # see lots of G.  This means there's a sense in which adapters "end" with
    # strings of G.
    adapter_rc += "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"

    with open(fname_in) as inf:
        with open(fname_out, 'w') as outf:
            #run(fname_in, inf, outf, adapter_rc, n_records)
            outf.write("test")

if __name__ == "__main__":
    start(*sys.argv[1:])
