#!/bin/sh

# This script installs the Alfred Bundler.

# Define the global bundler version.
bundler_version="aries";

# Define locations
git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/blob/$bundler_version"
__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"
# For now, we're using the 'initial' branch.
gitzip="https://github.com/shawnrice/alfred-bundler/archive/$bundler_version.zip"

# Make the directory structure
if [ ! -d "$__data" ]; then
  mkdir "$__data"
fi
if [ ! -d "$__data/assets" ]; then
  mkdir "$__data/assets"
fi
if [ ! -d "$__data/assets/utility" ]; then
  mkdir "$__data/assets/utility"
fi
if [ ! -d "$__data/assets/utility/terminal-notifier" ]; then
  mkdir "$__data/assets/utility/terminal-notifier"
fi
if [ ! -d "$__data/assets/utility/terminal-notifier/default" ]; then
  mkdir "$__data/assets/utility/terminal-notifier/default"
fi
if [ ! -d "$__cache" ]; then
  mkdir "$__cache"
fi
if [ ! -d "$__cache/installer" ]; then
  mkdir "$__cache/installer"
fi

# Grab the zip of the Github repo, unpack it, and move it to the data folder
curl -sL "$gitzip" > "$__cache/installer/$bundler_version.zip"
cd "$__cache/installer"
unzip -oq "$bundler_version.zip"
rm "$bundler_version.zip"
mv -f "alfred-bundler-$bundler_version"/* "$__data"
rm -fR "alfred-bundler-$bundler_version"
cd ..
rm -fR installer

# Grab the Terminal-Notifier utility, and install it to the data directory
curl -sL "https://github.com/shawnrice/Alfred-Helpers/blob/master/terminal-notifier.app.zip?raw=true" > "$__cache/terminal-notifier.zip"
cd "$__cache"
unzip -oq "terminal-notifier.zip"
cp -fR terminal-notifier.app "$__data/assets/utility/terminal-notifier/default"
rm -fR "$__cache/terminal*"
cd - > /dev/null

# Create the "invoke" file
echo "terminal-notifier.app/Contents/MacOS/terminal-notifier" \
> "$__data/assets/utility/terminal-notifier/default/invoke"

# Send a message to the user via the terminal-notifier
`"$__data/assets/utility/terminal-notifier/default/terminal-notifier.app/Contents/MacOS/terminal-notifier" \
-title 'Alfred Bundler Installation' -message 'A workflow that you use has \
requested its installation.'`

# That's it. We're installed.