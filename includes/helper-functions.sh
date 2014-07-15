#!/bin/sh

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"


# Define the global bundler version.
if [ -f "$path/meta/version_major" ]; then
  bundler_version=$(cat "$path/meta/version_major")
else
  bundler_version='devel'
fi

################################################################################
# Global Variables
################################################################################
__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"


################################################################################
# Functions
################################################################################

# Make a directory if it doesn't exist
function dir {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  fi
}

# Just grabs something via cURL
function get {
  curl -sL "$1" > "$2"
}

function cleanUp {
  rm -fR "$cache/$now"
}
