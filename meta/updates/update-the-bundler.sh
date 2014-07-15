#!/bin/bash

# This is the update script.

bundler_version=$(cat ../version_major)

__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__git="https://github.com/shawnrice/alfred-bundler/raw/aries"
newest=`curl -sL "https://github.com/shawnrice/alfred-bundler/raw/aries/meta/version_minor"`
current=`cat "$__data/meta/version_minor"`

numberTranslation=('zero' 'one' 'two' 'three' 'four' 'five' 'six' 'seven' 'eight' 'nine' 'ten')

counter="$current"
downloadQueue=()
deleteQueue=()

#### Upgrade Path Functions


###
# From Aries 1 to Aries 2
#
one_to_two() {

	# Remove Files
	deleteQueue+=' includes/download.php'
	deleteQueue+=' meta/defaults/php-5.5.5-cli.json'
	deleteQueue+=' manifest'

	# New Files
	downloadQueue+=' meta/defaults/Pip.json'
	downloadQueue+=' wrappers/bundler.py'

	# Updated Files
	downloadQueue+=' wrappers/alfred.bundler.sh'
	downloadQueue+=' wrappers/alfred.bundler.misc.sh'
	downloadQueue+=' meta/update.sh'
	downloadQueue+=' bundler.sh'
	downloadQueue+=' bundler.php'
	downloadQueue+=' meta/defaults/viewer.json'
	downloadQueue+=' includes/gatekeeper.sh'

	# Update the minor version
	downloadQueue+=' meta/version_minor'

}

###
# From Aries 2 to Aries 3
# Just for testing purposes

#two_to_three() {
	# Not needed yet.
#}

### Let's define some helper functions.

# Actual commands commented out, and
# echo commands put in for testing purposes.

downloadFile() {
	file="$1"
	echo "curl -sL '$__git/$file' > '$__data/$file'"
}

deleteFile() {
	file="$1"
	if [ -f "$__data/$file" ]; then
		rm "$__data/$file"
	fi
}

#### Start Script
counter="$current"

until [[  $counter -gt $newest ]]; do
	cmd=${numberTranslation[$counter]}"_to_"${numberTranslation[$counter+1]}
	eval "$cmd"
	let counter+=1
done

downloadQueue=`echo "${downloadQueue[@]}" | tr ' ' '\n' <<< "${downloadQueue[@]}" | sort -u | tr '\n' ' '`
deleteQueue=`echo "${deleteQueue[@]}" | tr ' ' '\n' <<< "${deleteQueue[@]}" | sort -u | tr '\n' ' '`

# echo ''
# echo "Download Queue"
# echo "------------"
for file in $downloadQueue; do
	downloadFile "$file"
done
# echo ''
# echo "Delete Queue"
# echo "------------"
for file in $deleteQueue; do
	deleteFile "$file"
done
