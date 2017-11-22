#!/bin/bash

CI_BIN="bin"
CI_BIN_TMP=".bin-tmp"
CI_LIB="lib"
CI_LIB_RELATIVE_BIN="../lib"
CI_PREFIX="ci"

get_relative_path () { echo "${1//$CI_LIB/$CI_LIB_RELATIVE_BIN}"; }
remove_extension () { echo "${1//.sh/}"; }
replace_prefix () { echo "${1//$CI_LIB/$CI_PREFIX}"; }
replace_slash () { echo "${1//\//-}"; }

chmod -R 755 "$CI_LIB"
mkdir -p "$CI_BIN_TMP"

git add "$CI_LIB"
git commit -m "[ci skip] update permissions"

while read -r -d "" CI_SCRIPT
do
  CI_SCRIPT_ALIAS="$(replace_prefix "$(remove_extension "$(replace_slash "$CI_SCRIPT")")")"
  CI_SCRIPT_ALIAS_PATH="$CI_BIN_TMP/$CI_SCRIPT_ALIAS"
  CI_SCRIPT_RELATIVE_PATH="$(get_relative_path "$CI_SCRIPT")"

  ln -s "$CI_SCRIPT_RELATIVE_PATH" "$CI_SCRIPT_ALIAS_PATH"
done < <(find lib -name "*.sh" -print0)

rm -rf "$CI_BIN"
mv "$CI_BIN_TMP" "$CI_BIN"

git add "$CI_BIN"
git commit -m "[ci skip] update executables"
