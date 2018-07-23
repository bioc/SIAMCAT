#!/usr/bin/Rscript
###
# SIAMCAT -  Statistical Inference of Associations between Microbial Communities And host phenoTypes
# EMBL Heidelberg 2012-2018
# GNU GPL 3.0
###
install.packages('session')
library(session)
restore.session(file="../dependencies/testImage.RData")
if(!"SIAMCAT"%in%installed.packages()) install.packages("./SIAMCAT_0.4.0.tar.gz", repos=NULL, type="source")
