#!/bin/bash

# This script installs the Alfred Bundler.

# Path to this file
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd -P )"
# Define the global bundler version.
major_version=$(cat "${path}/meta/version_major")


# Define locations
data="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${major_version}"
cache="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${major_version}"

# Make the directory structure
if [ ! -d "${data}" ]; then
  mkdir "${data}"
fi
if [ ! -d "${data}/data" ]; then
  mkdir "${data}/data"
fi
if [ ! -d "${data}/data/assets" ]; then
  mkdir "${data}/data/assets"
fi
if [ ! -d "${data}/data/assets/utility" ]; then
  mkdir "${data}/data/assets/utility"
fi
if [ ! -d "${data}/data/assets/utility/terminal-notifier" ]; then
  mkdir "${data}/data/assets/utility/terminal-notifier"
fi
if [ ! -d "${data}/data/assets/utility/terminal-notifier/default" ]; then
  mkdir "${data}/data/assets/utility/terminal-notifier/default"
fi
if [ ! -d "${cache}" ]; then
  mkdir "${cache}"
fi
if [ ! -d "${cache}/installer" ]; then
  mkdir "${cache}/installer"
fi


# Use the misc wrapper to load Terminal Notifier
tn=$(bash "${path}/wrappers/alfred.bundler.misc.sh" "Terminal-Notifier")


# Send a message to the user via the terminal-notifier
`"${data}/data/assets/utility/terminal-notifier/default/terminal-notifier.app/Contents/MacOS/terminal-notifier" \
-title 'Alfred Bundler Installation' -message 'A workflow that you use has \
requested its installation.'`

# That's it. We're installed.

exit

#### BELOW HERE IS OLD CODE BUT WILL NOT BE EXECUTED

# Grab the zip of the Github repo, unpack it, and move it to the data folder
curl -sL "$gitzip" > "${cache}/installer/$major_version.zip"
cd "${cache}/installer"
unzip -oq "$major_version.zip"
rm "$major_version.zip"
mv -f "alfred-bundler-$major_version"/* "${data}"
rm -fR "alfred-bundler-$major_version"
cd ..
rm -fR installer
