#!/bin/bash

: "${CI_PROJECT_PATH:?ci project path is not set}"
: "${CI_COMMIT_REF_NAME:?ci commit ref name is not set}"

ARTIFACTS=()
CI_REPOSITORY_URL="git@gitlab.com:$CI_PROJECT_PATH.git"

# parse arguments
while getopts 'a:t:' FLAG; do
  case "$FLAG" in
    a)
      ARTIFACT="$OPTARG"
      if [ -f "$ARTIFACT" ] || [ -d "$ARTIFACT" ]
      then
        ARTIFACTS+=("$ARTIFACT")
      else
        echo "\"$ARTIFACT\" is not a valid file or directory" >&2
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

TYPE=${TYPE:-node}

# stage artifacts for commit
for ARTIFACT in "${ARTIFACTS[@]}"
do
  git add "$ARTIFACT"
done

if [ "$TYPE" == "node" ]
then

  # tagged release and untagged prerelease
  yarn config set version-git-message "release v%s"
  yarn version --new-version patch
  yarn version --no-git-tag-version --new-version prerelease

  PRERELEASE_VERSION="$(node -p "require('./package.json').version")"

  git add package.json
  git commit -m "[ci skip] prerelease v${PRERELEASE_VERSION}"

elif [ "$TYPE" == "shell" ]
then

  # tagged release
  RELEASE_VERSION="$(git tag | wondermonger-version \
    --version-file .version \
    --prefix v \
    --new-version patch)"

  echo "$RELEASE_VERSION" > .version

  git add .version
  git commit -m "release ${RELEASE_VERSION}"
  git tag -a "$RELEASE_VERSION" -m "release ${RELEASE_VERSION}"

  # untagged prerelease
  PRERELEASE_VERSION="$(git tag | wondermonger-version \
    --version-file .version \
    --prefix v \
    --new-version prerelease)"

  echo "$PRERELEASE_VERSION" > .version

  git add .version
  git commit -m "[ci skip] prerelease ${PRERELEASE_VERSION}"

fi

git push --follow-tags "$CI_REPOSITORY_URL" "HEAD:$CI_COMMIT_REF_NAME"
