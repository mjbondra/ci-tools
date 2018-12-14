#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  npm run "test:$SUBTASK"
else
  npm run test
fi
