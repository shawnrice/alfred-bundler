#!/bin/sh
# Work in progress

function load {
 if [ -f "$data/$1" ]; then
  a=1
 fi
}

function loadAsset {

}


function registerAsset {

 if [ -f "info.plist" ]; then
  bundle="/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist'"
 fi

}

# This just downloads the install script and starts it up.
function installUtility {
  installer="https://raw.githubusercontent.com/shawnrice/alfred-bundler/initial/meta/installer.sh"
  data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
  cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"

  dir "$cache"
  dir "$cache/installer"
  dir "$data"
  curl -sL "$installer" > "$cache/installer.sh"
  sh "$cache/installer.sh"

}

# Just a helper function to make a directory if it doesn't exist.
function dir {
 if [ ! -d $1 ]; then
  mkdir $1
 fi
}