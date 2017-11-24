#!/bin/bash

: "${NPM_TOKEN:?npm token is not set}"

echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> ~/.npmrc
