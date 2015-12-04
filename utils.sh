#!/bin/bash
set -eu -o pipefail

fail() {
    echo "ERROR: ${1}. Aborting" >&2
    exit 1
} 

absolute_path() {
    [ -d $1 ] || fail "not a directory: $1"
    pushd . > /dev/null
    cd $1
    echo "$(pwd)/"
    popd > /dev/null
}

is_dir() {
    local dir=$1
    [ -n ${!dir} ] || fail "variable $1 is empty"
    [ -d ${!dir} ] || fail "${!dir}: directory not found (pwd is $(pwd))"
}

is_file() {
    local file=$1
    [ -n ${!file} ] || fail "variable $1 is empty"
    [ -f ${!file} ] || fail "${!dir}: file not found (pwd is $(pwd))"
}
