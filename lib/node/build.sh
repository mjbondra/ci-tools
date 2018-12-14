#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  npm run "build:$SUBTASK"
else
  npm run build
fi
