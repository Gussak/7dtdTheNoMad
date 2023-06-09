#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2023, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
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

#egrep "[#]help" $0

#set -x
set -Eeu

#if [[ "${1-}" == --help ]];then source ./libSrcCfgGenericToImport.sh --help;exit 0;fi
source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

strFlCACHE="`basename "$0"`.CACHE.sh" #help if you delete the cache file it will be recreated
source "$strFlCACHE"&&: #this file contents can be like: the last value appended for the save variable will win

#CFGFUNCsetGlobals tst123=10 tstb="abc";declare -p tst123 tstb;for((i=0;i<201;i++));do CFGFUNCpredictiveRandom Tst1;declare -p iPRandom;done;exit #KEEP THESE TESTERS HERE COMMENTED

strPrefabsXml="prefabs.xml"

#strFlRunLog="`basename "$0"`.LastRun.log.txt"
#echo -n >"$strFlRunLog"

#: ${strPathToUserData:="./_7DaysToDie.UserData"} #h elp relative to game folder (just put a symlink to it there)
#: ${strGenWorldName:="East Nikazohi Territory"} #h elp
#strFlGenPrefabsOrig="${strPathToUserData}/GeneratedWorlds/${strGenWorldName}/${strPrefabsXml}"

CFGFUNCinfo "MainGoal: place ALL AVAILABLE POIs in a SINGLE WORLD."
CFGFUNCinfo " OtherGoal: place POIs in the underground with collapsing ceiling what is overall fun and a good trap against the player."
CFGFUNCinfo " OtherGoal: place custom small traps around all POIs, bigger POIs will have more traps, they are actually useful if you do not fall on them."
CFGFUNCinfo " OtherGoal: prepare spawn points to be used by TheNoMad teleportation devices. Tracked spawn points also help to protect new players and help choosing a starting biome/difficulty."
CFGFUNCinfo "This is not highly optimized yet and not multithread (uses only 1 core). It takes 16min on my machine 3.2GHz."
CFGFUNCinfo "If in the end there are still missing POIs, you may want to run this script again to try to add all of them, but that is not required."
CFGFUNCprompt "It will be run now ($iReservedWastelandPOICountForMissingPOIs is for A20) like this: iReservedWastelandPOICountForMissingPOIs=$iReservedWastelandPOICountForMissingPOIs $0 #later will be asked if you want it to be zeroed, just keep hitting Enter to accept all defaults."

#: ${strFlGenPrefabsOrig:="${strCFGGeneratedWorldTNMFolder}/${strPrefabsXml}"} #he lp you can set this file path directly here
strFlOriginalBkp="${strCFGGeneratedWorldTNMFolder}/${strPrefabsXml}${strCFGOriginalBkpSuffix}"
if [[ -f "${strFlOriginalBkp}" ]];then
  strFlGenPrefabsOrig="${strFlOriginalBkp}"
  CFGFUNCprompt "recreating the variety based on the original backup file (the file created by the game engine RWG tool): '$strFlGenPrefabsOrig'"
else
  strFlGenPrefabsOrig="${strCFGGeneratedWorldTNMFolder}/${strPrefabsXml}"
  CFGFUNCinfo "there is no original file backup yet, so using the existing file: '$strFlGenPrefabsOrig'" 
fi
CFGFUNCtrash "${strFlGenPrefabsOrig}${strGenTmpSuffix}"&&:

strTmpPath="`pwd`/_tmp"
mkdir -vp "$strTmpPath"

#strRegexProtectedPOIs="(part_|rwg_|spider_|installation_red_mesa)"
strRegexCarefullyProtectedPOIs="(spider_)"
strRegexProtectedPOIs="(bombshelter_|bridge_|docks_|part_|rwg_|${strRegexCarefullyProtectedPOIs})" #these POIs shall be completely ignored anywhere #TODO ignore them if in removed towns too. rwg_ are for tiles rwg_tile_, including rwg_bridge_. part_ are things that are not buildings but complement the urbanicity. spider_ are potentially very hard special places, dont touch them ever! docks_ and bridge_ are very well placed by RWG near water, but missing ones will be placed weirdly elsewhere by this script TODO place them properly using the AddExtraSpecialPOIs file.

astrIgnoreTmp=( #these wont be used to create variety, they will be ignored when looking for missing POIs on the original file created by the game engine RWG
  "house_new_mansion_03" #there is no data for this POI and it cause errors on log when loading the game
  "trader_" #they will be replaced tho if outside wasteland see astrRemoveTradersIfOutsideWasteland. put one per biome at AddExtraSpecialPOIs file
  "part_" #these are small things from the "Prefabs/Parts" folder
  "rwg_"
  "sign_"
  "player_start"
  "bus_stop_"
  "deco_"
  ".*_filler_"
  ".*_sign"
  ".*_form"
  ".*_blk"
)
astrIgnoreOrig=("${astrIgnoreTmp[@]}")
strRegexIgnoreOrig="^(`echo "${astrIgnoreOrig[@]}" |tr " " "|"`)" #help when reading POI xml file from paths, ignore these
astrIgnoreGen=("${astrIgnoreTmp[@]}")
: ${bIgnoreCavesToo:=true} #help keep RWG caves as they are a nice break from the overworld even when repeated. But missing caves will still be added
if $bIgnoreCavesToo;then astrIgnoreGen+=("cave_" ".*_cave_");fi
strRegexIgnoreGen="^(`echo "${astrIgnoreGen[@]}" |tr " " "|"`)" #help when filling astrGenPOIsList, ignore these
astrIgnoreTmp=();unset astrIgnoreTmp # just to make it sure not to use a tmp array elsewhere

#astrSpecialBuildingPrefix=( #they are like a whole small town to explore
  #apartment_
  #apartments_
  #business_
  #factory_lg_
  #hospital_
  #hotel_
  #industrial_
  #installation_red_mesa
  ##lodge_
  ##lot_
  #office_
  #remnant_gas_station_
  #remnant_industrial_
  #remnant_skyscraper_
  #skyscraper_
  ##trader_
#)

#strGenPrefabsData="`(
  #cd "${strCFGGameFolder}";
  #cat "$strFlGenPrefabsOrig"
#)`"

declare -A astrTownList=()
strFlTownRect="./rwgImprovePOIs.sh.CfgTownsRectangles.sh"
if cat "${strFlTownRect}";then
  : ${bAskIfWorldTownRectanglesAreOk:=true} #help disable if this question is annoying you
  if $bAskIfWorldTownRectanglesAreOk;then
    CFGFUNCprompt "Check if the above town's rectangles are correct (if not, abort and edit '${strFlTownRect}' properly)"
    #CFGFUNCerrorExit "re-run this script after towns rectangles are fixed."
  fi
fi
source "${strFlTownRect}"&&:
iTownRectanglesOutsideWastelandCount=0
function FUNCchkPosIsInTownPIT() { # [--ignore <Wasteland|Snow|PineForest|Desert>] <lnX> <lnZ>
  #CFGFUNCchkDenySubshellForGlobalVarsWork
  local lstrIgnoreBiome="";if [[ "$1" == --ignore ]];then shift;lstrIgnoreBiome="$1";shift;fi #this will let wasteland town rectangles be ignored when checking if it is in town
  local lnX=$1;shift
  local lnZ=$1;shift
  
  for strTownData in "${!astrTownList[@]}";do
    eval "`echo "$strTownData" |sed -r 's@(.*)_CFG_(.*)_Biome(.*)_TownID(.*)@strPITWorldName="\1";strPITRWGcfg="\2";strPITBiome="\3";strPITTownID="\4";@'`"
    eval "`echo "${astrTownList[$strTownData]}" |sed -r 's@^([^,]*),([^,]*),([^,]*),([^,]*)$@iXTopLeftPIT=\1;iZTopLeftPIT=\2;iXBottomRightPIT=\3;iZBottomRightPIT=\4;@'`"
    strDbg="`declare -p strCFGGeneratedWorldTNMFixedAsID strCFGGeneratedWorldSpecificDataAsID lstrIgnoreBiome strPITWorldName strPITRWGcfg strPITBiome strPITTownID iXTopLeftPIT iZTopLeftPIT iXBottomRightPIT iZBottomRightPIT lnX lnZ|tr '\n' ';'`"
    CFGFUNCinfo --dbg "$strDbg" #this will be only on the log file
    if((iXTopLeftPIT>=iXBottomRightPIT || iZTopLeftPIT<=iZBottomRightPIT));then
      CFGFUNCerrorExit "invalid corners. iXTopLeftPIT=$iXTopLeftPIT >= iXBottomRightPIT=$iXBottomRightPIT || iZTopLeftPIT=$iZTopLeftPIT <= iZBottomRightPIT=$iZBottomRightPIT. $strDbg"
    fi
    if [[ "$strPITBiome" != "Wasteland" ]];then ((iTownRectanglesOutsideWastelandCount++))&&:;fi
    if [[ -n "$lstrIgnoreBiome" ]] && [[ "${lstrIgnoreBiome}" =~ "$strPITBiome" ]];then continue;fi
    if [[ "${strCFGGeneratedWorldTNMFixedAsID}" == "${strPITWorldName}" ]] && [[ "${strCFGGeneratedWorldSpecificDataAsID}" == "${strPITRWGcfg}" ]];then
      if((lnX>=iXTopLeftPIT && lnX<=iXBottomRightPIT && lnZ<=iZTopLeftPIT && lnZ>=iZBottomRightPIT));then
        CFGFUNCsetGlobals strPITWorldName strPITRWGcfg strPITBiome strPITTownID iXTopLeftPIT iZTopLeftPIT iXBottomRightPIT iZBottomRightPIT
        CFGFUNCinfo "InTownLimits($lnX,$lnZ) $strPITBiome $strPITTownID ($iXTopLeftPIT,$iZTopLeftPIT,$iXBottomRightPIT,$iZBottomRightPIT)"
        return 0
      fi
    fi
  done
  return 1
  
  ## TODO make these regions configurable using and external CFG file, and let more regions be added: astrTownRectangles. The file must contain the world name for each rectangle data
  #if [[ "${strCFGGeneratedWorldTNM}" == "East Nikazohi Territory" ]];then
    #if((lnX>=645 && lnX<=1019 && lnZ<=-523 && lnZ>=-899));then
      #if $lbIgnoreWasteland;then return 1;fi
      ## town 1 in radiated area wasteland OK
      ## x 662 645 1019 962
      ## z -899 -530 -523 -899
      ## topLeftXZ=645,-523;bottomRightXZ=1019,-899
      ##echo "${lstrMsg}InTown1Limits" |tee -a "$strFlRunLog" >/dev/stderr
      #CFGFUNCinfo "${lstrMsg}InTown1Limits"
      #CFGFUNCsetGlobals iTownIndex=1
      #return 0
    #fi
    ## t2 x 2285 2516 2434 z -738 -730 -588
    #if((lnX>=2285 && lnX<=2516 && lnZ<=-588 && lnZ>=-738));then
      ##TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      ##echo " >>> WARN:SKIPPING:InTown2Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      ##echo "${lstrMsg}InTown2Limits" |tee -a "$strFlRunLog" >/dev/stderr
      #CFGFUNCinfo "${lstrMsg}InTown2Limits"
      #CFGFUNCsetGlobals iTownIndex=2
      #return 0
    #fi
    ## t3 x 3359 3338 3451 z -1259 -1351 -1359
    #if((lnX>=3338 && lnX<=3451 && lnZ<=-1259 && lnZ>=-1359));then
      ##TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      ##echo " >>> WARN:SKIPPING:InTown3Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      ##echo "${lstrMsg}InTown3Limits" |tee -a "$strFlRunLog" >/dev/stderr
      #CFGFUNCinfo "${lstrMsg}InTown3Limits"
      #CFGFUNCsetGlobals iTownIndex=3
      #return 0
    #fi
  #fi
  
  #return 1
}

declare -A astrEvalV3cache
function FUNCgetV3() { #<lstrV3> set global vars: n1 n2 n3
  CFGFUNCchkDenySubshellForGlobalVarsWork
  
  local lstrV3="$1";shift
  
  if [[ -z "$lstrV3" ]];then CFGFUNCerrorExit "invalid lstrV3='$lstrV3'";fi
  
  local lstrGlobals123="${astrEvalV3cache[${lstrV3}]-}"
  if [[ -z "${lstrGlobals123}" ]];then
    lstrGlobals123="`echo "${lstrV3}" |sed -r 's@([0-9-]*)[.]*[0-9]*, *([0-9-]*)[.]*[0-9]*, *([0-9-]*)[.]*[0-9]*@CFGFUNCsetGlobals n1=\1 n2=\2 n3=\3;@' |head -n 1`" #collect only the integer part
    astrEvalV3cache[${lstrV3}]="${lstrGlobals123}"
  fi
  
  #CFGFUNCinfo --dbg "`declare -p lstrV3 lstrGlobals123`"
  
  eval "$lstrGlobals123"
}
function FUNCgetXYZ() { #<lstrPosOrig> set global vars: nX nY nZ
  #CFGFUNCchkDenySubshellForGlobalVarsWork
  FUNCgetV3 "$1"
  CFGFUNCsetGlobals nX=$n1 nY=$n2 nZ=$n3
  #local lstrPosOrig="$1";shift
  #if [[ -z "$lstrPosOrig" ]];then CFGFUNCerrorExit "invalid lstrPosOrig='$lstrPosOrig'";fi
  #local lstrGlobalsXYZ="`echo "${lstrPosOrig}" |sed -r 's@([.0-9-]*), *([.0-9-]*), *([.0-9-]*)@CFGFUNCsetGlobals nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #declare -p lstrPosOrig lstrGlobalsXYZ |tee -a "$strCFGScriptLog"
  #eval "$lstrGlobalsXYZ" #nX nY nZ
}
function FUNCgetWHL() { #<lstrSize> set global vars: nWidth nHeight nLength
  #CFGFUNCchkDenySubshellForGlobalVarsWork
  FUNCgetV3 "$1"
  CFGFUNCsetGlobals nWidth=$n1 nHeight=$n2 nLength=$n3
  #local lstrSize="$1";shift
  #if [[ -z "$lstrSize" ]];then CFGFUNCerrorExit "invalid lstrSize='$lstrSize'";fi
  #local lstrGlobalsWHL="`echo "${lstrSize}" |sed -r 's@([.0-9-]*), *([.0-9-]*), *([.0-9-]*)@CFGFUNCsetGlobals nWidth=\1 nHeight=\2 nLength=\3;@' |head -n 1`"
  #declare -p lstrSize lstrGlobalsWHL |tee -a "$strCFGScriptLog"
  #eval "$lstrGlobalsWHL" #nWidth nHeight nLength
}
function FUNCgetXYZfromXmlLine_outXYZaXLDglobals() { #<lstrXmlLine> set global vars: iXLDFilterIndex
  #CFGFUNCchkDenySubshellForGlobalVarsWork
  local lstrXmlLine="$1";shift
  local lstrPosOrig="`CFGFUNCxmlGetLinePropertyValue "$lstrXmlLine" "//decoration/@position"`"
  FUNCgetXYZ "$lstrPosOrig"
  CFGFUNCsetGlobals iXLDFilterIndex="`CFGFUNCxmlGetLinePropertyValue "$lstrXmlLine" "//decoration/@helpFilterIndex"`"
  CFGFUNCsetGlobals strXLDPrefabCurrentName="`CFGFUNCxmlGetLinePropertyValue "$lstrXmlLine" "//decoration/@name"`"
  #if [[ -z "$lstrPosOrig" ]];then CFGFUNCerrorExit "invalid lstrPosOrig='$lstrPosOrig'";fi
  ##declare -p lstrPosOrig >&2
  ##local lstrPos="`echo "${lstrXmlLine}" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@CFGFUNCsetGlobals nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #local lstrPos="`echo "${lstrPosOrig}" |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@CFGFUNCsetGlobals nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #eval "$lstrPos" #nX nY nZ
}

