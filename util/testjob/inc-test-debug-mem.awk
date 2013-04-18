#!/usr/bin/awk

BEGIN {
	curr = "NULL"
	mem = 0
	total = 0
	ddbg = 0

	if (ddbg)
		print "#Status\t\tFile"
}

/^# checking/ {
	curr=""
	for (i = 3; i <= NF; i++)
		curr = curr " " $i
	total++
}

/^Ok/ {
	if (ddbg)
		print "Ok\t" curr
}

/^Nonsense/ {
	print "Problem\t" curr
	mem++
}

END {
	printf ("#%d files checked -- %d problems\n", total, mem)
}
