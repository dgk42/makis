#!/bin/bash

die ()
{
	echo "Usage: $0 DIR[S]"
	exit 1
}

setup ()
{
	#directory="../../../Dataset/test small"
	directory="$1"
	images=( "$directory"/*.JPG "$directory"/*.jpg "$directory"/*.pnm )
	unset results
	k=0
	for i in "${images[@]}"
	do
		results[k]="$i".txt
		let k=$k+1
	done
}

test -z "$1" && die
