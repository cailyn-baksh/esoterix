#!/bin/bash
# updates build number by one when called

build=55

# write to stdout then increment
printf $build
((build++))

cp $0 $0.tmp
awk -v build="$build" -- '/^build=/{print "build=" build;next}{print}' $0 > $0.tmp
#trap "mv $0.tmp $0" exit
#kill -9 $(pgrep -f $0)

{ sleep 1; mv $0.tmp $0; } &
exit

