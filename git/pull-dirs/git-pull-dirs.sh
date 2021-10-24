#!/bin/bash
#
# pull all repos/subdirs in current directory
#

GIT=/usr/bin/git

# git pull in all subdirectories
ERRORS=""
for d in */
do
	[[ -e $d ]] || break
	echo "Pulling from $d..."
	if ! output=$(cd "$d" && $GIT pull); then
		ERRORS="$ERRORS\n$d"
	else
		echo "$output"
	fi
done

# print errors
if [[ -n $ERRORS ]]; then
	echo -e "\nErrors:$ERRORS"
fi
