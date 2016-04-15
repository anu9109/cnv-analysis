library(DNAcopy)

args <- commandArgs(TRUE)
prefix <- args[1]
sample <- args[2]

cn <- read.table(sample,header=T, sep="\t", stringsAsFactors = F)

CNA.object <-CNA( genomdat = cn[,7], chrom = cn[,1], maploc = cn[,2], data.type = 'logratio')
CNA.smoothed <- smooth.CNA(CNA.object)
segs <- segment(CNA.smoothed, verbose=0, min.width=2)
seg.pvalue <- segments.p(segs, ngrid=100, tol=1e-6, alpha=0.05, search.range=100, nperm=1000)

write.table (seg.pvalue, paste0(prefix, ".varscan_cnv.copynumber.seg"), row.names=F, col.names=F, quote=F, sep="\t")
