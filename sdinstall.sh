#!/bin/bash

mntpoint = /mnt/bfm-sd

mkdir -p $mntpoint
mount $1 $mntpoint
mkfs.vfat $mntpoint
cp bin/kernel.img $mntpoint/kernel.img
cp sysroot/* $mntpoint/
umount $mntpoint

