#!/bin/bash

# Make icns files from pngs

# Feed this script a png file, and it will create an icns file out of it

# Usage : png_to_icns.sh </full/path/to/image.png> </full/path/to/icon_name.icns>

function check_arguments() {
  # Check to make sure that all of the arguments are there and correct
  # before running the script

  # The script needs two arguments
  if [ "$#" -ne 2 ]; then
    echo "Usage: </full/path/to/image.png> </full/path/to/icon_name.icns>" >&2
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
  if [ "${2##*.}" != 'icns' ]; then
    echo "Error: specify a icns file name (icon_name.icns)" >&2
    return 1
  fi

  return 0
}

function main() {

  if [[ $(check_arguments "$1" "$2") -ne 0 ]]; then
    exit
  fi

  # Path to me
  path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

  # Get the major version of the bundler
  major_version=$(cat "${path}"/../meta/version_major)

  # This is a long path, so break it into two lines to keep it under 80 chars
  cache="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data"
  cache="${cache}/alfred.bundler-${major_version}"

  if [ ! -d "${cache}/icns" ]; then
    mkdir "${cache}/icns"
  fi

  out_file="${2##*/}" # This is the basename of the output file
  out_file="${out_file%%.icns}"
  out_dir="${2%/*}"    # This is the out directory
  if [[ "${out_dir}" == "$2" ]]; then
    out_dir="."
  fi

  i=0

  # The sizes, in px, needed to create the icns file
  sizes=(512 256 128 32 16)

  # Create the temporary iconset directory
  iconset="${out_dir}/${out_file}.iconset"
  mkdir -p "${iconset}"

  # Loop through each size and use sips to create a png of that size
  while [ $i -lt ${#sizes[@]} ]; do
    base=icon_${sizes[$i]}x${sizes[$i]}

    # Create the normal size png file
    cp "$1" "${iconset}/icon_${sizes[$i]}x${sizes[$i]}.png"
    sips -z "${sizes[$i]}" "${sizes[$i]}" "${iconset}/icon_${sizes[$i]}x${sizes[$i]}.png" &>/dev/null
    
    # Create the retina png file
    t=$((sizes[$i] * 2))
    cp "$1" "${iconset}/icon_${sizes[$i]}x${sizes[$i]}@2x.png"
    sips -z "${t}" "${t}" "${iconset}/icon_${sizes[$i]}x${sizes[$i]}@2x.png" &>/dev/null

    : $[ i++ ]
  done

  # Use iconutil to create the actual icns file
  iconutil -c icns "${iconset}"

  if [[ $? -ne 0 ]]; then
    echo "Error: iconutil could not make icns file" >&2
    return 1
  fi

  # Remove the temporary iconset folder
  rm -rf "${iconset}"
}

# Run the main loop and exit with the appropriate status
if [[ $(main "$1" "$2") -ne 0 ]]; then
  echo "Error: an unkown error occured" >&2
  exit 1
else
  exit 0
fi