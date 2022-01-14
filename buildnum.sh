#!/bin/bash
# updates build number by one when called

build=2

# write to stdout then increment
if [[ $# == 1 ]]; then
	build=$1
else
	printf $build
	((build++))
fi

cp $0 $0.tmp
awk -v build="$build" -- '/^build=/{print "build=" build;next}{print}' $0 > $0.tmp

{ sleep 0.25; mv $0.tmp $0; } &
exit

