#!/bin/bash

version='aries'

dirs=("${HOME}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/alfred.bundler-${version}"
      "${HOME}/Library/Application Support/Alfred 2/Workflow Data/alfred.bundler-${version}")

for path in "${dirs[@]}"; do
	[[ -d "${path}" ]] && echo "Deleting ${path} ..." && rm -rf "${path}"
done