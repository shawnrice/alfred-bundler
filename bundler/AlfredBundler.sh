#!/bin/bash
#
# A framework to lazyload assets for Alfred 2 workflows.
#
# See documentation at http://shawnrice.gitub.io/alfred-bundler
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.



# Declare Bundler Constants

# Path to base of bundler directory
declare -r AB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

# Define a general include directory to split this file into multiple ones
declare -r AB_INCLUDE_DIR="${AB_PATH}/includes/bash-includes"

# Get the major version from the file
if [ ! -z "${AB_BRANCH}" ]; then
  declare -r AB_MAJOR_VERSION="${AB_BRANCH}"
else
  declare -r AB_MAJOR_VERSION=$(cat "${AB_PATH}/meta/version_major")
fi

# Set the data directory, and the log file location
declare -r AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare -r AB_LOG="${AB_DATA}/data/logs/bundler-${AB_MAJOR_VERSION}.log"
declare -r AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare -r AB_COLOR_CACHE="${AB_CACHE}/color"
declare -r AB_PATH_CACHE="${AB_CACHE}/utilities"

# Set some variables about the workflow
declare -r WF_BUNDLE=$(/usr/libexec/PlistBuddy -c 'Print :bundleid' 'info.plist')
declare -r WF_NAME=$(/usr/libexec/PlistBuddy -c 'Print :name' 'info.plist')
declare -r WF_DATA=$(dirname "${AB_DATA}")"/${WF_BUNDLE}"
declare -r WF_LOG="${WF_DATA}/${WF_BUNDLE}.log"


. "${AB_INCLUDE_DIR}/logging.sh"
. "${AB_INCLUDE_DIR}/math.sh"
. "${AB_INCLUDE_DIR}/icons.sh"

# Make the log directory if it does not exist
AB::Log::Setup
# Rotate the logs if necessary
AB::Log::Rotate "${AB_LOG}"
AB::Log::Rotate "${WF_LOG}"

#### I need to bootstrap some things here (to get some variables: workflow directory, etc...)


# Check for updates to the bundler in the background
bash "${AB_PATH}/meta/update-wrapper.sh" > /dev/null 2>&1

# This is the beginning of a list of error codes
# More discussion and development here: https://github.com/shawnrice/alfred-bundler/issues/42

#  0 : Success

#  1 : Unspecified Error

# 10 : Bad arguments sent, recoverable
# 11 : Bad arguments sent, irrecoverable

# 20 : Connectivity issue, no internet connection
# 21 : Connectivity issue, could not connect to server
# 22 : Connectivity issue, corrupt download file
# 23 : User canceled bundler installation


###############################################################################
### Begin Asset Functions
###############################################################################

