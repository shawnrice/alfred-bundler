# Functions in this should be prepended with AB::Log::
#
################################################################################
### Start Log Functions
################################################################################

# User facing log function
# Currently, this is a duplicate of the internal one... but I need to
# figure out a way to combine them that doesn't hurt the call syntax much...
function AlfredBundler::Log() {

  local message
  local level
  local file
  local line
  local internal
  local date

  # Set necessary variables
  date=$(date +%H:%M:%S)
  internal=$(caller)
  line=$(echo "${internal}" | cut -d ' ' -f1)
  file="${internal#${line}}"
  file=$(basename "${file}")

  # Check to see if we have the right number of arguments
  if [[ $# -lt 2 ]]; then
    echo "[${date}] [${file}:${line}] [DEBUG] The logging function needs to " \
        "be used with a log level and message." >&2
    return 0
  fi

   # Set the arguments
  message="$1"

  level=$(AB::Log::normalize_log_level "$2")
  # Check for valid log level
  if [[ $? -eq 1 ]]; then
    echo "[${date}] [${file}:${line}] [WARNING] Log level '$2' is not valid. " \
         "Falling back to 'INFO' (1)" >&2
  fi

  [[ -z "${destination}" ]] && destination='console'
  destination=$(AB::Log::normalize_destination $3)
  # Check for valid destination
  if [[ $? -eq 1 ]]; then
    echo "[${date}] [${file}:${line}] [WARNING] Destination '$2' is not " \
         "valid. Falling back to 'console'" >&2
  fi

  message="[${file}:${line}] [${level}] ${message}"

  if [[ "${destination}" == 'console' ]] || [[ "${destination}" == 'both' ]]; then
    AB::Log::Console "${message}"
  fi
  if [[ "${destination}" == 'file' ]] || [[ "${destination}" == 'both' ]]; then
    AB::Log::File "${message}" "${WF_LOG}"
  fi

}

function AB::Log::Log() {
  local message
  local level
  local file
  local line
  local internal
  local date

  # Set necessary variables
  date=$(date +%H:%M:%S)
  internal=$(caller)
  line=$(echo "${internal}" | cut -d ' ' -f1)
  file="${internal#${line}}"
  file=${file## } # remove whitespace from the front
  file=$(basename "${file}")

  # Check to see if we have the right number of arguments
  if [[ $# -lt 2 ]]; then
    echo "[${date}] [${file}:${line}] [DEBUG] The logging function needs to " \
        "be used with a log level and message." >&2
    return 0
  fi

  # Set the arguments
  message="$1"

  level=$(AB::Log::normalize_log_level "$2")
  # Check for valid log level
  if [[ $? -eq 1 ]]; then
    echo "[${date}] [${file}:${line}] [WARNING] Log level '$2' is not valid. " \
         "Falling back to 'INFO' (1)" >&2
  fi

  [[ -z "${destination}" ]] && destination='console'
  destination=$(AB::Log::normalize_destination $3)
  # Check for valid destination
  if [[ $? -eq 1 ]]; then
    echo "[${date}] [${file}:${line}] [WARNING] Destination '$2' is not " \
         "valid. Falling back to 'console'" >&2
  fi

  message="[${file}:${line}] [${level}] ${message}"

  if [[ "${destination}" == 'console' ]] || [[ "${destination}" == 'both' ]]; then
    AB::Log::Console "${message}"
  fi
  if [[ "${destination}" == 'file' ]] || [[ "${destination}" == 'both' ]]; then
    AB::Log::File "${message}" "${AB_LOG}"
  fi
}





# Function that outputs information to the terminal (STDERR)
function AB::Log::Console() {
  # Message — $1
  local date=$(date +%H:%M:%S)
  echo "[${date}] $1" >&2
  return 0
}

function AB::Log::File() {
  local date=$(date +"%Y-%m-%d %H:%M:%S")
  local message="$1"
  local log="$2"

  if [[ ! -d $(dirname "${log}") ]]; then
    AB::Log::Log "Log directory '${log}' does not exist" ERROR console
    return 1
  fi

  echo "[${date}] ${message}" >> "${log}"
  return 0
}

# Make log directories
function AB::Log::Setup() {
  # This is internal setup...
  if [[ ! -e "${AB_LOG}" ]]; then
    mkdir -m 0775 -p "${AB_LOG}"
    if [[ $? -eq 0 ]]; then
      AB::Log::Log "Created directory '${AB_LOG}'" INFO console
      return 0
    else
      AB::Log::Log "Could not create directory '${AB_LOG}'" ERROR console
      return 1
    fi
  fi
}

function AB::Log::normalize_destination() {
  local destination=$(echo "$1" | tr [[:upper:]] [[:lower:]])
  local destinations=(file console both)
  [[ "${destinations[@]}" =~ $destination ]] && echo $destination && return 0
  # Log an error here and set the destination to console
  echo 'console'
  return 1
}



function AB::Log::normalize_log_level() {
  local levels
  local level

  # Define the log levels
  levels=(DEBUG INFO WARNING ERROR CRITICAL)
  level=$(echo "$1" | tr [[:lower:]] [[:upper:]])

  [[ "${level}" == "WARN" ]] && level="WARNING"
  [[ "${level}" == "FATAL" ]] && level="CRITICAL"

  # If the level is an int, then echo this:
  if [[ $level =~ ^-?[0-9]+$ ]]; then
    if [ ! -z ${levels[level]} ]; then
      echo ${levels[level]}
      return 0
    else
      echo 'INFO'
      return 1
    fi
  elif [[ "${levels[@]}" =~ $level ]]; then
    echo $level
    return 0
  else
    echo 'INFO'
    return 1
  fi
}


function AB::Log::Rotate() {
  local name
  local dir

  [[ ! -f "$1" ]] && return 0 # There is no log file to rotate
  if [[ $(stat -f "%z" "$1") -gt 1048576 ]]; then
    name=$(basename "$1")
    name=$(name%\.log)
    dir=$(dirname "$1")
    mv -f "$1" "${dir}/${name}1.log"
    AB::Log::Log "Rotated log '${name}.log" INFO console
  fi
  touch "$1"

  return 0
}


################################################################################
### End Log Functions
################################################################################