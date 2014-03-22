#!/bin/sh


checkUpdate() {
  git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/master"

  if [ ! -d "$data/alfred.bundler/meta"]; then
    mkdir "$data/alfred.bundler/meta"
  fi

  date=`date "+%s"`
  week=604800 # This is one week in seconds
  let date=$date+$week

  if [ ! -f "$data/alfred.bundler/meta/update-check"]; then
      # Update the update-check file for a week from today.
      echo "$data" > "$data/alfred.bundler/meta/update-check"
      return 0
  else
    if [  $date -lt `cat "$data/alfred.bundler/meta/update-check"` ]; then
      # Update the update-check file for a week from today.
      echo "$date" > "$data/alfred.bundler/meta/update-check"
      if [ `cat "$data/alfred.bundler/version" != `curl "$git/version"` ];
        doUpdate
      fi
      # There is an error in this logic in that the update won't work if called
      # when the function is run when the user is offline; start a fix for this
      # at some point soon.
    fi
  fi
}

doUpdate() {

  # Put the update logic here....

}
