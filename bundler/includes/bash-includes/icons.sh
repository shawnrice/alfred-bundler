################################################################################
### Functions to support icon manipulation
################################################################################

#######################################
# Checks and normalizes hex colors
# Globals:
#   None
# Arguments:
#   color
# Returns:
#   Normalized hex color
#######################################
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

#######################################
# Lightens or darks a hex color
# Globals:
#   None
# Arguments:
#   color
#   alter
# Returns:
#   Hex color
#######################################
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

    if [[ -f "${AB_DATA}/data/color-cache/${color}" ]]; then
      echo $(cat "${AB_DATA}/data/color-cache/${color}")
      return 0
    fi

    # Since they're the same, we'll alter the color
    if [ $2 == "TRUE" ]; then
      tmpcolor=$(echo "${color}" | tr [[:upper:]] [[:lower:]])
      color=$(AlfredBundler::hex_to_rgb ${color})
      color=($(AlfredBundler::rgb_to_hsv ${color}))
      color=(${color[0]} ${color[1]} $(echo "scale=10; 1 - ${color[2]}" | bc -l))
      color=$(AlfredBundler::hsv_to_rgb ${color[@]})
      color=$(AlfredBundler::rgb_to_hex ${color[@]})
      echo "${color}" | tr [[:upper:]] [[:lower:]] > "${AB_DATA}/data/color-cache/${tmpcolor}"
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

#######################################
# Get the background "color" of the current Alfred theme
# Globals:
#   AB_DATA
#   HOME
# Arguments:
#   None
# Returns:
#   'light' or 'dark'
#######################################
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

#######################################
# Checks whether a color is light or dark
# Globals:
#   None
# Arguments:
#   color
# Returns:
#   'light' or 'dark'
#######################################
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

#######################################
# Converts an RGB color to HSV
# Globals:
#   None
# Arguments:
#   R
#   G
#   B
# Returns:
#   An HSV representation of a color
#######################################
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

#######################################
# Converts HSV to RGB
# Globals:
#   None
# Arguments:
#   H
#   S
#   V
# Returns:
#   A color represented in RGB
#######################################
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

#######################################
# Converts Hex color to RGB
# Globals:
#   None
# Arguments:
#   hex
# Returns:
#   A color in RGB
#######################################
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

#######################################
# Converts RGB color to Hex
# Globals:
#   None
# Arguments:
#   R
#   G
#   B
# Returns:
#   A color in hex
#######################################
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
