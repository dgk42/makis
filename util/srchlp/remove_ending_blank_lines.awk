#!/usr/bin/awk -f

BEGIN {
	i=0
}

{
	if (NF) {
		for (j=0; j<i; j++)
			print ""
		print $0
		i=0
	} else
		i++
}

END {
	print ""
}
