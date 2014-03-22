#!/bin/sh

git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/master"
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"

if [ ! -f "$data" ]; then
  mkdir "$data"
fi
if [ ! -f "$data/meta" ]; then
  mkdir "$data/meta"
fi
if [ ! -f "$data/includes" ]; then
  mkdir "$data/includes"
fi
if [ ! -f "$data/utilities" ]; then
  mkdir "$data/utilities"
fi
if [ ! -f "$data" ]; then
  mkdir "$data/libraries"
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
  "$git/meta/defaults.json"
  "$git/includes/alfred.bundler.php"
  "$git/includes/alfred.bundler.py"
  "$git/includes/alfred.bundler.rb"
  "$git/includes/alfred.bundler.sh"
)
# These are the local filenames. We need these to match up with the URLs because we can't use wget.
filenames=(
  "bundler.php"
  "bundler.py"
  "bundler.rb"
  "bundler.sh"
  "meta/version"
  "meta/update.sh"
  "meta/defaults.json"
  "includes/alfred.bundler.php"
  "includes/alfred.bundler.py"
  "includes/alfred.bundler.rb"
  "includes/alfred.bundler.sh"
)

count=0
for file in "${files[@]}"
do
  tmp=${filenames[$count]}
  curl -sF $file > "$data/$tmp"
  count=$(( $count + 1 ))
done
