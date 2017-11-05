#!/bin/bash

: "${ACCESS_EMAIL:?git email not set}"
: "${ACCESS_NAME:?git name not set}"

git config --global user.email "${ACCESS_EMAIL}"
git config --global user.name "${ACCESS_NAME}"
