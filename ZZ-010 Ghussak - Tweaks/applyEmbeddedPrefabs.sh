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

set -Eeu

egrep "[#]help" "$0"

: ${strWorld:="Nulukoju Valley"} #help
: ${strFlPrefabs:="../../../../users/${USER}/Application Data/7DaysToDie/GeneratedWorlds/${strWorld}/prefabs.xml"} #help
: ${strFlPOI:="./Prefabs/POIs/TNM_TeamDeathMatch.xml"} #help

strPOIname="$(basename "$strFlPOI")";
strPOIname="${strPOIname%.xml}";

ls -l "$strFlPrefabs" "$strFlPOI"

# as may error til above
source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

strXmlLine="$(cat "$strFlPrefabs" |grep "$strPOIname")"
CFGFUNCinfo "[strXmlLine] $strXmlLine"

x=0;y=1;z=2
strPos=$(xmlstarlet sel -t -v "//decoration[@type='model' and @name='${strPOIname}']/@position" "$strFlPrefabs")
pos=($(echo "$strPos" |tr ',' ' '))
rot=($(xmlstarlet sel -t -v "//decoration[@type='model' and @name='${strPOIname}']/@rotation" "$strFlPrefabs"))
declare -p strPos pos rot #;echo "${pos[x]} ${pos[y]} ${pos[z]}"
#ex.: <decoration type="model" name="TNM_TeamDeathMatch" position="-97,36,29" rotation="0" />
#strToEval="$(echo "$strXmlLine" |tr -d '</>\r' |tr -s ' ' |tr ' ' ';' |sed -r -e 's@;decoration;@@' -e 's@position="([0-9-]*),([0-9-]*),([0-9-]*)"@nX=\1;nY=\2;nZ=\3@')"
#declare -p strToEval
#CFGFUNCinfo "[strToEval] $strToEval"
#if ! CFGFUNCprompt -q "code to EVAL above is ok?";then exit;fi
#eval "${strToEval}"
#declare -p nX nY nZ

##<property name="POIMarkerSize" value="9, 15, 9#11, 5, 7" />
#<property name="POIMarkerStart" value="10, 27, 9#17, 2, 2" />
##<property name="POIMarkerGroup" value="thenomad,parts" />
##<property name="POIMarkerTags" value="thenomad#part" />
#<property name="POIMarkerType" value="PartSpawn,PartSpawn" />
#<property name="POIMarkerPartToSpawn" value="part_TNM_TowerMedieval,part_coffee_stand" />
#<property name="POIMarkerPartRotations" value="0,0" />
#<property name="POIMarkerPartSpawnChance" value="1,1" />
#cat "$strFlPOI" |grep POIMarkerPartToSpawn
function FUNCxmlGetValue() { #only comma separated
	xmlstarlet sel -t -v "//property[@name='$1']/@value" "$strFlPOI" |tr ',' ' '
}
aPartList=($(FUNCxmlGetValue POIMarkerPartToSpawn));declare -p aPartList
IFS=$'#\n' read -d '' -r -a aRelPosList < <(xmlstarlet sel -t -v "//property[@name='POIMarkerStart']/@value" "$strFlPOI" |tr -d ' ')&&:;aTypeList=($(FUNCxmlGetValue POIMarkerType))
aRotList=($(FUNCxmlGetValue POIMarkerPartRotations))
aRndChance=($(FUNCxmlGetValue POIMarkerPartSpawnChance)) #TODOA
declare -p aPartList aRelPosList aTypeList aRotList aRndChance
  
for((i=0;i<${#aPartList[@]};i++));do
	strPart="${aPartList[i]}"
	
	posRel=($(echo "${aRelPosList[i]}" |tr ',' ' '))
	posNew[x]=$((pos[x] + posRel[x]))
	posNew[y]=$((pos[y] + posRel[y]))
	posNew[z]=$((pos[z] + posRel[z]))
	
	rotNew=$(( (rot + ${aRotList[i]}) % 4 ))
	
	strXmlNew="<decoration type=\"model\" name=\"${strPart}\" position=\"$(echo "${posNew[@]}" |tr ' ' ',')\" rotation=\"${rotNew}\" help=\"TNMApplyPart: placed into ${strPOIname} at ${strPos}\" />"
	sed -i.$(date +'%Y_%m_%d-%H_%M_%S_%N').bkp -r -e 's@.*<decoration type="model" name="'"${strPOIname}"'".*@&\n  '"${strXmlNew}"'@' "$strFlPrefabs"
	#cat "$strFlPrefabs" |grep "${strPOIname}" |tr -d '\r' |sed -r -e 's@.*decoration *type="model" *name="'"${strPOIname}"'".*(\r*)@&'"${strXmlNew}"'@'
done
cat "$strFlPrefabs" |egrep "${strPOIname}.*${strPos}"


















