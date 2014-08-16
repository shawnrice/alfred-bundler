#!/bin/bash
#
# A basic floating point math library
#
# This file is part of the Alfred Bundler, released under the MIT licence.
#
# Copyright (c) 2014 The Alfred Bundler Team
#
# See https://github.com/shawnrice/alfred-bundler for more information.

###############################################################################
### Math Functions to help with color calculations
###############################################################################

#######################################
# Finds the max value among a set of numbers
# Globals:
#   None
# Arguments:
#   numbers
# Returns:
#   The largest number
#######################################
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

#######################################
# Finds the min value among a set of numbers
# Globals:
#   None
# Arguments:
#   numbers
# Returns:
#   The lowest number
#######################################
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

#######################################
# Finds the mean value of a set of numbers
# Globals:
#   None
# Arguments:
#   numbers
# Returns:
#   The average of the numbers
#######################################
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

#######################################
# Truncates a float to an int
# Globals:
#   None
# Arguments:
#   float
# Returns:
#   Integer
#######################################
function Math::Floor() {
  local tmp
  tmp=$(echo "scale=0; $1 - ($1 % 1)" | bc -l)
  echo ${tmp%.*}
}

#######################################
# Rounds a float to nearest int
# Globals:
#   None
# Arguments:
#   float
# Returns:
#   Integer
#######################################
function Math::Round() {
  echo "scale=0; ($1 + .5) / 1" | bc -l
}

#######################################
# Multiplies two floats
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Times() {
  echo "scale=10; $1 * $2" | bc -l
}

#######################################
# Divides two floats
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Divide() {
  echo "scale=10; $1 / $2" | bc -l
}

#######################################
# Return the absolute value of a number
# Globals:
#   None
# Arguments:
#   float|int
# Returns:
#   float|int
#######################################
function Math::Abs() {
  local var="$1"
  echo ${var#-}
}

#######################################
# Modulous from two floats
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Mod() {
  local division=$(echo "scale=10; $1 / $2" | bc -l)
  local whole=${division%\.*}
  if [ -z $whole ]; then
    whole='0'
  fi
  echo "scale=10; $1 - (${whole} * $2 )" | bc -l
}

#######################################
# Adds two floats
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Plus() {
  echo "scale=10; $1 + $2" | bc -l
}

#######################################
# Subtracts one float from another
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Minus() {
  echo "scale=10; $1 - $2" | bc -l
}

#######################################
# Checks if one float is less than another
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::LT() {
  echo "$1 < $2" | bc -l
}

#######################################
# Checks if one float is greater than another
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::GT() {
  echo "$1 > $2" | bc -l
}

#######################################
# Checks if one float is equal to another
# Globals:
#   None
# Arguments:
#   float|int float|int
# Returns:
#   float
#######################################
function Math::Equals() {
  echo "$1 == $2" | bc -l
}

#######################################
# Converts base 16 to base 10
# Globals:
#   None
# Arguments:
#   hex
# Returns:
#   Number in base 10
#######################################
function Math::hex_to_dec() {
  local hex
  hex=$(echo "$1" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  echo "ibase=16; ${hex}" | bc
}

#######################################
# Converts base 10 to base 16
# Globals:
#   None
# Arguments:
#   dec
# Returns:
#   Number in base 16
#######################################
function Math::dec_to_hex() {
  local dec
  dec=$(echo "${1}" | tr [[:lower:]] [[:upper:]]) # needs to be uppercase
  dec=$(echo "${dec%\.*}")
  echo "obase=16; ${dec}" | bc
}

################################################################################
### End Math Functions
################################################################################