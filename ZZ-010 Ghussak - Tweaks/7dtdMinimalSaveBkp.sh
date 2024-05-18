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

egrep "[#]help" "$0"

trap 'read -n 1' ERR

#help backup only minimal save data: chunks where there are landclaims and bedroll, so your hired NPCs shall be left in a chunk where there is a landclaim. beware tho, it will not backup nearby chunks so better do not leave the NPC in patrol mode?
#help ISSUE: for now place a symlink to this script at "drive_c/users/$USER/Application Data/7DaysToDie"

: ${strSaveFolder:="./Saves/East Nikazohi Territory/HolyAir207b1_ab"} #help TODO: make this automatic to newest
strFlPlayersXml="$strSaveFolder/players.xml" #help

if [[ ! -f "$strFlPlayersXml" ]];then echoc -p "file not found: $strFlPlayersXml";exit 1;fi

cat "$strFlPlayersXml"
IFS=$'\n' read -d '' -r -a astrListCoords < <(cat "$strFlPlayersXml" |egrep "lpblock|bedroll" |egrep 'pos=".*"' -o |cut -d= -f 2 |tr '",' '  ' |awk '{print "x=" $1 ";" "z=" $3}')&&:;declare -p astrListCoords

# center of the map chunks x,z:
# -1,0  0,0
# -1,-1 0,-1

strRegionRegex=""
for strCoord in "${astrListCoords[@]}";do
	echo
	echo "[bkp chunk]"
	eval "$strCoord" # x z
	if((x>0));then xC=$((x/512));else xC=$(((x/512)-1));fi
	if((z>0));then zC=$((z/512));else zC=$(((z/512)-1));fi
	strChunk="$xC.$zC"
	declare -p strCoord x z strChunk
	ls -l "$strSaveFolder/Region/r.${strChunk}.7rg"&&:
	if [[ -n "$strRegionRegex" ]];then strRegionRegex+="|";fi
	strRegionRegex+="$strChunk"
done
declare -p strRegionRegex

IFS=$'\n' read -d '' -r -a astrListFlToBkp < <(find "${strSaveFolder}/" -type f |sort -u |egrep -v "/(DynamicMeshes|ConfigsDump|Region)/"; find "${strSaveFolder}/" -type f |sort -u |egrep    ".*/Region/r[.].*${strRegionRegex}[.]7rg$";)&&:;declare -p astrListFlToBkp |tr '[' '\n'

astrListFlToBkp+=("./Saves/profiles.sdf")

tar -cf "7dtdSaveMinimalBkp.tar" "${astrListFlToBkp[@]}"
7z a "7dtdSaveMinimalBkp.tar.7z" "7dtdSaveMinimalBkp.tar"
trash "7dtdSaveMinimalBkp.tar"
ls -l "7dtdSaveMinimalBkp.tar.7z"
7z l "7dtdSaveMinimalBkp.tar.7z"

read -n 1 -t 60 -p "press a key to exit (60s)"
