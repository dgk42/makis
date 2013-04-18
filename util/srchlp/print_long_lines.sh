#!/bin/sh

die ()
{
	echo "Usage: $0 MAX_LEN TAB_WIDTH [FILE1 ... FILEN]" 1>&2
	exit 0
}

test -z "$2" && die

n=$1
t=$2
shift
shift
awk 'BEGIN { \
	t=-1; \
	str0=" " \
} \
\
{ \
	if (-1==t) { \
		for (i=1; i<tabw; i++) str0=str0 " "; \
		t=1 \
	} \
	gsub (/\t/, str0, $0); \
	len0=length ($0); \
	if (len0>lenlen) print FILENAME":"FNR" ("len0"): "$0 \
}' lenlen=$n tabw=$t "$@"
