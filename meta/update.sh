#!/bin/bash

bundler_version="aries"

__checkUpdate() {
  local git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"
  local data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
  local nextupdate=$(date -v+1w "+%s")  # in one week's time
  local now=$(date "+%s")
  local remoteVersion
  local localVersion

  if [ ! -d "${data}/data" ]; then
    mkdir "${data}/data"
  fi

  if [ ! -f "${data}/data/update-cache" ]; then
      # Update the update-check file for a week from today.
      echo "${nextupdate}" > "${data}/data/update-cache"
      exit 0
  else
    if [  $now -gt $(cat "${data}/data/update-cache") ]; then
      remoteVersion=`curl "${git}/meta/version_minor"`
      if [ ! -z "${remoteVersion}" ]; then
        localVersion=$(cat "${data}/meta/version_minor")
        if [ "$localVersion" != "$remoteVersion" ]; then
          __doUpdate
        fi

        # Update the update-check file for a week from today.
        echo "${nextupdate}" > "${data}/data/update-cache"
      fi
    fi
  fi
}

__doUpdate() {
  # I need to have this point to an updater script instead of an installer
  local git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/${bundler_version}"
  local cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"
  local url
  local file
  local dirpath

  url="${git}/meta/updates/update-the-bundler.sh"
  # Create filename from URL
  file=$(echo $url | sed -e "s|${git}|${cache}|g")
  # Create directory if it doesn't exist
  dirpath=$(dirname "${file}")
  [[ ! -d "${dirpath}" ]] && mkdir -p "${dirpath}"

  # Download and run update script
  curl -sSL "${url}" > "${file}"

  if [[ $? -gt 0 ]]; then
    echo "Update failed" >&2
    return 1
  else
    /bin/bash "${file}"
  fi
}

__checkUpdate