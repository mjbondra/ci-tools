#!/bin/bash

: "${CI_PROJECT_NAME:?project name is not set}"
: "${DOCKER_ORGANIZATION:?docker organization not set}"

REPOSITORY="$DOCKER_ORGANIZATION/$CI_PROJECT_NAME"

docker push "$REPOSITORY"
