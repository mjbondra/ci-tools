#!/bin/bash

CI_BIN="bin"
CI_BIN_TMP=".bin-tmp"
CI_LIB="lib"
CI_LIB_RELATIVE_BIN="../lib"
CI_PREFIX="ci"

VALID_VERSION_REGEX="^[A-Za-z]*[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]*[0-9A-Za-z]+)*$"


# bin filename functions
get_relative_path () { echo "${1//$CI_LIB/$CI_LIB_RELATIVE_BIN}"; }
remove_extension () { echo "${1//.sh/}"; }
replace_prefix () { echo "${1//$CI_LIB/$CI_PREFIX}"; }
replace_slash () { echo "${1//\//-}"; }


# parse arguments
while getopts 'v:' FLAG; do
  case "$FLAG" in
    v)
      RAW_IMAGE_VERSION=${OPTARG/v/}
      if ! [[ "$RAW_IMAGE_VERSION" =~ $VALID_VERSION_REGEX ]]
      then
        echo "\"${RAW_IMAGE_VERSION}\" is an invalid semantic version" >&2
        exit 1
      fi
      IMAGE_VERSION="v${RAW_IMAGE_VERSION}"
      ;;
    *)
      echo "Unexpected option $FLAG" >&2
      ;;
  esac
done


# version templates
NEXT_PATCH_VERSION="$(git tag | wondermonger-version \
  --version-file .version \
  --prefix v \
  --new-version patch)"

IMAGE_VERSION=${IMAGE_VERSION:-$NEXT_PATCH_VERSION}
TPL_CI_IMAGE_HEADER="image: wondermonger/ci-tools:${IMAGE_VERSION}"
TPL_NODE_BASE="${TPL_CI_IMAGE_HEADER}"$'\n'"$(tail -n +2 ./tpl/node/base.yml)"
echo "$TPL_NODE_BASE" > ./tpl/node/base.yml


# ensure script permissions 
chmod -R 755 "$CI_LIB"


# create temporary bin directory
mkdir -p "$CI_BIN_TMP"


# create script symlinks in temporary bin directory
while read -r -d "" CI_SCRIPT
do
  CI_SCRIPT_ALIAS="$(replace_prefix "$(remove_extension "$(replace_slash "$CI_SCRIPT")")")"
  CI_SCRIPT_ALIAS_PATH="$CI_BIN_TMP/$CI_SCRIPT_ALIAS"
  CI_SCRIPT_RELATIVE_PATH="$(get_relative_path "$CI_SCRIPT")"

  ln -s "$CI_SCRIPT_RELATIVE_PATH" "$CI_SCRIPT_ALIAS_PATH"
done < <(find lib -name "*.sh" -print0)


# replace bin directory with temporary bin directory
rm -rf "$CI_BIN"
mv "$CI_BIN_TMP" "$CI_BIN"
