#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  yarn run "lint:$SUBTASK"
else
  yarn run lint
fi
