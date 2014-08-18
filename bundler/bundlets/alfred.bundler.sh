#!/bin/bash


# This is a Bash library that provides the functions for the Alfred Bundler

# Main Bash interface for the Alfred Dependency Bundler. This file should be
# the only one from the bundler that is distributed with your workflow.
#
# See documentation on how to use: http://shawnrice.github.io/alfred-bundler/
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

# Define default bundler major version.
declare AB_MAJOR_VERSION="devel"
declare AB_INSTALL_SUFFIX="-latest.zip"
declare AB_ME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

if [ ! -f 'info.plist' ]; then
  # TODO : use a real error message
  echo "Alfred Bundler Error.... need an info.plist to use the bundler." >&2
fi

# Set the workflow name from an ENV variable if available. Otherwise
# fallback to the plist.
if [ ! -z "${alfred_workflow_name}" ]; then
  declare WF_NAME=${alfred_workflow_name}
else
  declare WF_NAME=$(/usr/libexec/PlistBuddy -c 'Print :name' 'info.plist')
fi


# Set the bundler version from env variable if present
# Also set the appropriate URL suffix. Development versions, i.e. those
# set from the AB_BRANCH env var, should install from HEAD.
# Normal releases should install from the last tagged commit, hence
# the -latest.zip suffix.
if [ ! -z "${AB_BRANCH}" ]; then
  declare AB_MAJOR_VERSION="${AB_BRANCH}"
  declare AB_INSTALL_SUFFIX='.zip'
else
  # Set version from `version_major` file
  if [ -f "${AB_ME}/../meta/version_major" ]; then
    declare AB_MAJOR_VERSION=$(cat "${AB_ME}/../meta/version_major")
  fi
fi

# Define the Bundler's data and cache directories
declare AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"


# Define the installation server (and mirrors)

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
function AlfredBundler::load {
 # $1 -- type
 # $2 -- asset name
 # $3 -- version : optional, defaults to 'latest'
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
  local url
  local icon

  AlfredBundler::confirm_install
  status=$?
  if [[ $status -ne 0 ]]; then
    return $status
  fi

  echo "Installing Alfred Dependency Bundler version '${AB_MAJOR_VERSION}' ..." >&2

  # Make the install directory if it doesn't exist
  [[ ! -d "${AB_CACHE}/installer" ]] && mkdir -p -m 755 "${AB_CACHE}/installer"

  i=0
  len=${#AB_BUNDLER_SERVERS[@]}
  success=0

  # Loop through the bundler servers until we get one that works
  while [[ $i -lt $len ]]; do
    url="${AB_BUNDLER_SERVERS[$i]}"
    echo "Fetching ${url} ..." >&2
    curl -fsSL --connect-timeout 5 "${url}" > "${AB_CACHE}/installer/bundler.zip"
    status=$?

    [[ $? -eq 0 ]] && success=1 && echo "[OK] ${url}" >&2 && break || echo "Error retrieving ${url}. cURL exited with ${status}" >&2
    success=0

    : $[ i++ ]
  done;

  # Make sure that we got out of the loop correctly
  if [[ $success -eq 0 ]]; then # We couldn't download anything

    # Remove the installation directory for now
    [[ -d "${AB_CACHE}/installer" ]] && rm -fR "${AB_CACHE}/installer"

    # Send the error to STDERR
    echo "Error: could not install Alfred Bundler. Exiting script." >&2

    # Exit with appropriate error code
    return 21
  fi

  # Grab the current directory so we can come back
  my_path=$(pwd -P)

  # Go find the newly downloaded file, unzip it
  cd "${AB_CACHE}/installer"

  # Below, there are wildcards for now because of the differences between how
  # Github and Bitbucket build the zip files
  unzip -tq *.zip >&2 > /dev/null
  status=$?

  # This needs to be expanded
  if [[ $status -ne 0 ]]; then
    echo "Alfred Bundler Install Error: Installation zipfile is corrupted." >&2
    echo "Exiting Bundler installation..." >&2
    rm *.zip
    return 22
  fi

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
  . "${AB_DATA}/bundler/AlfredBundler.sh"

  # Load Terminal Notifier
  notifier=$(AlfredBundler::utility 'cocoaDialog')

  # Send notification that the installation is complete
  icon="${AB_DATA}/bundler/meta/icons/bundle.icns"

  "${notifier}" notify --title 'Installation Complete' --icon-file "${icon}" \
    --text 'The Alfred Bundler has been successfully installed. Your workflow will now continue'

  # We're successful, so return success
  return 0
}

AlfredBundler::confirm_install() {
  local icon
  if [ -f 'icon.png' ]; then
    # there has to be a better way to do this...
    icon=$(echo $(pwd)'/icon.png' | tr '/' ':')
    icon=${icon:1:${#icon}-1}
  else
    icon="System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:SideBarDownloadsFolder.icns"
  fi

  text="${WF_NAME} needs to install additional components, which will be placed in the Alfred storage directory and will not interfere with your system.

You may be asked to allow some components to run, depending on your security settings.

You can decline this installation, but ${WF_NAME} may not work without them. There will be a slight delay after accepting.";

  script="display dialog \"${text}\" buttons {\"More Info\",\"Cancel\",\"Proceed\"} default button 3 with title \"Setup ${WF_NAME}\" with icon file \"${icon}\"";

  # a="button returned:Proceed" && echo ${a#button returned:}
  response=$(osascript -e "${script}")
  response=${response#button returned:}
  if [[ $response == 'More Info' ]]; then
    open "https://github.com/shawnrice/alfred-bundler/wiki/What-is-the-Alfred-Bundler"
    echo "Opening Bundler 'Information Page', so killing workflow process." >&2
    return 1
  elif [[ $response == 'Proceed' ]]; then
    # Installing...
    return 0
  else
    # User canceled installation, throw an exception (return 1)
    return 23 # Bundler installation failure.
  fi

}


#######################################
# Includes the backend of the bundler
# Globals:
#   AB_DATA
# Arguments:
#   None
# Returns:
#   None
#######################################
function AlfredBundler::bootstrap() {
  # Install the Bundler if it does not already exist
  if [[ ! -f "${AB_DATA}/bundler/AlfredBundler.sh" ]]; then
    AlfredBundler::install_bundler
    status=$?

    # Install exited with some error
    # if 23, then set the refusal flag
    if [[ $status -eq 23 ]]; then
      ALFRED_BUNDLER_INSTALL_REFUSED='TRUE'
      exit 23
    fi
    # Just return the status for all others
    exit $status
  fi
  return 0
}

#######################################
# Load an icon/asset
# Arguments:
#   type
#   name / font
#   version / icon
#   json / color
#   alter
# Returns:
#   filepath to asset
#######################################
function AlfredBundler::main() {
  if [[ "$1" == "icon" ]]; then
    # <font> <icon> <color (optional)> <alter (optional)>
    AlfredBundler::icon "$2" "$3" "$4" "$5"
    return $?
  else
    # <type>, <name>, <version>, <json (optional)>
    AlfredBundler::load "$1" "$2" "$3" "$4"
    return $?
  fi
}

# Install the bundler if necessary
AlfredBundler::bootstrap
if [[ $? -eq 0 ]]; then
  . "${AB_DATA}/AlfredBundler.sh"
  # . "${AB_DATA}/bundler/AlfredBundler.sh"
fi

if [[ "$BASH_SOURCE" == "$0" ]]; then
  AlfredBundler::main "$1" "$2" "$3" "$4" "$5"
  exit $?
fi
