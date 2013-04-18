#!/bin/sh

fout=nfo-out-$OSTYPE.txt

evaluate ()
{
	echo "$1" >> "$fout"
	(eval "$1") >> "$fout" 2>&1
	echo >> "$fout"
	echo >> "$fout"
}

echo BEGIN > "$fout"
echo > "$fout"
evaluate 'date'
evaluate 'hostname'
evaluate 'whoami'
evaluate 'groups'
evaluate 'env'
evaluate 'cat /proc/cpuinfo'
evaluate 'echo NUMBER_OF_PROCESSORS = \
`cat /proc/cpuinfo | grep processor | wc -l`'
evaluate 'echo $NUMBER_OF_PROCESSORS'
evaluate 'cat /proc/meminfo'
evaluate 'free -m'
evaluate 'mount'
evaluate 'df -h'
evaluate 'lspci'
evaluate 'lsb_release -a'
evaluate 'uname -a'
evaluate '/lib/libc.so.6 | head -1'
evaluate 'gcc -v'
evaluate 'gdb -v | head -1'
evaluate 'gcov -v | head -1'
evaluate 'gprof -v | head -1'
evaluate 'dot -V'
evaluate 'python --version'
evaluate 'perl -v | head -3'
evaluate 'awk -W version | head -1'
evaluate 'make -v | head -2'
evaluate 'doxygen --version'
evaluate 'latex --version | head -1'
evaluate '/bin/bash --version | head -1'
echo END >> "$fout"
