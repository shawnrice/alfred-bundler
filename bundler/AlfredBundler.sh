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


################################################################################
### Begin Asset Functions
################################################################################

#######################################
# Downloads icons
# Globals:
#   AB_DATA
# Arguments:
#   font
#   name
#   color
#   alter
# Returns:
#   File path to an icon
#
#######################################
function AlfredBundler::icon() {

  local font
  local name
  local color
  local alter
  local icon_server
  local icon_dir
  local icon_path
  local status
  local url
  local system_icon_dir
  # Set font name
  if [ ! -z "$1" ]; then
    font=$(echo "$1" | tr [[:upper:]] [[:lower:]])
  else
    # Send error to STDERR
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" >&2
    return 1
  fi

  # Set icon name
  if [ ! -z "$2" ]; then
    name="$2"
  else
    # Send error to STDERR
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" >&2
    return 1
  fi

  # Take care of the system font first
  if [ "${font}" == "system" ]; then
    system_icon_dir="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"
    if [ -f "${system_icon_dir}/${name}.icns" ]; then
      echo "${system_icon_dir}/${name}.icns"
      return 0
    else
      echo "ERROR: System icon '${name}' not found" >&2
      echo "${AB_DATA}/bundler/meta/icons/default.icns"
      return 0
    fi
  fi

  # Set color or default to black
  if [ ! -z "$3" ]; then
    color="$3"
  else
    color="000000"
  fi

  # Normalize and check the color for valid hex
  color=$(AlfredBundler::check_hex "${color}")
  # If not a valid hex, then return 0
  [[ $? -ne 0 ]] && return 1


  # See if the alter variable is set
  if [ ! -z "$4" ]; then
    alter=$(echo "$4" | tr [[:lower:]] [[:upper:]])
  elif [[ -z "$3" ]] && [[ -z "$4" ]]; then
    alter="TRUE"
  else
    alter="FALSE"
  fi

  # Make the color cache directory if it doesn't exist
  [[ ! -d "${AB_DATA}/data/color-cache" ]] && mkdir -m 775 -p "${AB_DATA}/data/color-cache"


  if [[ "${alter}" == "TRUE" ]]; then
    color=$(AlfredBundler::alter_color ${color} TRUE)
  elif [[ ! -z $(AlfredBundler::check_hex ${alter} 2> /dev/null) ]]; then
    color=$(AlfredBundler::alter_color ${color} ${alter})
  fi
  color=$(echo "${color}" | tr [[:upper:]] [[:lower:]])
  icon_dir="${AB_DATA}/data/assets/icons/${font}/${color}"
  icon_path="${icon_dir}/${name}.png"

  # Make the icon directory if it doesn't exist
  [[ ! -d "${icon_dir}" ]] && mkdir -m 775 -p "${icon_dir}"

  if [[ -f "${icon_path}" ]]; then
    echo "${icon_path}"
    return 0
  fi

  i=0
  icon_servers=$(cat "${AB_DATA}/bundler/meta/icon_servers")
  len=${#icon_servers[@]}
  success="FALSE"

  # Download icon from web service and cache it
  # Loop through the bundler servers until we get one that works
  while [[ $i -lt $len ]]; do
    # Try to download the icon from the server, but give up if we cannot connect
    # in less than two seconds.
    curl -fsSL --connect-timeout 5 "${icon_servers[$i]}/icon/${font}/${color}/${name}" > "${icon_path}"
    status=$?
    if [[ $status -eq 0 ]]; then
      success="TRUE"
      AlfredBundler::report "Downloaded icon ${name} from ${font} in color ${color}" INFO
      break
    else
      AlfredBundler::report "Error retrieving icon from ${icon_servers[$i]}. cURL exited with ${status}" ERROR
      [[ -f "${icon_path}" ]] && rm -f "${icon_path}"
      success="FALSE"
    fi
    : $[ i++ ]
  done;

  # Here, we're doing a post-mortem to make sure that we got through to one
  # of the icon servers
  if [[ $success == "TRUE" ]]; then
    echo "${icon_path}"
  else
    echo "${AB_DATA}/bundler/meta/icons/default.png"
    AlfredBundler::report "Could not download icon ${name}" 3
    return 1
  fi

} # End AlfredBundler::icon

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
    AlfredBundler::report "Trying to load asset requires a minimum of two arguments." CRITICAL
    return 1
  fi

  # Keep the variables local so as not to interfere with the rest of the script
  local type
  local name
  local version
  local json
  local bundle
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

  AlfredBundler::report "Loading ${type} '${name}' version ${version} ..." INFO

  # Check to make sure that the json file exists
  if [ -z "${json}" ]; then
    if [ -f "${AB_DATA}/bundler/meta/defaults/${name}.json" ]; then
      # The json file is a default
      json="${AB_DATA}/bundler/meta/defaults/${name}.json"
    else
      # Send error message to STDERR
      AlfredBundler::report "Error: no valid JSON file found. This is a problem with the __implementation__ with the Alfred Bundler. Please let the workflow author know." CRITICAL
      return 1
    fi
  else
    # Trying to use custom json
    if [ ! -f "${json}" ]; then
      # json file does not exist; send error message to STDERR
      AlfredBundler::report "Error: no valid JSON file found. This is a problem with the __implementation__ with the Alfred Bundler. Please let the workflow author know." CRITICAL
      return 1
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
           "${bundle}" "${name}" "${version}"

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
        AlfredBundler::report "Could not install '${name}', type '${type}'" CRITICAL
        return 1
      fi

      # Register the asset
      bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' \
           "${AB_DATA}/bundler/includes/registry.php" \
           "${bundle}" "${name}" "${version}"

      AlfredBundler::report "Installed '${name}', type '${type}'" INFO
      # Return the path
      echo "${asset}/"$(cat "${asset}/invoke")
      return 0
    fi
  fi

  if [ ! -f "${asset}/invoke" ]; then
      # Install the asset

      AlfredBundler::report "Installing ${type} '${name}' version ${version} ..." INFO

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
  cache_dir="${AB_DATA}/data/call-cache"
  if [[ ! -d "${cache_dir}" ]]; then
    mkdir -p -m 775 "${cache_dir}"
    [[ $? -ne 0 ]] && AlfredBundler::report "Could not make directory: ${cache_dir}" CRITICAL || AlfredBundler::report "Created directory: ${cache_dir}" INFO
  fi

  # Cache path for this call
  key=$(md5 -q -s "${name}-${version}-${type}-${json}")
  cache_path="${cache_dir}/${key}"

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
      "${bundle}" "${name}" "${version}"

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
    bash "${AB_DATA}/bundler/includes/gatekeeper.sh" "${name}" "${path}" "${message}" "${icon}" "${bundle}"

    # get response and do the rest of the handling.
    status=$?
    [[ $status -gt 0 ]] && echo "User denied whitelisting $name" && return $status
    # If we're here, then the user whitelisted the application.
    path="${asset}/$(cat "${asset}/invoke")"
    echo "${path}" > "${cache_path}"

    # Register the asset
    bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' "${AB_DATA}/bundler/includes/registry.php" \
      "${bundle}" "${name}" "${version}"

    # Echo the path and return a successful status
    echo "${path}"
    return 0

  fi

  # Send message to STDERR
  AlfredBundler::report "You've encountered a problem with the __implementation__ of" "the Alfred Bundler; please let the workflow author know." "ERROR"
  return 1

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


################################################################################
### End Asset Functions
################################################################################

