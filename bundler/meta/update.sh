#!/bin/bash

# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##### INTERNAL NOTE -- FINISH COMMENTING

# This script checks for updates. The bundler is divided into major and minor
# releases. The major releases are the named releases (Aries, Taurus, etc...),
# and the minor versions are integers. The wrapper for each major version will
# always work with all minor versions of the major version; thus this script
# checks only for minor updates that can improve the efficiency of the bundler
# or fix bugs as the creep up.
#
# This script is run asynchonously, approximately once per week.

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"

# Define the global bundler version.
if [ -f "${path}/meta/version_major" ]; then
  major_version=$(cat "${path}/meta/version_major")
else
  # Fallback for us, we might consider taking this out
  major_version='devel'
fi

data="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${major_version}"
cache="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${major_version}"

################################################################################
### Functions
################################################################################

function check_update() {
  local next_update=$(date -v+1w "+%s")  # in one week's time
  local now=$(date "+%s")

  if [ ! -f "${data}/data/update-cache" ]; then
      # Update the update-check file for a week from today.
      echo "${next_update}" > "${data}/data/update-cache"
      return 0
  else
    if [[ $now -lt $(cat "${data}/data/update-cache") ]]; then
      return 0
    else

      # Cycle through the list of servers. If there is an error connecting, then we
      # move onto the next server on the list. If we get to one server and receive
      # a 404, then there is no update available. If there is a 200, then an update
      # is available.
      while read line; do
        response=$(curl -sL "${line}/${major_version}-${minor_version}.zip" --head | grep -E -o "200|404")
        if [[ $? -ne 0 ]]; then
          continue
        fi
        if [[ "${response}" -eq "404" ]]; then
          # There are no updates, so reset update-check file for a week from today
          log "$(date) -- INFO: no updates are available. Re-check in one week."
          echo "${next_update}" > "${data}/data/update-cache"
          return 0
        elif [[ "${response}" -eq "200" ]]; then
          server="${line}"
          break
        fi
      done < "${path}/meta/bundler_servers"

      # If we are here, then we need to update
      local status=$(do_update "${server}")

      # If the update did not succeed, then try again in one hour
      if [[ "${status}" -ne 0 ]]; then
        echo $(date -v+1H "+%s") > "${data}/data/update-cache"
        return 1
      fi
      echo "${next_update}" > "${data}/data/update-cache"
      return 0
  fi

  # We should not be here
  log "$(date) -- ERROR: Unknown error."
  return 1
} # END CHECK_UPDATE()



function do_update() {
  # The server that worked is passed to this function
  server="$1"

  # Make the temporary directories if they do not exist
  if [ ! -d "${cache}" ]; then
    mkdir "${cache}"
  fi
  if [ ! -d "${cache}/updater" ]; then
    mkdir "${cache}/updater"
  fi

  # Download the update and check for errors
  local status=$(download "${server}/${major_version}-${minor_version}.zip" "${cache}/updater/update.zip")
  if [[ "${status}" -ne "0" ]]; then
    log "$(date) -- ERROR: Downloading update failed."
    return 1
  fi

  # Move to the updater directory and test the zip file
  cd "${cache}/updater"
  unzip -tq update.zip 1>&2 &> /dev/null && status="$?"
  if [[ "${status}" -ne "0" ]]; then
    log "$(date) -- ERROR: Zip file failed integrity test."
    return 1
  fi

  # The zip file worked, so unzip it and move back to the regular directory
  unzip -oq update.zip
  cd - > /dev/null # Silence the command. We do not need to know the directory

  # Remove the conflicting directory if it exists and then move the current
  # bundler directory
  if [ -d "${cache}/updater/alfred-bundler-backup" ]; then
    rm "${cache}/updater/alfred-bundler-backup"
  fi
  mv "${data}/bundler" "${cache}/updater/alfred-bundler-backup"

  # Remove the conflicting directory if it exists and then move the new directory
  # into place
  if [ -d "${data}/bundler" ]; then
    rm "${data}/bundler"
  fi
  mv "${cache}/updater/alfred-bundler-${major_version}-${minor_version}/bundler" "${data}"

  # Remove the updater folder
  rm -fR "${cache}/updater"

  # Log success
  log "$(date) -- INFO: Bundler updated to ${major_version} v${minor_version}."

  # So, if the update-the-bundler script exists, then we'll run it. This script
  # updates any necessary background data structures
  if [ -f "${path}/meta/updates/update-the-bundler.sh" ]; then
    nohup /bin/bash "${path}/meta/updates/update-the-bundler.sh" 1>&2 &> /dev/null 1>&2 &> /dev/null &
  fi

  return 0
} # END DO_UPDATE()


# Downloads a file with weak validation of the URL and checks for the
# existence of the download directory
function download() {
  # $1 -- url
  # $2 -- localfile

  local url="$1"
  local file="$2"

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
  local status="$?"
  echo "${status}" && return "${status}"

} # END DOWNLOAD()

# Writes message to update log
function log() {
  # $1 : message

  message="$1" # Message to log

  log_file="${data}/data/logs/update.log"
  if [ ! -d "${data}/data/logs" ]; then
    mkdir "${data}/data/logs"
  fi
  # If the logfile exists, check if it's longer than 500 lines. If so, delete
  # the last 50 of them.
  if [ -f "${log_file}" ]; then
    if [[ $(wc -l < "${log_file}" | sed 's| ||g') -gt 500 ]]; then
      cat "${log_file}" | sed -n -e :a -e '1,50!{P;N;D;};N;ba' > "${log_file}"
    fi
  else
    touch "${log_file}"
  fi

  # Prepend line to log
  echo "${message}" | \
    cat - "${log_file}" > /tmp/out && mv /tmp/out "${log_file}"
} # END LOG()


################################################################################
### End Functions
################################################################################


# Get the minor version
if [ -f "${path}/meta/version_minor" ]; then
  minor_version=$(cat "${path}/meta/version_minor")
else
  # There is a problem here because we can't find the minor version file, so
  # we're going to write a log entry telling us that the updater screwed up
  # due to a missing file.
  log "$(date) -- ERROR: cannot find minor version file."
  exit 1
fi

# Let's reset the minor version so that it will be equal to itself + 1 for the
# purpose of checking updates.
minor_version=$((minor_version + 1))

check_update
exit $?


################################################################################
# NOTES
################################################################################
#
# Just some notes on cURL exit codes
#
# curl -f # will return 22 and fail silently
# options: --connect-timeout
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
