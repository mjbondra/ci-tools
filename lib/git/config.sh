#!/bin/bash

: "${GIT_USER_EMAIL:?git user email not set}"
: "${GIT_USER_NAME:?git user name not set}"

git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"
