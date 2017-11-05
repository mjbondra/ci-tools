#!/bin/bash

while read -r -d "" SCRIPT_PATH
do
  shellcheck "$SCRIPT_PATH"
done < <(find . -name "*.sh" -print0)
