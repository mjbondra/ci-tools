#!/bin/bash

: "${CI_COMMIT_TAG:?tag name not set}"
: "${CI_PROJECT_NAME:?project name is not set}"
: "${DOCKER_ORGANIZATION:?docker organization not set}"

VALID_VERSION_REGEX="^[A-Za-z]*[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]*[0-9A-Za-z]+)*$"

if ! [[ "$CI_COMMIT_TAG" =~ $VALID_VERSION_REGEX ]]; then
  echo "\"$CI_COMMIT_TAG\" is an invalid semantic version" >&2
  exit 1
fi

DOCKER_BUILD_ARGUMENTS=()
REPOSITORY="$DOCKER_ORGANIZATION/$CI_PROJECT_NAME"
read -r -a VERSION <<<"${CI_COMMIT_TAG//-/ }"

if [ -n "${VERSION[1]}" ]; then

  PRERELEASE="$CI_COMMIT_TAG"
  DOCKER_BUILD_ARGUMENTS+=("--tag" "$REPOSITORY:$PRERELEASE")

else

  read -r -a SEMANTIC_VERSION_ARRAY <<<"${VERSION//./ }"
  MAJOR="${SEMANTIC_VERSION_ARRAY[0]}"
  MINOR="$MAJOR.${SEMANTIC_VERSION_ARRAY[1]}"
  PATCH="$MINOR.${SEMANTIC_VERSION_ARRAY[2]}"

  DOCKER_BUILD_ARGUMENTS+=("--tag" "$REPOSITORY:latest")
  DOCKER_BUILD_ARGUMENTS+=("--tag" "$REPOSITORY:$MAJOR")
  DOCKER_BUILD_ARGUMENTS+=("--tag" "$REPOSITORY:$MINOR")
  DOCKER_BUILD_ARGUMENTS+=("--tag" "$REPOSITORY:$PATCH")

fi

docker build "${DOCKER_BUILD_ARGUMENTS[@]}" .
