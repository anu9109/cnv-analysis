#!/bin/bash

set -x

# source modules for current shell
source $MODULESHOME/init/bash

####INPUTS: $1=sample $2=CNV_DIR

module load R

Rscript /home/anu/cnv-analysis/cytoSNP850k_segmentation_PM.R $2 $1

exit 0
