#!/bin/bash
#
# pull all repos/subdirs in current directory
#

GIT=/usr/bin/git

for d in */
do
	[[ -e $d ]] || break
	echo "Pulling from $d..."
	(cd "$d" && $GIT pull)
done
