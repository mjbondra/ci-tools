#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  npm run "lint:$SUBTASK"
else
  npm run lint
fi
