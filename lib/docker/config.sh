#!/bin/bash

: "${DOCKER_PASSWORD:?docker password not set}"
: "${DOCKER_USERNAME:?docker username not set}"

if [ -n "$DOCKER_REGISTRY" ]; then

  # custom docker registry
  echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin "$DOCKER_REGISTRY"

else

  # default docker registry
  echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

fi
