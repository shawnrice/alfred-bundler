#!/bin/bash


# This is a Bash library that provides the functions for the Alfred Bundler

# Main Bash interface for the Alfred Dependency Bundler. This file should be
# the only one from the bundler that is distributed with your workflow.
#
# See documentation on how to use: http://shawnrice.github.io/alfred-bundler/
#
# License: GPLv3

# Get the PID of the script implementing the bundler. We'll kill the script
# if the bundler cannot install itself
export TOP_PID=$$

# Define the global bundler version.
if [ -f "../meta/version_major" ]; then
  declare AB_MAJOR_VERSION=$(cat "../meta/version_major")
else
  declare AB_MAJOR_VERSION="devel"
fi

# Define the Bundler's data and cache directories
declare AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"


# Define the installation server (and mirrors)
AB_BUNDLER_SERVERS=("https://github.com/shawnrice/alfred-bundler/archive/${AB_MAJOR_VERSION}-latest.zip")
AB_BUNDLER_SERVERS+=("https://bitbucket.org/shawnrice/alfred-bundler/get/${AB_MAJOR_VERSION}-latest.zip")


# This function is a thin wrapper over the internal AlfredBundler::load_asset
# function that exists in the backend of the Alfred Bash Bundler.
function AlfredBundler::load {
 # $1 -- type
 # $2 -- asset name
 # $3 -- version : optional, defaults to 'default'
 # $4 -- json    : optional, path to json file
 

 
  # Function is empty here because it is overridden in the backend.
}

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

  # Function is empty here because it is overridden in the backend.
}

function AlfredBundler::utility() {
  # $1 -- Utility Name
  # $2 -- Utility version (optional: defaults to 'default')
  # $3 -- JSON File path (optional: defaults to empty)

  # This is a wrapper function for the AlfredBundler::load function to make
  # it easier to call utilities.

  # Returns the path to the utility (after downloading it, if necessary).

  # Function is empty here because it is overridden in the backend.
}

# This just downloads the install script and starts it up.
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
    echo "Error: could not install Alfred Bundler. Exiting script." >&2

    # Kill the overall script that called this one
    kill -s TERM $TOP_PID
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
  . "${AB_DATA}/bundler/AlfredBundler.sh"

  # Load Terminal Notifier
  notifier=$(AlfredBundler::utility 'Terminal-Notifier')

  # Send notification that the installation is complete
  "${notifier}" -title 'Instllation Complete' \
    -message 'The Alfred Bundler has been successfully installed. Your workflow will now continue'

  # We're successful, so return success
  return 0
}

# We need to execute some code upon the inclusion of this file

function main() {
  # Install the Bundler if it does not already exist
  if [[ ! -f "${AB_DATA}/bundler/AlfredBundler.sh" ]]; then
    AlfredBundler::install_bundler
  else
    . "${AB_DATA}/bundler/AlfredBundler.sh"
  fi  
}

main

# Include the bundler.
# . "${AB_DATA}/bundler/AlfredBundler.sh"