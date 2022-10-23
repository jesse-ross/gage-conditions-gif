#!/bin/bash

Rscript -e 'setwd("/code"); scipiper::scmake("2_process/out/dv_stats.rds")'
Rscript -e 'readr::write_csv(readRDS("/code/2_process/out/dv_stats.rds"), "/output/dv_stats.rds")'
