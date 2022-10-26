#!/bin/bash

export AWS_DEFAULT_REGION=us-west-2
Rscript -e 'scipiper::scmake("2_process/out/dv_stats.rds")'
cp -v 2_process/out/dv_stats.rds /ephemeral/
