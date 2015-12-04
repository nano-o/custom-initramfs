#!/bin/bash
set -eu -o pipefail

readonly verbose="n"

readonly usage="Usage: create_image_fs.sh image_root image_files_dir packages_dir"
if [ $# -ne 3 ]; then
    echo $usage >&2
    echo "ERROR: wrong number of parameters" >&2
    exit 1
fi

declare image_root=$1
declare image_files=$2
declare packages_dir=$3
declare scripts_dir=$(pwd)

# load utility function definitions
. ${scripts_dir}/utils.sh

trap 'fail "caught signal"' HUP KILL QUIT

# check parameters
if [ -z $image_root ]; then
    fail "image root not given"
fi

if [ -z $image_files ] || [ ! -d $image_files ]; then
    fail "image files directory not given or not found"
fi

if [ -z $packages_dir ] || [ ! -d $packages_dir ]; then
    fail "image files directory not given or not found"
fi

declare -r image_files=$(absolute_path $image_files)
declare -r packages_dir=$(absolute_path $packages_dir)

# clean the image root
if [ -d $image_root ]; then
    echo "cleaning $image_root"
    rm -r $image_root
else
    # if $image_root is not an existing dir, check whether its parent exists.
    dirname=$(dirname "$image_root")
    if [ ! -d $dirname ]; then
        fail "$dirname does not exist"
    fi
fi
mkdir $image_root

declare -r image_root=$(absolute_path $image_root)

# create the basic fs structure
mkdir -p ${image_root}/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys}

# install packages
for p in $(ls -1 ${packages_dir}/); do
    dir="${packages_dir}/$p/"
    if [ -d $dir ]; then
        script="$dir/$(basename $dir).sh"
        ( cd $dir; . $script)
    fi
done

# copy file from $image_file
files="tunnelize.sh tunnel heartbeat"
for f in $files; do
    source=${image_files}"/""$f"
    if [ ! -f $source ]; then
        fail "$source not found"
        exit 1
    fi
    target=${image_root}"/""$f"
    dir=$(dirname "$target")
    mkdir -p $dir
    cp $source $target
done

