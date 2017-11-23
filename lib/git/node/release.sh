#!/bin/bash

: "${CI_PROJECT_PATH:?ci project path is not set}"
: "${CI_COMMIT_REF_NAME:?ci commit ref name is not set}"
: "${SSH_PRIVATE_KEY:?ssh private key not set}"

CI_REPOSITORY_URL="git@gitlab.com:$CI_PROJECT_PATH.git"

eval "$(ssh-agent -s)"
ssh-add <(echo "$SSH_PRIVATE_KEY")

# commit release artifacts
git add -A

# tagged release and untagged prerelease
yarn config set version-git-message "release v%s"
yarn version --new-version patch
yarn version --no-git-tag-version --new-version prerelease

PRERELEASE_VERSION="$(node -p "require('./package.json').version")"

git add package.json
git commit -m "[ci skip] prerelease v${PRERELEASE_VERSION}"
git push --follow-tags "$CI_REPOSITORY_URL" "HEAD:$CI_COMMIT_REF_NAME"
