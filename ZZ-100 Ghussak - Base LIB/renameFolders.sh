#!/bin/bash

set -Eeu

echo "move (or copy) all folders to be renamed to a temporary folder. run this script (symlink) inside that folder, and move the result back"
read

export nNewIndex=$1 #help

function FUNC() {
	strTo="$(echo "$1" |sed -r -e "s@ZZ-... Ghussak - (.*)@ZZ-${nNewIndex} Ghussak - \1@")"
	#declare -p strTo
	if [[ -d "$strTo" ]];then
		ls -ld "$strTo"
		echo "ERROR already exists"
		exit 1 
	fi
	mv -vT "$1" "$strTo"
};export -f FUNC

find -maxdepth 1 -type d -iregex ".*Ghussak.*" \
	|while read strFolder;do
		FUNC "$strFolder"
	done
