#!/bin/sh

dir="$PWD"

bundles=()

for D in `ls ../`
do
  bundles+=(`/usr/libexec/PlistBuddy -c "Print :bundleid" "../$D/info.plist"`)
done
echo ${#bundles[@]}
