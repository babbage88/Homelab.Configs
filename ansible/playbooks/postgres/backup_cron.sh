#!/bin/bash
DIRNAME=$(date +%Y_%m_%d)
mkdir $DIRNAME
cd /pgdumps && pg_dump k3s | gzip > $DIRNAME/k3s.gz
cd /pgdumps && pg_dump go-infra | gzip > $DIRNAME/go-infra.gz


#b2 file upload  example-bucket $DIRNAME/go-infra.gz $DIRNAME/go-infra.gz
#b2 file upload example-bucket $DIRNAME/k3s.gz $DIRNAME/k3s.gz
#pg_dump -Fc k3s > $DIRNAME/k3s.bak

# Restoring from gzip
#createdb k3s
#gunzip -c $DIRNAME/k3s.gz | psql k3s
