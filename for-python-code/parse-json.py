#!/bin/python

import json, sys, os
from pprint import pprint

if len(sys.argv) > 1:
  parts   = sys.argv[1].split(".")
if len(sys.argv) > 2:
  version = sys.argv[2]

if len(parts) == 2:
  if parts[1] != "json":
    print ""
    sys.exit()
if os.path.isfile(sys.argv[1]):
  json_data = json.loads(open(sys.argv[1]).read())
  for urls in json_data["urls"]:
    extensions = urls["filename"].split(".")
    if extensions[len(extensions)-1] == "gz":
      download_url = urls["url"]
    try:
      download_url
    except NameError:
      # Fallback to zip
      if extensions[len(extensions)-1] == "zip":
        download_url = urls["url"]
else:
  print ""
  sys.exit()

try:
  print download_url
except NameError:
  print ""
