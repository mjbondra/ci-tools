#!/bin/bash

: "${CI_JOB_ID:?ci job id is not set}"
: "${CI_PROJECT_NAME:?ci project name is not set}"
: "${CI_PROJECT_NAMESPACE:?ci project namespace is not set}"
: "${CI_PROJECT_PATH:?ci project path is not set}"

README_MARKDOWN="$(cat README.md)"

# parse arguments
while getopts 'b:t:' FLAG; do
  case "$FLAG" in
    b)
      BADGE="$OPTARG"
      if [ "$BADGE" != "coverage" ] && [ "$BADGE" != "pipeline" ]
      then
        echo "\"$BADGE\" is not a valid badge" >&2
        exit 1
      fi
      ;;
    t)
      TYPE="$OPTARG"
      if [ "$TYPE" != "node" ] && [ "$TYPE" != "shell" ]
      then
        echo "\"$TYPE\" is not a valid release type" >&2
        exit 1
      fi
      ;;
    *)
      echo "Unexpected option $FLAG" >&2
      ;;
  esac
done

: "${BADGE:?badge is not set}"

TYPE=${TYPE:-node}

if [ "$TYPE" == "node" ]
then
  CURRENT_VERSION="v$(node -p "require('./package.json').version")"
elif [ "$TYPE" == "shell" ]
then
  CURRENT_VERSION="$(cat .version)"
fi

NEXT_VERSION="$(echo "$CURRENT_VERSION" | wondermonger-version --prefix "v" --new-version patch)"
BADGE_IMAGE_REGEX="(https:\/\/gitlab\.com\/$CI_PROJECT_PATH\/badges\/)([a-zA-Z0-9.-]*)(\/$BADGE\.svg)"

if [ "$BADGE" == "pipeline" ]
then
  BADGE_LINK_REGEX="(https:\/\/gitlab\.com\/$CI_PROJECT_PATH\/commits\/)([a-zA-Z0-9.-]*)"
  BADGE_LINK_ID_REPLACEMENT="$NEXT_VERSION"
elif [ "$BADGE" == "coverage" ]
then
  BADGE_LINK_REGEX="(https:\/\/$CI_PROJECT_NAMESPACE\.gitlab\.io\/-\/$CI_PROJECT_NAME\/-\/jobs\/)([0-9]*)(\/artifacts\/coverage\/index\.html)"
  BADGE_LINK_ID_REPLACEMENT="$CI_JOB_ID"
fi

if [[ "$README_MARKDOWN" =~ $BADGE_IMAGE_REGEX ]]
then
  BADGE_IMAGE_PATTERN="${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
  BADGE_IMAGE_REPLACEMENT="${BASH_REMATCH[1]}$NEXT_VERSION${BASH_REMATCH[3]}"
fi

if [[ "$README_MARKDOWN" =~ $BADGE_LINK_REGEX ]]
then
  BADGE_LINK_PATTERN="${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
  BADGE_LINK_REPLACEMENT="${BASH_REMATCH[1]}$BADGE_LINK_ID_REPLACEMENT${BASH_REMATCH[3]}"
fi

README_MARKDOWN="${README_MARKDOWN//$BADGE_IMAGE_PATTERN/$BADGE_IMAGE_REPLACEMENT}"
README_MARKDOWN="${README_MARKDOWN//$BADGE_LINK_PATTERN/$BADGE_LINK_REPLACEMENT}"

echo "$README_MARKDOWN" > README.md
