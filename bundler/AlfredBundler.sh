#!/bin/bash

. "$__data/bundler/includes/helper-functions.sh"

bd_asset_cache="$__data/data/call-cache"

# Checks to make sure value fed to it is a hex color and converts 3 hex to 6 hex
# Returns normalized color on success, 1 on failure
function AlfredBundler::check_hex() {
  
  # Make sure that we have an argument
  if [[ -z "$1" ]]; then
    echo "Error: check_hex needs 1 argument" >&2
    return 1
  fi

  local color="$1"

  # Convert the color of lowercase
  color=$( echo "${color}" | tr [[:upper:]] [[:lower:]])

  # Remove the # from the beginning of the color
  color="${color/\#}"

  # Convert hex 3 to hex 6
  if [[ ${#color} -eq 3 ]]; then
    r=${color:0:1}
    g=${color:1:1}
    b=${color:2:1}
    color="${r}${r}${g}${g}${b}${b}"
  fi

  # The color needs to be in 6 hex
  if [[ ${#color} -ne 6 ]]; then
    echo "Error: Hex color must be 3 or 6 characters" >&2
    return 1
  fi

  # Make sure that the color contains only valid characters
  if [[ "${color}" =~ ^[a-f0-9]*$ ]]; then
    echo ${color}
  else
    echo "Error: '${color}' is not a valid hex color" >&2
    return 1
  fi
}

# # This function should be fed only proper hex codes
# # Usage: <color> <other color|TRUE>
function AlfredBundler::alter_color() {

  # We need two arguments
  if [[ $# -ne 2 ]]; then
    return 0
  fi

  local color="$1"

  if [[ $(AlfredBundler::check_brightness "${color}") == $(AlfredBundler::get_background) ]]; then
    # Since they're the same, we'll alter the color
    if [ $2 == "TRUE" ]; then
      color=$(AlfredBundler::hex_to_rgb ${color})
      color=($(AlfredBundler::rgb_to_hsv ${color}))  
      color=(${color[0]} ${color[1]} $(echo "scale=10; 1 - ${color[2]}" | bc -l))
      color=$(AlfredBundler::hsv_to_rgb ${color[@]})
      color=$(AlfredBundler::rgb_to_hex ${color[@]})
      echo ${color}
      return 0
    else
      echo $2
      return 0
    fi
  else
    # Since they're different, we'll just return the original color
    echo ${color}
    return 0
  fi
}

function AlfredBundler::get_background() {

  # Add in error checking

  # Path to base of bundler directory
  local path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../alfred-bundler/bundler" && pwd -P )"
  # Get the major version from the file
  local major_version=$(cat "${path}/meta/version_major")
  # Set the data directory
  local data="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${major_version}"

  local plist=$(stat -f%m "${HOME}/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist")
  local background=$(stat -f%m "${data}/data/theme_background")
  if [[ $plist -gt $background ]]; then
    echo $("${path}/includes/LightOrDark") > "${data}/data/theme_background"
  fi

  background=$(cat "${data}/data/theme_background")
  echo "${background}"
}

function AlfredBundler::check_brightness() {
  # add in validation of the arguments here
  color="$1"

  r=$(Math::hex_to_dec ${color:0:2})
  g=$(Math::hex_to_dec ${color:2:2})
  b=$(Math::hex_to_dec ${color:4:2})

  brightness=$(( ( (r * 299) + ( g * 587 ) + ( b * 114 ) ) / 1000 ))
  if [[ "${brightness}" -gt 130 ]]; then
    echo "light"
  else
    echo "dark"
  fi

  return 0
}

function AlfredBundler::rgb_to_hsv() {
  local r=$( echo "scale=10; $1 / 255" | bc -l)
  local g=$( echo "scale=10; $2 / 255" | bc -l)
  local b=$( echo "scale=10; $3 / 255" | bc -l)

  max=$(Math::Max $r $g $b)
  min=$(Math::Min $r $g $b)
  delta=$(echo "scale=10; ${max} - ${min}" | bc -l)
  v="${max}"

  if [[ $(echo "${max} != 0.0" | bc -l) -eq 1 ]]; then
    s=$(echo "scale=10; ${delta} / ${max}" | bc -l )
  else
    s="0.0"
  fi

  if [[ $(echo "scale=10; ${s} == 0" | bc -l) -eq 1 ]]; then
    h="0.0"
  else
    if [[ $(echo "${r} == ${max}" | bc -l) -eq 1 ]]; then
      h=$(echo "scale=10; (${g} - ${b}) / ${delta}" | bc -l)
    elif [[ $(echo "${g} == ${max}" | bc -l) -eq 1 ]]; then
      h=$(echo "scale=10; 2 + ((${b} - ${r}) / ${delta})" | bc -l)
    elif [[ $(echo "${b} == ${max}" | bc -l) -eq 1 ]]; then
      h=$(echo "scale=10; 4 + ((${r} - ${g}) / ${delta})" | bc -l)
    fi
  fi

  h=$(echo "scale=10; ${h} * 60" | bc -l)

  if [[ $(echo "${h} < 0" | bc -l) -eq 1 ]]; then
    h=$(echo "scale=10; ${h} += 360" | bc -l)
  fi
  h=$(echo "scale=10; ${h} / 360" | bc -l)
  echo "${h} ${s} ${v}"
  return 0
}

function AlfredBundler::hsv_to_rgb() {
  h="$1"
  s="$2"
  v="$3"


  if [[ $(echo "${s} == 0" | bc -l) -eq 1 ]]; then
    t=$(echo "${v} * 255" | bc -l)
    echo "${t} ${t} ${t}"
    return 0
  fi

  var_h=$(echo "scale=10; ${h} * 6" | bc -l)
  var_i=$(Math::Floor ${var_h})
  var_1=$(echo "${v} * (1 - ${s})" | bc -l)
  var_2=$(echo "${v} * (1 - ${s} * (${var_h} - ${var_i}))" | bc -l)
  var_3=$(echo "${v} * (1 - ${s} * (1 - (${var_h} - ${var_i})))" | bc -l)
  if [[ $( echo "${var_i} == 0" | bc -l) -eq 1 ]]; then
    r=${v}
    g=${var_3}
    b=${var_1}
  elif [[ $( echo "${var_i} == 1" | bc -l) -eq 1 ]]; then
    r=${var_2}
    g=${v}
    b=${var_1}
  elif [[ $( echo "${var_i} == 2" | bc -l) -eq 1 ]]; then
    r=${var_1}
    g=${v}
    b=${var_3}
  elif [[ $( echo "${var_i} == 3" | bc -l) -eq 1 ]]; then
    r=${var_1}
    g=${var_2}
    b=${v}
  elif [[ $( echo "${var_i} == 4" | bc -l) -eq 1 ]]; then
    r=${var_3}
    g=${var_1}
    b=${v}
  else
    r=${v}
    g=${var_1}
    b=${var_2}
  fi

  r=$(Math::Floor $(echo "${r} * 255" | bc -l))
  g=$(Math::Floor $(echo "${g} * 255" | bc -l))
  b=$(Math::Floor $(echo "${b} * 255" | bc -l))

  echo "${r} ${g} ${b}"

}

function AlfredBundler::hex_to_rgb() {
  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  r=$(Math::hex_to_dec "${hex:0:2}")
  g=$(Math::hex_to_dec "${hex:2:2}")
  b=$(Math::hex_to_dec "${hex:4:2}")

  echo "${r} ${g} ${b}"
}

function AlfredBundler::rgb_to_hex() {
  r=$(Math::dec_to_hex "$1")
  g=$(Math::dec_to_hex "$2")
  b=$(Math::dec_to_hex "$3")

  # Make sure everything turns back into 6 hex
  if [[ ${#r} -eq 1 ]]; then
    r=${r}${r}
  fi
  if [[ ${#g} -eq 1 ]]; then
    g=${g}${g}
  fi
  if [[ ${#b} -eq 1 ]]; then
    b=${b}${b}
  fi

  echo "${r}${g}${b}"
}

function Math::Max() {
  numbers=($@)
  i=0
  max=''
  len=${#numbers[@]}
  
  while [[ $i -lt $len ]]; do
    if [ -z ${max} ]; then
      max="${numbers[$i]}"
    fi

    if [[ $(echo "${numbers[$i]} > ${max}" | bc -l ) -eq 1 ]]; then
      max="${numbers[$i]}"
    fi

    : $[ i++ ]
  done;
  
  echo $max
}

function Math::Min() {
  numbers=($@)
  i=0
  min=''
  len=${#numbers[@]}
  
  while [[ $i -lt $len ]]; do
    if [ -z ${min} ]; then
      min="${numbers[$i]}"
    fi

    if [[ $(echo "${numbers[$i]} < ${min}" | bc -l ) -eq 1 ]]; then
      min="${numbers[$i]}"
    fi

    : $[ i++ ]
  done;
  
  echo $min
}

function Math::Mean() {
  numbers=($@)
  i=0
  total=0
  len=${#numbers[@]}
  while [[ $i -lt $len ]]; do
    total=$(( total + ${numbers[$i]} ))
    : $[ i++ ]
  done;
  if [[ "${total}" -eq 0 ]]; then
    echo "Total ${total}"
    echo 0
    return 0
  else
    echo "scale=10; ${total} / ${len}" | bc -l
    return 0
  fi
}

function Math::Floor() {
  tmp=$(echo "scale=0; $1 - ($1 % 1)" | bc -l)
  echo ${tmp%.*}
}


function Math::hex_to_dec() {
  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  echo "ibase=16; ${hex}" | bc
}

function Math::dec_to_hex() {
  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  echo "obase=16; ${hex}" | bc
}

function AlfredBundler::icon() {

  # Set font name
  if [ ! -z "$1" ]; then
    font="$1"
  else
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" &2>
    return 1
  fi

  # Set icon name
  if [ ! -z "$2" ]; then
    name="$2"
  else
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" &2>
    return 1
  fi

  # Set color or default to black
  if [ ! -z "$3" ]; then
    color="$3"
  else
    color="000000"
  fi

  # See if the alter variable is set
  if [ ! -z "$4" ]; then
    alter="$4"
  elif [[ -z "$3" ]] && [[ -z "$4" ]]; then
    alter="TRUE"
  else
    alter="FALSE"
  fi

  # Path to base of bundler directory
  local path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
  # Get the major version from the file
  local major_version=$(cat "${path}/meta/version_major")
  # Set the data directory
  local data="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${major_version}"

  # For now we're hardcoding this, but we should cycle through the icons
  local icon_server='http://icons.deanishe.net/icon'

}

# Caching wrapper around the real function
function AlfredBundler::load_asset {
  # $1 -- asset name
  # $2 -- version
  # $3 -- bundle
  # $4 -- type
  # $5 -- json (file-path)

  local name="$1"
  local version="$2"
  local bundle="$3"
  local type="$4"
  local json="$5"
  local cachepath
  local key
  local path
  local status

  # Icons
  #------------------------------------------------------------

  if [[ "${type}" = 'icon' ]]; then
    local icon="$1"
    local font="$2"
    local colour="$5"
    local url=

    local icondir="${__data}/data/assets/icons/${font}/${colour}"
    local path="${icondir}/${icon}.png"

    # Return path to file if it exists
    if [[ -f "$path" ]]; then
      echo "$path"
      return 0
    fi

    # Download icon from web service and cache it
    url="${bd_icon_server_url}/${font}/${colour}/${icon}"

    # Create parent directory if necessary
    [[ ! -d "${icondir}" ]] && mkdir -p "${icondir}"

    curl -fsSL "$url" > "${path}"
    status=$?

    if [[ $status -eq 0 ]]; then
      echo "${path}"
    else
      # Delete empty/corrupt file if it exists
      [[ -f "$path" ]] && rm -f "$path"
      echo "Error retrieving ${url}. cURL exited with ${status}"
    fi
    return $status
  fi

  # Other assets
  #------------------------------------------------------------

  # Cache path for this call
  key=$(md5 -q -s "${name}-${version}-${type}-${json}")
  cachepath="${bd_asset_cache}/${key}"

  # Load result from cache if it exists
  if [[ -f "${cachepath}" ]]; then
    path=$(cat "${cachepath}")
    if [[ -f "${path}" ]] || [[ -d "${path}" ]]; then
      echo "$path"
      return 0
    fi
  fi

  # Create cache directory if it doesn't exist
  [[ ! -d "${bd_asset_cache}" ]] && mkdir -p "${bd_asset_cache}"

  # No valid cache, call real function and cache that result
  path=$(AlfredBundler::load_asset_inner "${name}" "${version}" "${bundle}" "${type}" "${json}")
  status=$?
  [[ $status -gt 0 ]] && return $status
  echo "${path}" > "${cachepath}"
  echo "${path}"
  return 0
}

function AlfredBundler::load_asset_inner {
  # $1 -- asset name
  # $2 -- version
  # $3 -- bundle
  # $4 -- type
  # $5 -- json (file-path)

  local name="$1"
  local version="$2"
  local bundle="$3"
  local type="$4"
  local json="$5"

  if [ -f "$__data/data/assets/$type/$name/$version/invoke" ]; then
    invoke=$(cat "$__data/data/assets/$type/$name/$version/invoke")
    if [ "$invoke" = 'null' ]; then
      invoke=''
    fi
    if [ "$type" = 'utility' ]; then
      if [[ "$invoke" =~ \.app ]]; then
        # Call Gatekeeper for the utility on if '.app' is in the name
        bash "$__data/bundler/includes/gatekeeper.sh" "$name" "$__data/data/assets/$type/$name/$version/$name.app"  > /dev/null
        status=$?
        [[ $status -gt 0 ]] && echo "User denied whitelisting $name" && return $status
      fi
    fi
    echo "$__data/data/assets/$type/$name/$version/$invoke"
    if [[ ! -z $bundle ]] && [[ $bundle != '..' ]]; then
      php "$__data/bundler/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
    fi
    return 0
  fi
  # There is no JSON passed to us, so find it in the defaults.
  if [ -z "$json" ]; then
    json="$__data/bundler/meta/defaults/$name.json"
  fi
  # The $json variable should contain either the path to the default or the user-provided path.
  if [ -f "$json" ]; then
    # Take advantage of the PHP script to install the asset.
    php "$__data/bundler/includes/installAsset.php" "$json" "$version"
    if [ ! -z "$result" ]; then
      echo "$result"
      return 0
    fi
    if [ -f "$__data/data/assets/$type/$name/$version/invoke" ]; then
      invoke=`cat "$__data/data/assets/$type/$name/$version/invoke"`
      if [ "$invoke" = 'null' ]; then
        invoke=''
      fi
      echo "$__data/data/assets/$type/$name/$version/$invoke"
      if [[ ! -z "$bundle" ]] && [[ "$bundle" != '..' ]]; then
        php "$__data/bundler/includes/registry.php" "$bundle" "$name" "$version" > /dev/null &
      fi
      if [ $type = 'utility' ]; then
        if [ ! -z "$invoke" ]; then
          if [[ "$invoke" =~ \.app ]]; then
            # Call Gatekeeper for the utility on if '.app' is in the name
            bash "$__data/bundler/includes/gatekeeper.sh" "$name" "$__data/data/assets/$type/$name/$version/$invoke" > /dev/null
            status=$?
            [[ $status -gt 0 ]] && echo "User denied whitelisting $name" && return $status
          fi
        fi
      fi
      return 0
    fi
  else
    echo "JSON file does not exist : $json"
    return 1
  fi
  echo "You've encountered a problem with the __implementation__ of the Alfred Bundler; please let the workflow author know."
  return 1
}
