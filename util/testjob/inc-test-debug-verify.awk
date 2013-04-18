#!/usr/bin/awk

BEGIN {
	ddbg = 0

	print "#type\t\t\treal\t\tcalc\t\tref\t\trefnum\t\tfile"
}

{
	if (1 != index($1, "#")) {
		maxi = length ($1)
		nn++
		str1 = ""
		str2 = ""
		str3 = ""
		yy1 = 0
		yy2 = 0
		for (i = 1; i <= maxi; i++) {
			c1 = substr ($1, i, 1)
			c2 = substr ($2, i, 1)
			c3 = substr ($3, i, 1)
			if (c2 == c1)
				yy1++
			if (c3 == c1)
				yy2++
		}

		if (yy1 > yy2) {
			str2 = sprintf ("DIFF+(%d-%d)", yy1, yy2)
			nda++
		} else if (yy1 < yy2) {
			str2 = sprintf ("DIFF-(%d-%d)", yy1, yy2)
			ndm++
		}

		# NOTE: cannot understand why "Nothing" doesn't match!
		if ("Nothing" != $2) {
			match ($2, "[A-Z0-9]*")
			if (RLENGTH == maxi) {
				n1++
				if ($1 != $2) {
					n0++
					str1 = "FAIL"
				}
			} else if (yy1 == yy2) {
				str3 = "NULL"
				n1m++
			}
		} else if (yy1 == yy2) {
			str3 = "NULL"
			n1m++
		}

		str = str3 str1 str2
		if (str || ddbg)
			printf ("#%-20s\t%s\n", str, $0)
	}
}

END {
	if (0 != n1) {
		printf ("#TOTAL1: ")
		printf ("%.2f%% - %d out of %d correct (%d total)\n",
			100.0*(n1-n0)/n1, n1-n0, n1, nn)
		printf ("#TOTAL2: ")
		printf ("#%d - %d (calc vs. ref points) # %d / %d no-rec\n",
			nda, ndm, n1m, nn)
	} else
		print "#ERROR: division by zero"
}
