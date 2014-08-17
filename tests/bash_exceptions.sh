#!/bin/bash

set -o errtrace -o functrace
trap 'traperror $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "%s" ${FUNCNAME[@]})'  ERR

traperror () {

  local internal=$(caller)            # Where did this come from?
  local line=$(echo "${internal}" | cut -d ' ' -f1)
  local file="${internal#${line} }"   # get the file without the line number

  local status=$1                     # error status
  local line=$2                       # Actual line number of error
  local function_line=$3              # Line the function was called from
  local command="$4"
  local function="$5"

  if [[ $DUDE_DIDNT_INSTALL != 'TRUE' ]]; then
    trap - ERR EXIT # Not a bundler error, so, let it work normally (die) (unset trap).
  fi

  if [[ $command =~ "AB_*" ]] || [[ $command =~ "AlfredBundler::" ]]; then
    # This error was caused by a function with a bundler prefix
    if [[ $status -eq 127 ]]; then
      # And... this error was a "command not found"
      echo -n "Dude. You didn't install the bundler."
      echo -n " And the author wanted to call a function "
      echo -n "${command}"
      if [ ! -z $function ]; then
        echo -n " from the function: '${function}'"
      fi
      echo -n ", which was called from "
      if [ ! -z $function_line ]; then
        echo -n "line ${function_line}, and the function was called from "
      fi
      echo "line ${line} in file '${file}'."
      echo "So, um. Yeah. Totally your fault."
    else
      trap - ERR EXIT # Not a bundler error, so, let it work normally (die) (unset trap).
      exit $status
    fi
  else
    trap - ERR EXIT # Not a bundler error, so, let it work normally (die) (unset trap).
    exit $status
  fi
}

dialog="display dialog \"Do you want to install this Bundler thingie?\" buttons {\"No fucking way!\"} default button 1 with title \"Uh...\""
response=$(osascript -e "${dialog}")

if [[ $response != 'button returned:No fucking way!' ]]; then
    echo "Whoa! You shouldn't have made it here, duder."
else
    DUDE_DIDNT_INSTALL='TRUE'
    trap 'traperror $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "%s" ${FUNCNAME[@]})'  ERR
fi


AlfredBundler::Load what what

thisfunctionwillthrowerror () {
    deansniffsdogbutts 'chihuahua'
    }

thisfunctionwillthrowerror

exit