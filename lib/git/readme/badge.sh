#!/bin/bash

: "${CI_COMMIT_REF_NAME:?ci commit ref name is not set}"
: "${CI_JOB_ID:?ci job id is not set}"
: "${CI_PIPELINE_ID:?ci pipeline id is not set}"
: "${CI_PROJECT_NAME:?ci project name is not set}"
: "${CI_PROJECT_NAMESPACE:?ci project namespace is not set}"
: "${CI_PROJECT_PATH:?ci project path is not set}"

README_MARKDOWN="$(cat README.md)"

# parse arguments
while getopts 'b:' FLAG; do
  case "$FLAG" in
    b)
      BADGE="$OPTARG"
      if [ "$BADGE" != "coverage" ] && [ "$BADGE" != "pipeline" ]
      then
        echo "\"$BADGE\" is not a valid badge" >&2
        exit 1
      fi
      ;;
    *)
      echo "unexpected option $FLAG" >&2
      ;;
  esac
done

: "${BADGE:?badge is not set}"

BADGE_CHARACTERS="a-zA-Z0-9 "
URI_CHARACTERS="a-zA-Z0-9./:-"
BADGE_REGEX="\\[!\\[$BADGE[$BADGE_CHARACTERS]*\\]\\([$URI_CHARACTERS]*\\)\\]\\([$URI_CHARACTERS]*\\)"

if [[ "$README_MARKDOWN" =~ $BADGE_REGEX ]]
then
  BADGE_PATTERN="${BASH_REMATCH[0]}"
else
  echo "\"$BADGE\" badge not found in README.md" >&2
  exit 1
fi

if [ "$BADGE" == "pipeline" ]
then
  BADGE_TITLE="pipeline status"
  BADGE_LINK="https://gitlab.com/$CI_PROJECT_PATH/pipelines/$CI_PIPELINE_ID"
elif [ "$BADGE" == "coverage" ]
then
  BADGE_TITLE="coverage report"
  BADGE_LINK="https://$CI_PROJECT_NAMESPACE.gitlab.io/-/$CI_PROJECT_NAME/-/jobs/$CI_JOB_ID/artifacts/coverage/index.html"
fi

BADGE_IMAGE="https://gitlab.com/$CI_PROJECT_PATH/badges/$CI_COMMIT_REF_NAME/$BADGE.svg"
BADGE_REPLACEMENT="[![$BADGE_TITLE]($BADGE_IMAGE)]($BADGE_LINK)"
README_MARKDOWN_REPLACEMENT="${README_MARKDOWN//"$BADGE_PATTERN"/$BADGE_REPLACEMENT}"

echo "$README_MARKDOWN_REPLACEMENT" > README.md
