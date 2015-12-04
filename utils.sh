#!/bin/bash
set -eu -o pipefail

fail() {
    echo "ERROR: ${1}. Aborting" >&2
    exit 1
} 

absolute_path() {
    [ ! -d $1 ] && fail "not a directory: $1"
    pushd . > /dev/null
    cd $1
    echo "$(pwd)/"
    popd > /dev/null
}

