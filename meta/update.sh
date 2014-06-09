#!/bin/sh

bundler_version="aries"

__checkUpdate() {
  __git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"

  if [ ! -d "$data/alfred.bundler-$bundler_version/data"]; then
    mkdir "$data/alfred.bundler-$bundler_version/data"
  fi

  __date=`date "+%s"`
  __week=604800 # This is one week in seconds
  let __date=$__date+$__week

  if [ ! -f "$__data/alfred.bundler/data/update-cache" ]; then
      # Update the update-check file for a week from today.
      echo "$date" > "$__data/alfred.bundler-$bundler_version/data/update-cache"
      exit 0
  else
    if [  $__date -lt `cat "$__data/alfred.bundler-$bundler_version/data/update-cache"` ]; then
      __remoteVersion=`curl "$__git/meta/version_minor"`
      if [ ! -z $__remoteVersion ]; then
        if [ `cat "$__data/alfred.bundler-$bundle_version/meta/version_minor"` != "$remoteVersion" ]; then
          __doUpdate
        fi

        # Update the update-check file for a week from today.
        echo "$date" > "$__data/alfred.bundler-$bundler_version/data/update-cache"
    fi
  fi
}

__doUpdate() {
  # I need to have this point to an updater script instead of an installer
  __git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"
  __cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"

  file="$__git/meta/updates/update-the-bundler.sh"
  curl -sL "$file" > `echo $__cache | sed "s|$__git|$__cache|g"`

  sh "$__cache/update-the-bundler.sh"
}

__checkUpdate