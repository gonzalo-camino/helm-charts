#!/bin/bash
CHART=community-openam
cd chart
COPYFILE_DISABLE=1 tar -czf ../${CHART}.tgz ${CHART}/
