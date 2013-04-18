#!/bin/bash

bigmak="_makis.makis_"
awkcmd="awk -f"
rmcmd="rm -f"
clean="n"
fs=0

die0 ()
{
	echo "Usage: $0 PATH/TO/makiss.awk DIR1 [DIR2 ... DIRN]" 1>&2
	echo "# if PATH/TO/makiss.awk is :clean then all scons scripts" 1>&2
	echo "#    located in DIR1 [DIR2 ... DIRN] plus in their " 1>&2
	echo "#    sub-directories will be deleted" 1>&2
	exit 0
}

die1 ()
{
	echo ERROR: $bigmak not found 1>&2
	exit 1
}

die2 ()
{
	echo ERROR: "$mpath/makiss.awk" not found 1>&2
	exit 1
}

die3 ()
{
	$rmcmd "$1"
	echo ERROR: could not create scons script 1>&2
	exit 1
}

recurse ()
{
	for i in "$1"/*
	do
		if [ -d "$i" ]
		then
			if [ $clean = "Y" ]
			then
				$rmcmd "$i/SConstruct" "$i/SConscript" "$i/.sconsign.dblite"
				recurse "$i"
			else
				if [ -f "$i/$bigmak" ]
				then
					if [ ! -f "$i/SConscript" ] || [ "$i/$bigmak" -nt "$i/SConscript" ]
					then
						prjpath=`dirname "$i/$bigmak"`
						prj=`basename "$prjpath"`
						prjparnt=`dirname "$prjpath"`
						prjparnt=`basename "$prjparnt"`
						$awkcmd "$mpath/makiss.awk" proj_path="$prjpath" parent="$prjparnt" proj="$prj" makiss_path="$mpath" "$i/$bigmak" > "$i/SConscript"
						test $? -ne 0 && die3 "$i/SConscript"
						let fs=fs+1
					fi
					recurse "$i"
				fi
			fi
		fi
	done
}


test -z "$2" && die0

if [ "$1" = ":clean" ]
then
	clean="Y"
else
	mpath="$1"
	test -f "$mpath/makiss.awk" || die2
fi
shift

while (( "$#" ))
do
	if [ $clean = "Y" ]
	then
		$rmcmd "$1/SConstruct" "$1/SConscript" "$1/.sconsign.dblite"
		recurse "$1"
	else
		test -f "$1/$bigmak" || die1
		if [ ! -f "$1/SConstruct" ] || [ "$1/$bigmak" -nt "$1/SConstruct" ]
		then
			$awkcmd "$mpath/makiss.awk" makiss_path="$mpath" isroot=1 "$1/$bigmak" > "$1/SConstruct"
			test $? -ne 0 && die3 "$1/SConstruct"
			let fs=fs+1
		fi
		recurse "$1"
	fi

	shift
done

if [ $clean = "n" ]
then
	echo $fs file\(s\) affected.
fi
