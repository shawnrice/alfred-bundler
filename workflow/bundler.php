#!/bin/sh
# bundler.php
# This is actually a bash script
# Args:
# $1 -- Library Name
# $2 -- Version
# $3 -- URL
# $4 -- Filename

# "alfred.bundler/libraries/language/library_name/version"
# Also, create a "default" version

data="$HOME/Library/Application Support/Alfred 2/Workflow Data/"

if [ ! -d  "$data/alfred.bundler/libraries/php" ]; then
  mkdir "$data/alfred.bundler/libraries/php"
fi

git clone $git "$data/alfred.bundler/$language/$version/"


if [ ! -f  "$data/alfred.bundler/libraries/php/$1/$2/$4" ]; then
  if [ ! -z $3 ]; then
    returnError 99
  fi
  if [ ! -d  "$data/alfred.bundler/libraries/php/$1" ]; then
    mkdir "$data/alfred.bundler/libraries/php/$1"
  fi
  if [ ! -d  "$data/alfred.bundler/libraries/php/$1/$2" ]; then
    mkdir "$data/alfred.bundler/libraries/php/$1/$2"
  fi
  curl -sfL $3 > "$data/alfred.bundler/libraries/php/$1/$2/$4"
  # Add in error handling for a cURL problem here.
fi

echo "$data/alfred.bundler/libraries/php/$1/$2/$4"

# Checks for a malformed link
checkLink() {  regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  if [[ $1 =~ $regex ]]
  then
      echo "TRUE"
  else
      echo "FALSE"
fi
}

checkGit() {
  if [ -z `which git` ]; then
    return FALSE
  else
    return TRUE
  fi
}
returnError() {
  # add in curl error here
  if [ $1 = "99" ]; then
    echo "Fail. File not found, and no URL included."
  fi

  # cURL Error codes
  # 3 URL malformed. The syntax was not correct.
  # 6 Couldn't resolve host. The given remote host was not resolved.
  # 7 Failed to connect to host.
  # 18 Partial file. Only a part of the file was transferred.
  # 22 HTTP page not retrieved. The requested url was not found or returned another error with the HTTP error code being 400 or above. This return code only appears if -f, --fail is used.
  # 23 Write error. Curl couldn't write data to a local filesystem or similar.
  # 27 Out of memory. A memory allocation request failed.
  # 47 Too many redirects. When following redirects, curl hit the maximum amount.
  # 51 The peer's SSL certificate or SSH MD5 fingerprint was not OK.
  # 52 The server didn't reply anything, which here is considered an error.
  # 56 Failure in receiving network data.
  # 78 The resource referenced in the URL does not exist.

}
