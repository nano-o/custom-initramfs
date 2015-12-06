#!/bin/bash
# Main script to create a cpio ramdisk that can be used for booting Popcorn secondary kernels.
set -eu -o pipefail

readonly verbose="n"

if [ $# -ne 0 ]; then
    echo $usage >&2
    echo "ERROR: this script does not take any parameter. It produces a cpio initramfs name custom-initramfs.cpio.gz in the current directory." >&2
    exit 1
fi


# get absolute path to the dir containing the scripts
declare scripts_dir="$(dirname "$0")/"
pushd . > /dev/null
cd "$scripts_dir"
declare -r scripts_dir="$(pwd)/"
popd > /dev/null

# load utility function definitions
. "${scripts_dir}/utils.sh"

trap 'fail "caught signal"' HUP KILL QUIT

declare image_root="$scripts_dir/image/"
declare packages_dir="$scripts_dir/packages/"

is_dir packages_dir

declare -r packages_dir=$(absolute_path "$packages_dir")

( . "$scripts_dir/create_image_fs.sh" ) || fail "$scripts_dir/create_image_fs.sh failed"
( . "$scripts_dir/package_image.sh" "$scripts_dir/custom-initramfs.cpio.gz") || fail "$scripts_dir/package_image.sh failed"
