#!/bin/bash

export AWS_DEFAULT_REGION=us-west-2
cd /code/
Rscript -e 'cat(paste("region is", Sys.getenv("AWS_DEFAULT_REGION"), "\n")); cat(paste("scipiper.use_local_aws_credentials is", options("scipiper.use_local_aws_credentials"), "\n")); scipiper::scmake("2_process/out/dv_stats.rds"); cat("ran stats\n")'
Rscript -e 'cat("REFORMATTING dv_stats file\n"); cat("READING 2_process/out/dv_stats.rds\n"); readr::write_csv(readRDS("2_process/out/dv_stats.rds"), "/output/dv_stats.csv"); cat("WROTE /output/dv_stats.csv\n")'
