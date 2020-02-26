#!/bin/bash

docker build \
    --build-arg VCS_REF=$(git rev-parse HEAD | cut -c1-10) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    -t rhaix/ubuntu-base \
    -f Dockerfile.base \
    .

docker build \
    --build-arg VCS_REF=$(git rev-parse HEAD | cut -c1-10) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    -t rhaix/asciidoctor-base \
    -f Dockerfile.asciidoctor \
    .
