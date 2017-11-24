#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  yarn run "build:$SUBTASK"
else
  yarn run build
fi
