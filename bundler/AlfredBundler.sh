#!/bin/bash

# Declare Bundler Constants

# Path to base of bundler directory
declare -r AB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
  # Get the major version from the file
declare -r AB_MAJOR_VERSION=$(cat "${AB_PATH}/meta/version_major")
# Set the data directory
declare -r AB_DATA="${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${AB_MAJOR_VERSION}"

# Check for updates to the bundler in the background
bash "${AB_PATH}/meta/update-wrapper.sh" > /dev/null 2>&1

################################################################################
### Begin Asset Functions
################################################################################

function AlfredBundler::icon() {

  local font
  local name
  local color
  local alter
  local icon_server
  local icon_dir
  local icon_path
  local status
  local url
  local system_icon_dir
  # Set font name
  if [ ! -z "$1" ]; then
    font=$(echo "$1" | tr [[:upper:]] [[:lower:]])
  else
    # Send error to STDERR
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" >&2
    return 1
  fi

  # Set icon name
  if [ ! -z "$2" ]; then
    name="$2"
  else
    # Send error to STDERR
    echo "ERROR: AlfredBundler::icon needs a minimum of two arguments" >&2
    return 1
  fi

  # Take care of the system font first
  if [ "${font}" == "system" ]; then
    system_icon_dir="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"
    if [ -f "${system_icon_dir}/${name}.icns" ]; then
      echo "${system_icon_dir}/${name}.icns"
      return 0
    else
      echo "ERROR: System icon '${name}' not found" >&2
      return 0
    fi
  fi

  # Set color or default to black
  if [ ! -z "$3" ]; then
    color="$3"
  else
    color="000000"
  fi

  # Normalize and check the color for valid hex
  color=$(AlfredBundler::check_hex "${color}")
  # If not a valid hex, then return 0
  [[ $? -ne 0 ]] && return 1

  # See if the alter variable is set
  if [ ! -z "$4" ]; then
    alter="$4"
  elif [[ -z "$3" ]] && [[ -z "$4" ]]; then
    alter="TRUE"
  else
    alter="FALSE"
  fi

  if [[ "${alter}" == "TRUE" ]]; then
    color=$(AlfredBundler::alter_color ${color} TRUE)
  elif [[ ! -z $(AlfredBundler::check_hex ${alter} 2> /dev/null) ]]; then
    color=$(AlfredBundler::alter_color ${color} ${alter})
  fi



  
  icon_dir="${AB_DATA}/data/assets/icons/${font}/${color}"
  icon_path="${icon_dir}/${name}.png"

  if [[ -f "${icon_path}" ]]; then
    echo "${icon_path}"
    return 0
  fi

  # Make the icon directory if it doesn't exist
  [[ ! -d "${icondir}" ]] && mkdir -m 775 -p "${icon_dir}"


  
  # 

  # i=0
  # icon_servers=$(cat meta/icon_servers)
  # len=${#icon_servers[@]}
  # success=0  

  # # Loop through the bundler servers until we get one that works
  # while [[ $i -lt $len ]]; do
  #   curl -fsSL --connect-timeout 4 "${icon-servers[$i]}" > "${icon_path}"
  #   status=$?

  #   [[ $? -eq 0 ]] && success=1 && break || echo "Error retrieving icon from ${icon_servers[$i]}. cURL exited with ${status}" >&2
  #   success=0

  #   : $[ i++ ]
  # done;

  # For now we're hardcoding this, but we should cycle through the icons
  icon_server='http://icons.deanishe.net/icon'
  # Download icon from web service and cache it
  url="${icon_server}/${font}/${color}/${name}"
  curl -fsSL "${url}" > "${icon_path}"
  status=$?

  if [[ $status -eq 0 ]]; then
    echo "${icon_path}"
  else
    # Delete empty/corrupt file if it exists
    [[ -f "${icon_path}" ]] && rm -f "${icon_path}"
    # Output the error to STDERR
    echo "Error retrieving ${url}. cURL exited with ${status}" >&2
  fi
  return $status

} # End AlfredBundler::icon

