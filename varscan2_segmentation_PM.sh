#!/bin/bash
set -x

# source modules for current shell
source $MODULESHOME/init/bash

module load R

Rscript /home/anu/cnvanalysis/varscan2_segmentation_PM.R $2 $1
