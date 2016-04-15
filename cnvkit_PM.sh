#!/bin/bash

## Script to run the CNVkit pipeline on Pipemaster.

set -x

# source modules for current shell
source $MODULESHOME/init/bash

## INPUTS : $1=sample  $2=CNV_DIR
mkdir -p $2/$1/cnvkit

# pull required docker image
# Note: The original docker image for CNVkit (etal/cnvkit) has a missing R package *digest* which is required for the pipeline to run succesfully. This has been added to anu9109/cnvkit.
docker pull anu9109/cnvkit

# Run the pipeline on Tumor samples based on a previously generated pooled normal reference  
docker run -v /data:/home/data -i anu9109/cnvkit bash -c "cnvkit.py batch -p 0 /home/data/storage/patients/alignments/$1-T1-DNA/$1-T1-DNA_gatk_recal.bam -r /home/$2/cnvkit-medexome/pooledref_medexome.cnn --output-dir /home/$2/$1/cnvkit --scatter"

# Convert .cns with logR ratios to copy number calls
docker run -v /data:/home/data -i anu9109/cnvkit bash -c "cnvkit.py call /home/$2/$1/cnvkit/$1-T1-DNA_gatk_recal.cns -o /home/$2/$1/cnvkit/$1-T1-DNA_gatk_recal.call.cns"

# Create a .bed file with chr, start, stop and copy number for each Tumor sample
docker run -v /data:/home/data -i anu9109/cnvkit bash -c "cnvkit.py export bed /home/$2/$1/cnvkit/$1-T1-DNA_gatk_recal.call.cns --show-neutral -o /home/$2/$1/cnvkit/$1.out.bed"

exit 0
