#!/bin/bash

usage="Usage: package_image.sh image_root cpio_filename_absolute"
image_root=$1
target=$2


if [ -z $image_root ] || [ ! -d $image_root ]; then
    echo >&2 "error: image root not given or not found. Aborting"
    echo >&2 $usage
    exit 1
fi

if [ -z $target ]; then
    echo >&2 "error: filename of the cpio archive to be created not given. Aborting"
    echo >&2 $usage
    exit 1
fi

if [[ ! $target = /* ]]; then
    echo >&2 "error: filename of the cpio archive to be created is not an absolute path. Aborting"
    exit 1
fi

# do this in a sub-shell to avoid changing directory.
(cd $image_root && find . -print0 | cpio --null -ov --format=newc | gzip -9 > $target)
