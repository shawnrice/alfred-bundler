#!/bin/sh

################################################################################
# Global Variables
################################################################################
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"
now=`date "+%s"`


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
  curl -sL "$1" "$2"
}

function cleanUp {
  rm -fR "$cache/$now"
}
