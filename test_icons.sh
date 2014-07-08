#!/bin/bash

wrapper=wrappers/alfred.bundler.misc.sh

function load_icon() {
  local status
  local path
  local icon="$1"
  local font="$2"
  local colour="$3"
  /bin/bash "$wrapper" "${icon}" "${font}" icon "${colour}"
  return $?
}

function test_api() {
  icon=$(load_icon $1 $2 $3)
  status=$?
  echo "\$status : $status"
  echo "\$icon   : $icon"
  open -a Preview "$icon"
}

test_api thumbs-up fontawesome f00
test_api thumbs-up fontawesome 0f0
test_api thumbs-up fontawesome 00f
test_api thumbs-up fontawesome ff0
test_api thumbs-up fontawesome 0ff
test_api thumbs-up fontawesome f0f