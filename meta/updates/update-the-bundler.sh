# This is the update script.

bundler_version="aries";
newest=2

__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__git="https://github.com/shawnrice/alfred-bundler/raw/aries"
newest=`curl -sL "https://github.com/shawnrice/alfred-bundler/raw/aries/meta/version_minor"`
current=`cat "__data/meta/version_minor"`

## Let's now write a function that will go through each list and then do them all. Or something.

#### Upgrade Path Functions
#### We can just run them sequentially... maybe.

dlFiles=()
delFiles=()
###
# From Aries 1 to Aries 2
# 
one_to_two() {

	# Remove Files
	delFiles+=("includes/download.php")
	delFiles+=("meta/defaults/php-5.5.5-cli.json")

	# New Files
	dlFiles+=("meta/defaults/Pip.json")
	dlFiles+=("wrappers/bundler.py")

	# Updated Files
	dlFiles+=("wrappers/alfred.bundler.sh")
	dlFiles+=("wrappers/alfred.bundler.misc.sh")
	dlFiles+=("meta/update.sh")
	dlFiles+=("bundler.sh")
	dlFiles+=("bundler.php")
	dlFiles+=("meta/defaults/viewer.json")
	dlFiles+=("includes/gatekeeper.sh")

	# Update the minor version
	dlFiles+=("meta/version_minor")

	# Update the file manifest
	dlFiles+=("manifest")
}

### Let's define some helper functions.

downloadFile() {
	file="$1"
	curl -sL "$__git/$file" > "$__data/$file"
}

deleteFile() {
	file="$1"
	if [ -f "$__data/$file" ]; then
		rm "$__data/$file"
	fi
}