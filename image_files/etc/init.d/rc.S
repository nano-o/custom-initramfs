#!/bin/busybox sh
 
# Mount the /proc and /sys filesystems.
mount -t proc none /proc
mount -t sysfs none /sys
# Populate /dev
mount -t devtmpfs none /dev
# sleep in case mounting /dev takes time (is something synchronous?)
sleep 1

# configure eth0
ifconfig eth0 up
udhcpc -i eth0 -s "/etc/udhcpc/default.script"
