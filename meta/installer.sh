#!/bin/sh

git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/master"
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"

# Make the directory structure
if [ ! -d "$data" ]; then
  mkdir "$data"
fi
if [ ! -d "$data/meta" ]; then
  mkdir "$data/meta"
fi
if [ ! -d "$data/includes" ]; then
  mkdir "$data/includes"
fi
if [ ! -d "$data/utilities" ]; then
  mkdir "$data/utilities"
fi
if [ ! -d "$data" ]; then
  mkdir "$data/libraries"
fi
if [ ! -d "$data/meta/defaults" ]; then
  mkdir "$data/meta/defaults"
fi

# These are the URLs to download
files=(
  # List of files to download
  "$git/bundler.php"
  "$git/bundler.py"
  "$git/bundler.rb"
  "$git/bundler.sh"
  "$git/meta/version"
  "$git/meta/update.sh"
  "$git/meta/installer.sh"
  "$git/meta/defaults/list"
  "$git/includes/alfred.bundler.php"
  "$git/includes/alfred.bundler.py"
  "$git/includes/alfred.bundler.rb"
  "$git/includes/alfred.bundler.sh"
)

# Download all the files
for file in "${files[@]}"
do
  curl -sL $file > `echo $file | sed "s|$git|$data|g"`
done

# Download all the default libraries' metadata-json files
defaults="$data/meta/defaults/list"
while read l
do
  curl -s "$git/meta/defaults/$l.json" > "$data/meta/defaults/$l.json"
done < $defaults

# Download jq so we can parse json from bash
curl -sL "http://stedolan.github.io/jq/download/osx64/jq" > "$data/utilities/jq"
chmod +x "$data/utilities/jq"
