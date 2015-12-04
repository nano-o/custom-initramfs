#!/bin/bash
set -eu -o pipefail

absolute_path() {
    pushd . > /dev/null
    cd $1
    echo "$(pwd)/"
    popd > /dev/null
}

fail() {
    echo "ERROR: ${1}. Aborting" >&2
    exit 1
} 
trap 'fail "caught signal"' HUP KILL QUIT
