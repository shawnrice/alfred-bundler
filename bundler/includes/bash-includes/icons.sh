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
    echo $@ #send the arguments back
    return 0
  fi
  color="$1"

  if [[ "$2" == "FALSE" ]]; then
    echo "${color}"
    return 0
  fi

  if [[ $(AlfredBundler::get_brightness "${color}") == $(AlfredBundler::get_background) ]]; then

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

  r="$1"
  g="$2"
  b="$3"

  min='0'
  max='0'
  min=$(Math::Min $r $g $b)
  max=$(Math::Max $r $g $b)
  chroma=$(Math::Minus $max $min)

  if [[ $(Math::Equals $chroma 0) -eq 1 ]]; then
    echo 0 0 $(Math::Divide $max 255)
    return 0
  fi

  if [[ $r -eq $max ]]; then
    h=$(( g - b ))
    h=$(Math::Divide $h $chroma)

    if [[ $(Math::LT $h 0 ) -eq 1 ]]; then
      h=$(Math::Plus $h 6)
    fi
  elif [[ $g -eq $max ]]; then
    h=$(( b - r ))
    h=$(Math::Divide $h $chroma)
    h=$(Math::Plus $h 2)
  else
    h=$(( r - g ))
    h=$(Math::Divide $h $chroma)
    h=$(Math::Plus $h 4)
  fi

  h=$(Math::Times $h 60)
  s=$(Math::Divide $chroma $max)
  v=$(Math::Divide $max 255)

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
  local x
  local min
  local chroma

  h="$1"
  s="$2"
  v="$3"

  r='0'
  g='0'
  b='0'

  chroma=$(Math::Times $s $v )
  h=$(Math::Divide $h 60 )

  # We need to get the x value through the following formula
  # (from the PHP)  $x = $chroma * ( 1.0 - abs( ( fmod( $h, 2.0 ) ) - 1.0 ) );
  # So, let's do that in steps.
  x=$(Math::Mod $h 2)
  x=$(Math::Minus $x 1)
  x=$(Math::Abs $x)
  x=$(Math::Minus 1 $x)
  x=$(Math::Times $chroma $x)

  min=$(Math::Minus $v $chroma)

  if [[ $(Math::LT $h 1) == '1' ]]; then
    r=$chroma
    g=$x
  elif [[ $(Math::LT $h 2) == '1' ]]; then
    r=$x
    g=$chroma
  elif [[ $(Math::LT $h 3) == '1' ]]; then
    g=$chroma
    b=$x
  elif [[ $(Math::LT $h 4) == '1' ]]; then
    g=$x
    b=$chroma
  elif [[ $(Math::LT $h 5) == '1' ]]; then
    r=$x
    b=$chroma
  else
    r=$chroma
    b=$x
  fi

  # $r = round( ( $r + $min ) * 255 );
  r=$(Math::Plus $r $min)
  g=$(Math::Plus $g $min)
  b=$(Math::Plus $b $min)
  r=$(Math::Times $r 255)
  g=$(Math::Times $g 255)
  b=$(Math::Times $b 255)
  r=$(Math::Round $r)
  g=$(Math::Round $g)
  b=$(Math::Round $b)

  echo "${r} ${g} ${b}"
  return 0
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

  echo "${r}${g}${b}" | tr [[:upper:]] [[:lower:]]
}



function AlfredBundler::get_luminance() {

    local hex="$1"
    local rgb=$(AlfredBundler::hex_to_rgb $hex)
    local r=${rgb[0]}
    local g=${rgb[1]}
    local b=${rgb[2]}
    r=$(Math::Times $r .299)
    g=$(Math::Times $g .587)
    b=$(Math::Times $b .114)
    r=$(Math::Plus $r $g)
    r=$(Math::Plus $r $b)
    echo $(Math::Divide $r 255)
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
function AlfredBundler::get_brightness() {
  local luminance=$(AlfredBundler::get_luminance "$1")
  if [[ $(Math::GT $luminance .5) == '1' ]]; then
    echo 'light'
  else
    echo 'dark'
  fi

  return 0
}


###############################################################################
### End Icon Functions
###############################################################################
