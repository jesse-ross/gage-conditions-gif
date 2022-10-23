#!/bin/bash

Rscript -e 'scipiper::scmake("2_process/out/dv_stats.rds")'
Rscript -e 'readr::write_csv(readRDS("2_process/out/dv_stats.rds"), "/output/dv_stats.rds")'