# Caching wrapper around the real function
function AlfredBundler::load {
  # $1 -- type
  # $2 -- asset name
  # $3 -- version
  # $4 -- json (file-path)

  # We need two arguments at minimum
  if [ "$#" -lt 2 ]; then
    # Send message to STDERR
    echo "Error: the load function requires a minimum of two arguments" >&2
    return 1
  fi

  # Keep the variables local so as not to interfere with the rest of the script  
  local type
  local name
  local version
  local json
  local bundle
  local asset
  local status
  local gatekeeper
  local cache_path
  local cache_dir
  local key
  local path

  # Grab the arguments
  type="$1"
  name="$2"
  version="$3"
  json="$4"

  # Set the version to default if not specified
  [[ -z "${version}" ]] && version="default"

  # Check to make sure that the json file exists
  if [ -z "${json}" ]; then
    if [ -f "${AB_DATA}/bundler/meta/defaults/${name}.json" ]; then
      # The json file is a default
      json="${AB_DATA}/bundler/meta/defaults/${name}.json"
    else
      # Send error message to STDERR
      echo "Error: no valid JSON file found. This is a problem with the "\
           "__implementation__ with the Alfred Bundler. Please let the "\
           "workflow author know." >&2
      return 1
    fi
  else
    # Trying to use custom json
    if [ ! -f "${json}" ]; then
      # json file does not exist; send error message to STDERR
      echo "Error: no valid JSON file found. This is a problem with the "\
           "__implementation__ with the Alfred Bundler. Please let the "\
           "workflow author know." >&2
      return 1
    fi
  fi

  # Grab the bundle id (if possible)
  if [ -f 'info.plist' ]; then
    bundle=$(/usr/libexec/PlistBuddy -c 'print :bundleid' 'info.plist')
  elif [ -f '../info.plist' ]; then
    bundle=$(/usr/libexec/PlistBuddy -c 'print :bundleid' '../info.plist')
  else
    bundle=''
  fi


  # Handle non-utilities first
  if [ "${type}" != "utility" ]; then
    # There shouldn't be too many things that the bash bundler should need from here...
    # but, why not?
    if [ -f "${AB_DATA}/data/assets/${type}/${name}/${version}/invoke" ]; then

      # Register the asset
      bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' \
           "${AB_DATA}/bundler/includes/registry.php" \
           "${bundle}" "${name}" "${version}"

      # Return the path
      echo "${AB_DATA}/data/assets/${type}/${name}/${version}/"$(cat "${AB_DATA}/data/assets/${type}/${name}/${version}/invoke")
      return 0
    else
      # Install the asset
      php "${AB_DATA}/bundler/includes/install-asset.php" "${json}" "${version}"

      # If the install script exited with a non-zero status, then return 1;
      # the error messages were written to STDERR by the install script.
      status=$?
      [[ $status -ne 0 ]] && return 1

      # Register the asset
      bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' \
           "${AB_DATA}/bundler/includes/registry.php" \
           "${bundle}" "${name}" "${version}"

      # Return the path
      echo "${AB_DATA}/data/assets/${type}/${name}/${version}/"$(cat "${AB_DATA}/data/assets/${type}/${name}/${version}/invoke")
      return 0
    fi
  fi

  # While not all utilities need gatekeeper, launching the php script that checks
  # if it needs gatekeeper adds extra time. So, we'll cache the paths for all
  # utilities regardless of whether or not they need gatekeeper.
  # Step 1: Check the cache
  # Step 2: Check the json for the gatekeeper flag
  # Step 3: Run gatekeeper script

  # Create cache directory if it doesn't exist
  cache_dir="${AB_DATA}/data/call-cache"
  [[ ! -d "${cache_dir}" ]] && mkdir -p -m 775 "${cache_dir}"

  # Cache path for this call
  key=$(md5 -q -s "${name}-${version}-${type}-${json}")
  cache_path="${cache_dir}/${key}"

  # Check the cache
  if [[ -f "${cache_path}" ]]; then
    path=$(cat "${cache_path}")
    if [[ -f "${path}" ]] || [[ -d "${path}" ]]; then
      # Found a valid path in the cache, return it
      echo "${path}"
      return 0
    fi
  fi

  # Read the gatekeeper flag in the json
  gatekeeper=$(php includes/read-json.php "${json}" gatekeeper | tr [[:upper:]] [[:lower:]])

  if [ "${gatekeeper}" == "false" ]; then
    path="${AB_DATA}/data/assets/${type}/${name}/${version}"
    path="${path}/"$(cat "${path}/invoke")
    echo "${path}" > "${cache_path}"

    # Register the asset
    bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' "${AB_DATA}/bundler/includes/registry.php" \
      "${bundle}" "${name}" "${version}"

    # Echo the path and return a successful status  
    echo "${path}"
    return 0
  else
    # do gatekeeper stuff here
    status=$?
    [[ $status -gt 0 ]] && return $status
    echo "${path}" > "${cache_path}"
    echo "${path}"
    return 0

    # Try to find the icon, if there is one
    # Theoretically, this function is being run by a script in the workflow's
    # root directory, so the 'icon.png' should exist (if there has been an icon
    # assigned). There is a possibility that it's being run by a script not in
    # the workflow root directory, so, as a backup, we'll look one level below.
    [[ -f 'icon.png' ]] && icon=$(pwd -P)"/icon.png"
    [[ -f '../icon.png' ]] && icon=$(pwd -P)"/../icon.png"

    # Call gatekeeper
    bash "${AB_DATA}/includes/gatekeeper.sh" "${name}" "${path}" "${message}" "${icon}" "${bundle}"
    # get response and do the rest of the handling.
    status=$?
    [[ $status -gt 0 ]] && echo "User denied whitelisting $name" && return $status
    
    # If we're here, then the user whitelisted the application.
    path="${AB_DATA}/data/assets/${type}/${name}/${version}"
    path="${path}/"$(cat "${path}/invoke")
    echo "${path}" > "${cache_path}"

    # Register the asset
    bash "${AB_DATA}/bundler/meta/fork.sh" '/usr/bin/php' "${AB_DATA}/bundler/includes/registry.php" \
      "${bundle}" "${name}" "${version}"

    # Echo the path and return a successful status  
    echo "${path}"
    return 0

  fi

  # Send message to STDERR
  echo "You've encountered a problem with the __implementation__ of"\
        "the Alfred Bundler; please let the workflow author know." >&2
  return 1

} # End AlfredBundler::load

