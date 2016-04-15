#!/bin/bash

## Script to merge copy number segments created by DNAcopy as recommended by VarScan2.

set -x

# source modules for current shell
source $MODULESHOME/init/bash

####INPUTS: $1=sample $2=VARIANT_DIR

perl /data/database/varscan2/mergeSegments.pl $2/$1/$1.varscan_cnv.copynumber.seg --ref-arm-sizes /data/database/varscan2/chrom_lengths_hg19_varscan2.txt --output-basename $2/$1/$1

exit 0
