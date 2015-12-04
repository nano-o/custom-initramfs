#!/bin/bash
set -eu -o pipefail

usage="Usage: package_image.sh image_root cpio_filename"

if [ $# -ne 2 ]; then
    echo $usage >&2
    echo "ERROR: wrong number of parameters" >&2
    exit 1
fi

. ./utils.sh

declare image_root=$1
declare target=$2

is_dir image_root
declare -r image_root=$(absolute_path $image_root)

if [ -z $target ]; then
    echo >&2 "error: filename of the cpio archive to be created not given. Aborting"
    echo >&2 $usage
    exit 1
fi
# get the absolute path
declare -r target="$(absolute_path $(dirname $target))/$(basename $target)"

# do this in a sub-shell to avoid changing directory.
(cd $image_root && find . -print0 | cpio --null -ov --format=newc | gzip -9 > $target) || fail "creation of the cpio archive failed"
