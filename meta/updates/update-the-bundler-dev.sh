#!/bin/bash

# Define the global bundler version.
bundler_version="aries";
__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"

link="https://github.com/shawnrice/alfred-bundler/archive/aries.zip"

if [ ! -d "$__cache" ]; then
	mkdir "$__cache"
fi

if [ -f "$__data" ]; then
	# If the data directory doesn't exist, then it should be a fresh install, not an update
	exit 1
fi

if [ ! -d "$__cache/update-bundler" ]; then
	mkdir "$__cache/update-bundler"
fi

curl -sL "$link" > "$__cache/update-bundler/bundler-update.zip"

# Check to see if we were successful, and exit if not.
status=$?
[[ $status -gt 0 ]] && exit $status

cd "$__cache/update-bundler"
unzip -q bundler-update.zip
cd - 

cd "$__data"
zip -q -r "$__cache/update-bundler/data.zip" *
zip -q -r "$__cache/update-bundler/assets.zip" *
rm -fR *
cd -

mv "$__cache/update-bundler/alfred-bundler-aries/"* ./
mv "$__cache/update-bundler/data.zip" ./
mv "$__cache/update-bundler/assets.zip" ./
unzip -q data.zip
unzip -q assets.zip
rm data.zip
rm assets.zip
rm -fR "$__cache/update-bundler"