#!/bin/bash

export AWS_DEFAULT_REGION=us-west-2
Rscript -e 'setwd("/code"); cat("cd-ed\n"); cat(paste("region is", Sys.getenv("AWS_DEFAULT_REGION"), "\n")); scipiper::scmake("2_process/out/dv_stats.rds"); cat("ran stats\n")'
Rscript -e 'readr::write_csv(readRDS("/code/2_process/out/dv_stats.rds"), "/output/dv_stats.rds")'
