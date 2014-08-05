#!/bin/bash
#
# Starts update script and forks it

# At least a few of the scripting binaries native on OS X are not compiled with
# the functions to fork processes, so this file serves as a wrapper to fork a
# the update process indirectly. Basically, this file is called by the bundler
# wrapper checking to see if the bundler needs to update itself from one minor
# version to another, since we do not want the bundler to wait for things like
# http connections, we use this wrapper to call and fork the actual update
# script and then quickly return an exit code 0 so that the bundler script
# can continue to function as normal.

# Path to base of bundler directory
path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd -P )"

# Execute the update script entirely in the background
nohup /bin/bash "${path}/meta/update.sh" 1>&2 &> /dev/null 1>&2 &> /dev/null &

exit 0