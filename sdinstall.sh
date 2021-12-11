#!/bin/bash

mntpoint = /mnt/bfm-sd

mkdir -p $mntpoint
mount $1 $mntpoint
mkfs.vfat $mntpoint
cp bin/kernel7.img $mntpoint/kernel7.img
cp sysroot/* $mntpoint/
umount $mntpoint

