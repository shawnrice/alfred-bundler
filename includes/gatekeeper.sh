#!/bin/sh

################################################################################
# In 10.8, Apple introduced something called "Gatekeeper," which is that
# annoying thing that will warn you when opening up an unsigned application in
# 10.8, and, really annoying, in 10.9, it will not let you open anything not
# from the Apple App Store unless you change the settings. Since we can't rely
# on a user to have changed these settings, then we might have to seek
# exceptions. This script checks to see if Gatekeeper will deny an app from
# opening and ask permission if it will. Otherwise, it exits with a hunky-dorey
# status.
################################################################################

# This script is called internally from the bundler, so you shouldn't ever need
# to call it. However, it's nice of you to have opened this file and read this
# explanatory note.

# Exit codes:
#    0 : Success.
#    1 : Failure to invoke script properly.
#    2 : User denied request, alas.

name="$1"
path="$2"
bundler_version="aries";

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "ERROR: Use with args 'name' 'path'."
  exit 1
fi

version=`sw_vers -productVersion`
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"

# Check for Mavericks or Mountain Lion
if [[ $version =~ "10.9" ]] || [[ $version =~ "10.8" ]]; then
  status=`spctl --status`
  # Check to see if Gatekeeper is on.
  if [ "$status" = "assessments enabled" ]; then
    # It's enabled, so we'll see if the file has an exception logged.
    spctl -a "$path" > /dev/null 2>&1
    if [ `echo "$?"` = "0" ]; then
      echo "okay"
      exit 0
    fi
  else
    # Gatekeeper is off. Do nothing.
    echo "off"
    exit 0
  fi
else
  # Pre-10.7, Gatekeeper doesn't exist
  echo "false"
  exit 0
fi

# At this point,  we know that
#   (1) we're using either Mavericks or Mountain Lion;
#   (2) Gatekeeper is enabled; and
#   (3) the requested app isn't whitelisted.

# Change the following to the correct data path
icon="$data/meta/icons/bundle.icns"
icon=`echo "$icon" | sed 's|/|:|g' | cut -c 2-`

# Construct the Applescript dialog
read -d '' script <<-"_EOF_"
display dialog "A workflow that you have downloaded uses the Alfred Bundler to install required support software, and it wants to use '$name.'

Will you allow it?

If you press 'Allow,' then you will be prompted to enter your password, which will grant access to this application.
" buttons {"Allow","Deny"} default button 1 with title "Alfred Bundler" with icon file "$icon"
_EOF_
script=`echo "$script" | sed 's|$icon|'"$icon"'|g'`
script=`echo "$script" | sed 's|$name|'"$name"'|g'`

response=`osascript -e "$script"`

if [[ $response =~ "Deny" ]]; then
  # The user has denied access to the app, so we're going to, well, exit and die.
  echo "denied"
  exit 2
fi

label="alfred-bundle-$name"
spctl --list --label "$label" > /dev/null 2>&1
if [ `echo $?` = "1" ]; then
  # No label was found, so we'll add one then enable it.
  spctl --add --label "alfred-bundle-$name" "$path" > /dev/null 2>&1
  if [ `echo "$?"` = "1" ]; then
    echo "denied"
    exit 2
  fi
  spctl --enable --label "alfred-bundle-$name"
  if [ `echo "$?"` = "1" ]; then
    echo "denied"
    exit 2
  fi
else
  # We found the label, so we'll just re-enable it.
  spctl --enable --label "alfred-bundle-$name"
  if [ `echo "$?"` = "1" ]; then
    echo "denied"
    exit 2
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