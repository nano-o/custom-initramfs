#!/bin/bash

usage="Usage: create_image_fs.sh image_root image_files_dir"
image_root=$1
image_files=$2

if [ -z $image_root ]; then
    echo >&2 "error: image root not given. Aborting"
    echo >&2 $usage
    exit 1
fi

if [ -z $image_files ] || [ ! -d $image_files ]; then
    echo >&2 "error: image files directory not given or not found. Aborting"
    echo >&2 $usage
    exit 1
fi

# first clean the image root
if [ -d $image_root ]; then
    echo "cleaning $image_root"
    rm -r $image_root
else
    dirname=$(dirname "$image_root")
    if [ ! -d $dirname ]; then
        echo >&2 "error: $dirname does not exist. Aborting"
        exit 1
    fi
fi

mkdir $image_root
mkdir -p ${image_root}/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys}

# copy file from $image_file
files="etc/inittab etc/init.d/rc.S"
for f in $files; do
    source=${image_files}"/""$f"
    if [ ! -f $source ]; then
        echo >&2 "error: $source not found. Aborting"
        exit 1
    fi
    target=${image_root}"/""$f"
    dir=$(dirname "$target")
    mkdir -p $dir
    cp $source $target
done

command -v busybox >/dev/null 2>&1 || { echo >&2 "error: busybox is not installed.  Aborting."; exit 1; }

# copy busybox from the current system
busybox="/bin/busybox"
if [ ! -f $busybox ]; then
    echo >&2 "error: $busybox not found. Aborting"
    exit 1
else
    ./copy_exec.sh $busybox $image_root
fi

# create a symlink from /init to /bin/busybox
ln -s /bin/busybox ${image_root}/init

./create_busybox_links.sh $image_root $busybox

udhcpc_default_script="/etc/udhcpc/default.script"
if [ ! -f $udhcpc_default_script ]; then
    echo >&2 "error: $udhcpc_default_script not found. Aborting"
    exit 1
else
    mkdir ${image_root}"/etc/udhcpc/"
    cp $udhcpc_default_script  ${image_root}"/etc/udhcpc/"
fi
