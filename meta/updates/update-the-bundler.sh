# This is the update script.

bundler_version="aries";
newest=2

__data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-$bundler_version"
__git="https://github.com/shawnrice/alfred-bundler/raw/aries"

#### Upgrade Path Functions
#### We can just run them sequentially... maybe.

###
# From Aries 1 to Aries 2
one_to_two() {

	# Remove Files
	rm "$__data/includes/download.php"
	rm "$__data/meta/defaults/php-5.5.5-cli.json"

	# New Files
	curl -sL "$__git/meta/defaults/Pip.json" > "$__data/meta/defaults/Pip.json"
	curl -sL "$__git/wrappers/bundler.py" > "$__data/wrappers/bundler.py"

	# Updated Files
	curl -sL "$__git/wrappers/alfred.bundler.sh" > "$__data/wrappers/alfred.bundler.sh"
	curl -sL "$__git/wrappers/alfred.bundler.misc.sh" > "$__data/wrappers/alfred.bundler.misc.sh"
	curl -sL "$__git/meta/update.sh" > "$__data/update.sh"


	# Update the minor version
	curl -sL "$__git/meta/version_minor" > "$__data/meta/version_minor"

	# Update the file manifest
	curl -sL "$__git/manifest" > "$__data/manifest"
}