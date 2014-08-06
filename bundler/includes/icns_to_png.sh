#!/bin/bash

# Extracts a png file from an icns file
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

# Usage : icns_to_png.sh </full/path/to/image.icns> </full/path/to/icon_name.png>

#######################################
# Checks to make sure the arguments are valid
# Globals:
#   None
# Arguments:
#   1 — Path to icns file
#   2 — Path to png output file
# Returns:
#   None
#######################################
function check_arguments() {
  # Check to make sure that all of the arguments are there and correct
  # before running the script

  # The script needs two arguments
  if [ "$#" -ne 2 ]; then
    echo "Usage: </full/path/to/image.icns> </full/path/to/icon_name.png>" >&2
    return 1
  fi

  # Argument 1 needs to be an extant filepath
  if [ ! -f "$1" ]; then
    echo "Error: $1 not found" >&2
    return 1
  fi

  # Directory for Argument 2 needs to exist
  if [[ ! -e $(dirname ${2%/*}) ]]; then
    echo "Error: destination directory must exist" >&2
    return 1
  fi

  # Argument 2 needs to be an icns filename
  if [ "${2##*.}" != 'png' ]; then
    echo "Error: specify a icns file name (icon_name.icns)" >&2
    return 1
  fi

  return 0
}

#######################################
# Converts an icns file to a png
# Globals:
#   None
# Arguments:
#   1 — Path to icns file
#   2 — Path to png output file
# Returns:
#   None
#######################################
function main() {

  if [[ $(check_arguments "$1" "$2") -ne 0 ]]; then
    exit
  fi

  sips -z 128 128 -s format png "$1" --out "$2" 1>&2 > /dev/null
  echo $?
  return $?
}

# Run the main loop and exit with the appropriate status
if [[ $(main "$1" "$2") -ne 0 ]]; then
  echo "Error: an unkown error occured" >&2
  exit 1
else
  exit 0
fi