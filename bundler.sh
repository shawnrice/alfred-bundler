#!/bin/sh

. "$__data/includes/helper-functions.sh"

bd_asset_cache="$__data/data/call-cache"

# Caching wrapper around the real function
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
  local cachepath
  local key
  local path

  # Create cache directory if it doesn't exist
  [[ ! -d "${bd_asset_cache}" ]] && mkdir -p "${bd_asset_cache}"

  # Cache path for this call
  key=$(md5 -q -s "${name}-${version}-${bundle}-${type}-${json}")
  cachepath="${bd_asset_cache}/${key}"

  # Load result from cache if it exists
  if [[ -f "${cachepath}" ]]; then
    path=$(cat "${cachepath}")
    if [[ -f "${path}" ]]; then
      echo "$path"
      return 0
    fi
  fi

  # No valid cache, call real function and cache that result
  path=$(__loadAssetInner "${name}" "${version}" "${bundle}" "${type}" "${json}")
  status=$?
  [[ $status -gt 0 ]] && return $status
  echo "${path}" > "${cachepath}"
  echo "${path}"
  return 0
}

function __loadAssetInner {
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
    invoke=$(cat "$__data/assets/$type/$name/$version/invoke")
    if [ "$invoke" = 'null' ]; then
      invoke=''
    fi
    if [ "$type" = 'utility' ]; then
      if [[ "$invoke" =~ \.app ]]; then
        # Call Gatekeeper for the utility on if '.app' is in the name
        sh "$__data/includes/gatekeeper.sh" "$name" "$__data/assets/$type/$name/$version/$name.app"  > /dev/null
      fi
    fi
    echo "$__data/assets/$type/$name/$version/$invoke"
    if [[ ! -z $bundle ]] && [[ $bundle != '..' ]]; then
      php "$__data/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
    fi
    return 0
  fi
  # There is no JSON passed to us, so find it in the defaults.
  if [ -z "$json" ]; then
    json="$__data/meta/defaults/$name.json"
  fi
  # The $json variable should contain either the path to the default or the user-provided path.
  if [ -f "$json" ]; then
    # Take advantage of the PHP script to install the asset.
    php "$__data/includes/installAsset.php" "$json" "$version"
    if [ ! -z "$result" ]; then
      echo "$result"
      return 0
    fi
    if [ -f "$__data/assets/$type/$name/$version/invoke" ]; then
      invoke=`cat "$__data/assets/$type/$name/$version/invoke"`
      if [ "$invoke" = 'null' ]; then
        invoke=''
      fi
      echo "$__data/assets/$type/$name/$version/$invoke"
      if [[ ! -z "$bundle" ]] && [[ "$bundle" != '..' ]]; then
        php "$__data/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
      fi
      if [ $type = 'utility' ]; then
        if [ ! -z "$invoke" ]; then
          if [[ "$invoke" =~ \.app ]]; then
            # Call Gatekeeper for the utility on if '.app' is in the name
            sh "$__data/includes/gatekeeper.sh" "$name" "$__data/assets/$type/$name/$version/$invoke" > /dev/null
          fi
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