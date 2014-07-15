#!/bin/sh

# Interface for other implementations of the Alfred Dependency Bundler to graft onto.
# This file should be the only one from the bundler that is distributed with your workflow.
#
# See documentation on how to use: http://shawnrice.github.io/alfred-bundler/
#
# License: GPLv3

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"

# Define the global bundler version.
if [ -f "$path/meta/version_major" ]; then
  bundler_version=$(cat "$path/meta/version_major")
else
  bundler_version='devel'
fi

__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"

function __load {
  # $1 -- asset name
  # $2 -- version
  # $3 -- type
  # $4 -- json -- this is a file path

  if [ -z "$1" ]; then
    echo "You need to pass at minimum one argument to use the __load function."
    return 1
  fi

  local name="$1"
  local version="$2"
  local type="$3"
  local json="$4"
  local asset

  if [ -z $version ]; then
    version="default"
  fi
  if [ -z $type ]; then
    type="utility"
  fi

# Grab the bundle id.
  if [ -f 'info.plist' ]; then
    local bundle=`/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'`
  elif [ -f '../info.plist' ]; then
    local bundle=`/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'`
  else
    local bundle='..'
  fi
  asset=`__loadAsset "$name" "$version" "$bundle" "$type" "$json"`
  status=$?
  echo "$asset"
  return $status
}

# This just downloads the install script and starts it up.
function __installBundler {
  local installer="https://raw.githubusercontent.com/shawnrice/alfred-bundler/$bundler_version/meta/installer.sh"
  dir "$__cache/installer"
  dir "$__data"
  curl -sL "$installer" > "$__cache/installer/installer.sh"
  sh "$__cache/installer/installer.sh"
}

# Just a helper function to make a directory if it doesn't exist.
function dir {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

if [ ! -f "$__data/bundler.sh" ]; then
  __installBundler
fi

# Include the bundler.
# . "$__data/bundler.sh"
. "bundler.sh"
# Check for updates.
sh "$__data/meta/update.sh" > /dev/null 2>&1

__load "$1" "$2" "$3" "$4"
exit $?
