#!/bin/bash
#
# Starts a new script and forks it
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

# At least a few of the scripting binaries native on OS X are not compiled with
# the functions to fork processes, so this file serves as a wrapper to fork a
# process indirectly. Call this script with
# '/bin/prog' 'fullpathtoscriptname' 'args....'

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"

for arg in "$@" ; do
  args="${args} '${arg}'"
done

# Execute the script entirely in the background
nohup ${args} 1>&2 &> /dev/null 1>&2 &> /dev/null &

exit 0