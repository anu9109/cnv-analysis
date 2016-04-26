## Update CNV DIR file path as needed (RCC files are expected in this directory as *nanostringCNV*.RCC) ##

library(plyr)

readRaw <- function(file) {
  dat <- read.csv2(file, skip=26, sep=',', stringsAsFactors=F)
  dat <- dat[1:(dim(dat)[1]-3),]
  
  endo <- subset(dat, CodeClass=='Endogenous')
  inv <- subset(dat, CodeClass=='Invariant')
  ctrls <- subset(dat, CodeClass=='Positive' | CodeClass=='Negative')
  res <- subset(dat, CodeClass=='RestrictionSite')
  
  return(list(endo=endo,
              inv=inv,
              ctrls=ctrls,
              res=res))
}

## NORMALIZATION
# +ve control 
posCtrls <- sapply(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "nanostringCNV.*\\.RCC$", recursive = TRUE, full.names = TRUE), function(i) subset(readRaw(i)$ctrls, CodeClass=="Positive")$Count)
geomSample <- apply(posCtrls, 2, mean)
geomAll <- exp(mean(log(geomSample))) 
sf <- geomSample / geomAll

# -ve control
negCtrls <- sapply(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "nanostringCNV.*\\.RCC$", recursive = TRUE, full.names = TRUE), function(i) subset(readRaw(i)$ctrls, CodeClass=="Negative")$Count)
meanSample <- apply(negCtrls, 2, mean)
sdSample <- apply(negCtrls, 2, sd)
bg <- meanSample + 3 * sdSample

# calculating mean INV count across all samples (change size flag for random subset)
randINVmeancount <- mean(sapply(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "nanostringCNV.*\\.RCC$", recursive = TRUE, full.names = TRUE), function(i) mean(readRaw(i)$inv$Count)))


normNSinvar <- function(NSdat, NSfile) {
  invar <- NSdat$inv
  invar$Countpos <- NSdat$inv$Count * sf[NSfile]
  invar$Countneg <- invar$Countpos - bg[NSfile]
  invnf <- randINVmeancount / mean(NSdat$inv$Count)
  invar$Count <- invar$Countneg* invnf
  return(invar)
}

# invariants
invariants <- function(NSfile){
  NSdat <- readRaw(NSfile)
  NSdat$inv_norm <- normNSinvar(NSdat, NSfile)
  return(NSdat$inv_norm$Count)
}

# t-test
tt_patient <- function(x){
  return(as.numeric(t.test(invariants(paste0("/Users/aanu/Desktop/AWS/storage/patients/cnv/", x, "/", x, "-nanostringCNV-T.RCC")), invariants(paste0("/Users/aanu/Desktop/AWS/storage/patients/cnv/", x, "/", x, "-nanostringCNV-B.RCC")))$p.value))
}

# per-patient t-test pvalues
samples <- c(substring(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "-T.RCC$", recursive = TRUE),1,6))
pvalues_per_pt <- cbind(samples, p.value=lapply(samples,tt_patient))


# per-invariant probe t-test pvalues
x <- "CCD025"
invar_probes <- normNSinvar(readRaw(paste0("/Users/aanu/Desktop/AWS/storage/patients/cnv/", x, "/", x, "-nanostringCNV-T.RCC")), paste0("/Users/aanu/Desktop/AWS/storage/patients/cnv/", x, "/", x, "-nanostringCNV-T.RCC"))$Name
t_norm_invar <- data.frame(cbind(sapply(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "-T.RCC$", recursive = TRUE, full.names = TRUE), function(i) invariants(i))))
b_norm_invar <- data.frame(cbind(sapply(list.files(path = "/Users/aanu/Desktop/AWS/storage/patients/cnv", pattern = "-B.RCC$", recursive = TRUE, full.names = TRUE), function(i) invariants(i))))
a <- data.frame(t(t_norm_invar))
b <- data.frame(t(b_norm_invar))
pvalues_per_invar_probe <- cbind(invar_probes, p.values=(sapply(c(1:54), function(i) t.test(a[,i], b[,i])$p.value)))

# 12 invariant probes that have a significant p-value
subset(data.frame(pvalues_per_invar_probe, stringsAsFactors = F), p.values < 0.05)

# adjusted p-values
p.adjust(pvalues_per_invar_probe[,"p.values"],method = "BH")
which(p.adjust(pvalues_per_invar_probe[,"p.values"],method = "BH") < 0.05)
table(pvalues_per_invar_probe[,2] < 0.05)

# box-plots to visualize the 3 most "variant" regions
boxplot(as.numeric(t_norm_invar[6,]),as.numeric(b_norm_invar[6,]))
boxplot(as.numeric(t_norm_invar[14,]),as.numeric(b_norm_invar[14,]))
boxplot(as.numeric(t_norm_invar[19,]),as.numeric(b_norm_invar[19,]))

