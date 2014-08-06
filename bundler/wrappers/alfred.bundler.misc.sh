#!/bin/bash

# Interface for other implementations of the Alfred Dependency Bundler to
# graft onto. This file should be the only one from the bundler that is
# distributed with your workflow.
#
# See documentation on how to use: http://shawnrice.github.io/alfred-bundler/
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

declare -r AB_ME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

# Define the global bundler version.
declare AB_MAJOR_VERSION="devel"
AB_INSTALL_SUFFIX='-latest.zip'

# Use version specified in env variable if given
if [ ! -z "${ALFRED_BUNDLER_DEVEL}" ]; then
  declare AB_MAJOR_VERSION="${ALFRED_BUNDLER_DEVEL}"
  AB_INSTALL_SUFFIX='.zip'
else
  # Define the global bundler version.
  if [ -f "../meta/version_major" ]; then
    declare AB_MAJOR_VERSION=$(cat "../meta/version_major")
  fi
fi

# Define the Bundler's data and cache directories
declare AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"


# Define the installation server (and mirrors)
# AB_BUNDLER_SERVERS=("https://github.com/shawnrice/alfred-bundler/archive/${AB_MAJOR_VERSION}-latest.zip")
# Grab the current Repo, not the latest release
AB_BUNDLER_SERVERS=("https://github.com/shawnrice/alfred-bundler/archive/${AB_MAJOR_VERSION}${AB_INSTALL_SUFFIX}")
AB_BUNDLER_SERVERS+=("https://bitbucket.org/shawnrice/alfred-bundler/get/${AB_MAJOR_VERSION}${AB_INSTALL_SUFFIX}")


#######################################
# Loads an asset
# Globals:
#   None
# Arguments:
#   type
#   name
#   version
#   json
# Returns:
#   filepath to asset
#######################################
function AlfredBundler::load() {
 # $1 -- type
 # $2 -- asset name
 # $3 -- version : optional, defaults to 'default'
 # $4 -- json    : optional, path to json file


  a=0
  # Function is empty here because it is overridden in the backend.
}

#######################################
# Loads an icon
# Globals:
#   None
# Arguments:
#   font
#   name
#   color
#   alter
# Returns:
#   filepath to asset
#######################################
function AlfredBundler::icon() {
  # $1 -- Icon Font
  # $2 -- Icon Name
  # $3 -- Color (optional: defaults to 000000) :: Must be a hex color
  # $4 -- Backup Color or TRUE (optional: defaults to FALSE)

  # See the Workflow Icon Generator (http://icons.deanishe.net) to preview the
  # icons and icon fonts.

  # Returns the filepath to the icon (after downloading it, if necessary).

  # Example: icon=$(AlfredBundler::icon elusive fire ffffff TRUE)
  # Return value: ${HOME}/Application Support/Alfred 2/Workflow Data/alfred.bundler-taurus/data/assets/icons/elusive/ffffff/fire.png

  # Example: icon2=$(AlfredBundler::icon system Accounts)
  # Return value: /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Accounts.icns

  a=0
  # Function is empty here because it is overridden in the backend.
}

#######################################
# Wrapper around load to call a utility
# Globals:
#   None
# Arguments:
#   name
#   version
#   json
# Returns:
#   filepath to utility
#######################################
function AlfredBundler::utility() {
  # $1 -- Utility Name
  # $2 -- Utility version (optional: defaults to 'default')
  # $3 -- JSON File path (optional: defaults to empty)

  # This is a wrapper function for the AlfredBundler::load function to make
  # it easier to call utilities.

  # Returns the path to the utility (after downloading it, if necessary).

  a=0
  # Function is empty here because it is overridden in the backend.
}

#######################################
# Installs the bundler
# Globals:
#   AB_DATA
#   AB_CACHE
#   AB_BUNDLER_SERVERS
# Arguments:
#   None
# Returns:
#   None
#######################################
function AlfredBundler::install_bundler {

  local server
  local i
  local len
  local success
  local status
  local my_path

  # Make the install directory if it doesn't exist
  [[ ! -d "${AB_CACHE}/installer" ]] && mkdir -p -m 755 "${AB_CACHE}/installer"

  i=0
  len=${#AB_BUNDLER_SERVERS[@]}
  success=0

  # Loop through the bundler servers until we get one that works
  while [[ $i -lt $len ]]; do
    curl -fsSL --connect-timeout 4 "${AB_BUNDLER_SERVERS[$i]}" > "${AB_CACHE}/installer/bundler.zip"
    status=$?

    [[ $? -eq 0 ]] && success=1 && break || echo "Error retrieving ${AB_BUNDLER_SERVERS[$i]}. cURL exited with ${status}" >&2
    success=0

    : $[ i++ ]
  done;

  # Make sure that we got out of the loop correctly
  if [[ $success -eq 0 ]]; then # We couldn't download anything

    # Remove the installation directory for now
    [[ -d "${AB_CACHE}/installer" ]] && rm -fR "${AB_CACHE}/installer"

    # Send the error to STDERR
    echo "Error: could not install Alfred Bundler." >&2
    exit 21

  fi

  # Grab the current directory so we can come back
  my_path=$(pwd -P)

  # Go find the newly downloaded file, unzip it
  cd "${AB_CACHE}/installer"
  unzip -oq *.zip
  rm *.zip
  cd *

  # Make the bundler data directory if it doesn't exist
  [[ ! -d "${AB_DATA}" ]] && mkdir -p -m 775 "${AB_DATA}"

  # Remove the bundler's bundler directory if it exists, so we can replace
  # it with the newly downloaded one. It should not be there already
  # except in the case of a bad installation
  [[ -f "${AB_DATA}/bundler" ]] && rm -fR "${AB_DATA}/bundler"
  mv bundler "${AB_DATA}"

  # Return to the initial directory
  cd "${my_path}"

  # Remove the Cache installer directory
  rm -fR "${AB_CACHE}/installer"

  # Include the Bundler
  . "${AB_ME}/../AlfredBundler.sh"

  # Load Terminal Notifier
  notifier=$(AlfredBundler::utility "Terminal-Notifier")

  # Send notification that the installation is complete
  "${notifier}" -title 'Instllation Complete' \
    -message 'The Alfred Bundler has been successfully installed. Your workflow will now continue'

  # We're successful, so return success
  return 0
}

#######################################
# Includes the backend of the bundler and processes load request
# Globals:
#   AB_DATA
# Arguments:
#   type
#   name / font
#   version / icon
#   json / color
#   alter
# Returns:
#   Filepath to asset
#######################################
function main() {
  # Install the Bundler if it does not already exist
  if [[ ! -f "${AB_DATA}/bundler/AlfredBundler.sh" ]]; then
    AlfredBundler::install_bundler
  else
    . "${AB_ME}/../AlfredBundler.sh"
    # . "${AB_DATA}/bundler/AlfredBundler.sh"
  fi

  echo $(AlfredBundler::utility "Terminal-Notifier")
  exit

  if [ "$1" == "icon" ]; then
    # <font> <icon> <color (optional)> <alter (optional)>
    AlfredBundler::icon "$2" "$3" "$4" "$5"
    exit $?
  else
    # <type>, <name>, <version>, <json (optional)>
    AlfredBundler::load "$2" "$3" "$4" "$5"
    exit $?
  fi
}

main $@
exit $?
