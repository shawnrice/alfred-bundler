#!/bin/bash
# Build documentation for the Python version with `sphinx`

root=$(cd $(dirname "$0"); pwd)
docdir=${root}/pydoc
curdir=$(pwd)

cd ${docdir}
make singlehtml
cd ${curdir}
