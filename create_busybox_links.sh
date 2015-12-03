#!/bin/bash

verbose="n"

# $1 is the root of the image
image_root=$1

# location of busybox on the fs of the image:
busybox=$2

busybox_target=${image_root}$busybox

if [ ! -f $busybox_target ]; then
    echo "error: busybox has not been copied to the image. Aborting."
    exit 1
fi

list=`busybox --list-all`

for f in $list; do
    target=${image_root}/$f
    dirname=$(dirname "$target")
    if [ ! -d "$dirname" ]; then
        [ "${verbose}" = "y" ] && echo "creating directory $dirname"
        mkdir -p "$dirname"
    fi
    [ "${verbose}" = "y" ] && echo "creating symlink $target"
    ln -s $busybox $target
done