function FUNCxmlGetName() { #<strDecorationLine>
  #echo "$1" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
  CFGFUNCxmlGetLinePropertyValue "$1" "//decoration/@name"
}

function FUNCcalcPOINewY() { # <lnY> <lstrPOIold> <lstrPOInew> this will return the Y of the base (bottomest) of the POI
  local lnY="$1";shift
  local lstrPOIold="$1";shift
  local lstrPOInew="$1";shift
  
  local liYOSOld=${astrAllPrefabYOS[$lstrPOIold]-};if [[ -z "${liYOSOld}" ]];then CFGFUNCerrorExit "not found $lstrPOIold";fi
  local liYOSNew=${astrAllPrefabYOS[$lstrPOInew]-};if [[ -z "${liYOSNew}" ]];then CFGFUNCerrorExit "not found $lstrPOInew";fi
  #echo $(( liYOSOld+(liYOSNew-liYOSOld) ))&&:
  
  #help RWG calcs like this right? if terrain y=100 and POI YOffset=-3, POIFinalY=100-3=97. And the game running will then ignore any YOffset, that is used only by RWG right?
  local lNewY=$lnY
  (( lNewY+=(liYOSOld * -1) ))&&: #this will restore the terrain Y at the location
  (( lNewY+=liYOSNew ))&&: #this will then lower the Y if required by the new POI
  
  echo "$lNewY"
  
  #it should keep the original Y as the yOffset will let any y work correctly: a building w/o underground is YOS 0. another with underground height 1 is YOS -1. Both will be correctly placed at y 30 already...
  #echo "$lnY"
  
  #local liYNew=$(( lnY+(liYOSOld-liYOSNew) ));CFGFUNCinfo 'liYNew=$(( lnY+(liYOSOld-liYOSNew) )): '"$liYNew=(( $lnY+($liYOSOld-$liYOSNew) ))"
  
  #FUNCgetWHL "${astrAllPrefabSize[$strPOI]}" #nWidth nHeight nLength
  ##try to use height yoffset and ypos to avoid cutting the building underground on bedrock
  #if((liYOSNew<0));then
    #local liYDiff=$((liYNew+liYOSNew))&&:
    #local liMargin=3
    #if(( liYDiff < $liMargin ));then
      #liYNew+=$(( (-1*liYDiff)+(liMargin*2) ));CFGFUNCinfo 'liYNew+=$(( (-1*liYDiff)+(liMargin*2) )): '"$liYNew+=(( (-1*$liYDiff)+($liMargin*2) ))"
    #fi
  #fi
  
  ##if((liYNew!=lnY));then
    ##declare -p liYOSOld liYOSNew liYNew >&2
  ##fi
  #echo "$liYNew" #OUTPUT
}

#function FUNCxmlGetLinePropertyValue(){ # <lstrLine> <lstrPropID>
  #local lstrLine="$1";shift
  #local lstrPropID="$1";shift
  #echo "$lstrLine" |xmlstarlet sel -t -v "//decoration/@${lstrPropID}"
  ##echo "$lstrLine" |sed -r "s@.* ${lstrPropID}=\"([^\"]*)\".*@\1@"
  ##echo "$lstrLine" |sed -r 's@.* '"${lstrPropID}"'="([^"]*)".*@\1@'
#}
#function FUNCxmlSetLinePropertyValue(){ # <lstrLine> <lstrPropID> <lstrValue>
  #local lstrLine="$1";shift
  #local lstrPropID="$1";shift
  #local lstrValue="$1";shift
  #echo "$lstrLine" |xmlstarlet ed -P -L -u "//decoration/@${lstrPropID}" -v "${lstrValue}" |tail -n 1
  ##echo "$lstrLine" |sed -r "s@(.* ${lstrPropID}=\")[^\"]*(\".*)@\1${lstrValue}\2@"
  ##echo "$lstrLine" |sed -r 's@(.* '"${lstrPropID}"'=")[^"]*(".*)@\1'"${lstrValue}"'\2@'
#}
#function FUNCxmlAppendLinePropertyValue(){ # <lstrLine> <lstrPropID> <lstrValue>
  #local lstrLine="$1";shift
  #local lstrPropID="$1";shift
  #local lstrValue="$1";shift
  
  #local lstrValueOld="`FUNCxmlGetLinePropertyValue "$lstrLine" "$lstrPropID"`"
  #FUNCxmlSetLinePropertyValue "$lstrLine" "$lstrPropID" "${lstrValueOld};${lstrValue}"
#}

#IFS=$'\n' read -d '' -r -a astrRWGOriginalPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig" |tr -d '\r' |egrep -v 'name="${strRegexProtectedPOIs}[^"]*"')&&:
IFS=$'\n' read -d '' -r -a astrRWGOriginalPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig" |tr -d '\r' |sort)&&:
#if [[ "`FUNCxmlGetName "${strPatchedPOIdataLine}"`" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder

strFlAddExtraPOIs="`basename "$0"`.AddExtraPOIs.${strCFGGeneratedWorldTNMFixedAsID}.${strCFGGeneratedWorldSpecificDataAsID}.xml"
CFGFUNCinfo "MAIN:adding extra manually placed POI locations for the current configured world RWG data: ${strFlAddExtraPOIs}"
if [[ -f "$strFlAddExtraPOIs" ]];then
  IFS=$'\n' read -d '' -r -a astrFlAddExtraPOIsList < <(egrep "<decoration " "$strFlAddExtraPOIs" |tr -d '\r' |sort)&&:
  astrRWGOriginalPOIdataLineList+=("${astrFlAddExtraPOIsList[@]}")
else
  if ! CFGFUNCprompt -q "No extra POIs file found (expected: '${strFlAddExtraPOIs}'), is that correct? they are good to help on adding all missing POIs.";then
    CFGFUNCerrorExit "missing file '$strFlAddExtraPOIs'"
  fi
fi

#strFlCACHE="`basename "$0"`.CACHE.sh" #help if you delete the cache file it will be recreated
#source "$strFlCACHE"&&: #this file contents can be like: the last value appended for the save variable will win

function FUNCwriteCacheFile(){ #call this after each var is set
  echo "#PREPARE_RELEASE:REVIEWED:OK" >"${strFlCACHE}"
  echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"${strFlCACHE}"
  declare -p iTotalChkBiome >>"${strFlCACHE}"
  #declare -p iReservedWastelandPOICountForMissingPOIs >>"${strFlCACHE}"
  declare -p astrEvalV3cache >>"${strFlCACHE}"
  # put all cache vars here!
  
  # cfg vars can go like this:
  echo ': ${iReservedWastelandPOICountForMissingPOIs:='"${iReservedWastelandPOICountForMissingPOIs-0}"'}' >>"${strFlCACHE}"
}

bUpdateBiomeCache=false
: ${iTotalChkBiome:=0}
if((iTotalChkBiome==0));then
  bUpdateBiomeCache=true
fi
if((iTotalChkBiome>0));then
  if CFGFUNCprompt -q "Biome cache found: iTotalChkBiome=$iTotalChkBiome. Update biome cache anyway (will take a very long time)? this is required if you just used the Engine RWG and have a new prefabs.xml file and a new biome png file.";then #todo check sha1sum for biome and prefabs file, if they changed this will be automatic
    bUpdateBiomeCache=true
  fi
fi
if $bUpdateBiomeCache;then
  CFGFUNCinfo "MAIN:updating all biomes info for all prefabs originally placed by RWG at '${strFlGenPrefabsOrig}'. This happens only once and will take a lot of time. Please wait this step end."
  for strGenPOIdataLine in "${astrRWGOriginalPOIdataLineList[@]}";do
    ((iTotalChkBiome++))&&:
    CFGFUNCinfo "UpdateBiomeDataFor(${iTotalChkBiome}/${#astrRWGOriginalPOIdataLineList[@]}): ${strGenPOIdataLine}"
    FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strGenPOIdataLine}"
    ./getBiomeData.sh "$nX,$nY,$nZ" #just to create the database
  done
  FUNCwriteCacheFile
fi
source "./getBiomeData.sh.PosVsBiomeColor.CACHE.sh" #this line is allowed to fail, do not protect with &&:
#eval "$(CFGFUNCbiomeData "-391,36,-2422")";declare -p iBiome strBiome strColorAtBiomeFile
#exit

if((iReservedWastelandPOICountForMissingPOIs>0));then
  if CFGFUNCprompt -q "iReservedWastelandPOICountForMissingPOIs=$iReservedWastelandPOICountForMissingPOIs, do you want to set it to 0 so you can see how much is needed again (this will take a long time)? (if not, that value will be used now)";then
    iReservedWastelandPOICountForMissingPOIs=0
  fi
  FUNCwriteCacheFile
fi

#IFS=$'\n' read -d '' -r -a astrPrefabPOIsPathList < <(cd "${strCFGGameFolder}"/;find "`pwd`/" -type d -iregex ".*[/]Prefabs[/]POIs")&&:
IFS=$'\n' read -d '' -r -a astrPrefabPathList < <(cd "${strCFGGameFolder}"/;find "`pwd`/" -type d -iregex ".*[/]Prefabs[/]\(POIs\|Parts\|RWGTiles\|Test\)")&&:
declare -p astrPrefabPathList |tr '[' '\n'

