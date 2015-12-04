#!/bin/bash
set -eu -o pipefail

readonly verbose="n"

readonly usage="Usage: create_image_fs.sh image_root packages_dir"
if [ $# -ne 2 ]; then
    echo $usage >&2
    echo "ERROR: wrong number of parameters" >&2
    exit 1
fi

declare image_root=$1
declare packages_dir=$2

# get absolute path to the dir containing the scripts
declare scripts_dir="$(dirname "$0")/"
pushd . > /dev/null
cd $scripts_dir
declare -r scripts_dir="$(pwd)/"
popd > /dev/null

# load utility function definitions
. ${scripts_dir}/utils.sh

trap 'fail "caught signal"' HUP KILL QUIT

# check parameters
[ -n $image_root ] || fail "$image_root not given"

is_dir packages_dir

declare -r packages_dir=$(absolute_path $packages_dir)

# clean the image root
if [ -d $image_root ]; then
    declare -r image_root=$(absolute_path $image_root)
    echo "cleaning $image_root"
    rm -r $image_root
    mkdir $image_root
else
    # if $image_root is not an existing dir, check whether its parent exists.
    readonly root_parent=$(dirname "$image_root")
    [ -d $root_parent ] || fail "directory $root_parent not found"
    mkdir $image_root
    declare -r image_root=$(absolute_path $image_root)
fi


# create the basic fs structure
mkdir -p ${image_root}/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys}

# install packages
inst_packages() {
    local p dir script
    for p in $(ls -1 ${packages_dir}/); do
        dir="${packages_dir}/$p/"
        if [ -d $dir ]; then
            script="$dir/$(basename $dir).sh"
            ( cd $dir; . $script ) || fail "running $script failed"
        fi
    done
}
inst_packages
