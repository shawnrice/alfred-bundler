#!/bin/sh

# setup.sh
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/"
git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/master"

# download the proper files from the gists

# Make the data directory
if [ ! -d "$data/alfred.bundler" ]; then
  mkdir "$data/alfred.bundler"
fi

# Make the libraries directory
if [ ! -d "$data/alfred.bundler/libraries" ]; then
  mkdir "$data/alfred.bundler/libraries"
fi

# Make the utilities directory
if [ ! -d "$data/alfred.bundler/utilities" ]; then
  mkdir "$data/alfred.bundler/utilities"
fi

# Download pip
# or do we get it from here: https://github.com/pypa/pip?
if [ ! -f "$data/alfred.bundler/utilities/get-pip.py" ]; then
  curl -s https://raw.github.com/pypa/pip/master/contrib/get-pip.py >  "$data/alfred.bundler/utilities/get-pip.py"
fi

# Download the utilities
if [ ! -f "$data/alfred.bundle/bundler.php"]; then
  curl -sF "$git/bundler.php" "$data/alfred.bundle/bundler.php"
fi
if [ ! -f "$data/alfred.bundle/bundler.py"]; then
  curl -sF "$git/bundler.py" "$data/alfred.bundle/bundler.py"
fi
if [ ! -f "$data/alfred.bundle/bundler.rb"]; then
  curl -sF "$git/bundler.rb" "$data/alfred.bundle/bundler.rb"
fi
if [ ! -f "$data/alfred.bundle/bundler.sh"]; then
  curl -sF "$git/bundler.sh" "$data/alfred.bundle/bundler.sh"
fi
