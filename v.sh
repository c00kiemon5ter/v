#!/bin/sh

usage() {
    printf 'usage: %s %s %s\n' "${0##*/}" "[-a] [-l|--list] [-[0-9]] [-h|--help]" "<regexe[s]>" >&2
	exit 1
}

while [ $# -ne 0 ]
do
    case "$1" in
        -a|--all)
            del=1
            ;;
		-d|--debug)
			dbg=1
			;;
        -l|--list)
            list=1
            ;;
        -h|--help)
            usage
            ;;
        --)
            break
            ;;
        *)
			break
            ;;
    esac
    shift
done

info="${info:-$HOME/.viminfo}"

case $# in
	0)
		list=1
		;;
	1)
		if [ -f "$1" ]
		then
			vim "$1"
			exit
		fi
esac

# if no arguments were given
# then default to list files
if [ $# -eq 0 ]
then list=1
# if there's only one argument
# and that argument is a file
# then edit that file
elif [ $# -eq 1 -a -f "$1" ]
then
	vim "$1"
    exit
fi

# construct regex
rgx="$(printf '%s\|' "$@")"
rgx="${rgx%??}"

# TODO test with files with spaces
# generate list of matched files
set -- $(grep "^>" "$info" | grep -i "$rgx" | while read -r _ file
do
	if [ -z "${file%%~*}" ]
	then file="$HOME/${file#?}"
	fi
	[ -f "$file" -o ${del:-0} -ne 0 ] && printf '%s ' "$file"
done)

if [ $# -eq 0 ]
then
	echo 'no files found' >&2
	exit 1
fi

if [ ${list:-0} -eq 0 -o $# -eq 1 ]
then file="$1"
else
	while [ ${i:=1} -le $# ]
	do
		printf "%3d. %s\n" "$i" "${!i}"
		: $((i+=1))
	done
	# TODO sanitize choice
	read -p 'choose file: ' file
	file="${!file:-$1}"
fi

[ ${dbg:-0} -ne 0 ] && echo "vim $file" || vim "$file"

