#!/usr/bin/env Rscript
# put the script with dataset together
# sessionInfo()
library(stringr)
library(tidyr)
library(ggplot2)
require(lattice)
library(reticulate) # version 1.13
library(roahd) # version 1.4.1
library(cluster)
library(optparse)

option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="clustered.csv", 
              help="output file name [default= %default]", metavar="character"),
  # make_option(c("-e", "--environment"), default=NULL, help="conda environment", metavar="character"),
  make_option(c("-n", "--n_trial_kmeans"),  default="100", 
              help="the times of kmeans++ you want to run", metavar=""),
  make_option(c("-m", "--n_trial_kneedle"),  default="100", 
              help="the times of kneedle algorithm  you want to run", metavar=""),
  make_option(c("-k", "--n_cluster"), default="25", 
              help="the range of clusters number you want to test, if you put 25 , then the range is from 1 to 25", metavar="")) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
########################################################
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}
# use the conda environments
# use_condaenv(opt$environment, conda="/bin/micromamba")
use_condaenv(condaenv="/opt/conda/envs/arbc", conda="/bin/micromamba")
source_python("Step1_Kmeans_kneed_2022.1.py")

# (1) check if there is any clusters that have less than 3 curves
# the input: the "best" result from kmeans++ classfification
checkless3 <- function(bestrun){
  cluster_label=bestrun$cluster_label
  min_freq = min(table(cluster_label))
  if (min_freq < 3){
    return(TRUE)
  }
  else {
    return(FALSE)
  }}


# (2) function to delete clusters with less 3 curves and rerun kmeans++
delete_less3 <- function(bestrun,n_trial,n_trial_kneedle,ncluster_test){
  cluster_label=bestrun$cluster_label
  delete_cluster = names(which(table(cluster_label)==min(table(cluster_label))))
  # delete the cluster thta less than 3
  run <- bestrun[bestrun$cluster_label!=delete_cluster, ]
  return(run)}

# (3) function to dectect shape and magnitude outeliers 
# function to dectect shape and magnitude outeliers
shapemagoutlier <- function(bestrun){
  # depthe for xlab
  depth = seq(0.1,0.9, length.out = 9)
  # K is how many clusters in the input dataset
  Kmax = max(as.numeric((bestrun$cluster_label)))
  print(Kmax)
  Kmin = min(as.numeric((bestrun$cluster_label)))
  print(Kmin)
  outlier_list <- c()
  for (i in Kmin:Kmax){
    c <- bestrun[bestrun$cluster_label==i,]
    if (nrow(c) > 2) {
      d <- c[, 2:10]
      data <- as.matrix(d, dimnames = NULL)
      fd = fData(depth, data)
      title <- paste0("cluster", i )
      #print(title)
      # if you want to plot shapeoutlier, change the display to T
      ShapeOutlier <- outliergram(fd, display = F, Fvalue = 1,  main = list(title, "Shape_Outlier_Graph"))
      ShapeOutlier_id <- ShapeOutlier$ID_outliers
      #print("shapeOutlier", ShapeOutlier_id)
      # if you want to plot mag outlier, change the display to T
      MagOutlier <- fbplot(fd,display = F, adjust=T, main = title , Fvalue=1.50, xlab='Depth', ylab='DS_value')
      MagOutlier_id <- MagOutlier$ID_outliers
      #print("Magnitude Outlier", MagOutlier)
      outlier_list <- c(outlier_list,ShapeOutlier_id,MagOutlier_id)}
  }
  outlier_list <- as.numeric(names(outlier_list))
  outlier_list <- outlier_list[!is.na(outlier_list)]
  #print(outlier_list_row)
  return(outlier_list)
}


# code to run spectrum pipeline 
# number of kmeans++ you want to run 
n_trial = opt$n_trial_kmeans
# number of kneedle algorithm you want to run 
n_trial_kneedle = opt$n_trial_kneedle
# number of clusters you want to test 
ncluster_test = opt$n_cluster

ds <- inputdata_ds(opt$file)
dswithtag <- inputdata_dswithtag(opt$file)
run <- kmeansplusplus(as.integer(n_trial),as.integer(n_trial_kneedle),as.integer(ncluster_test),ds,dswithtag)
i=1
while (i < 10 ) {
  if (length(shapemagoutlier(run)) > 0) {
    run <- run [-shapemagoutlier(run),]
    ds_new <- run[,2:10]
    dswithtag_new <- run [,1:10]
    run <- kmeansplusplus(as.integer(n_trial),as.integer(n_trial_kneedle),as.integer(ncluster_test),ds_new,dswithtag_new)}
  else 
  {break}}
# write csv file include each cluster assignment. 

write.csv(run, opt$out,row.names = F)

######################################################################################################################


