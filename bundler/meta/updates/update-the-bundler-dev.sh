#!/bin/bash

#### NOT WORKING REDEFINE ALL THE PATHS
# Define the global bundler version.
bundler_version=$(cat ../version_major)

# Define the data and cache directories for the bundler
__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-$bundler_version"

# Make the cache directory if it doesn't exist
if [ ! -d "$__cache" ]; then
	mkdir "$__cache"
fi

# Make the data directory if it doesn't exist
if [ -f "$__data" ]; then
	# If the data directory doesn't exist, then it should be a fresh install, not an update
	exit 1
fi

# Ping test for Internet connectivity
ping -t 1 -c 1 www.google.com 2>&1>/dev/null
[[ $? -ne 0 ]] && exit 1

# We have Internet. Continue.
newest=`curl -sL "https://github.com/shawnrice/alfred-bundler/raw/aries/bundler/meta/version_minor"`
current=`cat "$__data/meta/bundler/version_minor"`

# The version check should have already happened, but we'll run it again for good measure.
[[ $newest -le $current ]] && exit 0
# There is a new version. Continue.

################################################################################
# The function to download the new bundler archive from GH and migrate to new
# version, keeping the data and assets directories.
################################################################################

function updateBundler() {
	# Link to the GH bundler archive
	link="https://github.com/shawnrice/alfred-bundler/archive/aries.zip"

	# Make the working directory for the update
	if [ ! -d "$__cache/update-bundler" ]; then
		mkdir "$__cache/update-bundler"
	else
		# The directory exists, so go in there and make sure it's clean.
		cd "$__cache/update-bundler"
		rm -fR *
		cd -
	fi

	# Download the new archive
	curl -sL "$link" > "$__cache/update-bundler/bundler-update.zip"

	# Check to see if we were successful, and exit if not.
	status=$?
	[[ $status -gt 0 ]] && exit $status

	# Move into the temp directory and unzip/test/start
	cd "$__cache/update-bundler"
	unzip -q bundler-update.zip
	# Check to make sure it was a valid zip, otherwise, exit
	status=$?
	if [[ $status -gt 0 ]]; then
		cd -
		# Badness happened, so let's remove the files and get the hell out
		# of here.
		rm -fR "$__cache/update-bundler"
		return $status
	fi
	cd -

	# Backup the data and assets directories so that we can restore them
	cd "$__data"
	zip -q -r "$__cache/update-bundler/data.zip" *
	zip -q -r "$__cache/update-bundler/assets.zip" *
	rm -fR *
	cd -

	# Move all the new bundler files into the bundler directory
	mv "$__cache/update-bundler/alfred-bundler-aries/"* ./
	# Restore the data and assets directories
	mv "$__cache/update-bundler/data.zip" ./
	mv "$__cache/update-bundler/assets.zip" ./
	unzip -q -o data.zip
	unzip -q -o assets.zip
	# Delete the backup archives
	rm data.zip
	rm assets.zip
	# Remove the update temp directory
	rm -fR "$__cache/update-bundler"

	return 0
}

################################################################################
# Define special upgrade functions here
################################################################################

function one_to_two() {
	# This is an empty function.
	a=1
}

################################################################################
# End special upgrade functions. Start the script.
################################################################################

check=`updateBundler`
[[ ${check} -ne 0 ]] && exit $check

# This will help with the special upgrade methods
numberTranslation=('zero' 'one' 'two' 'three' 'four' 'five' 'six' 'seven' 'eight' 'nine' 'ten')

#### Start Script
counter="$current"

until [[  $counter -gt $newest ]]; do
	# Grab the function
	cmd=${numberTranslation[$counter]}"_to_"${numberTranslation[$counter+1]}

	# See if function is defined
	function=`type -t "$cmd"`
	# If function is defined, then execute it; otherwise, do nothing
	[ -n "${function}" ] && eval "$cmd"

	# Increase the counter for the next version
	let counter+=1
done
