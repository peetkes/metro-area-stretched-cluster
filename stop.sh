#!/bin/bash
source .env
docker compose -f marklogic-3n-centos.yaml -p $DOCKERPROJECT stop