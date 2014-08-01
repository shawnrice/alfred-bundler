#!/bin/sh

################################################################################
# In 10.8, Apple introduced something called "Gatekeeper," which is that
# annoying thing that will warn you when opening up an unsigned application in
# 10.8+. Since we can't rely on a user to have changed these settings, then we
# might have to seek exceptions. This script checks to see if Gatekeeper will
# deny an app from opening and ask permission if it will. Otherwise, it exits
# with a hunky-dorey status.
################################################################################

# This script is called internally from the bundler, so you shouldn't ever need
# to call it. However, it's nice of you to have opened this file and read this
# explanatory note.

# Exit codes:
#    0 : Success.
#    1 : Failure to invoke script properly.
#    2 : User denied request, alas.

# Path to this file
me="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd -P )"

# Define the global bundler version.
major_version=$(cat "${me}/meta/version_major")

name="$1"     # Name of utility
path="$2"     # Full path to utility
message="$3"  # Description of what the utility does
icon="$4"     # Icon file to create
bundle="$5"   # Bundle ID for icns file

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "ERROR: Use with args 'name' 'path'."
  exit 1
fi

version=`sw_vers -productVersion`
data="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${major_version}"
cache="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${major_version}"

# Check for Mavericks or Mountain Lion
if [[ $version =~ "10.10" ]] || [[ $version =~ "10.9" ]] || [[ $version =~ "10.8" ]]; then
  status=`spctl --status`

  # Check to see if Gatekeeper is on.
  if [ "${status}" != "assessments enabled" ]; then
    # Gatekeeper is off. Do nothing.
    echo "off"
    exit 0
  else
    # It's enabled, so we'll see if the file has an exception logged.
    label="alfred-bundle-${name}"
    gatekeeper=`spctl -a "${path}" > /dev/null 2>&1; echo $?`
    # gatekeeper=`spctl --list --label "$label" > /dev/null 2>&1; echo $?`
    if [[ $gatekeeper -eq 0 ]]; then
      echo "okay"
      exit 0
    fi
  fi
else
  # Pre-10.7, Gatekeeper doesn't exist
  echo "false"
  exit 0
fi

# label="alfred-bundle-$name"
# gatekeeper=`spctl --list --label "$label"`
# if [ "$gatekeeper" != "error: no matches for search or update operation" ]; then
#   exit 0
# fi

# At this point,  we know that
#   (1) we're using either Mavericks or Mountain Lion (or Yosemite);
#   (2) Gatekeeper is enabled; and
#   (3) the requested app isn't whitelisted.

# Create custom icns file
if [ ! -z "${icon}" ]; then
  if [ -f "${icon}" ]; then
    [[ ! -d "${cache}/icns" ]] && mkdir -p -m 0775 "${cache}/icns"
    bash "${me}/includes/png_to_icns.sh" "${icon}" "${cache}/icns/${bundle}.icns"
    if [[ $? == 0 ]]; then
      icon="${cache}/icns/${bundle}.icns"
    else
      icon="${data}/bundler/meta/icons/bundle.icns"
    fi
  else
    icon="${data}/bundler/meta/icons/bundle.icns"
  fi
else
  icon="${data}/bundler/meta/icons/bundle.icns"
fi

# Change the following to the correct data path
# icon="${data}/bundler/meta/icons/bundle.icns" # Old icon file to use
icon=$(echo "${icon}" | sed 's|/|:|g' | cut -c 2-) # Change from POSIX path

######
######
### Add in message from JSON
######
######

# Construct the Applescript dialog
read -d '' script <<-"_EOF_"
display dialog "A workflow that you have downloaded uses the Alfred Bundler to install required support software, and it wants to use '$name.'

Will you allow it?

If you press 'Allow,' then you will be prompted to enter your password, which will grant access to this application.
" buttons {"Allow","Deny"} default button 1 with title "Alfred Bundler" with icon file "$icon"
_EOF_
script=$(echo "${script}" | sed 's|$icon|'"${icon}"'|g')
script=$(echo "${script}" | sed 's|$name|'"${name}"'|g')

response=$(osascript -e "${script}")

if [[ $response =~ "Deny" ]]; then
  # The user has denied access to the app, so we're going to, well, exit and die.
  echo "denied"
  exit 1
fi

label="alfred-bundle-${name}"
gatekeeper=$(spctl --list --label "$label" > /dev/null 2>&1; echo $?)

if [ $gatekeeper -eq 1 ]; then
  # No label was found, so we'll add one then enable it.
  status=$(spctl --add --label "alfred-bundle-${name}" "${path}" > /dev/null 2>&1; spctl --enable --label "alfred-bundle-${name}"; echo $?)
  if [[ $status -eq 1 ]]; then
    echo "denied"
    exit 1
  fi
fi

exit 0

################################################################################
# Internal notes:
# Commands to use later to "deauthorize"
# Full list of labels
# spctl --list
# Check to see if label is avilable
# spctl --list --label "LABEL"
# Check the status of Gatekeeper
# returns either "assessments enabled" or "assessments disabled"
# spctl --status
# Disables the label, which, effectively, de-authorizes it
# spctl --disable --label "LABEL"
# Delete the label
# spctl --remove --label "LABEL"
################################################################################
