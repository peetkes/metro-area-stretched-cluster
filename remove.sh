#!/bin/bash
source .env
docker compose -f marklogic-3n-centos.yaml -p $DOCKERPROJECT down --volumes

rm -rf data/MarkLogic1/export
rm -rf data/MarkLogic1/Logs
rm -rf data/MarkLogic2/export
rm -rf data/MarkLogic2/Logs
rm -rf data/MarkLogic3/Logs
