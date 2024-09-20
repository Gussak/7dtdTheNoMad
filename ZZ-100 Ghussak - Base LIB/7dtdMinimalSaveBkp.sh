#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2024, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#PREPARE_RELEASE:REVIEWED:OK

source ./libSrcCfgGenericToImport.sh

egrep "[#]help" "$0"

set -Eeu

trap 'read -n 1' ERR

#pwd
#echo "$0"
#cd "$(dirname "$0")"
#pwd

#help backup only minimal save data: chunks where there are landclaims and bedroll, so your hired NPCs shall be left in a chunk where there is a landclaim. beware tho, it will not backup nearby chunks so better do not leave the NPC in patrol mode?

function FUNCbkp() {
	if [[ ! -f "$strFlPlayersXml" ]];then echo "PROBLEM: file not found: $strFlPlayersXml" >/dev/stderr;return 1;fi

	cat "$strFlPlayersXml"
	IFS=$'\n' read -d '' -r -a astrListCoords < <(cat "$strFlPlayersXml" |egrep "lpblock|bedroll" |egrep 'pos=".*"' -o |cut -d= -f 2 |tr '",' '  ' |awk '{print "x=" $1 ";" "z=" $3}')&&:;declare -p astrListCoords

	# center of the map chunks x,z:
	# -1,0  0,0
	# -1,-1 0,-1

	strRegionRegex=""
	iMarginWarning=0
	for strCoord in "${astrListCoords[@]}";do
		echo
		echo "[bkp chunk]"
		
		eval "$strCoord" # x z
		
		: ${iChunkSize:=512} #help I think this is hardcoded and fixed tho
		xC=$((x/iChunkSize));
		zC=$((z/iChunkSize));
		
		#help remainder xR zR are absolute values to easy calc
		xR=$((x%iChunkSize))
		zR=$((z%iChunkSize))
		
		if((x<0));then ((xC-=1))&&:; ((xR*=-1))&&:;fi
		if((z<0));then ((zC-=1))&&:; ((zR*=-1))&&:;fi
		
		strChunk="$xC.$zC"
		
		: ${iMargin:=32} #help safety margin to warn in case of the possibility of not making a good enough backup
		if(( xR < iMargin || zR < iMargin || xR > (iChunkSize-iMargin) || zR > (iChunkSize-iMargin) ));then
			echo "[[[ WARNING ]]] ISSUE: landclaims and bedroll near limit of chunk region will probably fail to backup stuff that goes to a connected chunk there, so if it is in the middle of a building and the building center is in the crossing of 4 nearby chunks, only 1/4 of the building will be backuped!! Also too near the limit of a chunk region may fail to sucessfully backup where NPCs are left to wait? so if xR or zR is < $iMargin or > $iChunkSize-$iMargin, these problems may happen. TODO: calc and backup also all nearby chunks in this case."
			((iMarginWarning++))&&:
		fi
		
		declare -p strCoord x z strChunk xR zR
		
		ls -l "$strSaveFolder/Region/r.${strChunk}.7rg"&&:
		
		if [[ -n "$strRegionRegex" ]];then strRegionRegex+="|";fi
		strRegionRegex+="$strChunk"
	done
	declare -p strRegionRegex

	IFS=$'\n' read -d '' -r -a astrListFlToBkp < <(
		(
			find "${strSaveFolder}/" -type f |sort -u |egrep -v "/(DynamicMeshes|ConfigsDump|Region)/";
			find "${strSaveFolder}/" -type f |sort -u |egrep    ".*/Region/r[.].*${strRegionRegex}[.]7rg$";
			echo "${strCFGSavesPath}/profiles.sdf";
			echo "${strCFGSavesPath}/newGameOptions.sdf";
			echo "${strCFGSavesPath}/sdcs_profiles.sdf";
			ls "${strSaveFolder}/Region/r."*".7rg" -1t |head -n 4; # the newest files are where the player is, this also grants the backup of NPCs activelly following the player TODO: try read this from player files, binary data probably. would be better in case of multiplayer also.
		) |sort -u
	)&&:

	#fix the list
	astrListFlToBkpTmp=()
	for strFlToFix in "${astrListFlToBkp[@]}";do
		astrListFlToBkpTmp+=("$(echo "$strFlToFix" |sed -r -e 's@/+@/@g' -e 's@.*/Application Data/7DaysToDie/Saves@./7DaysToDie/Saves@')")
	done
	astrListFlToBkp=("${astrListFlToBkpTmp[@]}")

	#astrListFlToBkp+=("./Saves/profiles.sdf")

	#IFS=$'\n' read -d '' -r -a astrListPlayerNear < <(ls "${strSaveFolder}/Region/r."*".7rg" -1t |head -n 4)&&:;declare -p astrListPlayerNear |tr '[' '\n'
	#astrListFlToBkp+=("${astrListPlayerNear[@]}")



	declare -p astrListFlToBkp |tr '[' '\n'
	
	strFlBkpCoreName="${strCFGAppDataFolder}/7dtdSaveMinimalBkpA22" #help
	strFlBkpBN="${strFlBkpCoreName}.$(date +'%Y_%m_%d-%H_%M_%S_%N')" #help

	#trash "${strFlBkpBN}.tar.7z"&&:
	#trash "${strFlBkpBN}.jpg"&&:
	: ${iKeepMaxSaves:=20} #help
	while true;do
		nTotSaves=$(ls -1t "${strFlBkpCoreName}".*.7z |wc -l)
		if(( nTotSaves > iKeepMaxSaves ));then
			strFlOldest="$(ls -1t "${strFlBkpCoreName}".*.7z |tail -n 1)"
			echo "($nTotSaves) oldest to trash: $strFlOldest"
			trash "$strFlOldest" "${strFlOldest%.tar.7z}.jpg"&&: #"${strFlOldest%.7z}"
		else
			break
		fi
	done

	while true;do
		echo "`date` preparing minimal save bkp in 3s"
		read -t 3 -n 1&&:
		
		pwd
		
		if ! strKey="$(ls -l "${astrListFlToBkp[@]}")";then echo "preparing key failed, retring...";continue;fi
		
		rm -v "${strFlBkpBN}.tar"&&:
		if ! tar -cf "${strFlBkpBN}.tar" "${astrListFlToBkp[@]}";then echo "tar failed, retring...";continue;fi
		
		if ! tar --list -f "${strFlBkpBN}.tar";then echo "tar list failed, retrying...";continue;fi
		
		############ check if nothing changed below #####
		
		echo "[`date`] waiting no changes happen in 3s...";read -t 3 -n 1&&:
		
		if ! strKeyNew="$(ls -l "${astrListFlToBkp[@]}")";then echo "checking key failed, retring...";continue;fi
		if [[ "$strKeyNew" == "$strKey" ]];then
			declare -p strKey; 
			break; 
		else
			echo "some file(s) changed, retrying..."
			colordiff <(echo "$strKey") <(echo "$strKeyNew")&&:
		fi
	done
	
	if [[ "$strKeyPreviousBkp" != "$strKey" ]];then
		# screenshot 
		if nWId="$(xdotool search "Default - Wine desktop")";then
			import -window "$nWId" "${strFlBkpBN}.jpg"&&: #accepts webp tho
		fi
		
		#while ! tar --list -f "${strFlBkpBN}.tar";do echo "retring...";read -t 3 -n 1&&:;done
		7z a "${strFlBkpBN}.tar.7z" "${strFlBkpBN}.tar"
		trash "${strFlBkpBN}.tar" #cleanup
		
		ls -l "${strFlBkpBN}.tar.7z"
		7z l "${strFlBkpBN}.tar.7z"

		if((iMarginWarning>0));then
			echo "[[[ WARNING ]]]: there happened iMarginWarning=$iMarginWarning"
		fi
		
		strKeyPreviousBkp="$strKey"
	else
		echo "Previous backup has identical contents, skipping."
		trash "${strFlBkpBN}.tar"
	fi
};export -f FUNCbkp

: ${strSaveFolder:="$(realpath _NewestSavegamePath.IgnoreOnBackup)"} #help TODO: make this automatic to newest
strFlPlayersXml="$strSaveFolder/players.xml" #help
if [[ ! -f "$strFlPlayersXml" ]];then
	echo "ERROR: unable to find strFlPlayersXml='$strFlPlayersXml'";read -n 1&&:
	exit 1
fi

./updateNewestSavegameSymlink.sh

#: ${strWorkPath:="${strCFG7dtdAppDataFolder}"} #help relative path to this mod, for Wine on linux (may be cygwin too)
: ${strWorkPath:="${strCFGAppDataFolder}"} #help relative path to this mod, for Wine on linux (may be cygwin too)
cd "$strWorkPath"
pwd
ls -ld *

export strKeyPreviousBkp=""
while true;do
	FUNCbkp&&:
	
	: ${iDelayBetweenBkps:=60} #help
	while read -t 0.01 -n 1;do :;done #clear buffer
	echo "press ctrl+c to exit, ctrl+s to wait, ctrl+q to continue, or a key to repeat bkp now (60s)";read -t ${iDelayBetweenBkps} -n 1&&:
done

exit 0
