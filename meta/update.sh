#!/bin/sh

# INCOMPLETE

bundler_version="aries"

checkUpdate() {
  git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"

  if [ ! -d "$data/alfred.bundler-$bundler_version/meta"]; then
    mkdir "$data/alfred.bundler-$bundler_version/meta"
  fi

  date=`date "+%s"`
  week=604800 # This is one week in seconds
  let date=$date+$week

  if [ ! -f "$data/alfred.bundler/meta/update-check" ]; then
      # Update the update-check file for a week from today.
      echo "$data" > "$data/alfred.bundler-$bundler_version/meta/update-check"
      return 0
  else
    if [  $date -lt `cat "$data/alfred.bundler-$bundler_version/meta/update-check"` ]; then
      # Update the update-check file for a week from today.
      echo "$date" > "$data/alfred.bundler-$bundler_version/meta/update-check"
      if [ `cat "$data/alfred.bundler-$bundle_version/meta/version"` != `curl "$git/meta/version"` ];
        doUpdate
      fi
      # There is an error in this logic in that the update won't work if called
      # when the function is run when the user is offline; start a fix for this
      # at some point soon.
    fi
  fi
}

doUpdate() {
  # I need to have this point to an updater script instead of an installer
  git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"
  data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"

  file="$git/meta/installer.sh"
  curl -sL "$file" > `echo $file | sed "s|$git|$data|g"`

  sh "$data/meta/installer.sh"
}
