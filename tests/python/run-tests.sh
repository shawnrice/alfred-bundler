#!/bin/bash
# Copied from flask-login
# https://github.com/maxcountryman/flask-login

# OUTPUT_PATH=$(pwd)/tests_output

# DEFAULT_BRANCH="devel"

# [[ -z "$AB_BRANCH" ]] && export AB_BRANCH=$DEFAULT_BRANCH

LOGPATH="$(pwd)/test.log"

function log() {
    echo "$@" | tee -a $LOGPATH
}

rm -rf $LOGPATH

here=$(dirname "$0")

cd "$here"

NOSETEST_OPTIONS="-d"

if [ -n "$VERBOSE" ]; then
    NOSETEST_OPTIONS="$NOSETEST_OPTIONS --verbose"
fi

if [ -z "$NOCOLOR" ]; then
    NOSETEST_OPTIONS="$NOSETEST_OPTIONS --with-yanc --yanc-color=on"
fi

if [ -n "$OPTIONS" ]; then
    NOSETEST_OPTIONS="$NOSETEST_OPTIONS $OPTIONS"
fi

if [ -n "$TESTS" ]; then
    NOSETEST_OPTIONS="$NOSETEST_OPTIONS $TESTS"
else
    NOSETEST_OPTIONS="$NOSETEST_OPTIONS -v --with-coverage --cover-min-percentage=100 --cover-package=pybundler.AlfredBundler --cover-package=pybundler.bundler --cover-erase --logging-clear-handlers"
fi

log "Running tests..."

nosetests $NOSETEST_OPTIONS 2>&1 | tee -a $LOGPATH
ret=${PIPESTATUS[0]}

echo

case "$ret" in
    0) log -e "SUCCESS" ;;
    *) log -e "FAILURE" ;;
esac

cd -

exit $ret
