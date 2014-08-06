#!/bin/bash
#
# Uninstalls the bundler
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

declare -r AB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

  # Get the major version from the file
if [[ ! -z "${ALFRED_BUNDLER_DEVEL}" ]]; then
	declare -r AB_MAJOR_VERSION="${ALFRED_BUNDLER_DEVEL}"
 else
	declare -r AB_MAJOR_VERSION=$(cat "${AB_PATH}/meta/version_major")
fi

# Set the data directory
declare -r AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"
declare -r AB_CACHE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"

echo "Trying to uninstall Alfred Dependency Bundler version '${AB_MAJOR_VERSION}' ..."

dirs=("${AB_CACHE}"
      "${AB_DATA}")

uninstalled=0

for path in "${dirs[@]}"; do
	[[ -d "${path}" ]] && echo "Deleting ${path} ..." >&2 && rm -rf "${path}" && uninstalled=1
done

[[ $uninstalled -eq 1 ]] && echo "Bundler was uninstalled." >&2 || echo "No bundler found." >&2
