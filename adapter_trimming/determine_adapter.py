#!/usr/bin/env python3

# Assumes the specific Illumina kit used in Rothman (2021) and produces
# full adapters in the read direction as expected by AdapterRemoval.

import re
import sys
from collections import Counter
from Bio.SeqIO.QualityIO import FastqGeneralIterator

PRIMER1_RC="CTGTCTCTTATACACATCTGACGCTGCCGACGA"
PRIMER2_RC="CTGTCTCTTATACACATCTCCGAGCCCACGAGAC"

P5_RC="GTGTAGATCTCGGTGGTCGCCGTATCATT"
P7_RC="ATCTCGTATGCCGTCTTCTGCTTG"

COLOR_RED = "\x1b[1;31m"
COLOR_END = "\x1b[0m"

def determine_barcode(fname, handle, regex):
    barcodes = Counter()
    for title, seq, qal in FastqGeneralIterator(handle):
        matches = regex.findall(seq)
        if matches:
            match = matches[0]
            barcodes[match] += 1

    if not barcodes:
        raise Exception("%s: no matches for %s" % (
            fname, regex))

    top_two = barcodes.most_common(n=2)
    barcode_top, count_top = top_two[0]

    if len(top_two) > 1:
        barcode_ntop, count_ntop = top_two[1]

        if count_top/count_ntop < 15:
            raise Exception(
                "%s: most common barcode (%s, %s) appears only %.2fx as often as "
                "next most common (%s, %s)." % (
                    fname,
                    barcode_top, count_top,
                    count_top/count_ntop,
                    barcode_ntop, count_ntop))

    return barcode_top

def start(fname_in, fwd_rev):
    primer_rc = {
        "fwd": PRIMER2_RC,
        "rev": PRIMER1_RC,
    }[fwd_rev]

    flow_cell_binder_rc = {
        "fwd": P7_RC,
        "rev": P5_RC,
    }[fwd_rev]

    regex = re.compile("%s([ACGT]{10})%s" % (primer_rc, flow_cell_binder_rc))

    inf = sys.stdin if fname_in == "-" else open(fname_in)
    barcode = determine_barcode(fname_in, inf, regex)

    if sys.stdout.isatty():
        # Make prettier output if presenting to a user.
        barcode = COLOR_RED + barcode + COLOR_END

    print("%s%s%s" % (primer_rc, barcode, flow_cell_binder_rc))

if __name__ == "__main__":
    start(*sys.argv[1:])
