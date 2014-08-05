#!/bin/bash
#
# Uninstalls the bundler

declare -r AB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
  # Get the major version from the file
declare -r AB_MAJOR_VERSION=$(cat "${AB_PATH}/meta/version_major")
# Set the data directory
declare -r AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"

dirs=("${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
      "${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}")

for path in "${dirs[@]}"; do
	[[ -d "${path}" ]] && echo "Deleting ${path} ..." && rm -rf "${path}"
done