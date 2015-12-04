#!/bin/bash
set -eu -o pipefail

# This script installs busybox in $image_root

command -v busybox >/dev/null 2>&1 || { echo >&2 "error: busybox is not installed.  Aborting."; exit 1; }
busybox=$(command -v busybox)

echo $(pwd)

${scripts_dir}/copy_exec.sh $busybox $image_root

# create a symlink from /init to /bin/busybox
ln -s /bin/busybox ${image_root}/init

# create a symlink for each busybox utility
( . ${scripts_dir}/create_busybox_links.sh)

# copy inittab and rc.S
files="etc/inittab etc/init.d/rc.S"
for f in $files; do
    source="./"$(basename $f)
    if [ ! -f $source ]; then
        echo >&2 "error: $source not found. Aborting"
        exit 1
    fi
    target="${image_root}/$f"
    dir=$(dirname "$target")
    mkdir -p $dir
    cp $source $target
done

# set up udhcpc
udhcpc_default_script="/etc/udhcpc/default.script"
if [ ! -f $udhcpc_default_script ]; then
    echo >&2 "error: $udhcpc_default_script not found. Aborting"
    exit 1
else
    mkdir ${image_root}"/etc/udhcpc/"
    cp $udhcpc_default_script  ${image_root}"/etc/udhcpc/"
fi
