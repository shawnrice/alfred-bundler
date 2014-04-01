#!/bin/sh

git="https://raw.githubusercontent.com/shawnrice/alfred-bundler/master"
data="$HOME/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler"
cache="$HOME/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler"
gitzip="https://github.com/shawnrice/alfred-bundler/archive/initial.zip"

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

curl -sL "$gitzip" > "$cache/installer/master.zip"
cd "$cache/installer"
unzip -oq "master.zip"
rm master.zip
mv -f alfred-bundler-initial/* "$data"

curl -sL "https://github.com/Ritashugisha/AlfredWorkflowResourcePack/blob/\
master/terminal-notifier/terminal-notifier.app.zip?raw=true" > "$data/assets/utilities\
/terminal-notifier.zip"
unzip -oq "$data/assets/utilities/terminal-notifier.zip" -d "$data/assets/utilities/terminal-notifier/default/"
rm "$data/assets/utilities/terminal-notifier.zip"

echo "$data/assets/utilities/terminal-notifier/default/terminal-notifier.app/Contents/MacOS/terminal-notifier" \
> "$data/assets/utilities/terminal-notifier/default/invoke"

`"$data/assets/utilities/terminal-notifier/default/terminal-notifier.app/Contents/MacOS/terminal-notifier" \
-title 'Alfred Bundler Installation' -message 'A workflow that you use has \
requested its installation.'`