function AlfredBundler::utility() {
a=1
} # End AlfredBundler::utility

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

################################################################################
### End Asset Functions
################################################################################

################################################################################
### Functions to support icon manipulation
################################################################################

# Checks to make sure value fed to it is a hex color and converts 3 hex to 6 hex
# Returns normalized color on success, 1 on failure
function AlfredBundler::check_hex() {
  local color
  local r
  local g
  local b
  # Make sure that we have an argument
  if [[ -z "$1" ]]; then
    echo "Error: check_hex needs 1 argument" >&2
    return 1
  fi

  color="$1"

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
    return 0
  else
    echo "Error: '${color}' is not a valid hex color" >&2
    return 1
  fi
}

# # This function should be fed only proper hex codes
# # Usage: <color> <other color|TRUE>
function AlfredBundler::alter_color() {
  
  local color

  # We need two arguments
  if [[ $# -ne 2 ]]; then
    return 0
  fi
  color="$1"

  if [[ "$2" == "FALSE" ]]; then
    echo "${color}"
    return 0
  fi

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

  local plist=$(stat -f%m "${HOME}/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist")
  local background=$(stat -f%m "${AB_DATA}/data/theme_background")
  if [[ $plist -gt $background ]]; then
    echo $("${AB_PATH}/includes/LightOrDark") > "${AB_DATA}/data/theme_background"
  fi

  background=$(cat "${AB_DATA}/data/theme_background")
  echo "${background}"
}

function AlfredBundler::check_brightness() {
  local color
  local r
  local g
  local b
  local brightness
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
  local r
  local g
  local b
  local h
  local s
  local v
  local max
  local min
  local delta

  r=$( echo "scale=10; $1 / 255" | bc -l)
  g=$( echo "scale=10; $2 / 255" | bc -l)
  b=$( echo "scale=10; $3 / 255" | bc -l)

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
  local r
  local g
  local b
  local h
  local s
  local v
  local var_1
  local var_2
  local var_3
  local var_h
  local var_i

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
  local hex
  local r
  local g
  local b

  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  r=$(Math::hex_to_dec "${hex:0:2}")
  g=$(Math::hex_to_dec "${hex:2:2}")
  b=$(Math::hex_to_dec "${hex:4:2}")

  echo "${r} ${g} ${b}"
}

function AlfredBundler::rgb_to_hex() {
  local r
  local g
  local b

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

################################################################################
### End Icon Functions
################################################################################

################################################################################
### Math Functions to help with color calculations
################################################################################

function Math::Max() {

  local numbers
  local i
  local max
  local len

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

  local numbers
  local i
  local min
  local len

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

  local numbers
  local i
  local total
  local len

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
  local tmp
  tmp=$(echo "scale=0; $1 - ($1 % 1)" | bc -l)
  echo ${tmp%.*}
}


function Math::hex_to_dec() {
  local hex
  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  echo "ibase=16; ${hex}" | bc
}

function Math::dec_to_hex() {
  local dec
  dec=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  echo "obase=16; ${dec}" | bc
}

################################################################################
### End Math Functions
################################################################################