CFGFUNCinfo "MAIN:colleting all valid POIs from prefabs xmls (later will check if any was ignored by RWG or removed from non wasteland town areas)"
IFS=$'\n' read -d '' -r -a astrAllPOIsList < <(
  for strPrefabPath in "${astrPrefabPathList[@]}";do
    if [[ "${strPrefabPath}" =~ .*/POIs$ ]];then
      cd "$strPrefabPath"
      pwd >/dev/stderr;
      ls *.xml|sed -r 's@[.]xml@@'|egrep -v "${strRegexIgnoreOrig}"|sort
    fi
  done
)&&:
if((${#astrAllPOIsList[@]}==0));then CFGFUNCerrorExit "astrAllPOIsList empty";fi

CFGFUNCinfo "MAIN:colleting all POIs Y offset and size from prefabs"
#strFlTmp="`mktemp`"
strFlTmp="`pwd`/_tmp/`basename "$0"`.POIsYOS.tmp.txt" #todo cache this. deleting it will refresh the cache
echo -n >"$strFlTmp"
declare -A astrAllPrefabYOS
declare -A astrAllPrefabSize
#execCFGAliases="eval $("$(realpath ./libSrcCfgGenericToImport.sh)" --aliases)"
( # subshell to easy changing path
  #$execCFGAliases
  for strPrefabPath in "${astrPrefabPathList[@]}";do
    cd "$strPrefabPath"
    #cd "${strCFGGameFolder}"/Data/Prefabs/POIs
    pwd >/dev/stderr;
    IFS=$'\n' read -d '' -r -a astrPrefabsList < <(ls *.xml&&:)&&:
    for strFlPrefabXml in "${astrPrefabsList[@]}";do
      strPOI="${strFlPrefabXml%.xml}"
    #for strPOI in "${astrAllPOIsList[@]}";do
      #$execCFGAliases
      #declare -p execCFGAliases
      #shopt -s expand_aliases
      #alias CFGFUNCinfoA='CFGFUNCinfo -l $LINENO'
      #shopt -s expand_aliases
      #shopt -s expand_aliases
      #eval "`./libSrcCfgGenericToImport.sh --aliases`"
      #CFGFUNCinfo "`realpath "${strPOI}.xml"`"
      
      if ! iYOS="`xmlstarlet sel -t -v "//property[@name='YOffset']/@value" "${strPOI}.xml"`";then
        iYOS=0
        CFGFUNCinfo "WARN: YOffset missing for strPOI='$strPOI', using default iYOS='$iYOS'"
      fi
      if((iYOS>0));then CFGFUNCinfo "INTERESTING: positive YOffset $iYOS for strPOI='$strPOI'";fi
      #iYOS="`egrep '"YOffset"' "${strPOI}.xml" |egrep 'value="[^"]*"' -o |tr -d '[a-zA-Z"=]'`"
      echo "astrAllPrefabYOS[$strPOI]=$iYOS" >>"$strFlTmp"
      
      if ! strSize="`xmlstarlet sel -t -v "//property[@name='PrefabSize']/@value" "${strPOI}.xml" |tr -d ' '`";then
        strSize="1,1,1"
        CFGFUNCinfo "WARN: PrefabSize missing for strPOI='$strPOI', using default strSize='$strSize'"
      fi
      #<property name="PrefabSize" value="60, 108, 60" />
      echo "astrAllPrefabSize[$strPOI]='$strSize'" >>"$strFlTmp"
      
      CFGFUNCinfo "strPrefabPath=${strPrefabPath}/ ${strFlPrefabXml} iYOS=$iYOS strSize=$strSize"
    done
  done
)
source "$strFlTmp"
declare -p astrAllPrefabYOS |tr '[' '\n'
declare -p astrAllPrefabSize |tr '[' '\n'

strFlImportantBuildings="`basename "$0"`.AddedToRelease.ImportantBuildings.txt" #help if you delete the cache file it will be recreated
echo -n >>"$strFlImportantBuildings" #just to create it if needed
astrSpecialBuildingPOI=(`cat "$strFlImportantBuildings"`)&&:
if [[ -z "${astrSpecialBuildingPOI[@]-}" ]];then
  CFGFUNCinfo "MAIN:show special POIs (usually the tallest) to cherry pick for buildings, that are like a small town to explore"
  for strPOI in "${!astrAllPrefabSize[@]}";do
    if [[ -f "${strCFGGameFolder}/Prefabs/POIs/${strPOI}.xml" ]];then
      FUNCgetWHL "${astrAllPrefabSize[$strPOI]}"
      echo "nHeight=$nHeight, $strPOI size ${astrAllPrefabSize[$strPOI]}"
    fi
  done |egrep -vi "000_|AAA_|part_|rwg_|test_" |sort -n |tee -a "$strCFGScriptLog"
  CFGFUNCprompt "please cherry pick the important special buildings (probably the tallest ones but others may be good too) that have a lot to be explored in just a single building, and place one per line in the file: $strFlImportantBuildings"
  CFGFUNCerrorExit "the important buildings list was empty, re-run after editing the required file"
fi

function FUNChelpInfoPOI() {
  local lstrName="$1"
  echo "${lstrName},YOffset=${astrAllPrefabYOS[${lstrName}]-},Size=${astrAllPrefabSize[${lstrName}]-}"
}

CFGFUNCinfo "MAIN:create help and sorter xml properties for all POIs"
#for strGenPOIdataLine in "${astrRWGOriginalPOIdataLineList[@]}";do
for((i=0;i<"${#astrRWGOriginalPOIdataLineList[@]}";i++));do
  strGenPOIdataLine="${astrRWGOriginalPOIdataLineList[i]}"
  
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strGenPOIdataLine}"
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  
  # helpFilterIndex would be used to grant no clashes will happen (but no clash will happen as position is already unique as POIs wont be placed above or below others)
  strName="`FUNCxmlGetName "$strGenPOIdataLine"`"
  strHelp="${strBiome};${strColorAtBiomeFile};OriginalPOI(`FUNChelpInfoPOI "${strName}"`)"
  strSed='s@(name=")([^"]*)(")@helpSort="'"${strName}"'" helpFilterIndex="'$i'" \1\2\3 help="'"${strHelp}"'"@'
  astrRWGOriginalPOIdataLineList[$i]="`echo "$strGenPOIdataLine" |sed -r "$strSed"`"
  CFGFUNCinfo "${astrRWGOriginalPOIdataLineList[$i]}"
done
declare -p astrRWGOriginalPOIdataLineList |tr '[' '\n'

CFGFUNCinfo "MAIN:collecting original location (to know the Y) for each POI originally placed by RWG. that Y was calculated based on the POI YOffset originally placed there (I guess). This Y can be used to calculate the new Y based on the difference of the YOffset of the old POI and the new POI that will be placed there (just skip the underground ones that are a fun trap)."
declare -A astrRWGOriginalLocationVsPOI=()
#for strGenPOIdataLine in "${astrRWGOriginalPOIdataLineList[@]}";do
for((i=0;i<"${#astrRWGOriginalPOIdataLineList[@]}";i++));do
  strGenPOIdataLine="${astrRWGOriginalPOIdataLineList[i]}"
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strGenPOIdataLine}"
  strOriginalPOI="`FUNCxmlGetName "$strGenPOIdataLine"`"
  astrRWGOriginalLocationVsPOI["$nX,$nY,$nZ"]="${strOriginalPOI}"
  #astrRWGOriginalPOIdataLineList[$i]="`CFGFUNCxmlSetLinePropertyValue "${astrRWGOriginalPOIdataLineList[$i]}" "//decoration/@helpFilterIndex" "$i"`" #this index will be used to grant no clashes will happen (but no clash will happen as position is already unique as POIs wont be placed above or below others)
  #echo "$LINENO:RET=$?" >&2
  #astrRWGOriginalPOIdataLineList[$i]="`CFGFUNCxmlAppendLinePropertyValue "${astrRWGOriginalPOIdataLineList[$i]}" "//decoration/@help" "strOriginalPOI=${strOriginalPOI}"`"
  #echo "$LINENO:RET=$?" >&2
  CFGFUNCinfo "UPDATED:HelpInfo:${astrRWGOriginalPOIdataLineList[$i]}"
done

CFGFUNCinfo "MAIN:delete all POIs from TOWNS that are outside wasteland and were originally placed by RWG at '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
astrPatchedPOIdataLineList=()
iTotalRemovedPOIsFromTownsOutsideWasteland=0
declare -A astrVaporisedTownsRestoreOnePOIPerRectangle
astrVaporisedTownsRestoreOnePOIPerRectangle=()
for strGenPOIdataLine in "${astrRWGOriginalPOIdataLineList[@]}";do
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strGenPOIdataLine}"
  if ! FUNCchkPosIsInTownPIT --ignore Wasteland $nX $nZ;then
    astrPatchedPOIdataLineList+=("${strGenPOIdataLine}")
    echo -n "." # ok POIs
  else
    ((iTotalRemovedPOIsFromTownsOutsideWasteland++))&&:
    CFGFUNCinfo "INFO:RemovingNonWastelandTownPrefabFromList[$iTotalRemovedPOIsFromTownsOutsideWasteland]: ${strGenPOIdataLine}"
    if ! [[ "${strXLDPrefabCurrentName}" =~ ^${strRegexProtectedPOIs} ]];then
      astrVaporisedTownsRestoreOnePOIPerRectangle["${strPITTownID}"]="${strGenPOIdataLine}" #this will keep one POI per town rectangle (if a town have 2 rectangles, it will be 2 on that town). Add more rectangles to keep more POIs.
    fi
  fi
