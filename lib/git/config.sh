#!/bin/bash

: "${GIT_USER_EMAIL:?git user email not set}"
: "${GIT_USER_NAME:?git user name not set}"
: "${SSH_PRIVATE_KEY:?ssh private key not set}"

git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"

eval "$(ssh-agent -s)"
ssh-add <(echo "$SSH_PRIVATE_KEY")