#######################################
# Downloads and loads an asset
# Globals:
#   AB_DATA
# Arguments:
#   type
#   name
#   version
#   json
# Returns:
#   Filepath to asset
#
#######################################
function AlfredBundler::load {
  # $1 -- type
  # $2 -- asset name
  # $3 -- version
  # $4 -- json (file-path)

  # We need two arguments at minimum
  if [ "$#" -lt 2 ]; then
    # Send message to STDERR
    AB::Log::Log "Trying to load asset requires a minimum of two arguments." CRITICAL console
    return 11
  fi

  # Keep the variables local so as not to interfere with the rest of the script
  local type
  local name
  local version
  local json
  local asset
  local status
  local gatekeeper
  local cache_path
  local cache_dir
  local key
  local path

  # Grab the arguments
  type="$1"
  name="$2"
  version="$3"
  json="$4"

  # Set the version to latest if not specified
  [[ -z "${version}" ]] && version="latest"

  AB::Log::Log "Loading ${type} '${name}' version ${version} ..." INFO console

  # Check to make sure that the json file exists
  if [ -z "${json}" ]; then
    if [ -f "${AB_DATA}/bundler/meta/defaults/${name}.json" ]; then
      # The json file is a default
      json="${AB_DATA}/bundler/meta/defaults/${name}.json"
    else
      # Send error message to STDERR
      AlfredBundler::Log::Log "Error: no valid JSON file found. This is a problem with the __implementation__ with the Alfred Bundler. Please let the workflow author know." CRITICAL both
      return 11
    fi
  else
    # Trying to use custom json
    if [ ! -f "${json}" ]; then
      # json file does not exist; send error message to STDERR
      AB::Log::Log "Error: no valid JSON file found. This is a problem with the __implementation__ with the Alfred Bundler. Please let the workflow author know." CRITICAL both
      return 11
    fi
  fi

  # Grab the bundle id (if possible)
  if [ -f 'info.plist' ]; then
    bundle=$(/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist')
  elif [ -f '../info.plist' ]; then
    bundle=$(/usr/libexec/PlistBuddy -c 'print :bundleid' '../info.plist')
  else
    bundle=''
  fi

  # Set the path to the asset
  asset="${AB_DATA}/data/assets/${type}/${name}/${version}"


  # Handle non-utilities first
  if [ "${type}" != "utility" ]; then
    # There shouldn't be too many things that the bash bundler should need from here...
    # but, why not?
    if [ -f "${asset}/invoke" ]; then

      # Register the asset
      bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' \
           "${AB_DATA}/bundler/includes/registry.php" \
           "${WF_BUNDLE}" "${name}" "${version}"

      # Return the path
      echo "${asset}/"$(cat "${asset}/invoke")
      return 0
    else
      # Install the asset
      php "${AB_DATA}/bundler/includes/install-asset.php" "${json}" "${version}"

      # If the install script exited with a non-zero status, then return 1;
      # the error messages were written to STDERR by the install script.
      status=$?
      if [[ $status -ne 0 ]]; then
        AB::Log::Log "Could not install '${name}', type '${type}'" CRITICAL both
        return 1
      fi

      # Register the asset
      bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' \
           "${AB_DATA}/bundler/includes/registry.php" \
           "${WF_BUNDLE}" "${name}" "${version}"

      AB::Log::Log "Installed '${name}', type '${type}'" INFO both
      # Return the path
      echo "${asset}/"$(cat "${asset}/invoke")
      return 0
    fi
  fi

  if [ ! -f "${asset}/invoke" ]; then
      # Install the asset

      AB::Log::Log "Installing ${type} '${name}' version ${version} ..." INFO console

      php "${AB_DATA}/bundler/includes/install-asset.php" "${json}" "${version}"

      # If the install script exited with a non-zero status, then return 1;
      # the error messages were written to STDERR by the install script.
      status=$?
      [[ $status -ne 0 ]] && return 1
  fi

  # While not all utilities need gatekeeper, launching the php script that checks
  # if it needs gatekeeper adds extra time. So, we'll cache the paths for all
  # utilities regardless of whether or not they need gatekeeper.
  # Step 1: Check the cache
  # Step 2: Check the json for the gatekeeper flag
  # Step 3: Run gatekeeper script

  # Create cache directory if it doesn't exist
  if [[ ! -d "${AB_PATH_CACHE}" ]]; then
    mkdir -p -m 775 "${AB_PATH_CACHE}"
    [[ $? -ne 0 ]] && AB::Log::Log "Could not make directory: ${AB_PATH_CACHE}" CRITICAL both || AB::Log::Log "Created directory: ${cache_dir}" INFO both
  fi

  # Cache path for this call
  key=$(md5 -q -s "${name}-${version}-${type}-${json}")
  cache_path="${AB_PATH_CACHE}/${key}"

  # Check the cache
  if [[ -f "${cache_path}" ]]; then
    path=$(cat "${cache_path}")
    if [[ -f "${path}" ]] || [[ -d "${path}" ]]; then
      # Found a valid path in the cache, return it
      echo "${path}"
      return 0
    fi
  fi

  # Read the gatekeeper flag in the json
  gatekeeper=$(php "${AB_DATA}/bundler/includes/read-json.php" "${json}" gatekeeper | tr [[:upper:]] [[:lower:]])

  if [ "${gatekeeper}" == "false" ]; then
    path="${asset}/$(cat "${asset}/invoke")"
    echo "${path}" > "${cache_path}"

    # Register the asset
    bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' "${AB_DATA}/bundler/includes/registry.php" \
      "${WF_BUNDLE}" "${name}" "${version}"

    # Echo the path and return a successful status
    echo "${path}"
    return 0
  else

    # Try to find the icon, if there is one
    # Theoretically, this function is being run by a script in the workflow's
    # root directory, so the 'icon.png' should exist (if there has been an icon
    # assigned). There is a possibility that it's being run by a script not in
    # the workflow root directory, so, as a backup, we'll look one level below.
    [[ -f 'icon.png' ]] && icon=$(pwd -P)"/icon.png"
    [[ -f '../icon.png' ]] && icon=$(pwd -P)"/../icon.png"

    path="${asset}/$(cat "${asset}/invoke")"

    # Call gatekeeper
    bash "${AB_DATA}/bundler/includes/gatekeeper.sh" "${name}" "${path}" "${message}" "${icon}" "${WF_BUNDLE}"

    # get response and do the rest of the handling.
    status=$?
    [[ $status -gt 0 ]] && echo "User denied whitelisting $name" && return $status
    # If we're here, then the user whitelisted the application.
    path="${asset}/$(cat "${asset}/invoke")"
    echo "${path}" > "${cache_path}"

    # Register the asset
    bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' "${AB_DATA}/bundler/includes/registry.php" \
      "${WF_BUNDLE}" "${name}" "${version}"

    # Echo the path and return a successful status
    echo "${path}"
    return 0

  fi

  # Send message to STDERR
  AB::Log::Log "You've encountered a problem with the __implementation__ of" "the Alfred Bundler; please let the workflow author know." ERROR both
  return 11

} # End AlfredBundler::load


#######################################
# Specific wrapper for the load function
#
# Globals:
#   AB_DATA
# Arguments:
#   name
#   version
#   json
# Returns:
#   Filepath to utility
#
#######################################
function AlfredBundler::utility() {
  local name
  local version
  local json

  name="$1"
  version="$2"
  json="$3"

  [[ -z "${version}" ]] && version='latest'

  path=$(AlfredBundler::load "utility" "${name}" "${version}" "${json}")
  status=$?
  [[ $status -eq 0 ]] && echo ${path} && return 0
  return 1
} # End AlfredBundler::utility

#######################################
# Specific wrapper for the load function
#
# Globals:
#   AB_DATA
# Arguments:
#   name
#   version
#   json
# Returns:
#   Filepath to library
#
#######################################
function AlfredBundler::library() {
  local name
  local version
  local json

  name="$1"
  version="$2"
  json="$3"

  [[ -z "${version}" ]] && version='latest'

  path=$(AlfredBundler::load "bash" "${name}" "${version}" "${json}")
  status=$?
  [[ $status -eq 0 ]] && echo ${path} && return 0
  return 1
}

###############################################################################
### End Asset Functions
###############################################################################

#######################################
# Sends a notification with CocoaDialog
#
# Globals:
#   AB_DATA
#   WF_NAME
# Arguments:
#   message
# Returns:
#   None
#
#######################################
function AlfredBundler::notify() {
  local cd="$(AlfredBundler::utility CocoaDialog)"
  local icon
  local message="$1"

  if [ -f 'icon.png' ]; then
    icon=$(pwd -P)'/icon.png'
  else
    icon="${AB_DATA}/bundler/meta/icons/bundle.png"
  fi

  "'${cd}' notify --title '${WF_NAME}' --icon-file '${icon}' --text '${message}'"
  return 0
}