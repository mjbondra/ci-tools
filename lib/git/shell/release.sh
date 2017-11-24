#!/bin/bash

: "${CI_PROJECT_PATH:?ci project path is not set}"
: "${CI_COMMIT_REF_NAME:?ci commit ref name is not set}"
: "${SSH_PRIVATE_KEY:?ssh private key not set}"

CI_REPOSITORY_URL="git@gitlab.com:$CI_PROJECT_PATH.git"

eval "$(ssh-agent -s)"
ssh-add <(echo "$SSH_PRIVATE_KEY")

# commit release artifacts
git add -A

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

git push --follow-tags "$CI_REPOSITORY_URL" "HEAD:$CI_COMMIT_REF_NAME"
