#!/bin/bash

SUBTASK="$1"

if [ -n "$SUBTASK" ]
then
  yarn run "test:$SUBTASK"
else
  yarn run test
fi
