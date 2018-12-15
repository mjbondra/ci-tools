#!/bin/bash

: "${NPM_TOKEN:?npm token is not set}"

NPM_REGISTRY=${NPM_REGISTRY:-"registry.npmjs.org"}

echo "//${NPM_REGISTRY}/:_authToken=${NPM_TOKEN}" >> ~/.npmrc