done
if((${#astrTownList[@]}>0)) && ((iTownRectanglesOutsideWastelandCount>0)) && ((iTotalRemovedPOIsFromTownsOutsideWasteland==0));then
  CFGFUNCerrorExit "there are configured town regions outside wasteland but nothing was removed from them! are the rectangles correctly configured in the '${strFlTownRect}' file?"
fi
declare -p astrVaporisedTownsRestoreOnePOIPerRectangle |tr '[' '\n'
if((${#astrVaporisedTownsRestoreOnePOIPerRectangle[@]}>0));then
  astrPatchedPOIdataLineList+=("${astrVaporisedTownsRestoreOnePOIPerRectangle[@]}") #TODO replace with strDummyPOI ?
fi

CFGFUNCinfo "MAIN:collecting special buildings POIs that shall all be placed only in the wasteland"
astrSpecialBuildingList=()
#for strPOI in "${astrAllPOIsList[@]}";do
for((i=0;i<"${#astrAllPOIsList[@]}";i++));do
  strPOI="${astrAllPOIsList[i]}"
  for strSpecialBuildingPOI in "${astrSpecialBuildingPOI[@]}";do
    if [[ "${strPOI}" =~ ^${strSpecialBuildingPOI}$ ]];then
      CFGFUNCinfo "SpecialBuildingFound: $strPOI"
      astrSpecialBuildingList+=("$strPOI")
      unset astrAllPOIsList[$i] #removing special buildings from the full list
    fi
  done
done
astrAllPOIsList=("${astrAllPOIsList[@]}") #fixes the array after removing the entries
iTotalUniqueSpecialBuildings=${#astrSpecialBuildingList[@]}
if((iTotalUniqueSpecialBuildings==0));then CFGFUNCerrorExit "invalid iTotalUniqueSpecialBuildings=0. Special POIs are required to prepare end game Wasteland region";fi

CFGFUNCinfo "MAIN:replacing special buildings outside wasteland with a dup to be replaced again later with unique POIs"
strDummyPOI="abandoned_house_01" #this simple POI may happen many times to be replaced
iRemovedSpecialBuildingsFromNonWasteland=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strPatchedPOIdataLine}"
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" != "Wasteland" ]];then
    astrRemoveTradersIfOutsideWasteland+=( #see AddExtraSpecialPOIs to place them by hand in different biomes
     trader_hugh
     trader_bob
     trader_jen
     trader_joel
     trader_rekt
    )
    if CFGFUNCarrayContains "`FUNCxmlGetName "$strPatchedPOIdataLine"`" "${astrSpecialBuildingList[@]}" "${astrRemoveTradersIfOutsideWasteland[@]}";then
      CFGFUNCinfo "BEFORE:$strBiome: $strPatchedPOIdataLine"
      strSedReplaceId='s/name="[^"]*"/name="'"${strDummyPOI}"'"/'
      astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
      CFGFUNCinfo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
      ((iRemovedSpecialBuildingsFromNonWasteland++))&&:
    fi
  fi
done

CFGFUNCinfo "MAIN:replacing POIs inside wasteland with a dup so the remaining ones will be replaced again later with special buildings or missing POIs"
iTotalWastelandPOIsLeastInTowns=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strPatchedPOIdataLine}"
  if FUNCchkPosIsInTownPIT $nX $nZ;then echo -n "Wt,";continue;fi #skip the wasteland town!
  
  #strPrefabCurrentName="`FUNCxmlGetName "${strPatchedPOIdataLine}"`"
  if [[ "${strXLDPrefabCurrentName}" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder
  
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" == "Wasteland" ]];then
    CFGFUNCinfo "BEFORE:$strBiome: $strPatchedPOIdataLine"
    strSedReplaceId='s/name="[^"]*"/name="'"${strDummyPOI}"'"/'
    astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
    CFGFUNCinfo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
    if echo "${astrPatchedPOIdataLineList[i]}" |egrep " name=\"${strRegexProtectedPOIs}";then
      CFGFUNCDevMeErrorExit "wrong replacing above strXLDPrefabCurrentName='$strXLDPrefabCurrentName' strRegexProtectedPOIs='$strRegexProtectedPOIs'"
    fi
    ((iTotalWastelandPOIsLeastInTowns++))&&:
  fi
done

CFGFUNCinfo "MAIN:placing special buildings in the wasteland"
strMarkToSkip="_MARKED_TO_BE_SKIPPED_"
iLastPPOIindexReplaced=0
: ${iReservedWastelandPOICountForMissingPOIs:=0} #help after running the script, if there is missing POIs, put that value on this var TODO check the prefabs ignored thru strRegexIgnoreGen, may be some of them could be used instead of preventing buildings being added on the wasteland below
iNotUsedReservedWastelandPOICountForMissingPOIs=$iReservedWastelandPOICountForMissingPOIs
iTotalSpecialBuildingsPlacedInWasteland=0
iLoopCount=0
iDiffTotWPOIsVsReserved=$((iTotalWastelandPOIsLeastInTowns - iReservedWastelandPOICountForMissingPOIs))
bHintAboutReservingPOIs=false
while true;do #this loop will try to populate the whole wasteland (least the RGW town) with special buildings 
  bTryFitMore=true
  ((iLoopCount++))&&:
  for strSpecialBuilding in "${astrSpecialBuildingList[@]}";do
    #for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    bReplaced=false
    for((i=iLastPPOIindexReplaced;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
      if((iLoopCount>=2));then #to make it sure all the priority POIs will be placed
        bHintAboutReservingPOIs=true;
        if(( iTotalSpecialBuildingsPlacedInWasteland >= iDiffTotWPOIsVsReserved ));then
          iRemained=$(( iReservedWastelandPOICountForMissingPOIs-(iTotalSpecialBuildingsPlacedInWasteland-iDiffTotWPOIsVsReserved) ))
          CFGFUNCinfo "Keeping ${iRemained} wasteland places to use with missing POIs"
          bReplaced=false;
          bTryFitMore=false;
          break;
        fi
      fi
      
      echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
      strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
      if [[ "$strPatchedPOIdataLine" =~ name=\"${strMarkToSkip}[^\"]*\" ]];then echo -n .;continue;fi
      
      FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strPatchedPOIdataLine}"
      if FUNCchkPosIsInTownPIT $nX $nZ;then echo -n .;continue;fi #skip the wasteland town!
      
      eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
      #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
      if [[ "$strBiome" == "Wasteland" ]];then
        CFGFUNCinfo "BEFORE:$i: $strPatchedPOIdataLine"
        strSedReplaceId='s/name="[^"]*"/name="'"${strMarkToSkip}${strSpecialBuilding}"'"/'
        strSedReplaceIdHS='s/helpSort="[^"]*"/helpSort="'"${strSpecialBuilding}"'"/'
        astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r -e "${strSedReplaceId}" -e "${strSedReplaceIdHS}"`"
        CFGFUNCinfo "AFTER_:$i: ${astrPatchedPOIdataLineList[i]}"
        ((iTotalSpecialBuildingsPlacedInWasteland++))&&:
        iLastPPOIindexReplaced=$i
        bReplaced=true
        break
      fi
    done
    if ! $bReplaced;then bTryFitMore=false;break;fi
  done
  if ! $bTryFitMore;then break;fi
done
CFGFUNCinfo "MAIN:placing special buildings in the wasteland: remove skip marker from IDs"
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  astrPatchedPOIdataLineList[i]="`echo "${astrPatchedPOIdataLineList[i]}" |sed -r "s/${strMarkToSkip}//"`"
done
declare -p astrPatchedPOIdataLineList |tr '[' '\n'

CFGFUNCinfo "MAIN:collecting remaining POIs originally placed by RWG"
IFS=$'\n' read -d '' -r -a astrGenPOIsList < <(
  #cd "${strCFGGameFolder}"; # bash uses the symlinked path while ls and cat use the realpath
  #pwd >/dev/stderr;
  #cat "$strFlGenPrefabsOrig" 
  #echo "$strGenPrefabsData"           \
  #
  for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    #echo "$strPatchedPOIdataLine" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
    FUNCxmlGetName "$strPatchedPOIdataLine"
  done |egrep -v "${strRegexIgnoreGen}" |sort # sort (non unique) is essential here to make replacing easier
)&&:
if((${#astrGenPOIsList[@]}==0));then CFGFUNCerrorExit "astrGenPOIsList empty";fi

CFGFUNCinfo "MAIN:searching for missing POIs (that RWG ignored or were removed from non wasteland town areas)"
astrMissingPOIsList=()
for strPOI in "${astrAllPOIsList[@]}";do
  bFound=false
  for strGenPOI in "${astrGenPOIsList[@]}";do
    if [[ "$strGenPOI" == "$strPOI" ]];then
      bFound=true
      break
    fi
  done
  if ! $bFound;then 
    astrMissingPOIsList+=("$strPOI");
  fi
done
if((${#astrMissingPOIsList[@]}==0));then
  CFGFUNCinfo "No missing POIs."
  exit 0
fi

CFGFUNCinfo "MAIN:granting POIs IDs (from filenames) have no spaces (if they have, this script must be updated to prevent errors)"
#echo "DEBUG:$LINENO:astrMissingPOIsList:Size:${#astrMissingPOIsList[@]}"
for strMissingPOI in "${astrMissingPOIsList[@]}";do
  if [[ "${strMissingPOI}" =~ .*[\ ].* ]];then
    CFGFUNCerrorExit "Ln$LINENO: this prefab has space(s) on the filename: '${strMissingPOI}'" >/dev/stderr
  fi
done
astrMissingPOIsList=(`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort -u`)
astrMPOItmp=("${astrMissingPOIsList[@]}")
#astrMissingPOIsList=(`echo "${astrMPOItmp[@]}" |tr " " "\n" |sort -u`)
#declare -p astrMPOItmp astrMissingPOIsList |tr '[' '\n' |tee -a "$strCFGScriptLog"
#if((${#astrMissingPOIsList[@]}!=${#astrMPOItmp[@]}));then
  #CFGFUNCerrorExit "Ln$LINENO: arrays sizes should match, some prefab has space(s) on the filename" >/dev/stderr
  ##exit 1
#fi
astrMPOIbkp=("${astrMissingPOIsList[@]}")

#: ${nSeedRandomPOIs:=1337} #help this seed wont give the same result on other game versions that have a different ammount of POIs (or if you added new custom POIs)
#CFGFUNCinfo "MAIN:randomizing POIs order using seed '$nSeedRandomPOIs'"
CFGFUNCinfo "MAIN:randomizing POIs order using predictable random seed"
#RANDOM=${nSeedRandomPOIs} 
astrMissingPOIsList=() #reset to randomize
#for strPOI in "${astrMPOItmp[@]}";do
iTot="${#astrMPOItmp[@]}"
for((i=0;i<iTot;i++));do
  CFGFUNCpredictiveRandom POIsOrder
  iRnd="$(( iPRandom % ${#astrMPOItmp[@]} ))"
  strPOI="${astrMPOItmp[$iRnd]}"
  unset astrMPOItmp[$iRnd] #this clears the entry but do not change the array size
  astrMPOItmp=("${astrMPOItmp[@]}") #to update the array size
  astrMissingPOIsList+=("$strPOI")
done
if((${#astrMPOItmp[@]}>0));then
  declare -p astrMPOItmp |tr "[" "\n" >/dev/stderr
  #echo "ERROR:$LINENO: not empty" >/dev/stderr
  CFGFUNCerrorExit "Ln$LINENO: the list used to extract POIs randomly is not empty. Because only when it is empty it means all POIs got extracted from it."
  #exit 1
fi
unset astrMPOItmp #to not reuse it empty
if((${#astrMissingPOIsList[@]}!=${#astrMPOIbkp[@]}));then
  CFGFUNCerrorExit "ERROR:$LINENO: sizes should match"
  #exit 1
fi
if [[ "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort`" != "`echo "${astrMPOIbkp[@]}" |tr " " "\n" |sort`" ]];then
  CFGFUNCerrorExit "ERROR:$LINENO: contents should match"
  #exit 1
fi
if [[ "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort`" != "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort -u`" ]];then
  CFGFUNCerrorExit "ERROR:$LINENO: contents should match"
  #exit 1
fi
declare -p astrMissingPOIsList |tr "[" "\n"

#CFGFUNCinfo "MAIN:detecting repetead POIs"
#declare -A astrGenPOIsDupCountList=()
#for strGenPOI in "${astrGenPOIsList[@]}";do
  #if [[ "${strGenPOI}" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder
  ##strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  ##eval "$strPos" #nX nY nZ
  #astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
#done
#for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  #if((${astrGenPOIsDupCountList[$strGPD]}==1));then
    #unset astrGenPOIsDupCountList[$strGPD]
  #fi
#done
#declare -p astrGenPOIsDupCountList |tr '[' '\n' |tee -a "$strCFGScriptLog"

#astrGenPOIsDupCountList=("${astrGenPOIsDupCountList[@]}")

#CFGFUNCinfo "MAIN:delete all prefabs from towns that are outside wasteland: '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
#IFS=$'\n' read -d '' -r -a astrRWGOriginalPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig")&&:
#astrPatchedPOIdataLineList=()
#for strGenPOIdataLine in "${astrRWGOriginalPOIdataLineList[@]}";do
  #FUNCgetXYZfromXmlLine_outXYZaXLDglobals "${strGenPOIdataLine}"
  #if ! FUNCchkPosIsInTownPIT --ignore Wasteland $nX $nZ;then
    #astrPatchedPOIdataLineList+=("${strGenPOIdataLine}")
  #else
    #echo "INFO:RemovingNonWastelandTownPrefabFromList: ${strGenPOIdataLine}"
  #fi
#done

CFGFUNCinfo "MAIN:preparing patch file: only decorations lines"
#"${strFlPatched}${strGenTmpSuffix}"
: ${strFlPatched:="${strTmpPath}/tmp.`basename "$0"`.`date +"${strCFGDtFmt}"`.${strPrefabsXml}${strGenTmpSuffix}"} #help
strEnclosurerToken="ENCLOSURER_TOKEN_REMOVE_THIS_LINE"
echo '' >"$strFlPatched" #easy trunc
echo "<${strEnclosurerToken}>" >>"$strFlPatched" #this enclosurer wil prevent xmlstarlet error: "3.1: Extra content at the end of the document"
echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >>"$strFlPatched" #as this file will be copied to outside this modlet folder
for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
  echo "$strPatchedPOIdataLine" >>"$strFlPatched" #this way it becomes a sector patch for gencodeApply.sh!
done
echo "</${strEnclosurerToken}>" >>"$strFlPatched"
#egrep "<decoration " "$strFlGenPrefabsOrig" >>"$strFlPatched" #this way it becomes a sector patch for gencodeApply.sh!
#(cd "${strCFGGameFolder}";cp -fv "$strFlGenPrefabsOrig" "$strFlPatched")
cp -v "$strFlPatched" "${strFlPatched}.BackupBeforeFurtherPatchingIt.xml" #good to see data to help debugging

CFGFUNCinfo "MAIN:detecting repetead POIs"
declare -A astrGenPOIsDupCountList=()
for strGenPOI in "${astrGenPOIsList[@]}";do
  if [[ "${strGenPOI}" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder
  #strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
  #astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
  astrGenPOIsDupCountList["$strGenPOI"]="$(egrep "[ ]name=\"${strGenPOI}\"[ ]" "$strFlPatched" |wc -l)" #the dup count from file is granted
done
astrRWGsinglePOIsList=() #these POIs will not be replaced
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  if((${astrGenPOIsDupCountList[$strGPD]}==1));then # clear non dups
    unset astrGenPOIsDupCountList[$strGPD]
    #astrRWGsinglePOIsList+=("$strGPD")
  fi
  astrRWGsinglePOIsList+=("$strGPD") #here because all/most dups will be replaced and then only one will remain
done
declare -p astrGenPOIsDupCountList |tr '[' '\n' |tee -a "$strCFGScriptLog"

#function FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile() { #<lstrPrefab> works always on the 2nd match found, therefore the 1st remains unique in the end
  #local lstrPrefab="$1";shift
  ##local lstrPos="`echo "$strGenPrefabsData" |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  ##local lstrPos="`for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do echo "${strPatchedPOIdataLine}";done |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  #local lstrLine="$(egrep "[ ]name=\"${lstrPrefab}\"[ ]" "$strFlPatched" |head -n 2 |tail -n 1)" # do not use `` it will fail resulting in 0, only $() worked!!! why? anyway `` is deprecated for bash...
  #FUNCgetXYZfromXmlLine_outXYZaXLDglobals "$lstrLine"
#}
function FUNCget2ndMatchingPrefabOnPatcherFile() { #<lstrPrefab> works always on the 2nd match found, therefore the 1st remains unique in the end
  local lstrPrefab="$1";shift
  #local lstrPos="`echo "$strGenPrefabsData" |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  #local lstrPos="`for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do echo "${strPatchedPOIdataLine}";done |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  local lstrLine="$(egrep "[ ]name=\"${lstrPrefab}\"[ ]" "$strFlPatched" |head -n 2 |tail -n 1)" # do not use `` it will fail resulting in 0, only $() worked!!! why? anyway `` is deprecated for bash...
  #FUNCgetXYZfromXmlLine_outXYZaXLDglobals "$lstrLine"
  echo "$lstrLine"
}
#function FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile() { #<strPrefab>
  #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@CFGFUNCsetGlobals nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
#}

CFGFUNCinfo "MAIN:preparing patch file: replacing repeated POIs with random new POIs"
function FUNCpatchFileCurrentIndex_HelpGet() {
  local lstrHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" "$strFlPatched"`"
  echo "$lstrHelp"
}
function FUNCpatchFileCurrentIndex_HelpAppend() {
  local lstrHelp="`FUNCpatchFileCurrentIndex_HelpGet`"
  lstrHelp+="$1"
  CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" -v "${lstrHelp}" "$strFlPatched"
}      

iTotalTrapsInWorld=0
iMaxTrapsInASinglePOI=0
function FUNCpatchFileCurrentIndex_TrapAdd() { #required input vars: astrAllPrefabSize strFlPatched nNewPOIWidth nNewPOILength strBiome strColorAtBiomeFile nX nY nZ strRWGoriginalPOI iXLDFilterIndex 
  : ${iTryTrapEveryPOIcount:=1} #help was 3, now every POI will have a trap around it with this set to 1
  : ${iTryAddWildTrap:=0}
  ((iTryAddWildTrap++))&&:
  if((iTryAddWildTrap>=iTryTrapEveryPOIcount));then
    : ${bCreateWildernessTraps:=true} #help they will be near POIs tho...
    if $bCreateWildernessTraps;then
      iTrapTot=$(( 2*(nNewPOIWidth+nNewPOILength)/16 )) #the full perimeter length. 16 dist between each trap (but instead they will be placed randomly)
      if((iTrapTot<1));then iTrapTot=1;fi
      if((iMaxTrapsInASinglePOI<iTrapTot));then iMaxTrapsInASinglePOI=$iTrapTot;fi
      for((iCurrentTrapIndex=0;iCurrentTrapIndex<iTrapTot;iCurrentTrapIndex++));do
        #iYOTrap=0 #TODO is the YOffset used only by RWG to place POIs? so, when the game is running it will ignore YOffset as RWG already calculated using it right?
        if [[ "$strBiome" == "PineForest" ]];then
          strPrefabTrap="part_TNM_WildernessTrapForest"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltForest";fi
        fi
        if [[ "$strBiome" == "Snow" ]];then
          strPrefabTrap="part_TNM_WildernessTrapSnow"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltSnow";fi
        fi
        if [[ "$strBiome" == "Desert" ]];then
          strPrefabTrap="part_TNM_WildernessTrapDesert"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltDesert";fi
        fi
        if [[ "$strBiome" == "Wasteland" ]];then
          strPrefabTrap="part_TNM_WildernessTrapWasteland"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltWasteland";fi
        fi
        FUNCgetWHL "${astrAllPrefabSize[${strPrefabTrap}]}"
        nTrapW=$nWidth
        nTrapH=$nHeight
        nTrapL=$nLength
        
        #POI origin is always bottom left corner. this will place a trap around every POI following that square line. X is +right -left. Z is +up -down.
        nTrapX=$nX
        #nTrapY=$((nY+(nYOffsetOld * -1)+iYOTrap))
        nTrapY="`FUNCcalcPOINewY $nY "$strRWGoriginalPOI" "$strPrefabTrap"`"
        nTrapZ=$nZ
        CFGFUNCpredictiveRandom TrapVaryXorZ
        if((iPRandom%2==0));then #vary X
          CFGFUNCpredictiveRandom TrapX
          ((nTrapX+=iPRandom%nNewPOIWidth))&&: 
          CFGFUNCpredictiveRandom TrapZTop
          if((iPRandom%2==0));then #because the default is already on Z bottom
            ((nTrapZ+=nNewPOILength+1))&&: #this ends already totally outside POI area
          else
            ((nTrapZ-=nLength+1))&&: #so the trap stays outside the POI area to not destroy its' edges
          fi
        else #vary Z
          CFGFUNCpredictiveRandom TrapZ
          ((nTrapZ+=iPRandom%nNewPOILength))&&: #POI origin is always bottom left corner
          CFGFUNCpredictiveRandom TrapXRight
          if((iPRandom%2==0));then #because the default is already on X left
            ((nTrapX+=nNewPOIWidth+1))&&: #this ends already totally outside POI area
          else
            ((nTrapX-=nTrapW+1))&&: #so the trap stays outside the POI area to not destroy its' edges
          fi
        fi
        CFGFUNCpredictiveRandom WildernessTrap
        echo '  <decoration type="model" name="'"${strPrefabTrap}"'" help="'"${strBiome};${strColorAtBiomeFile};"'WildernessTrap('"$iCurrentTrapIndex/$iTrapTot"'):POIIndex:'"${iXLDFilterIndex}"'" position="'"$nTrapX,$nTrapY,$nTrapZ"'" rotation="'"$((iPRandom%4))"'"/>' >>"${strFlPatched}.WildernessTrap.xml"
        ((iTotalTrapsInWorld++))&&:
      done
    fi
    iTryAddWildTrap=0
  fi
}
function FUNCpatchFileCurrentIndex_TrapAdd_BugouOuNao() { #required input vars: astrAllPrefabSize strFlPatched nNewPOIWidth nNewPOILength strBiome strColorAtBiomeFile nX nY nZ strRWGoriginalPOI iXLDFilterIndex     nOrigPOIWidth    nOrigPOIHeight    nOrigPOILength

  : ${iTryTrapEveryPOIcount:=1} #help was 3, now every POI will have a trap around it with this set to 1
  : ${iTryAddWildTrap:=0}
  ((iTryAddWildTrap++))&&:
  if((iTryAddWildTrap>=iTryTrapEveryPOIcount));then
    : ${bCreateWildernessTraps:=true} #help they will be near POIs tho. TODO find what file holds the elevation of any spot in the map
    if $bCreateWildernessTraps;then
      : ${liBiggestTrapSize:=4} #help traps are all square
      : ${liTrapSizeGap:=4} #help between each trap there shall have this distance based in current trap size (but as positioning is random 1x1 this will never happen like a chessboard that would require random 4x4 but then it would be more predictable and less fun)
      local liPseudoDistBetweenTraps=$((liBiggestTrapSize*liTrapSizeGap))
      local liTrapTot=$(( 2*(nNewPOIWidth+nNewPOILength)/liPseudoDistBetweenTraps )) #the full perimeter length. 16 dist between each trap (but instead they will be placed randomly)
      if((liTrapTot<1));then liTrapTot=1;fi
      #for((liCurrentTrapIndex=0;liCurrentTrapIndex<liTrapTot;liCurrentTrapIndex++));do
      local liCurrentTrapIndex=0
      local lbAllowIncTotOnce=true
      while true;do
        #iYOTrap=0 #TODO is the YOffset used only by RWG to place POIs? so, when the game is running it will ignore YOffset as RWG already calculated using it right?
        if [[ "$strBiome" == "PineForest" ]];then
          strPrefabTrap="part_TNM_WildernessTrapForest"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltForest";fi
        fi
        if [[ "$strBiome" == "Snow" ]];then
          strPrefabTrap="part_TNM_WildernessTrapSnow"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltSnow";fi
        fi
        if [[ "$strBiome" == "Desert" ]];then
          strPrefabTrap="part_TNM_WildernessTrapDesert"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltDesert";fi
        fi
        if [[ "$strBiome" == "Wasteland" ]];then
          strPrefabTrap="part_TNM_WildernessTrapWasteland"
          if((iTotalTrapsInWorld%2==0));then strPrefabTrap="part_TNM_TrapAltWasteland";fi
        fi
        FUNCgetWHL "${astrAllPrefabSize[${strPrefabTrap}]}"
        nTrapW=$nWidth
        nTrapH=$nHeight
        nTrapL=$nLength
        
        #POI origin is always bottom left corner. this will place a trap around every POI following that square line. X is +right -left. Z is +up -down.
        nTrapX=$nX
        #nTrapY=$((nY+(nYOffsetOld * -1)+iYOTrap))
        nTrapY="`FUNCcalcPOINewY $nY "$strRWGoriginalPOI" "$strPrefabTrap"`"
        nTrapZ=$nZ
        CFGFUNCpredictiveRandom TrapVaryXorZ
        local lnDiffOrigNewTrapW=0 lnDiffOrigNewTrapL=0
        if((iPRandom%2==0));then #vary X
          CFGFUNCpredictiveRandom TrapX
          ((nTrapX+=iPRandom%nNewPOIWidth))&&: 
          CFGFUNCpredictiveRandom TrapZTop
          if((iPRandom%2==0));then #because the default is already on Z bottom
            ((nTrapZ+=nNewPOILength+1))&&: #this ends already totally outside POI area
            lnDiffOrigNewTrapW=$((nOrigPOILength-nNewPOILength-nTrapL))
            if((lnDiffOrigNewTrapW>0));then ((nTrapZ+=iPRandom%lnDiffOrigNewTrapW))&&:;fi #this will fit the trap in the available area between original and new POI, if original was bigger than new
          else
            ((nTrapZ-=nLength+1))&&: #so the trap stays outside the POI area to not destroy its' edges
          fi
        else #vary Z
          CFGFUNCpredictiveRandom TrapZ
          ((nTrapZ+=iPRandom%nNewPOILength))&&: #POI origin is always bottom left corner
          CFGFUNCpredictiveRandom TrapXRight
          if((iPRandom%2==0));then #because the default is already on X left
            ((nTrapX+=nNewPOIWidth+1))&&: #this ends already totally outside POI area
            lnDiffOrigNewTrapL=$((nOrigPOIWidth-nNewPOIWidth-nTrapW))
            if((lnDiffOrigNewTrapL>0));then ((nTrapZ+=iPRandom%lnDiffOrigNewTrapL))&&:;fi #this will fit the trap in the available area between original and new POI, if original was bigger than new
          else
            ((nTrapX-=nTrapW+1))&&: #so the trap stays outside the POI area to not destroy its' edges
          fi
        fi
        
        if $lbAllowIncTotOnce && ((lnDiffOrigNewTrapW>0 || lnDiffOrigNewTrapL>0));then
          #the full extra area from the area difference of OriginalPOI-NewPOI can fit many more traps.
          #liTrapTot+=$(( 2*(lnDiffOrigNewTrapW+lnDiffOrigNewTrapL)/4 )) 
          
          ####### LBNW is the OriginalPOIArea
          # LB LengthDiffArea BothLWDiffCornerArea
          # NW NewPOIArea WitdhDiffArea
          local lnAreaExtra=0
          lnAreaExtra+=$((lnDiffOrigNewTrapW*nNewPOILength)) #WitdhDiffArea
          lnAreaExtra+=$((lnDiffOrigNewTrapL*nNewPOIWidth)) #LengthDiffArea
          lnAreaExtra+=$((lnDiffOrigNewTrapW*lnDiffOrigNewTrapL)) #BothLWDiffCornerArea
          : ${nBiggestTrapArea:=16} #help
          local lnGapBetweenTrapsAreas=1
          local lnDivForTrapsAreas=$(((lnGapBetweenTrapsAreas+1)*2*nBiggestTrapArea))
          ######### traps would be like this (if it was random 4x4 like a chessboard where each biggest trap means one square there)
          # T T T
          #     
          # T T T     ???  ? is a possible new trap
          #           GG?  G is the gap between traps
          # T T T     TG?
          #
          # Obs.: BUT POSITIONING IS NOT 4x4 dist, it is 1x1! so results are intentionally probably overlapping. And... ahhhh whatever!! I will just test and see if it looks acceptable! this part will be messy to maintain anyway...
          liTrapTot+=$((lnAreaExtra/lnDivForTrapsAreas)) 
          lbAllowIncTotOnce=false
        fi
        if((iMaxTrapsInASinglePOI<liTrapTot));then iMaxTrapsInASinglePOI=$liTrapTot;fi
        
        CFGFUNCpredictiveRandom WildernessTrap
        echo '  <decoration type="model" name="'"${strPrefabTrap}"'" help="'"${strBiome};${strColorAtBiomeFile};"'WildernessTrap('"$liCurrentTrapIndex/$liTrapTot"'):POIIndex:'"${iXLDFilterIndex}"'" position="'"$nTrapX,$nTrapY,$nTrapZ"'" rotation="'"$((iPRandom%4))"'"/>' >>"${strFlPatched}.WildernessTrap.xml"
        ((iTotalTrapsInWorld++))&&:
        
        # loop control
        ((liCurrentTrapIndex++))&&:
        if((liCurrentTrapIndex>=liTrapTot));then break;fi
      done
    fi
    iTryAddWildTrap=0
  fi
}      
function FUNCpatchFileCurrentIndex_ExplosionAdd() { #requires: bSuccessfullyPlacedUnderground iXLDFilterIndex nX nY nZ strMissingPOI
  #todoa try to create a prefab with a barrel or a car with earth below it. When placing it above a POI, it may fill up with more earth below that may auto collapse
  bPlaceExplodeAbove=false
  if ! $bSuccessfullyPlacedUnderground;then
    : ${iTryExplAbove:=0}
    : ${iTryExplodeAt:=1} #help every this POI count that is not underground and is not protected, a explosive POI will be placed
    ((iTryExplAbove++))&&:
    if((iTryExplAbove>=iTryExplodeAt));then #once every 10 POIs on surface
      bPlaceExplodeAbove=true
    fi
  fi
  : ${bAllowExplodeAbovePrefabs:=true} #help
  if $bAllowExplodeAbovePrefabs && $bPlaceExplodeAbove;then 
    #todo try to create some prefab that will explode just after being generated. FAIL: a single almost destroyed car prefab was not placed in the world in high position, the world generator ignored it
    #nYSafeMargin=3 
    #nYAboveBuildingMin=$((nY+nNewPOIHeight+nYSafeMargin))  #margin will give a minimum terrain to collapse
    
    #nYWorldMax=255 #todo confirm this by placing nerdpole blocks till reach the limit: 260?
    #nYAboveBuildingLimit=30 #max collapsible
    #nExplosivePOIHeight=$(FUNCgetWHL "${astrAllPrefabSize[${strExplPOI}]}";echo $nHeight)
    strExplPOI="part_TNM_Explosion1"
    
    #CFGFUNCpredictiveRandom ExplosivePOIElevation
    #nYExplPOI=$((nYAboveBuildingMin+(iPRandom%nYAboveBuildingLimit)))
    #if(( (nYExplPOI+nExplosivePOIHeight+nYSafeMargin)>nYWorldMax ));then
      #nYExplPOI=$((nYWorldMax-nYSafeMargin))
      #if((nYExplPOI<nYAboveBuildingMin));then
        #nYExplPOI=-1 #to fail
      #fi
    #fi
    nYExplPOI=$nY
    
    if((nYExplPOI>-1));then
      iDisplacementXZ=-1 #outside POI
      #nYAboveBuildingMax=((nYAboveBuildingMin+(RANDOM%todo)))
      strPOIExplPos="$((nX+iDisplacementXZ)),${nYExplPOI},$((nZ+iDisplacementXZ))" # for X and Z, the hook is always bottom left corner right? so try to place it by luck above the building to let terrain auto collapse when player is near
      CFGFUNCpredictiveRandom ExplosivePOIRotation
      echo '  <decoration type="model" name="'"${strExplPOI}"'" help="'"${strBiome};${strColorAtBiomeFile}"'ExplosionPoleForPOIIndex:'"${iXLDFilterIndex}"'" position="'"${strPOIExplPos}"'" rotation="'"$((iPRandom%4))"'"/>' >>"${strFlPatched}.ExplodeAbove.xml" 
      CFGFUNCinfo "added explode pole nExplodeAboveCount=$nExplodeAboveCount strMissingPOI='$strMissingPOI'"
      ((nExplodeAboveCount++))&&:
      iTryExplAbove=0
    fi
  else
    echo -n >>"${strFlPatched}.ExplodeAbove.xml" #this is just to at least create the file
  fi
}      
function FUNCpatchFileCurrentIndex_ExplosionFailAdd() { #not working
  #todoa try to create a prefab with a barrel or a car with earth below it. When placing it above a POI, it may fill up with more earth below that may auto collapse
  bPlaceExplodeAbove=false
  if ! $bSuccessfullyPlacedUnderground;then
    : ${iTryExplAbove:=0}
    : ${iTryExplodeAt:=3} #help every this POI count that is not underground and is not protected, a explosive POI will (if luckly) be placed above it
    ((iTryExplAbove++))&&:
    if((iTryExplAbove>=iTryExplodeAt));then #once every 10 POIs on surface
      bPlaceExplodeAbove=true
    fi
  fi
  : ${bAllowExplodeAbovePrefabs:=false} #help this does not work. The prefab has no auto ground placed below it and above the other prefab, it just stays there floating and wont collapse, wont fall, wont explode. Only enable when it is working one day.
  if $bAllowExplodeAbovePrefabs && $bPlaceExplodeAbove;then 
    #todo try to create some prefab that will explode just after being generated. FAIL: a single almost destroyed car prefab was not placed in the world in high position, the world generator ignored it
    nYSafeMargin=3 
    nYAboveBuildingMin=$((nY+nNewPOIHeight+nYSafeMargin))  #margin will give a minimum terrain to collapse
    
    nYWorldMax=255 #todo confirm this by placing nerdpole blocks till reach the limit: 260?
    nYAboveBuildingLimit=30 #max collapsible
    strExplPOI="part_gas_contraption_01"
    nExplosivePOIHeight=$(FUNCgetWHL "${astrAllPrefabSize[${strExplPOI}]}";echo $nHeight)
    
    CFGFUNCpredictiveRandom ExplosivePOIElevation
    nYExplPOI=$((nYAboveBuildingMin+(iPRandom%nYAboveBuildingLimit)))
    if(( (nYExplPOI+nExplosivePOIHeight+nYSafeMargin)>nYWorldMax ));then
      nYExplPOI=$((nYWorldMax-nYSafeMargin))
      if((nYExplPOI<nYAboveBuildingMin));then
        nYExplPOI=-1 #to fail
      fi
    fi
    
    if((nYExplPOI>-1));then
      iDisplacementXZ=20 #minimum =3 to avoid the corners of POIs that may have no building. buildings are not terrain support right? 20 will try to place above buildings!
      #nYAboveBuildingMax=((nYAboveBuildingMin+(RANDOM%todo)))
      strPOIExplPos="$((nX+iDisplacementXZ)),${nYExplPOI},$((nZ+iDisplacementXZ))" # for X and Z, the hook is always bottom left corner right? so try to place it by luck above the building to let terrain auto collapse when player is near
      CFGFUNCpredictiveRandom ExplosivePOIRotation
      echo '  <decoration type="model" name="'"${strExplPOI}"'" help="'"${strBiome};${strColorAtBiomeFile}"'TryCollapseAndExplosionAboveForPOIIndex:'"${iXLDFilterIndex}"'" position="'"${strPOIExplPos}"'" rotation="'"$((iPRandom%4))"'"/>' >>"${strFlPatched}.ExplodeAbove.xml" 
      CFGFUNCinfo "added explode above nExplodeAboveCount=$nExplodeAboveCount strMissingPOI='$strMissingPOI'"
      ((nExplodeAboveCount++))&&:
      iTryExplAbove=0
    fi
  else
    echo -n >>"${strFlPatched}.ExplodeAbove.xml" #this is just to at least create the file
  fi
}      
function FUNCpatchFileCurrentIndex_HintAdd() {
  astrUnderGroundHinters=(
    part_fusebox_01
    part_waterheater_01 
    part_utility_pole
    #not good, gives 4 clocks easily for free: part_street_clock
    part_sculpture_02
    part_sculpture_01
    #part_lab_greeble_16
    #part_lab_greeble_17
    #part_lab_greeble_18
    #part_lab_greeble_19
    #part_lab_greeble_20
    #part_lab_greeble_21
  )
  #bad, this will make it float a bit in the air: nYHint=$((nY+1)) #most prefab hints were placed like original y-1 why?
  nYHint=$nY
  : ${bPlaceObviousPrefabHintsForUndergroundPOIs:=false} #help this wont look good as the prefabs will be floating in the air w/o terrain below to sustain it
  if $bPlaceObviousPrefabHintsForUndergroundPOIs;then
    nYHint=$((nY+nNewPOIHeight+nYExtraUndergroundDistFromSurface))
  fi
  : ${bUseUndergroundSmokePrefabHint:=true} #help otherwise it will use small static prefabs
  if $bUseUndergroundSmokePrefabHint;then
    if [[ "$strBiome" == "Snow" ]];then
      strUndergroundPrefabHint="part_TNM_Hint_UndergroundWhite" #this white smoke blends better on snow
    else
      strUndergroundPrefabHint="part_TNM_Hint_UndergroundBlack" #dark smoke
    fi
  else
    CFGFUNCpredictiveRandom UndergroundHint
    strUndergroundPrefabHint="${astrUnderGroundHinters[$((iPRandom%${#astrUnderGroundHinters[@]}))]}"
  fi
  CFGFUNCpredictiveRandom UndergroundHintRotation
  echo '  <decoration type="model" name="'"${strUndergroundPrefabHint}"'" help="'"${strBiome};${strColorAtBiomeFile};"'UndergroundPOIHintForPOIIndex:'"${iXLDFilterIndex}"'" position="'"$((nX-1)),$nYHint,$((nZ-1))"'" rotation="'"$((iPRandom%4))"'"/>' >>"${strFlPatched}.UndergroundHints.xml" #that Y change is because it seems that engine RWG makes more precise calculations and my calcs here wont suffice as it may end below the ground for some reason. As these are just hints, even if they do not look good, that is what I can do in a script for now. #this wont suffice: nY+1 because all the hints were being placed a bit below surface, I dont know why.
}      
function FUNCextractBestMatchingMissingPOIvsOriginalPOI_outBestMatchingPOIglobal() { 
  #CFGFUNCchkDenySubshellForGlobalVarsWork
  local lstrOriginalPOI="$1"
  
  FUNCgetWHL "${astrAllPrefabSize[${lstrOriginalPOI}]}"
  local lnOW=$nWidth lnOH=$nHeight lnOL=$nLength
  
  local liBestMatchMPOIindex=0
  local lastrMatchModeList=(  # put best match modes in order here!
    MatchWHL #precise
    MatchWL #best fit W L is good enough too as the whole problem is adequating the terrain around it
    MatchWHLp1
    MatchWHLdiff1 #new can be -2 or +2 size diff than original
    MatchWHLdiff2 #new can be -2 or +2 size diff than original
    MatchWHLdiff3 #new can be -2 or +2 size diff than original
    MatchWLp1
    MatchWLp3 #new can be bigger than original by 3
    MatchWLm3 #new can be smaller than original by 3
    MatchWLm5 #new can be smaller than original by 5
    MatchWLm10 #new can be smaller than original by 5
    MatchWLm15 #new can be smaller than original by 5
    MatchWLm20 #new can be smaller than original by 5
    MatchWLp5 #new can be bigger than original by 5
    BestMatchFailed_WillUseDefault #keep as last one
  )
  CFGFUNCsetGlobals -A astrPOIsMatchMode
  local lbOk=false
  for lstrMatchMode in "${lastrMatchModeList[@]}";do
    for liMisPOIIndex in "${!astrMissingPOIsList[@]}";do
      local lstrMissingPOI="${astrMissingPOIsList[$liMisPOIIndex]}"
      FUNCgetWHL "${astrAllPrefabSize[${lstrMissingPOI}]}"
      local lnMW=$nWidth lnMH=$nHeight lnML=$nLength
      
      if [[ "$lstrMatchMode" == "MatchWHL" ]] && ((
        lnMW==lnOW && 
        lnMH==lnOH && 
        lnML==lnOL
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
        
      if [[ "$lstrMatchMode" == "MatchWL" ]] && ((
        lnMW==lnOW && 
        lnML==lnOL
      ));then 
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWHLp1" ]] && ((
        ( lnMW>=lnOW && lnMW<=(lnOW+1) ) &&
        ( lnMH>=lnOH && lnMH<=(lnOH+1) ) &&
        ( lnML>=lnOL && lnML<=(lnOL+1) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWHLdiff1" ]] && ((
        ( lnMW>=(lnOW-1) && lnMW<=(lnOW+1) ) &&
        ( lnMH>=(lnOH-1) && lnMH<=(lnOH+1) ) &&
        ( lnML>=(lnOL-1) && lnML<=(lnOL+1) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWHLdiff2" ]] && ((
        ( lnMW>=(lnOW-2) && lnMW<=(lnOW+2) ) &&
        ( lnMH>=(lnOH-2) && lnMH<=(lnOH+2) ) &&
        ( lnML>=(lnOL-2) && lnML<=(lnOL+2) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWHLdiff3" ]] && ((
        ( lnMW>=(lnOW-3) && lnMW<=(lnOW+3) ) &&
        ( lnMH>=(lnOH-3) && lnMH<=(lnOH+3) ) &&
        ( lnML>=(lnOL-3) && lnML<=(lnOL+3) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLp1" ]] && ((
        ( lnMW>=lnOW && lnMW<=(lnOW+1) ) &&
        ( lnML>=lnOL && lnML<=(lnOL+1) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLdiff2" ]] && ((
        ( lnMW>=(lnOW-2) && lnMW<=(lnOW+2) ) &&
        ( lnML>=(lnOL-2) && lnML<=(lnOL+2) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLp3" ]] && ((
        ( lnMW>=lnOW && lnMW<=(lnOW+3) ) &&
        ( lnML>=lnOL && lnML<=(lnOL+3) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi

      if [[ "$lstrMatchMode" == "MatchWLm3" ]] && ((
        ( lnMW<=lnOW && lnMW>=(lnOW-3) ) &&
        ( lnML<=lnOL && lnML>=(lnOL-3) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLm5" ]] && ((
        ( lnMW<=lnOW && lnMW>=(lnOW-5) ) &&
        ( lnML<=lnOL && lnML>=(lnOL-5) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLm10" ]] && ((
        ( lnMW<=lnOW && lnMW>=(lnOW-10) ) &&
        ( lnML<=lnOL && lnML>=(lnOL-10) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLm15" ]] && ((
        ( lnMW<=lnOW && lnMW>=(lnOW-15) ) &&
        ( lnML<=lnOL && lnML>=(lnOL-15) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLm20" ]] && ((
        ( lnMW<=lnOW && lnMW>=(lnOW-20) ) &&
        ( lnML<=lnOL && lnML>=(lnOL-20) ) 
      ));then
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if [[ "$lstrMatchMode" == "MatchWLp5" ]] && (( 
        ( lnMW>=lnOW && lnMW<=(lnOW+5) ) &&
        ( lnML>=lnOL && lnML<=(lnOL+5) ) 
      ));then #this is already too much but better than more...
        liBestMatchMPOIindex=$liMisPOIIndex;lbOk=true;
        break;
      fi
      
      if $lbOk;then break;fi
    done
    if $lbOk;then break;fi
  done
  astrPOIsMatchMode[${lstrMatchMode}]=$((${astrPOIsMatchMode[${lstrMatchMode}]-0}+1))
  local lstrNewPOI="${astrMissingPOIsList[$liBestMatchMPOIindex]}"
  CFGFUNCinfo "BestMatchingPOIFor:lbOk=$lbOk;lstrMatchMode=$lstrMatchMode;index:$liBestMatchMPOIindex;Original(${lstrOriginalPOI},sz:${astrAllPrefabSize[${lstrOriginalPOI}]});New(${astrMissingPOIsList[$liBestMatchMPOIindex]},sz:${astrAllPrefabSize[${lstrNewPOI}]})"
  
  CFGFUNCsetGlobals strBestMatchingPOI="${lstrNewPOI}" #OUTPUT. if not found, will be the 1st index 0
  
  unset astrMissingPOIsList[$liBestMatchMPOIindex]
  astrMissingPOIsList=("${astrMissingPOIsList[@]}") #updates the array
}
#: ${strFlPatchUndergroundEvents:="${strTmpPath}/tmp.`basename "$0"`.`date +"${strCFGDtFmt}"`.GameEvents.${strGenTmpSuffix}"} #help strFlGenEve CFGFUNCgencodeApply "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"
bEnd=false
iRestoredMissingPOIs=0
#iCountAtMissingPOIs=0
iSkippedAtRemainingTowns=0
iSkippedWastelandNonDummyPOI=0
iSkippedOriginalPOIs=0
iSkippedProtectedPOIs=0
nExplodeAboveCount=0
astrRestoredPOIs=()
iUndergroundPOIs=0
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  iDupCount="$(egrep "[ ]name=\"${strGPD}\"[ ]" "$strFlPatched" |wc -l)" #the dup count from file is granted
  if((iDupCount!=${astrGenPOIsDupCountList[${strGPD}]}));then #this is a consistency check
    CFGFUNCinfo "WARNING: DupPOI '$strGPD' grepped dup count $iDupCount at file '$strFlPatched' does not match the array dup count ${astrGenPOIsDupCountList[${strGPD}]}"
  fi
  if((iDupCount<=1));then CFGFUNCerrorExit "invalid iDupCount=$iDupCount for '$strGPD'";fi
  #CFGFUNCinfo "Working with DupPOI: $strGPD dup $iDupCount"  
  
  for((i=iDupCount;i>1;i--));do #i>1 means to replace only the dups, not the last one
    CFGFUNCinfo "Working with DupPOI($i): $strGPD dup $iDupCount"  
    egrep "[ ]name=\"${strGPD}\"[ ]" "$strFlPatched" |tee -a "$strCFGScriptLog"
    #FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile "$strGPD" #as this file is being constantly updated here on this loop. This is the first original POI information collection.
    FUNCgetXYZfromXmlLine_outXYZaXLDglobals "`FUNCget2ndMatchingPrefabOnPatcherFile "$strGPD"`" #as this file is being constantly updated here on this loop. This is the first original POI information collection.
    #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r  's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
    #eval "$strPos" #nX nY nZ
    #declare -p nX nY nZ
    strOriginalXYZ="$nX,$nY,$nZ" #This is the first original POI information.
    strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
    FUNCgetWHL "${astrAllPrefabSize[${strRWGoriginalPOI}]}"
    nOrigPOIWidth=$nWidth
    nOrigPOIHeight=$nHeight
    nOrigPOILength=$nLength
    CFGFUNCinfo "DupPOI: $strGPD iXLDFilterIndex=$iXLDFilterIndex XYZ=$strOriginalXYZ strRWGoriginalPOI='$strRWGoriginalPOI'"
    
    
    bSkip=false;
    #The remaining POIs from rectangles at towns may be DUPs, if that is the case they must be replaced properly. #if FUNCchkPosIsInTownPIT $nX $nZ;then bSkip=true;((iSkippedAtRemainingTowns++))&&:;CFGFUNCinfo "iSkippedAtRemainingTowns=$iSkippedAtRemainingTowns";fi # skip locations in towns to keep the RGW good looking quality
    
    eval "$(CFGFUNCbiomeData "$strOriginalXYZ")" # iBiome strBiome strColorAtBiomeFile
    #if [[ -n "${astrPosVsBiomeColor[${strOriginalXYZ}]-}" ]];then      # faster
      #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["${strOriginalXYZ}"]}`" # iBiome strBiome strColorAtBiomeFile
    #else      # much slower
      #eval "`./getBiomeData.sh "${strOriginalXYZ}"`" # strColorAtBiomeFile strBiome iBiome
    #fi
    #if [[ "$strBiome" == "Wasteland" ]];then bSkip=true;fi # skip wasteland that was already filled up with special buildings
    #help The wasteland biome was already filled with priority POIs as much as possible beyond the minimum and considering the reserved limit
    
    #strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
    #if [[ "${strRWGoriginalPOI}" =~ ^${strRegexProtectedPOIs}.*$ ]];then bSkip=true;((iSkippedOriginalPOIs++))&&:;fi #todo this seems wrong! should compare with the current name="" not the original!!!
    #strPrefabNameToCheck="`xmlstarlet sel -t -c "//decoration[@helpFilterIndex='${iXLDFilterIndex}']" "$strFlPatched"`"
    if [[ "${strXLDPrefabCurrentName}" =~ ^${strRegexProtectedPOIs}.*$ ]];then bSkip=true;((iSkippedProtectedPOIs++))&&:;CFGFUNCinfo "iSkippedProtectedPOIs=$iSkippedProtectedPOIs";fi
    
    if [[ "$strBiome" == "Wasteland" ]] && [[ "${strXLDPrefabCurrentName}" != "${strDummyPOI}" ]];then 
      bSkip=true;
      ((iSkippedWastelandNonDummyPOI++))&&:;
      CFGFUNCinfo "iSkippedWastelandNonDummyPOI=$iSkippedWastelandNonDummyPOI";
    else
      if((iNotUsedReservedWastelandPOICountForMissingPOIs>0));then
        ((iNotUsedReservedWastelandPOICountForMissingPOIs--))&&:
      fi
    fi
    
    CFGFUNCexec -m "Query to be sure the entry exists for consistency" xmlstarlet sel -t -c "//decoration[@helpFilterIndex='${iXLDFilterIndex}']" "$strFlPatched";echo #this line is allowed to fail, do not protect with &&:
    if $bSkip;then
      #strMarkToSkip
      #strMarkToSkip="@@@";#add IGNORE mark @@@ so when perl runs, trying the 2nd match will ignore this one
      #if FUNCchkPosIsInTownPIT --ignore Wasteland $nX $nZ;then strMark="@D@";fi #this is a DELETE mark, to remove the entry
      #perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"${strMarkToSkip}${strGPD}"'"/s' "$strFlPatched"
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@name" -v "${strMarkToSkip}${strGPD}" "$strFlPatched" #add IGNORE mark strMarkToSkip so when perl runs, trying the 2nd match will ignore this one just because it will be different and invalid for now
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@helpSort" -v "${strGPD}" "$strFlPatched" #MUST COME ALWAYS IF @name is being set!
      
      #((iSkippedAtRemainingTowns++))&&: #add IGNORE mark strMarkToSkip so when perl runs, trying the 2nd match will ignore this one just because it will be different and invalid for now
    else
      FUNCextractBestMatchingMissingPOIvsOriginalPOI_outBestMatchingPOIglobal "${strRWGoriginalPOI}"
      strMissingPOI="${strBestMatchingPOI}"
      #strMissingPOI="${astrMissingPOIsList[$iCountAtMissingPOIs]}"
      FUNCgetWHL "${astrAllPrefabSize[${strMissingPOI}]}"
      nNewPOIWidth=$nWidth
      nNewPOIHeight=$nHeight
      nNewPOILength=$nLength

      #strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
      CFGFUNCinfo "Dup=$strGPD:$i:Orig=$strRWGoriginalPOI:Miss=$strMissingPOI:($nX,$nY,$nZ):YOS(O=${astrAllPrefabYOS[$strRWGoriginalPOI]-}/M=${astrAllPrefabYOS[$strMissingPOI]-}/D=${astrAllPrefabYOS[$strGPD]-})" # |tee -a "$strFlRunLog"&&: >/dev/stderr
      # this will change the 2nd match only of a dup entry strGPD
      #perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"$strMissingPOI"'"/s' "$strFlPatched"
      
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@name" -v "${strMissingPOI}" "$strFlPatched"
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@helpSort" -v "${strMissingPOI}" "$strFlPatched" #MUST COME ALWAYS IF @name is being set!
      
      #strHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" "$strFlPatched"`"
      #strHelp+=";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
      #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" -v "${strHelp}" "$strFlPatched"
      FUNCpatchFileCurrentIndex_HelpAppend ";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
      
      bAllowUnderground=true
      if xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@helpAddExtraPOI" "$strFlPatched";then CFGFUNCinfo "prevent underground for iXLDFilterIndex=$iXLDFilterIndex $strMissingPOI strOriginalXYZ='$strOriginalXYZ'";bAllowUnderground=false;fi #these POIs locations are manually properly placed already
      
      : ${bApplyYOSDiff:=true} #help changes prefab Y pos to be the difference between old and new prefab YOS (only to make things underground), if false will not change anything
      nYUpdatedFromPOIsOldVsNew="`FUNCcalcPOINewY $nY "$strRWGoriginalPOI" "$strMissingPOI"`" #use xmlstarlet to apply the new Y
      nYUpdFrPOIsOvsNinitialVal="$nYUpdatedFromPOIsOldVsNew"
      nYOffsetNew=${astrAllPrefabYOS[$strMissingPOI]}
      #if((nYUpdatedFromPOIsOldVsNew<nY));then bApplyYOSDiff=false;fi #only apply YOS diff if overground, keep underground unchanged!
      strHelpUnderground=""
      #todo (done?) improve the below idea to better randomly place POIs underground up to 33% total POIs, based on Y vs POIs' height
      : ${iUndergroundTryAt:=3} #help once every 3 is like 33%
      : ${iUndergroundFail:=0} #todo this feels a bit unpredictable the way it is coded below? :>
      : ${iUndergroundTry:=0}
      ((iUndergroundTry++))&&:
      #if((iUndergroundFail>0 && iUndergroundTry<iUndergroundTryAt));then
        #((iUndergroundTry++))&&:
        #((iUndergroundFail--))&&:
      #fi
      #if((iUndergroundFail>0));then
        #((iUndergroundTry=iUndergroundTryAt))&&:
        ##((iUndergroundFail--))&&:
      #fi
      bSuccessfullyPlacedUnderground=false
      if $bAllowUnderground && ((iUndergroundTry>=iUndergroundTryAt || iUndergroundFail>0));then
        : ${nYExtraUndergroundDistFromSurface:=7} #help this will create a layer of earth above the underground POI. The value of 3 did not work well for some buildings, better keep it above 4 (that would make 1 block tall tick layer).
        #nYUpdatedFromPOIsOldVsNew=$((nY-nYOffsetNew-nNewPOIHeight-nYExtraUndergroundDistFromSurface)) #the negative YOffset will actually raise the building to let it's height value work properly. -3 is a terrain margin. Obs.: Engine's RWG, at least when creating towns, may place POIs very near bedrock, letting them getting cutout see house_old_bungalow_11 with position Y=-15 for TNM original world prefabs.xml file.
        (( nYUpdatedFromPOIsOldVsNew+=(nYOffsetNew * -1) ))&&: #puts the new POI base on the terrain level
        (( nYUpdatedFromPOIsOldVsNew-=(nNewPOIHeight+nYExtraUndergroundDistFromSurface) ))&&: #puts the new POI totally underground with a margin
      #if((nYUpdatedFromPOIsOldVsNew<nY));then
        #more calc can be done based on the new POI height for better underground placement (more close to the expected surface elevation: nYUpdatedFromPOIsOldVsNew-newPOIheight-3. -3 is to not be so close that would create structural instability, despite that still may happen cuz of earth ground I think)
        #nYUpdatedFromPOIsOldVsNew=$((nYUpdatedFromPOIsOldVsNew-nNewPOIHeight-3))
#        if(( (nYUpdatedFromPOIsOldVsNew+nYOffsetNew) > 1 ));then
        if(( nYUpdatedFromPOIsOldVsNew >= 1 ));then
          strHelpUnderground="Underground"
          ((iUndergroundPOIs++))&&:
          ((iUndergroundTry-=iUndergroundTryAt))&&:
          if((iUndergroundFail>0));then
            ((iUndergroundFail--))&&:
          fi
          
          FUNCpatchFileCurrentIndex_HintAdd
          
          CFGFUNCinfo "iUndergroundPOIs=$iUndergroundPOIs strMissingPOI='$strMissingPOI'"
          bSuccessfullyPlacedUnderground=true
        else #revert final Y
          ((iUndergroundFail++))&&:
          #nYUpdatedFromPOIsOldVsNew=$nY
          nYUpdatedFromPOIsOldVsNew=$nYUpdFrPOIsOvsNinitialVal
          #if((iUndergroundTry>0));then
            #((iUndergroundTry--))&&: #try again on next POI
          #fi
        fi
      fi
      
      FUNCpatchFileCurrentIndex_ExplosionAdd
      
      CFGFUNCinfo "old=${strRWGoriginalPOI}($nX,$nY,$nZ)(YO=${astrAllPrefabYOS[$strRWGoriginalPOI]-})(Sz=${astrAllPrefabSize[${strRWGoriginalPOI}]-});new=${strMissingPOI}($nX,$nYUpdFrPOIsOvsNinitialVal/$nYUpdatedFromPOIsOldVsNew,$nZ)(YO=${astrAllPrefabYOS[$strMissingPOI]-})(Sz=${astrAllPrefabSize[${strMissingPOI}]-}) iUndergroundTry=$iUndergroundTry iUndergroundFail=$iUndergroundFail"
      strStatus=""
      if $bApplyYOSDiff;then
        #strRWGoriginalPOIindex="${astrRWGOriginalLocationVsPOIindex[$nX,$nY,$nZ]}"
        #FUNCcalcPOINewY $nY "$strGPD" "$strMissingPOI" #use xmlstarlet to apply the new Y
        #xmlstarlet ed -P -L -u "//decoration[@position='$nX,$nY,$nZ' and @helpFilterIndex='${strRWGoriginalPOIindex}']/@position" -v "$nYUpdatedFromPOIsOldVsNew" "$strFlPatched"
        #CFGFUNCexec -m "Query to be sure the entry exists" xmlstarlet sel -t -c "//decoration[@helpFilterIndex='${iXLDFilterIndex}']" "$strFlPatched";echo #this line is allowed to fail, do not protect with &&:
        
        #nYOffsetNew=${astrAllPrefabYOS[$strMissingPOI]}
        if((nYUpdatedFromPOIsOldVsNew<0));then
          CFGFUNCinfo "WARN:NewYLT0:nYUpdatedFromPOIsOldVsNew='$nYUpdatedFromPOIsOldVsNew' < 0"
        fi
        #if(( (nYUpdatedFromPOIsOldVsNew+nYOffsetNew) < 1 ));then
          #nYFixed=$(( (-1*nYOffsetNew) +1 ))
          #CFGFUNCinfo "WARN: fixing wrong too low Y: nYUpdatedFromPOIsOldVsNew='$nYUpdatedFromPOIsOldVsNew' strMissingPOI='$strMissingPOI' YOffset:${nYOffsetNew} nNewPOIHeight=$nNewPOIHeight iXLDFilterIndex=${iXLDFilterIndex} nYFixed=$nYFixed"
          #nYUpdatedFromPOIsOldVsNew=$nYFixed
        #fi
        if(( nYUpdatedFromPOIsOldVsNew < 1 ));then
          nYFixed=1
          CFGFUNCinfo "WARN: fixing wrong too low Y: nYUpdatedFromPOIsOldVsNew='$nYUpdatedFromPOIsOldVsNew' strMissingPOI='$strMissingPOI' YOffset:${nYOffsetNew} nNewPOIHeight=$nNewPOIHeight iXLDFilterIndex=${iXLDFilterIndex} nYFixed=$nYFixed"
          nYUpdatedFromPOIsOldVsNew=$nYFixed
        fi
        #if((nYUpdatedFromPOIsOldVsNew<1));then
          #CFGFUNCerrorExit "nYUpdatedFromPOIsOldVsNew='$nYUpdatedFromPOIsOldVsNew' is still < 1"
        #fi
        #if((nYOffsetNew<0)) && (( (nYUpdatedFromPOIsOldVsNew+nYOffsetNew) < 1 ));then
          #CFGFUNCerrorExit "nYOffsetNew='$nYOffsetNew' nYUpdatedFromPOIsOldVsNew='$nYUpdatedFromPOIsOldVsNew' is still < 1"
        #fi
        
        CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@position" -v "$nX,$nYUpdatedFromPOIsOldVsNew,$nZ" "$strFlPatched"
        
        #if [[ -n "$strHelpUnderground" ]];then
          #FUNCpatchFileCurrentIndex_HelpAppend ";${strHelpUnderground}"
        #fi
        
        #strHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" "$strFlPatched"`"
        #strHelp+=";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
        #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@help" -v "${strHelp}" "$strFlPatched"
        
        #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iXLDFilterIndex}']/@helpSort" -v "${strMissingPOI}" "$strFlPatched"
        
        strStatus="UpdatedPositionFromOriginal(${strOriginalXYZ})"
        CFGFUNCinfo "$strStatus" #UpdateYOffsetForPOI"
        # BUT THERE IS A BIGGER PROBLEM: the rwg game engine considers several things to make it look good and fit perfectly on the surrounding environment. What is impossible to do with this script.
      else
        strStatus="KeptPosition"
        CFGFUNCinfo "$strStatus" #Kept POI position" #CFGFUNCinfo "Kept POI expectedly Underground"
      fi
      
      #if [[ -n "$strHelpUnderground" ]];then
      if $bSuccessfullyPlacedUnderground;then
        FUNCpatchFileCurrentIndex_HelpAppend ";${strStatus};${strHelpUnderground}"
        : ${iUnderGroundBegin:=30000} #todo collect from buffs file
        iMaxUndergroundIndex=$((iUnderGroundBegin+iUndergroundPOIs))
        echo '
    <action_sequence name="eventGSKTeleportAboveUndergroundPOI'$((iMaxUndergroundIndex))'"><action class="Teleport">
      <property name="target_position" value="'$nX',260,'$nZ'" help="'"`FUNCpatchFileCurrentIndex_HelpGet`"'"/>
    </action></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      else #because underground POIs are not fit for traps as these would be easily seen from above and they would also be extra visible as would show up like digs on the surrounding walls
        FUNCpatchFileCurrentIndex_TrapAdd
      fi
      
      if echo " ${astrRestoredPOIs[@]} " |grep " $strMissingPOI ";then
        CFGFUNCerrorExit "using again a missing POI $strMissingPOI"
      fi
      astrRestoredPOIs+=("$strMissingPOI")
      
      ((iRestoredMissingPOIs++))&&:
      #((iCountAtMissingPOIs++))&&:
      #if((iCountAtMissingPOIs>=${#astrMissingPOIsList[@]}));then bEnd=true;break;fi
      if((${#astrMissingPOIsList[@]}==0));then bEnd=true;break;fi
    fi
  done
  if $bEnd;then break;fi
done
declar -p astrRestoredPOIs |tr '[' '\n' |tee -a "$strCFGScriptLog"

CFGFUNCinfo "MAIN:preparing patch file: adding traps to non DUP (unique or finally unique) POIs"
for strRWGsinglePOI in "${astrRWGsinglePOIsList[@]}";do
  FUNCgetWHL "${astrAllPrefabSize[${strRWGsinglePOI}]}"
  nNewPOIWidth=$nWidth
  nNewPOIHeight=$nHeight
  nNewPOILength=$nLength
  
  FUNCgetXYZfromXmlLine_outXYZaXLDglobals "`FUNCget2ndMatchingPrefabOnPatcherFile "$strRWGsinglePOI"`" #nX nY nZ iXLDFilterIndex 
  
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  #strOriginalXYZ="$nX,$nY,$nZ"
  #strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
  
  strRWGoriginalPOI="$strRWGsinglePOI"
  
  FUNCpatchFileCurrentIndex_TrapAdd #all the above prepared the data required for this calls
  
  bSuccessfullyPlacedUnderground=false
  strMissingPOI="$strRWGsinglePOI"
  FUNCpatchFileCurrentIndex_ExplosionAdd #all the above prepared the data required for this calls
done

CFGFUNCinfo "MAIN:Cleanup patcher file: ${strFlPatched}"
#sed -i -r 's"@@@""' "${strFlPatched}" #clean ignore mark to let game accept the data
sed -i -r "s/${strMarkToSkip}//" "${strFlPatched}" #clean ignore mark to let game accept the data
#CFGFUNCinfo "MAIN:Remove prefabs from town areas outside the wasteland"
#cat "${strFlPatched}" |egrep -v "@D@" >"${strFlPatched}.DeleteTowns.tmp"
#ls -l "${strFlPatched}" "${strFlPatched}.DeleteTowns.tmp"
#CFGFUNCmeld "${strFlPatched}" "${strFlPatched}.DeleteTowns.tmp"
#CFGFUNCexec mv -vf "${strFlPatched}.DeleteTowns.tmp" "${strFlPatched}"
#ls -l "${strFlPatched}"
function FUNCcleanupFlPatch() {
  local lstrTask="$1";shift
  "$@" "${strFlPatched}" >"${strFlPatched}.${lstrTask}.tmp"
  cp -vf "${strFlPatched}" "${strFlPatched}.old"
  mv -vf "${strFlPatched}.${lstrTask}.tmp" "${strFlPatched}"
}
#egrep -v "$strEnclosurerToken" "${strFlPatched}" >"${strFlPatched}.RmEnclosurer.tmp";mv -vf "${strFlPatched}.RmEnclosurer.tmp" "${strFlPatched}"
FUNCcleanupFlPatch "RmEnclosurer" egrep -v "$strEnclosurerToken"
#egrep -v "xml *version=" "${strFlPatched}" >"${strFlPatched}.RmXmlVerLines.tmp";mv -vf "${strFlPatched}.RmXmlVerLines.tmp" "${strFlPatched}"
FUNCcleanupFlPatch "RmXmlVerLines" egrep -v "xml *version="
#sort "${strFlPatched}" >"${strFlPatched}.Sorted.tmp";mv -vf "${strFlPatched}.Sorted.tmp" "${strFlPatched}"
FUNCcleanupFlPatch "Sorted" sort

#echo;echo "#####################################################################################"
#declare -p astrAllPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrMissingPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsDupCountList |tr '[' '\n' #|egrep -v '="1"'

CFGFUNCinfo "MAIN:Check still missing POIs: ${strFlPatched}"
#iStillMissingPOIs=$((${#astrMissingPOIsList[@]}-iCountAtMissingPOIs))
#if((iStillMissingPOIs>0));then
  #CFGFUNCinfo "MAIN:Listing missing POIs"
  #for((i=iCountAtMissingPOIs;i<${#astrMissingPOIsList[@]};i++));do
    #echo "${astrMissingPOIsList[i]}"
  #done |sort |tee -a "$strCFGScriptLog"
#fi
astrStillMissingPOIsList=()
for strMissingPOI in "${astrMissingPOIsList[@]}";do
  if ! egrep -q "name=\"$strMissingPOI\"" "${strFlPatched}";then
    astrStillMissingPOIsList+=("$strMissingPOI")
    CFGFUNCinfo "StillMissingPOI: $strMissingPOI"
  else
    echo -n .
  fi
done
declare -p astrStillMissingPOIsList |tr '[' '\n' |tee -a "$strCFGScriptLog"
iStillMissingPOIs=${#astrStillMissingPOIsList[@]}

CFGFUNCinfo "MAIN:Check consistency of: ${strFlPatched}"
#if egrep "name=\"${strRegexProtectedPOIs}.*NewPOI\(" "${strFlPatched}" |egrep -v "NewPOI\(${strRegexProtectedPOIs}";then
strChkWrongReplace="`egrep "OriginalPOI\(${strRegexProtectedPOIs}.*NewPOI\(" "${strFlPatched}"`"&&:
if [[ -n "$strChkWrongReplace" ]];then
  echo "$strChkWrongReplace" |tee -a "$strCFGScriptLog"
  CFGFUNCprompt "WARN:the above protected POIs where probably replaced incorrectly (this script needs fixing)"
fi
if(( $(egrep "name=\"${strDummyPOI}\"" "${strFlPatched}" |wc -l) > 1 ));then
  egrep "name=\"${strDummyPOI}\"" "${strFlPatched}" |tee -a "$strCFGScriptLog"
  CFGFUNCprompt "WARN:the above dups of strDummyPOI='$strDummyPOI' should have been replaced (ask some developer to improve this script, or become one) unless you over configured iReservedWastelandPOICountForMissingPOIs=$iReservedWastelandPOICountForMissingPOIs value, like in you have reserved (iNotUsedReservedWastelandPOICountForMissingPOIs=$iNotUsedReservedWastelandPOICountForMissingPOIs) more than required."
fi
#if((iNotUsedReservedWastelandPOICountForMissingPOIs>0));then
  #CFGFUNCprompt "WARN:iNotUsedReservedWastelandPOICountForMissingPOIs=$iNotUsedReservedWastelandPOICountForMissingPOIs more than required."
#fi

FUNCwriteCacheFile #here for astrEvalV3cache etc

declare -p astrCFGIdForRandomVsCurrentIndex |tr '[' '\n' |tee -a "${strCFGScriptLog}"

iMaxAllowedReservablePOIsInWasteland=$((iTotalWastelandPOIsLeastInTowns-iTotalUniqueSpecialBuildings))
strFlResultsFinal="`basename "$0"`.AddedToRelease.LastRunStatus.txt" #help if you delete the cache file it will be recreated
CFGFUNCinfo "MAIN:REPORT FINAL STATUS"
#astrFinalStatus=()
echo "[[[Totals:]]]" >"$strFlResultsFinal" #trunc
echo "POI places:total original RWG generated: ${#astrRWGOriginalPOIdataLineList[@]}" >>"$strFlResultsFinal"
echo "POI places:total removed POIs from NON wasteland towns: $iTotalRemovedPOIsFromTownsOutsideWasteland" >>"$strFlResultsFinal"
echo "POI places:total remaining on patched file: `egrep "<decoration " "${strFlPatched}" |wc -l`" >>"$strFlResultsFinal"
echo "Total missing POIs: ${#astrMissingPOIsList[@]}" >>"$strFlResultsFinal"
echo "Missing POIs that were restored: $iRestoredMissingPOIs" >>"$strFlResultsFinal"
#echo "Preserved POIs from remaining towns or just from anywhere in the wasteland: $iSkippedAtRemainingTowns" >>"$strFlResultsFinal"
echo "iStillMissingPOIs=$iStillMissingPOIs (0 is good)" >>"$strFlResultsFinal"
#${#astrGenPOIsList[@]}
#echo "astrAllPOIsList: ${#astrAllPOIsList[@]}" >>"$strFlResultsFinal"
echo "[[[ETC:(DevInfo)]]]" >>"$strFlResultsFinal"
#echo "iSkippedAtRemainingTowns=$iSkippedAtRemainingTowns" >>"$strFlResultsFinal"
echo "iSkippedProtectedPOIs=$iSkippedProtectedPOIs" >>"$strFlResultsFinal"
echo "nExplodeAboveCount=$nExplodeAboveCount" >>"$strFlResultsFinal"
echo "iSkippedWastelandNonDummyPOI=$iSkippedWastelandNonDummyPOI" >>"$strFlResultsFinal"
#echo "iSkippedOriginalPOIs=$iSkippedOriginalPOIs" >>"$strFlResultsFinal"
echo "iRemovedSpecialBuildingsFromNonWasteland=${iRemovedSpecialBuildingsFromNonWasteland}" >>"$strFlResultsFinal"
echo "iTotalWastelandPOIsLeastInTowns=${iTotalWastelandPOIsLeastInTowns}" >>"$strFlResultsFinal"
echo "iTotalSpecialBuildingsPlacedInWasteland=${iTotalSpecialBuildingsPlacedInWasteland} (big values here means more goods can be found on the Wasteland's POIs)" >>"$strFlResultsFinal"
echo "iTotalUniqueSpecialBuildings=$iTotalUniqueSpecialBuildings" >>"$strFlResultsFinal"
echo "iMaxAllowedReservablePOIsInWasteland=$iMaxAllowedReservablePOIsInWasteland" >>"$strFlResultsFinal"
echo "iNotUsedReservedWastelandPOICountForMissingPOIs=$iNotUsedReservedWastelandPOICountForMissingPOIs (0 is good)" >>"$strFlResultsFinal"
echo "iUndergroundPOIs=$iUndergroundPOIs (expectedly fully underground)" >>"$strFlResultsFinal"
echo "iTotalTrapsInWorld=$iTotalTrapsInWorld" >>"$strFlResultsFinal"
echo "iMaxTrapsInASinglePOI=$iMaxTrapsInASinglePOI" >>"$strFlResultsFinal"
declare -p astrPOIsMatchMode astrStillMissingPOIsList |tr '[' '\n' |tee -a "$strFlResultsFinal" #may be useful
CFGFUNCinfo "`cat "$strFlResultsFinal"`"

#if(( ${#astrMissingPOIsList[@]} != iCountAtMissingPOIs+iStillMissingPOIs ));then
  #CFGFUNCDevMeErrorExit "values do not sum up: \${#astrMissingPOIsList[@]} != iCountAtMissingPOIs+iStillMissingPOIs: ${#astrMissingPOIsList[@]} != $iCountAtMissingPOIs+$iStillMissingPOIs"
#fi

CFGFUNCprompt "check totals and etc above"

if((iStillMissingPOIs>0));then
  #read -n 1 -p "list still missing POIs(y/...)?" strResp;echo
  #if [[ "$strResp" == y ]];then
  #if CFGFUNCprompt -q "list again still missing POIs";then
    #for((i=iCountAtMissingPOIs;i<${#astrMissingPOIsList[@]};i++));do
      #echo "${astrMissingPOIsList[i]}"
    #done |sort |tee -a "$strCFGScriptLog"
  #fi
  
  iSuggestReservedAmount=$((iStillMissingPOIs+iReservedWastelandPOICountForMissingPOIs))
  if((iSuggestReservedAmount>iMaxAllowedReservablePOIsInWasteland));then
    CFGFUNCprompt "not all iStillMissingPOIs='$iStillMissingPOIs' will fit in this world because iMaxAllowedReservablePOIsInWasteland='$iMaxAllowedReservablePOIsInWasteland' (as other biomes than wasteland are already all usable to place missing POIs)"
    iSuggestReservedAmount=$iMaxAllowedReservablePOIsInWasteland
  fi
  CFGFUNCprompt "to add all (or most) missing POIs, try to add dup POIs '${strDummyPOI}' at AddExtraPOIs file or try to run this script again like: iReservedWastelandPOICountForMissingPOIs=${iSuggestReservedAmount} $0"
fi

strModGenWorlTNMPath="GeneratedWorlds.ManualInstallRequired/${strCFGGeneratedWorldTNM}"
CFGFUNCgencodeApply "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"
CFGFUNCgencodeApply --subTokenId "UndergroundHints" "${strFlPatched}.UndergroundHints.xml" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#if [[ -f "${strFlPatched}.ExplodeAbove.xml" ]];then
CFGFUNCgencodeApply --subTokenId "WildernessTrap" "${strFlPatched}.WildernessTrap.xml" "${strModGenWorlTNMPath}/${strPrefabsXml}"
CFGFUNCgencodeApply --subTokenId "ExplodeAbove" "${strFlPatched}.ExplodeAbove.xml" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#fi

strFlAddExtraSpecialPOIs="`basename "$0"`.AddExtraSpecialPOIs.${strCFGGeneratedWorldTNMFixedAsID}.${strCFGGeneratedWorldSpecificDataAsID}.xml"
CFGFUNCinfo "MAIN:adding extra special manually placed POIs for the current configured world RWG data: ${strFlAddExtraSpecialPOIs}"
if [[ -f "$strFlAddExtraSpecialPOIs" ]];then
  egrep "HELPGOOD|<decoration" "${strFlAddExtraSpecialPOIs}" |egrep -v "dummy" >>"${strFlPatched}"
else
  if ! CFGFUNCprompt -q "No extra POIs file found (expected: '${strFlAddExtraSpecialPOIs}'), is that correct?";then
    CFGFUNCerrorExit "missing file '$strFlAddExtraSpecialPOIs'"
  fi
fi
#echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >>"${strFlPatched}${strGenTmpSuffix}" #as this file will be copied to outside this modlet folder
#echo '  <decoration type="model" name="bombshelter_02" position="-3131,3,-3131" rotation="2" help="oasis teleport is on the ground above, this prefab will be placed further underground than vanilla, teleport -3131 37 -3131"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
#echo '  <decoration type="model" name="ranger_station_04" position="-2105,43,-2313" rotation="0" help="extra spawn point (todo: explain why)"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
#while ! CFGFUNCgencodeApply "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}";do

CFGFUNCgencodeApply --subTokenId "ManuallyAddedPrefabs" "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#while ! CFGFUNCgencodeApply "${strFlPatched}" "${strFlPatched}";do
  #CFGFUNCprompt "the merger app will be run. on the left is the data that will be placed on the right file. you need to paste the above tokens (copy them now) on the right file to let the merge happens automatically on the next loop."
  #CFGFUNCmeld "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}"
  ##CFGFUNCinfo "waiting you place the above tokens on the required file: ${strFlPatched}"
#done

CFGFUNCgencodeApply --subTokenId "UndergroundPOIs" "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"
CFGFUNCgencodeApply --xmlcfg ".iGSKElctrnTeleUndergroundIndexMax" "${iMaxUndergroundIndex}"

#CFGFUNCinfo "MAIN:updating this mod's prefabs file"
#strModGenWorlTNMPath="GeneratedWorlds.ManualInstallRequired/${strCFGGeneratedWorldTNM}"
#CFGFUNCcreateBackup "${strModGenWorlTNMPath}/${strPrefabsXml}"
#CFGFUNCmeld "${strModGenWorlTNMPath}/${strPrefabsXml}" "${strFlPatched}"
#if CFGFUNCprompt -q "apply patch at the modlet file '${strModGenWorlTNMPath}/${strPrefabsXml}' for the release?";then
  #CFGFUNCexec cp -vf "$strFlPatched" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#fi

#ls -l "$strFlGenPrefabsOrig" "$strFlPatched"
#CFGFUNCcreateBackup "$strFlGenPrefabsOrig"
#CFGFUNCmeld "$strFlGenPrefabsOrig" "$strFlPatched"
##read -n 1 -p "apply patch at '${strFlGenPrefabsOrig}' (y/...)?" strResp;echo
##if [[ "$strResp" == y ]];then
#if CFGFUNCprompt -q "apply patch at '${strFlGenPrefabsOrig}' for your gamemplay?";then
  ##(
    ##cd "${strCFGGameFolder}";
    ##cp -v "$strFlGenPrefabsOrig" "${strFlGenPrefabsOrig}.`date +"${strCFGDtFmt}"`.bkp"
    ##cp -vf "$strFlPatched" "$strFlGenPrefabsOrig"
    ##trash -v "$strFlPatched"
  ##)
  #CFGFUNCexec cp -vf "$strFlPatched" "$strFlGenPrefabsOrig"
  ##echo "SUCCESS!!!"
#fi

CFGFUNCinfo "MAIN:Listing to check for dups (tho town in wasteland shall not be touched!)"
egrep "<decoration" "${strModGenWorlTNMPath}/${strPrefabsXml}" |egrep 'name="[^"]*"' -o |sort #todo try to list just the dups

CFGFUNCinfo "MAIN:SUCCESS!"

CFGFUNCprompt "MAIN: you should update the spawn points file now! and install the improved file '${strModGenWorlTNMPath}/${strPrefabsXml}' (and the spawnpoints file) at the game folder (outside this modlet folder): ./createSpawnPoints.sh;./installSpecificFilesIntoGameFolder.sh"

#CFGFUNCprompt "MAIN: then run ./installSpecificFilesIntoGameFolder.sh to install the improved file '${strModGenWorlTNMPath}/${strPrefabsXml}' (and the spawnpoints file) at the game folder (outside this modlet folder)"

CFGFUNCwriteTotalScriptTimeOnSuccess
#declare -p astrCFGIdForRandomVsCurrentIndex |tr '[' '\n' |tee -a "${strCFGScriptLog}"
