#!/bin/bash

export AWS_DEFAULT_REGION=us-west-2
Rscript -e 'cat(paste("working directory is", getwd(), "\n")); cat(paste("region is", Sys.getenv("AWS_DEFAULT_REGION"), "\n")); cat(paste("scipiper.use_local_aws_credentials is", options("scipiper.use_local_aws_credentials"), "\n")); scipiper::scmake("2_process/out/dv_stats.rds"); cat("ran stats\n")'
Rscript -e 'cat(paste("working directory is", getwd(), "\n")); cat("REFORMATTING dv_stats file\n"); cat("READING 2_process/out/dv_stats.rds\n"); readr::write_csv(readRDS("2_process/out/dv_stats.rds"), "/ephemeral/dv_stats.csv"); cat("WROTE /ephemeral/dv_stats.csv\n")'
cp 2_process/out/dv_stats.rds /ephemeral/
echo "COPIED dv_stats.rds to /ephemeral/"
