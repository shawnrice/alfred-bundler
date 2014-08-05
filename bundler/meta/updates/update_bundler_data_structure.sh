#!/bin/bash
#
# Updates the internal data structure of the bundler between minor versions

# This script should be called __only__ by the update.sh script after a
# successful update.
# 
# Currently, this is a skeleton of the internal script and does not / cannot
# be fully written until a minor update is needed.

# Define the global bundler version.
declare -r AB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}"/../../ )" && pwd -P )"
 # Get the major version from the file
declare -r AB_MAJOR_VERSION=$(cat "${AB_PATH}/meta/version_major")
 # Get the major version from the file
declare -r AB_MINOR_VERSION=$(cat "${AB_PATH}/meta/version_minor")
# Set the data directory
declare -r AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
{AB_MAJOR_VERSION}=$(cat ../version_major)
# Set the cache directory
declare -r AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"

################################################################################
# Define special upgrade functions here
################################################################################

#######################################
# Updates from minor 1 to minor 2
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
function one_to_two() {
	# This is an empty function that will
	# be written when an upgrade is needed
	a=1
}

#######################################
# Runs all of the upgrade functions
# Globals:
#   MINOR_VERSION
# Arguments:
# 	None
# Returns:
#   None
#######################################
function main() {
	# This will help with the special upgrade methods
	numberTranslation=('zero' 'one' 'two' 'three' 'four' 'five' 'six' 'seven' 'eight' 'nine' 'ten')

	#### Set the counter; we'll start the internal upgrade process from here
	counter=1

	until [[  $counter -gt $AB_MINOR_VERSION ]]; do
		# Grab the function
		cmd=${numberTranslation[$counter]}"_to_"${numberTranslation[$counter+1]}

		# See if function is defined
		function=`type -t "$cmd"`
		# If function is defined, then execute it; otherwise, do nothing
		[ -n "${function}" ] && eval "${cmd}"

		# Increase the counter for the next version
		let counter+=1
	done
	return 0	
}

main
exit $?