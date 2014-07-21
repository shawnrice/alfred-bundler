#!/bin/bash

# Feed this script a png file, and it will create an icns file out of it
# placed in the bundler's cache directory (bundler_cache/icns/file.icns)
# Usage :
# make_icns.sh </path/to/file.png> <output name.icns>



# Path to me
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

if [ "$#" -ne 2 ]; then
    echo "Usage: </path/to/img.png> <final.icns>"
    exit 1
fi

if [ ! -f "$1" ]; then
  echo "Error: $1 not found"
  exit 1
fi

if [[ ! -d `dirname "$2"` ]]; then
  echo "Error: destination ($2) not a directory"
  exit 1
fi

if [ "${2##*.}" != 'icns' ]; then
  echo "Error: specify a icns file (/path/to/myicon.icns)"
  exit 1
fi

major_version=$(cat "$path"/../meta/version_major)
cache="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${major_version}"

if [ ! -d "${cache}/icns" ]; then
  mkdir "${cache}/icns"
fi

# icns="${2%.*}"
out_file="${2%%.*}"
out_file="${out_file##*/}" # This is the basename of the output file
out_dir="${cache}/icns/"    # This is the out directory

i=0

sizes=(512 256 128 32 16)

iconset="${out_dir}/${out_file}".iconset

mkdir -p "$iconset"

while [ $i -lt ${#sizes[@]} ]; do
  base=icon_${sizes[$i]}x${sizes[$i]}

  cp "$1" "$iconset/icon_${sizes[$i]}x${sizes[$i]}.png"
  sips -z "${sizes[$i]}" "${sizes[$i]}" "$iconset/icon_${sizes[$i]}x${sizes[$i]}.png" &>/dev/null
  t=$((sizes[$i] * 2))
  cp "$1" "$iconset/icon_${sizes[$i]}x${sizes[$i]}@2x.png"
  sips -z "${t}" "${t}" "$iconset/icon_${sizes[$i]}x${sizes[$i]}@2x.png" &>/dev/null
  : $[ i++ ]
done
iconutil -c icns "$iconset"
rm -rf "$iconset"
