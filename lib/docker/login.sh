#!/bin/bash

: "${DOCKER_PASSWORD:?docker password not set}"
: "${DOCKER_USERNAME:?docker username not set}"

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
