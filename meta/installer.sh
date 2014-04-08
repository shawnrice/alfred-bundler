#!/bin/sh

# This script installs the Alfred Bundler.

# Define the global bundler version.
bundler_version="aries";

# Define locations
git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"
# For now, we're using the 'initial' branch.
gitzip="https://github.com/shawnrice/alfred-bundler/archive/$bundler_version.zip"

# Make the directory structure
if [ ! -d "$data" ]; then
  mkdir "$data"
fi
if [ ! -d "$data/assets" ]; then
  mkdir "$data/assets"
fi
if [ ! -d "$data/assets/utilities" ]; then
  mkdir "$data/assets/utilities"
fi
if [ ! -d "$data/assets/utilities/terminal-notifier" ]; then
  mkdir "$data/assets/utilities/terminal-notifier"
fi
if [ ! -d "$data/assets/utilities/terminal-notifier/default" ]; then
  mkdir "$data/assets/utilities/terminal-notifier/default"
fi
if [ ! -d "$cache" ]; then
  mkdir "$cache"
fi
if [ ! -d "$cache/installer" ]; then
  mkdir "$cache/installer"
fi

# Grab the zip of the Github repo, unpack it, and move it to the data folder
curl -sL "$gitzip" > "$cache/installer/$bundler_version.zip"
cd "$cache/installer"
unzip -oq "$bundler_version.zip"
rm "$bundler_version.zip"
mv -f "alfred-bundler-$bundler_version"/* "$data"
rm -fR "alfred-bundler-$bundler_version"
cd ..
rm -fR installer

# Grab the Terminal-Notifier utility, and install it to the data directory
curl -sL "https://github.com/shawnrice/Alfred-Helpers/blob/master/terminal-notifier.app.zip?raw=true" > "$data/assets/utilities\
/terminal-notifier.zip"
unzip -oq "$data/assets/utilities/terminal-notifier.zip" -d "$data/assets/utilities/terminal-notifier/default/"
rm "$data/assets/utilities/terminal-notifier.zip"

# Create the "invoke" file
echo "terminal-notifier.app/Contents/MacOS/terminal-notifier" \
> "$data/assets/utilities/terminal-notifier/default/invoke"

# Send a message to the user via the terminal-notifier
`"$data/assets/utilities/terminal-notifier/default/terminal-notifier.app/Contents/MacOS/terminal-notifier" \
-title 'Alfred Bundler Installation' -message 'A workflow that you use has \
requested its installation.'`

# That's it. We're installed.