#!/bin/bash

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"

# Define the global bundler version.
if [ -f "$path/meta/version_major" ]; then
  bundler_version=$(cat "$path/meta/version_major")
else
  bundler_version='devel'
fi


# We're moving to releases...
# curl https://github.com/shawnrice/alfred-bundler/archive/devel-latest.zip --head --silent | grep Status: | grep -o "[0-9][0-9][0-9]"
# curl -f # will return 22 and fail silently
# --connect-timeout
# curl error codes:
# 6  -- can't resolve host
# 7  -- failed to connect to host
# 18 -- partial file
# 22 -- url not found
# 23 -- write error to local system
# 27 -- out of memory
# 28 -- operation timeout
# 52 -- server didn't reply
# 56 -- failure in receiving network data
#

__download() {
  # $1 -- url
  # $2 -- localfile

  local url=$1
  local file=$2

  # Find the directory
  local dir=${file%\/*}

  if [ ! -d "${dir}" ]; then
    echo "Error: invalid download path -- '${dir}'"
    exit 1
  fi

  # This regex could be stronger
  local regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  if [[ ! $url =~ $regex ]]; then
    echo "Error: invalid URL '${url}'"
    exit 1
  fi

  curl -sLf "${url}" -o "${file}"
  return $?

}

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
      return 0
  else
    if [  $now -gt $(cat "${data}/data/update-cache") ]; then
      remoteVersion=$(curl -sSL "${git}/meta/version_minor")
      if [ ! -z "${remoteVersion}" ]; then
        localVersion=$(cat "${data}/meta/version_minor")
        if [ "$localVersion" != "$remoteVersion" ]; then
          status=__doUpdate
          if [[ $status -eq 0 ]]; then
            # Update the update-check file for a week from today.
            echo "${nextupdate}" > "${data}/data/update-cache"
          else
            return $status
          fi
        fi
      fi
    fi
  fi
  return 0
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
  status=$?
  if [[ $status -gt 0 ]]; then
    echo "Update failed" >&2
    return $status
  else
    # Run update-the-bundler.sh
    /bin/bash "${file}"
    return $?
  fi
}

__checkUpdate
exit $?
