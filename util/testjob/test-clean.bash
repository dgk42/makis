#!/bin/bash

source inc-test-begin.bash

while [ "$1" != "" ]
do
	setup "$1"
	rm -f "$directory"/*.txt "$directory"/*.memlog
	shift
done
