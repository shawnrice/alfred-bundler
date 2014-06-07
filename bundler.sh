#!/bin/sh

. "$__data/includes/helper-functions.sh"

function __loadAsset {
  # $1 -- asset name
  # $2 -- version
  # $3 -- bundle
  # $4 -- type
  # $5 -- json (file-path)

  local name="$1"
  local version="$2"
  local bundle="$3"
  local type="$4"
  local json="$5"

  if [ -f "$__data/assets/$type/$name/$version/invoke" ]; then
    invoke=$(echo `cat "$__data/assets/$type/$name/$version/invoke"`)
    if [ "$invoke" = 'null' ]; then
      invoke=''
    fi
    if [ "$type" = "utility" ]; then
      sh "$__data/includes/gatekeeper.sh" "$name" "$__data/assets/$type/$name/$version/$invoke"  > /dev/null
    fi
    echo "$__data/assets/$type/$name/$version/$invoke"
    if [[ ! -z $bundle ]] && [[ $bundle != '..' ]]; then
      php "$__data/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
    fi
    return 0
  fi
  if [ -z "$json" ]; then
    json="$__data/meta/defaults/$name.json"
  fi
  if [ -f "$json" ]; then
    php "$__data/includes/installAsset.php" "$json" "$version"
    if [ ! -z "$result" ]; then
      echo "$result"
      return 0
    fi
    if [ -f "$__data/assets/$type/$name/$version/invoke" ]; then
      invoke=$(echo `cat "$__data/assets/$type/$name/$version/invoke"`)
      if [ "$invoke" = 'null' ]; then
        invoke=''
      fi
      echo "$__data/assets/$type/$name/$version/$invoke"
      if [[ ! -z "$bundle" ]] && [[ "$bundle" != '..' ]]; then
        php "$__data/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
      fi
      if [ $type = 'utility' ]; then
        if [ ! -z "$invoke" ]; then
          sh "$__data/includes/gatekeeper.sh" "$name" "$__data/assets/$type/$name/$version/$invoke" > /dev/null
        fi
      fi
      return 0
    fi
  else
    echo "JSON file does not exist : $json"
    return 1
  fi
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know."
  return 1
}