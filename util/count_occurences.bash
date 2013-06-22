#!/bin/bash


function usage {
	echo Usage: "$0" FILE SEARCHWORD >&2

	exit 1
}


test -z "$2" && usage

tr -s ' ' '\n' < "$1" | grep -c "$2"
