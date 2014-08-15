################################################################################
### Start Log Functions
################################################################################

# User facing log function
function AlfredBundler::log() {
a=0
}

# Function that outputs information to the terminal (stderr)
function AlfredBundler::report() {
# Message — $1
# Level   — $2

local message
local level
local file
local line
local internal

local levels

local date

message="$1"
level="$2"

level=$(echo "${level}" | tr [[:lower:]] [[:upper:]])

[[ "${level}" == "WARN" ]] && level="WARNING"
[[ "${level}" == "FATAL" ]] && level="CRITICAL"

# @TODO : Add in better error checking for empty arguments
internal=$(caller)
line=$(echo "${internal}" | cut -d ' ' -f1)
file="${internal#${line}}"
file=$(basename "${file}")

# Define the log levels
levels=(DEBUG INFO WARNING ERROR CRITICAL)

date="["$(date +"%T")"]"

if [[ $# -lt 2 ]]; then
  echo "${date} [${file}:${line}] [DEBUG] The logging function needs to be used with a log level and message." >&2
  return 0
fi

# If the level is an int, then echo this:
if [[ $level =~ ^-?[0-9]+$ ]]; then
  if [ ! -z ${levels[level]} ]; then
    echo "${date} [${file}:${line}] [${levels[level]}] ${message}" >&2
  else
    echo "${date} [${file}:${line}] [WARNING] Invalid log level (${level}); defaulting to 'DEBUG'" >&2
    echo "${date} [${file}:${line}] [DEBUG] ${message}" >&2
  fi
 return 0
elif [[ "${levels[@]}" =~ $level ]]; then
  echo "${date} [${file}:${line}] [${level}] ${message}" >&2
  return 0
else
  echo "${date} [${file}:${line}] [WARNING] Invalid log level (${level}); defaulting to 'DEBUG'" >&2
  echo "${date} [${file}:${line}] [DEBUG] ${message}" >&2
fi


}

# Internal logging function
function AlfredBundler::internalLog() {
  local message
  local level
  local file
  local line
  local internal

  local log_path
  local log

  local date

  log="$1"
  message="$2"
  level="$3"

  log_path="${AB_DATA}/data/logs"
  if [[ ! -d "${log_path}" ]]; then
    mkdir -m 0775 -p "${log_path}"
    if [[ $? -eq 0 ]]; then
      AlfredBundler::report "Created directory '${log_path}" INFO
    else
      AlfredBundler::report "Could not create directory '${log_path}" ERROR
      return 1
    fi
  fi

  level=$(echo "${level}" | tr [[:lower:]] [[:upper:]])

  [[ "${level}" == "WARN" ]] && level="WARNING"
  [[ "${level}" == "FATAL" ]] && level="CRITICAL"

  # @TODO : Add in better error checking for empty arguments
  internal=$(caller)
  line=$(echo "${internal}" | cut -d ' ' -f1)
  file="${internal#${line} }"

  # Define the log levels
  levels=(DEBUG INFO WARNING ERROR CRITICAL)

  date=$(date +"%T")

  # If the level is an int, then echo this:
  if [[ $level =~ ^-?[0-9]+$ ]]; then
    if [ ! -z ${levels[level]} ]; then
      out="[${date}] [${file}:${line}] [${levels[level]}] ${message}"
    else
      echo "[${date}] [${file}:${line}] [WARNING] Invalid log level (${level}); defaulting to 'DEBUG'" >&2
      out="[${date}] [${file}:${line}] [DEBUG] ${message}"
    fi
  elif [[ "${levels[@]}" =~ $level ]]; then
    out="[${date}] [${file}:${line}] [${level}] ${message}"
  else
    echo "$[{date}] [${file}:${line}] [WARNING] Invalid log level (${level}); defaulting to 'DEBUG'" >&2
    out="$[{date}] [${file}:${line}] [DEBUG] ${message}"
  fi

  # need to add in error reporting and taming log size
  [[ ! -f "${log_path}/${log}.log" ]]; touch "${log_path}/${log}.log"
  AlfredBundler::prepend "${out}" "${log_path}/${log}.log"

  return 0

}

# Prepends a string to a file
function AlfredBundler::prepend() {
  # $1 line
  # $2 file
  exec 3<> "${file}" && awk -v TEXT="${line}" 'BEGIN {print TEXT}{print}' "${file}" >&3
  return 0
}

function AlfredBundler::rotate_log() {
  local log
}

################################################################################
### End Log Functions
################################################################################