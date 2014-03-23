#!/bin/sh
# This is the downloader script. But, really, it should just be rewritten in python.

# ./jq '.version' < meta/defaults/Workflows.json

file="meta/defaults/Alp.json"
v="default"
# Path variables to help with installation
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"
tmp=`date "+%s"`

# Make the caches directory
if [ ! -d "$cache" ]; then
  mkdir "$cache"
fi
if [ ! -d "$cache/$tmp" ]; then
  mkdir "$cache/$tmp"
fi

name=`./utilities/jq -r '.name' < $file`
language=`./utilities/jq -r '.language' < $file`

# This is the method of how to get it. Currently, we can use "pip", "gem", or "download"
method=`./utilities/jq -r '.method' < $file`

# Copy all of the versions into a tmp file
version=`./utilities/jq '.versions | .[]' < "$file"  > "$cache/$tmp/versions.json"`
zip=`./utilities/jq -r '.zip' < "$cache/$tmp/versions.json"`
versions=`./utilities/jq '{(.version): .files[] }' < "$cache/$tmp/versions.json"`
versions=`echo $versions > "$cache/$tmp/versions.json"`
url=`./utilities/jq "[.$v]" < "$cache/$tmp/versions.json"`
url=`echo $url | sed 's|null||g'`
url=`echo $url| sed 's|\[ \]||g' | sed 's| \[ "||g' | sed 's|" \]||g' | sed 's| ||g'`
echo $url
exit

url=`./utilities/jq '.url' < $file | sed 's|"||g'`
zip=`./utilities/jq '.zip' < $file | sed 's|"||g'`





# echo $name
# echo $version
# echo $language
# echo $url
# echo $zip







if [ $language != "utility" ]; then
  if [ ! -d "$data/assets" ]; then
    mkdir "$data/assets"
  fi
  if [ ! -d "$data/assets/$language" ]; then
    mkdir "$data/assets/$language"
  fi
  if [ ! -d "$data/assets/$language/$name" ]; then
    mkdir "$data/assets/$language/$name"
  fi
  if [ ! -d "$data/assets/$language/$name/$version" ]; then
    mkdir "$data/assets/$language/$name/$version"
  fi
  # We now have the folder structure, so let's download the thing

  if [ "$zip" == "true" ]; then
    # curl -sL $url > "$cache/$name.zip"
    # unzip "$cache/$name.zip" -d "$cache/$tmp"
    a=1
  else
    while read l
    do
      curl -sL "$l" > "$data/assets/$language/$name/$version/"`basename "$l"`
    done < "$cache/$tmp.txt"
  fi
else
  if [ ! -d "$data/utilities" ]; then
    mkdir "$data/utilities"
  fi
fi

rm -fR "$cache"
