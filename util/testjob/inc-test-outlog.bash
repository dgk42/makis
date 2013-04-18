#!/bin/bash

reference=../results/total.csv

outlog_intro ()
{
	echo -ne "# real\t\tcalc\t\tref\t\trefnum\t\tfile\n" > $1
}

outlog ()
{
	# columns:
	# 1: real plate
	# 2: lpr result
	# 3: reference
	# 4: reference num
	# 5: filename
	echo "# $directory" >> $1
	for i in "${results[@]}"
	do
		cw=$(basename "$i")
		cw=${cw%.*}
		if [ -f "$i" ]
		then
			cz=`grep ",$cw," $reference | awk 'NR==1'`
			if [ -z "$cz" ]		# NOTE: needs double quotes!!
			then
				cz=`grep ",\"$cw\"," $reference | awk 'NR==1'`
			fi
			if [ -n "$cz" ]
			then
				cy=`echo "$cz" |
					awk 'BEGIN {FS=","}; {print $2}'`
				ca=`echo "$cz" |
					awk 'BEGIN {FS=","}; {print $9}'`
				cb=`echo "$cz" |
					awk 'BEGIN {FS=","}; {print $1}'`
				cx=`cat "$i"`
				if [ -n "$cx" ]
				then
					echo -ne "$cy\t\t$cx\t\t$ca\t\t$cb\t\t$cw\n" >> $1
				fi
			fi
		fi
	done
}
