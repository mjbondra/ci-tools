#!/bin/bash

: "${CI_COMMIT_TAG:?tag name not set}"
: "${CI_PROJECT_NAME:?project name is not set}"
: "${DOCKER_ORGANIZATION:?docker organization not set}"

REPOSITORY="$DOCKER_ORGANIZATION/$CI_PROJECT_NAME"
TAG="$REPOSITORY:$CI_COMMIT_TAG"
LATEST="$REPOSITORY:latest"

docker build --tag "$TAG" --tag "$LATEST" .
