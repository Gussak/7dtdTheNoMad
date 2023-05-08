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

strPrefabsXml="prefabs.xml"

#strFlRunLog="`basename "$0"`.LastRun.log.txt"
#echo -n >"$strFlRunLog"

#: ${strPathToUserData:="./_7DaysToDie.UserData"} #h elp relative to game folder (just put a symlink to it there)
#: ${strGenWorldName:="East Nikazohi Territory"} #h elp
#strFlGenPrefabsOrig="${strPathToUserData}/GeneratedWorlds/${strGenWorldName}/${strPrefabsXml}"

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

strRegexProtectedPOIs="(part_|rwg_|spider_|installation_red_mesa)" #these POIs shall be completely ignored anywhere #TODO ignore them if in removed towns too. rwg_ are for tiles rwg_tile_, including rwg_bridge_

astrIgnoreTmp=( #these wont be used to create variety, they will be ignored when looking for missing POIs on the original file created by the game engine RWG
  "house_new_mansion_03" #there is no data for this POI and it cause errors on log when loading the game
  "trader_"
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

#astrTallBuildingPrefix=( #they are like a whole small town to explore
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
  #cd ../..;
  #cat "$strFlGenPrefabsOrig"
#)`"

declare -A astrTownList=()
strFlTownRect="./rwgImprovePOIs.sh.CfgTownsRectangles.sh"
if cat "${strFlTownRect}";then
  : ${bAskIfWorldTownRectanglesAreOk:=true} #help disable if this question is annoying you
  if $bAskIfWorldTownRectanglesAreOk && ! CFGFUNCprompt -q "Are the above town's rectangles correct? (if not edit '${strFlTownRect}' properly)";then
    CFGFUNCerrorExit "re-run this script after towns rectangles are fixed."
  fi
fi
source "${strFlTownRect}"&&:
function FUNCchkPosIsInTown() { # [--ignore <Wasteland|Snow|PineForest|Desert>] <lnX> <lnZ>
  local lstrIgnoreBiome="";if [[ "$1" == --ignore ]];then shift;lstrIgnoreBiome="$1";shift;fi #this will let wasteland town rectangles be ignored when checking if it is in town
  local lnX=$1;shift
  local lnZ=$1;shift
  local lstrMsg=" >>> WARN:SKIPPING:X=$lnX,Z=$lnZ:"
  
  for strTownData in "${!astrTownList[@]}";do
    eval "`echo "$strTownData" |sed -r 's@(.*)_CFG_(.*)_Biome(.*)_TownID(.*)@strPITWorldName="\1";strPITRWGcfg="\2";strPITBiome="\3";strPITTownID="\4";@'`"
    eval "`echo "${astrTownList[$strTownData]}" |sed -r 's@^([^,]*),([^,]*),([^,]*),([^,]*)$@iXTopLeftPIT=\1;iZTopLeftPIT=\2;iXBottomRightPIT=\3;iZBottomRightPIT=\4;@'`"
    if [[ -n "$lstrIgnoreBiome" ]] && [[ "${lstrIgnoreBiome}" =~ "$strPITBiome" ]];then continue;fi
    if [[ "`CFGFUNCfixId "$strCFGGeneratedWorldTNM"`" == "$strPITWorldName" ]];then
      if((lnX>=iXTopLeftPIT && lnX<=iXBottomRightPIT && lnZ<=iZTopLeftPIT && lnZ>=iZBottomRightPIT));then
        declare -g strPITWorldName strPITRWGcfg strPITBiome strPITTownID iXTopLeftPIT iZTopLeftPIT iXBottomRightPIT iZBottomRightPIT
        CFGFUNCinfo "${lstrMsg}InTownLimits($lnX,$lnZ) $strPITBiome $strPITTownID ($iXTopLeftPIT,$iZTopLeftPIT,$iXBottomRightPIT,$iZBottomRightPIT)"
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
      #declare -g iTownIndex=1
      #return 0
    #fi
    ## t2 x 2285 2516 2434 z -738 -730 -588
    #if((lnX>=2285 && lnX<=2516 && lnZ<=-588 && lnZ>=-738));then
      ##TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      ##echo " >>> WARN:SKIPPING:InTown2Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      ##echo "${lstrMsg}InTown2Limits" |tee -a "$strFlRunLog" >/dev/stderr
      #CFGFUNCinfo "${lstrMsg}InTown2Limits"
      #declare -g iTownIndex=2
      #return 0
    #fi
    ## t3 x 3359 3338 3451 z -1259 -1351 -1359
    #if((lnX>=3338 && lnX<=3451 && lnZ<=-1259 && lnZ>=-1359));then
      ##TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      ##echo " >>> WARN:SKIPPING:InTown3Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      ##echo "${lstrMsg}InTown3Limits" |tee -a "$strFlRunLog" >/dev/stderr
      #CFGFUNCinfo "${lstrMsg}InTown3Limits"
      #declare -g iTownIndex=3
      #return 0
    #fi
  #fi
  
  #return 1
}

function FUNCgetXYZ() { #<lstrPosOrig> set global vars: nX nY nZ
  local lstrPosOrig="$1";shift
  if [[ -z "$lstrPosOrig" ]];then CFGFUNCerrorExit "invalid lstrPosOrig='$lstrPosOrig'";fi
  local lstrGlobalsXYZ="`echo "${lstrPosOrig}" |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  eval "$lstrGlobalsXYZ" #nX nY nZ
}
function FUNCgetXYZfromXmlLine() { #<lstrXmlLine> set global vars: iFilterIndex
  local lstrXmlLine="$1";shift
  local lstrPosOrig="`CFGFUNCxmlGetLinePropertyValue "$lstrXmlLine" "//decoration/@position"`"
  FUNCgetXYZ "$lstrPosOrig"
  declare -g iFilterIndex="`CFGFUNCxmlGetLinePropertyValue "$lstrXmlLine" "//decoration/@helpFilterIndex"`"
  #if [[ -z "$lstrPosOrig" ]];then CFGFUNCerrorExit "invalid lstrPosOrig='$lstrPosOrig'";fi
  ##declare -p lstrPosOrig >&2
  ##local lstrPos="`echo "${lstrXmlLine}" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #local lstrPos="`echo "${lstrPosOrig}" |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #eval "$lstrPos" #nX nY nZ
}

function FUNCxmlGetName() { #<strDecorationLine>
  #echo "$1" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
  CFGFUNCxmlGetLinePropertyValue "$1" "//decoration/@name"
}

function FUNCcalcPOINewY() { # <lnY> <lstrPOIold> <lstrPOInew>
  local lnY="$1";shift
  local lstrPOIold="$1";shift
  local lstrPOInew="$1";shift
  local liYOSOld=${astrAllPOIsYOS[$lstrPOIold]-};if [[ -z "${liYOSOld}" ]];then CFGFUNCerrorExit "not found $lstrPOIold";fi
  local liYOSNew=${astrAllPOIsYOS[$lstrPOInew]-};if [[ -z "${liYOSNew}" ]];then CFGFUNCerrorExit "not found $lstrPOInew";fi
  #echo $(( liYOSOld+(liYOSNew-liYOSOld) ))&&:
  local liYNew=$(( lnY+(liYOSNew-liYOSOld) ))
  #if((liYNew!=lnY));then
    #declare -p liYOSOld liYOSNew liYNew >&2
  #fi
  echo "$liYNew" #OUTPUT
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

#IFS=$'\n' read -d '' -r -a astrGenPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig" |tr -d '\r' |egrep -v 'name="${strRegexProtectedPOIs}[^"]*"')&&:
IFS=$'\n' read -d '' -r -a astrGenPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig" |tr -d '\r')&&:
#if [[ "`FUNCxmlGetName "${strPatchedPOIdataLine}"`" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder

strFlCACHE="`basename "$0"`.CACHE.sh" #help if you delete the cache file it will be recreated
source "$strFlCACHE"&&: #this file contents can be like: the last value appended for the save variable will win

: ${iTotalChkBiome:=0}
if((iTotalChkBiome==0));then
  CFGFUNCinfo "MAIN:updating all biomes info for all prefabs originally placed by RWG at '${strFlGenPrefabsOrig}'. This happens only once and will take a lot of time. Please wait this step end."
  for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
    ((iTotalChkBiome++))&&:
    CFGFUNCinfo "UpdateBiomeDataFor(${iTotalChkBiome}/${#astrGenPOIdataLineList[@]}): ${strGenPOIdataLine}"
    FUNCgetXYZfromXmlLine "${strGenPOIdataLine}"
    ./getBiomeData.sh "$nX,$nY,$nZ" #just to create the database
  done
  
  echo "#PREPARE_RELEASE:REVIEWED:OK" >>"${strFlCACHE}"
  echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"${strFlCACHE}"
  declare -p iTotalChkBiome >>"${strFlCACHE}"
fi
source "./getBiomeData.sh.PosVsBiomeColor.CACHE.sh" #this line is allowed to fail, do not protect with &&:
#eval "$(CFGFUNCbiomeData "-391,36,-2422")";declare -p iBiome strBiome strColorAtBiomeFile
#exit

IFS=$'\n' read -d '' -r -a astrPrefabPOIsPathList < <(cd ../../;find "`pwd`/" -type d -iregex ".*[/]Prefabs[/]POIs")&&:
declare -p astrPrefabPOIsPathList |tr '[' '\n'

CFGFUNCinfo "MAIN:colleting all valid POIs from prefabs xmls (later will check if any was ignored by RWG or removed from non wasteland town areas)"
IFS=$'\n' read -d '' -r -a astrAllPOIsList < <(
  for strPrefabPOIsPath in "${astrPrefabPOIsPathList[@]}";do
    cd "$strPrefabPOIsPath"
    pwd >/dev/stderr;
    ls *.xml|sed -r 's@[.]xml@@'|egrep -v "${strRegexIgnoreOrig}"|sort
  done
)&&:
if((${#astrAllPOIsList[@]}==0));then CFGFUNCerrorExit "astrAllPOIsList empty";fi

CFGFUNCinfo "MAIN:colleting all POIs Y offset and size from prefabs"
#strFlTmp="`mktemp`"
strFlTmp="`pwd`/_tmp/`basename "$0"`.POIsYOS.tmp.txt"
echo -n >"$strFlTmp"
declare -A astrAllPOIsYOS
declare -A astrAllPOIsSize
#execCFGAliases="eval $("$(realpath ./libSrcCfgGenericToImport.sh)" --aliases)"
( # subshell to easy changing path
  #$execCFGAliases
  for strPrefabPOIsPath in "${astrPrefabPOIsPathList[@]}";do
    cd "$strPrefabPOIsPath"
    #cd ../../Data/Prefabs/POIs
    pwd >/dev/stderr;
    IFS=$'\n' read -d '' -r -a astrPrefabsList < <(ls *.xml)&&:
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
      fi
      #iYOS="`egrep '"YOffset"' "${strPOI}.xml" |egrep 'value="[^"]*"' -o |tr -d '[a-zA-Z"=]'`"
      echo "astrAllPOIsYOS[$strPOI]=$iYOS" >>"$strFlTmp"
      
      strSize="`xmlstarlet sel -t -v "//property[@name='PrefabSize']/@value" "${strPOI}.xml" |tr -d ' '`"
      #<property name="PrefabSize" value="60, 108, 60" />
      echo "astrAllPOIsSize[$strPOI]='$strSize'" >>"$strFlTmp"
      
      CFGFUNCinfo "${strFlPrefabXml} iYOS=$iYOS strSize=$strSize"
    done
  done
)
source "$strFlTmp"
declare -p astrAllPOIsYOS |tr '[' '\n'
declare -p astrAllPOIsSize |tr '[' '\n'

strFlImportantBuildings="`basename "$0"`.ImportantBuildings.AddedToRelease.txt" #help if you delete the cache file it will be recreated
echo -n >>"$strFlImportantBuildings"
astrTallBuildingPrefix=(`cat "$strFlImportantBuildings"`)&&:
if [[ -z "${astrTallBuildingPrefix[@]-}" ]];then
  CFGFUNCinfo "MAIN:show tallest POIs to cherry pick for buildings that are like a small town to explore"
  for strPOI in "${!astrAllPOIsSize[@]}";do
    FUNCgetXYZ "${astrAllPOIsSize[$strPOI]}"
    echo "$nY height, $strPOI size ${astrAllPOIsSize[$strPOI]}"
  done |sort -n |tee -a "$strCFGScriptLog"
  CFGFUNCprompt "please cherry pick the important buildings and place one per line in the file: $strFlImportantBuildings"
  CFGFUNCerrorExit "the important buildings list was empty, re-run after editing the required file"
fi

function FUNChelpInfoPOI() {
  local lstrName="$1"
  echo "${lstrName},YOffset=${astrAllPOIsYOS[${lstrName}]-},Size=${astrAllPOIsSize[${lstrName}]-}"
}

CFGFUNCinfo "MAIN:create help and sorter xml properties for all POIs"
#for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
for((i=0;i<"${#astrGenPOIdataLineList[@]}";i++));do
  strGenPOIdataLine="${astrGenPOIdataLineList[i]}"
  
  FUNCgetXYZfromXmlLine "${strGenPOIdataLine}"
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  
  # helpFilterIndex would be used to grant no clashes will happen (but no clash will happen as position is already unique as POIs wont be placed above or below others)
  strName="`FUNCxmlGetName "$strGenPOIdataLine"`"
  strHelp="${strBiome};OriginalPOI(`FUNChelpInfoPOI "${strName}"`)"
  strSed='s@(name=")([^"]*)(")@helpSort="'"${strName}"'" helpFilterIndex="'$i'" \1\2\3 help="'"${strHelp}"'"@'
  astrGenPOIdataLineList[$i]="`echo "$strGenPOIdataLine" |sed -r "$strSed"`"
  CFGFUNCinfo "${astrGenPOIdataLineList[$i]}"
done
declare -p astrGenPOIdataLineList |tr '[' '\n'

CFGFUNCinfo "MAIN:collecting original location (to know the Y) for each POI originally placed by RWG. that Y was calculated based on the POI YOffset originally placed there (I guess). This Y can be used to calculate the new Y based on the difference of the YOffset of the old POI and the new POI that will be placed there (just skip the underground ones that are a fun trap)."
declare -A astrRWGOriginalLocationVsPOI=()
#for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
for((i=0;i<"${#astrGenPOIdataLineList[@]}";i++));do
  strGenPOIdataLine="${astrGenPOIdataLineList[i]}"
  FUNCgetXYZfromXmlLine "${strGenPOIdataLine}"
  strOriginalPOI="`FUNCxmlGetName "$strGenPOIdataLine"`"
  astrRWGOriginalLocationVsPOI["$nX,$nY,$nZ"]="${strOriginalPOI}"
  #astrGenPOIdataLineList[$i]="`CFGFUNCxmlSetLinePropertyValue "${astrGenPOIdataLineList[$i]}" "//decoration/@helpFilterIndex" "$i"`" #this index will be used to grant no clashes will happen (but no clash will happen as position is already unique as POIs wont be placed above or below others)
  #echo "$LINENO:RET=$?" >&2
  #astrGenPOIdataLineList[$i]="`CFGFUNCxmlAppendLinePropertyValue "${astrGenPOIdataLineList[$i]}" "//decoration/@help" "strOriginalPOI=${strOriginalPOI}"`"
  #echo "$LINENO:RET=$?" >&2
  CFGFUNCinfo "UPDATED:HelpInfo:${astrGenPOIdataLineList[$i]}"
done

CFGFUNCinfo "MAIN:delete all POIs from TOWNS that are outside wasteland and were originally placed by RWG at '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
astrPatchedPOIdataLineList=()
iTotalRemovedPOIsFromTownsOutsideWasteland=0
for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
  FUNCgetXYZfromXmlLine "${strGenPOIdataLine}"
  if ! FUNCchkPosIsInTown --ignore Wasteland $nX $nZ;then
    astrPatchedPOIdataLineList+=("${strGenPOIdataLine}")
    echo -n "."
  else
    #todoa keep the 4 POIs from corners of each town, 4 loops each checking: min X then min Z; max X then min Z; min X then max Z; max X then max Z ?
    ((iTotalRemovedPOIsFromTownsOutsideWasteland++))&&:
    CFGFUNCinfo "INFO:RemovingNonWastelandTownPrefabFromList[$iTotalRemovedPOIsFromTownsOutsideWasteland]: ${strGenPOIdataLine}"
  fi
done

CFGFUNCinfo "MAIN:collecting tall building special POIs that shall all be placed only in the wasteland"
astrTallBuildingList=()
#for strPOI in "${astrAllPOIsList[@]}";do
for((i=0;i<"${#astrAllPOIsList[@]}";i++));do
  strPOI="${astrAllPOIsList[i]}"
  for strTallBuildingPrefix in "${astrTallBuildingPrefix[@]}";do
    if [[ "${strPOI}" =~ ^${strTallBuildingPrefix} ]];then
      CFGFUNCinfo "TallBuildingFound: $strPOI"
      astrTallBuildingList+=("$strPOI")
      unset astrAllPOIsList[$i] #removing tall buildings from the full list
    fi
  done
done
astrAllPOIsList=("${astrAllPOIsList[@]}") #fixes the array after removing the entries
iTotalUniqueTallBuildings=${#astrTallBuildingList[@]}

function FUNCarrayContains() { # <lstrChk> <array values...>
  local lstrChk="$1";shift
  local lstr
  for lstr in "${@}";do
    if [[ "$lstrChk" == "$lstr" ]];then return 0;fi
  done
  return 1
}

CFGFUNCinfo "MAIN:replacing tall buildings outside wasteland with a dup to be replaced again later"
strDummyPOI="abandoned_house_01" #this simple POI may happen many times to be replaced
iRemovedTallBuildingsFromNonWasteland=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  FUNCgetXYZfromXmlLine "${strPatchedPOIdataLine}"
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" != "Wasteland" ]];then
    if FUNCarrayContains "`FUNCxmlGetName "$strPatchedPOIdataLine"`" "${astrTallBuildingList[@]}";then
      CFGFUNCinfo "BEFORE:$strBiome: $strPatchedPOIdataLine"
      strSedReplaceId='s/name="[^"]*"/name="'"${strDummyPOI}"'"/'
      astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
      CFGFUNCinfo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
      ((iRemovedTallBuildingsFromNonWasteland++))&&:
    fi
  fi
done

CFGFUNCinfo "MAIN:replacing POIs inside wasteland with a dup so the remaining ones will be replaced again later"
iTotalWastelandPOIsLeastInTowns=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  
  FUNCgetXYZfromXmlLine "${strPatchedPOIdataLine}"
  if FUNCchkPosIsInTown $nX $nZ;then echo -n "Wt,";continue;fi #skip the wasteland town!
  
  if [[ "`FUNCxmlGetName "${strPatchedPOIdataLine}"`" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder
  
  eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
  #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" == "Wasteland" ]];then
    CFGFUNCinfo "BEFORE:$strBiome: $strPatchedPOIdataLine"
    strSedReplaceId='s/name="[^"]*"/name="'"${strDummyPOI}"'"/'
    astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
    CFGFUNCinfo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
    ((iTotalWastelandPOIsLeastInTowns++))&&:
  fi
done

CFGFUNCinfo "MAIN:placing tall buildings in the wasteland"
strMarkToSkip="_MARKED_TO_BE_SKIPPED_"
iLastPPOIindexReplaced=0
: ${iReservedWastelandPOICountForMissingPOIs:=0} #help after running the script, if there is missing POIs, put that value on this var TODO check the prefabs ignored thru strRegexIgnoreGen, may be some of them could be used instead of preventing buildings being added on the wasteland below
iTotalTallBuildingsPlacedInWasteland=0
iLoopCount=0
iDiffTotWPOIsVsReserved=$((iTotalWastelandPOIsLeastInTowns - iReservedWastelandPOICountForMissingPOIs))
bHintAboutReservingPOIs=false
while true;do #this loop will try to populate the whole wasteland (least the RGW town) with tall buildings 
  bTryFitMore=true
  ((iLoopCount++))&&:
  for strTallBuilding in "${astrTallBuildingList[@]}";do
    #for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    bReplaced=false
    for((i=iLastPPOIindexReplaced;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
      if((iLoopCount>=2));then #to make it sure all the priority POIs will be placed
        bHintAboutReservingPOIs=true;
        if(( iTotalTallBuildingsPlacedInWasteland >= iDiffTotWPOIsVsReserved ));then
          iRemained=$(( iReservedWastelandPOICountForMissingPOIs-(iTotalTallBuildingsPlacedInWasteland-iDiffTotWPOIsVsReserved) ))
          CFGFUNCinfo "Keeping ${iRemained} wasteland places to use with missing POIs"
          bReplaced=false;
          bTryFitMore=false;
          break;
        fi
      fi
      
      echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
      strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
      if [[ "$strPatchedPOIdataLine" =~ name=\"${strMarkToSkip}[^\"]*\" ]];then echo -n .;continue;fi
      
      FUNCgetXYZfromXmlLine "${strPatchedPOIdataLine}"
      if FUNCchkPosIsInTown $nX $nZ;then echo -n .;continue;fi #skip the wasteland town!
      
      eval "$(CFGFUNCbiomeData "$nX,$nY,$nZ")" # iBiome strBiome strColorAtBiomeFile
      #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
      if [[ "$strBiome" == "Wasteland" ]];then
        CFGFUNCinfo "BEFORE:$i: $strPatchedPOIdataLine"
        strSedReplaceId='s/name="[^"]*"/name="'"${strMarkToSkip}${strTallBuilding}"'"/'
        astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
        CFGFUNCinfo "AFTER_:$i: ${astrPatchedPOIdataLineList[i]}"
        ((iTotalTallBuildingsPlacedInWasteland++))&&:
        iLastPPOIindexReplaced=$i
        bReplaced=true
        break
      fi
    done
    if ! $bReplaced;then bTryFitMore=false;break;fi
  done
  if ! $bTryFitMore;then break;fi
done
CFGFUNCinfo "MAIN:placing tall buildings in the wasteland: remove skip marker from IDs"
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  astrPatchedPOIdataLineList[i]="`echo "${astrPatchedPOIdataLineList[i]}" |sed -r "s/${strMarkToSkip}//"`"
done
declare -p astrPatchedPOIdataLineList |tr '[' '\n'

CFGFUNCinfo "MAIN:collecting remaining POIs originally placed by RWG"
IFS=$'\n' read -d '' -r -a astrGenPOIsList < <(
  #cd ../..; # bash uses the symlinked path while ls and cat use the realpath
  #pwd >/dev/stderr;
  #cat "$strFlGenPrefabsOrig" 
  #echo "$strGenPrefabsData"           \
  #
  for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    #echo "$strPatchedPOIdataLine" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
    FUNCxmlGetName "$strPatchedPOIdataLine"
  done |egrep -v "${strRegexIgnoreGen}" |sort
)&&: # sort (non unique) is essential here to make replacing easier
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

: ${nSeedRandomPOIs:=1337} #help this seed wont give the same result on other game versions that have a different ammount of POIs (or if you added new custom POIs)
CFGFUNCinfo "MAIN:randomizing POIs order using seed '$nSeedRandomPOIs'"
RANDOM=${nSeedRandomPOIs} 
astrMissingPOIsList=() #reset to randomize
#for strPOI in "${astrMPOItmp[@]}";do
iTot="${#astrMPOItmp[@]}"
for((i=0;i<iTot;i++));do
  iRnd="$(( RANDOM % ${#astrMPOItmp[@]} ))"
  strPOI="${astrMPOItmp[$iRnd]}"
  unset astrMPOItmp[$iRnd] #this clears the entry but do not change the array size
  astrMPOItmp=("${astrMPOItmp[@]}") #to update the array size
  astrMissingPOIsList+=("$strPOI")
done
if((${#astrMPOItmp[@]}>0));then
  declare -p astrMPOItmp |tr "[" "\n" >/dev/stderr
  #echo "ERROR:$LINENO: not empty" >/dev/stderr
  CFGFUNCerrorExit "Ln$LINENO: the list used to extract POIs randomly is not empty"
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

CFGFUNCinfo "MAIN:detecting repetead POIs"
declare -A astrGenPOIsDupCountList=()
for strGenPOI in "${astrGenPOIsList[@]}";do
  if [[ "${strGenPOI}" =~ ^${strRegexProtectedPOIs}.*$ ]];then echo -n "Pt,";continue;fi #skip things from the Prefabs/Parts folder
  #strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
  astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
done
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  if((${astrGenPOIsDupCountList[$strGPD]}==1));then
    unset astrGenPOIsDupCountList[$strGPD]
  fi
done
declare -p astrGenPOIsDupCountList |tr '[' '\n' |tee -a "$strCFGScriptLog"
#astrGenPOIsDupCountList=("${astrGenPOIsDupCountList[@]}")

#CFGFUNCinfo "MAIN:delete all prefabs from towns that are outside wasteland: '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
#IFS=$'\n' read -d '' -r -a astrGenPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig")&&:
#astrPatchedPOIdataLineList=()
#for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
  #FUNCgetXYZfromXmlLine "${strGenPOIdataLine}"
  #if ! FUNCchkPosIsInTown --ignore Wasteland $nX $nZ;then
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
#(cd ../..;cp -fv "$strFlGenPrefabsOrig" "$strFlPatched")

function FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile() { #<lstrPrefab> works always on the 2nd match found, therefore the 1st remains unique in the end
  local lstrPrefab="$1";shift
  #local lstrPos="`echo "$strGenPrefabsData" |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  #local lstrPos="`for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do echo "${strPatchedPOIdataLine}";done |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  local lstrLine="$(egrep "[ ]name=\"${lstrPrefab}\"[ ]" "$strFlPatched" |head -n 2 |tail -n 1)" # do not use `` it will fail resulting in 0, only $() worked!!! why? anyway `` is deprecated for bash...
  FUNCgetXYZfromXmlLine "$lstrLine"
}
#function FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile() { #<strPrefab>
  #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
#}

CFGFUNCinfo "MAIN:preparing patch file: replacing repeated POIs with random new POIs"
function FUNCappendHelpOnPatchedFile() {
  local lstrHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" "$strFlPatched"`"
  lstrHelp+="$1"
  CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" -v "${lstrHelp}" "$strFlPatched"
}      
bEnd=false
iCountAtMissingPOIs=0
iSkipped=0
astrRestoredPOIs=()
iUndergroundPOIs=0
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  iDupCount="$(egrep "[ ]name=\"${strGPD}\"[ ]" "$strFlPatched" |wc -l)" #the dup count from file is granted
  if((iDupCount!=${astrGenPOIsDupCountList[${strGPD}]}));then #this is a consistency check
    CFGFUNCinfo "WARNING: DupPOI '$strGPD' grepped dup count $iDupCount at file '$strFlPatched' does not match the array dup count ${astrGenPOIsDupCountList[${strGPD}]}"
  fi
  if((iDupCount<=1));then CFGFUNCerrorExit "invalid dup count $iDupCount";fi
  #CFGFUNCinfo "Working with DupPOI: $strGPD dup $iDupCount"  
  
  for((i=iDupCount;i>1;i--));do
    CFGFUNCinfo "Working with DupPOI($i): $strGPD dup $iDupCount"  
    egrep "[ ]name=\"${strGPD}\"[ ]" "$strFlPatched" |tee -a "$strCFGScriptLog"
    FUNCgetXYZfor2ndMatchingPrefabOnPatcherFile "$strGPD" #as this file is being constantly updated here on this loop
    #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r  's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
    #eval "$strPos" #nX nY nZ
    #declare -p nX nY nZ
    strXYZ="$nX,$nY,$nZ"
    CFGFUNCinfo "DupPOI: $strGPD iFilterIndex=$iFilterIndex XYZ=$strXYZ "
    
    bSkip=false;
    
    if FUNCchkPosIsInTown $nX $nZ;then bSkip=true;fi # skip locations in towns to keep the RGW good looking quality
    
    eval "$(CFGFUNCbiomeData "$strXYZ")" # iBiome strBiome strColorAtBiomeFile
    #if [[ -n "${astrPosVsBiomeColor[${strXYZ}]-}" ]];then      # faster
      #eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["${strXYZ}"]}`" # iBiome strBiome strColorAtBiomeFile
    #else      # much slower
      #eval "`./getBiomeData.sh "${strXYZ}"`" # strColorAtBiomeFile strBiome iBiome
    #fi
    #if [[ "$strBiome" == "Wasteland" ]];then bSkip=true;fi # skip wasteland that was already filled up with tall buildings
    #help The wasteland biome was already filled with priority POIs as much as possible beyond the minimum and considering the reserved limit
    
    strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
    if [[ "${strRWGoriginalPOI}" =~ ^${strRegexProtectedPOIs}.*$ ]];then bSkip=true;fi
    
    CFGFUNCexec -m "Query to be sure the entry exists for consistency" xmlstarlet sel -t -c "//decoration[@helpFilterIndex='${iFilterIndex}']" "$strFlPatched";echo #this line is allowed to fail, do not protect with &&:
    if $bSkip;then
      #strMarkToSkip
      #strMarkToSkip="@@@";#add IGNORE mark @@@ so when perl runs, trying the 2nd match will ignore this one
      #if FUNCchkPosIsInTown --ignore Wasteland $nX $nZ;then strMark="@D@";fi #this is a DELETE mark, to remove the entry
      #perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"${strMarkToSkip}${strGPD}"'"/s' "$strFlPatched"
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@name" -v "${strMarkToSkip}${strGPD}" "$strFlPatched"
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@helpSort" -v "${strGPD}" "$strFlPatched"
      
      ((iSkipped++))&&: #add IGNORE mark strMarkToSkip so when perl runs, trying the 2nd match will ignore this one just because it will be different and invalid for now
    else
      #strRWGoriginalPOI="${astrRWGOriginalLocationVsPOI[$nX,$nY,$nZ]}"
      strMissingPOI="${astrMissingPOIsList[$iCountAtMissingPOIs]}"
      CFGFUNCinfo "Dup=$strGPD:$i:Orig=$strRWGoriginalPOI:Miss=$strMissingPOI($iCountAtMissingPOIs):($nX,$nY,$nZ):YOS(O=${astrAllPOIsYOS[$strRWGoriginalPOI]-}/M=${astrAllPOIsYOS[$strMissingPOI]-}/D=${astrAllPOIsYOS[$strGPD]-})" # |tee -a "$strFlRunLog"&&: >/dev/stderr
      # this will change the 2nd match only of a dup entry strGPD
      #perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"$strMissingPOI"'"/s' "$strFlPatched"
      
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@name" -v "${strMissingPOI}" "$strFlPatched"
      CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@helpSort" -v "${strMissingPOI}" "$strFlPatched"
      
      #strHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" "$strFlPatched"`"
      #strHelp+=";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
      #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" -v "${strHelp}" "$strFlPatched"
      FUNCappendHelpOnPatchedFile ";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
      
      : ${bApplyYOSDiff:=true} #help changes prefab Y pos to be the difference between old and new prefab YOS (only to make things underground), if false will not change anything
      nYUpdatedFromPOIsOldVsNew="`FUNCcalcPOINewY $nY "$strRWGoriginalPOI" "$strMissingPOI"`" #use xmlstarlet to apply the new Y
      nYUpdFrPOIsOvsNinitialVal="$nYUpdatedFromPOIsOldVsNew"
      #if((nYUpdatedFromPOIsOldVsNew<nY));then bApplyYOSDiff=false;fi #only apply YOS diff if overground, keep underground unchanged!
      strHelpUnderground=""
      if((nYUpdatedFromPOIsOldVsNew<nY));then
        #more calc can be done based on the new POI height for better underground placement (more close to the expected surface elevation: nYUpdatedFromPOIsOldVsNew-newPOIheight-3. -3 is to not be so close that would create structural instability, despite that still may happen cuz of earth ground I think)
        nNewPOIHeight=$(FUNCgetXYZ "${astrAllPOIsSize[${strMissingPOI}]}";echo $nY)
        nYUpdatedFromPOIsOldVsNew=$((nYUpdatedFromPOIsOldVsNew-nNewPOIHeight-3))
        strHelpUnderground="Underground"
        ((iUndergroundPOIs++))&&:
      fi
      CFGFUNCinfo "old=${strRWGoriginalPOI}($nX,$nY,$nZ)(YO=${astrAllPOIsYOS[$strRWGoriginalPOI]-})(Sz=${astrAllPOIsSize[${strRWGoriginalPOI}]-});new=${strMissingPOI}($nX,$nYUpdFrPOIsOvsNinitialVal/$nYUpdatedFromPOIsOldVsNew,$nZ)(YO=${astrAllPOIsYOS[$strMissingPOI]-})(Sz=${astrAllPOIsSize[${strMissingPOI}]-})"
      strStatus=""
      if $bApplyYOSDiff;then
        #strRWGoriginalPOIindex="${astrRWGOriginalLocationVsPOIindex[$nX,$nY,$nZ]}"
        #FUNCcalcPOINewY $nY "$strGPD" "$strMissingPOI" #use xmlstarlet to apply the new Y
        #xmlstarlet ed -P -L -u "//decoration[@position='$nX,$nY,$nZ' and @helpFilterIndex='${strRWGoriginalPOIindex}']/@position" -v "$nYUpdatedFromPOIsOldVsNew" "$strFlPatched"
        #CFGFUNCexec -m "Query to be sure the entry exists" xmlstarlet sel -t -c "//decoration[@helpFilterIndex='${iFilterIndex}']" "$strFlPatched";echo #this line is allowed to fail, do not protect with &&:
        
        CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@position" -v "$nX,$nYUpdatedFromPOIsOldVsNew,$nZ" "$strFlPatched"
        
        #if [[ -n "$strHelpUnderground" ]];then
          #FUNCappendHelpOnPatchedFile ";${strHelpUnderground}"
        #fi
        
        #strHelp="`xmlstarlet sel -t -v "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" "$strFlPatched"`"
        #strHelp+=";NewPOI(`FUNChelpInfoPOI "${strMissingPOI}"`)"
        #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@help" -v "${strHelp}" "$strFlPatched"
        
        #CFGFUNCexec xmlstarlet ed -P -L -u "//decoration[@helpFilterIndex='${iFilterIndex}']/@helpSort" -v "${strMissingPOI}" "$strFlPatched"
        
        strStatus="UpdatedPosition"
        CFGFUNCinfo "$strStatus" #UpdateYOffsetForPOI"
        # BUT THERE IS A BIGGER PROBLEM: the rwg game engine considers several things to make it look good and fit perfectly on the surrounding environment. What is impossible to do with this script.
      else
        strStatus="KeptPosition"
        CFGFUNCinfo "$strStatus" #Kept POI position" #CFGFUNCinfo "Kept POI expectedly Underground"
      fi
      if [[ -n "$strHelpUnderground" ]];then
        FUNCappendHelpOnPatchedFile ";${strStatus};${strHelpUnderground}"
      fi
      
      if echo " ${astrRestoredPOIs[@]} " |grep " $strMissingPOI ";then
        CFGFUNCerrorExit "using again a missing POI $strMissingPOI"
      fi
      astrRestoredPOIs+=("$strMissingPOI")
      
      ((iCountAtMissingPOIs++))&&:
      if((iCountAtMissingPOIs>=${#astrMissingPOIsList[@]}));then bEnd=true;break;fi
    fi
  done
  if $bEnd;then break;fi
done
declar -p astrRestoredPOIs |tr '[' '\n' |tee -a "$strCFGScriptLog"

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
  CFGFUNCprompt "WARN:the above dups of strDummyPOI='$strDummyPOI' should have been replaced"
fi

iMaxAllowedReservablePOIsInWasteland=$((iTotalWastelandPOIsLeastInTowns-iTotalUniqueTallBuildings))
CFGFUNCinfo "MAIN:REPORT RESULTS:"
CFGFUNCinfo "[Totals:]"
CFGFUNCinfo "POI places:total original RWG generated: ${#astrGenPOIdataLineList[@]}"
CFGFUNCinfo "POI places:total removed POIs from NON wasteland towns: $iTotalRemovedPOIsFromTownsOutsideWasteland"
CFGFUNCinfo "POI places:total remaining on patched file: `egrep "<decoration " "${strFlPatched}" |wc -l`"
CFGFUNCinfo "Total missing POIs: ${#astrMissingPOIsList[@]}"
CFGFUNCinfo "Missing POIs that were restored: $iCountAtMissingPOIs"
#CFGFUNCinfo "Preserved POIs from remaining towns or just from anywhere in the wasteland: $iSkipped"
CFGFUNCinfo "iStillMissingPOIs=$iStillMissingPOIs (0 is good)"
#${#astrGenPOIsList[@]}
#CFGFUNCinfo "astrAllPOIsList: ${#astrAllPOIsList[@]}"
CFGFUNCinfo "[ETC:]"
CFGFUNCinfo "iSkipped=$iSkipped"
CFGFUNCinfo "iRemovedTallBuildingsFromNonWasteland=${iRemovedTallBuildingsFromNonWasteland}"
CFGFUNCinfo "iTotalWastelandPOIsLeastInTowns=${iTotalWastelandPOIsLeastInTowns}"
CFGFUNCinfo "iTotalTallBuildingsPlacedInWasteland=${iTotalTallBuildingsPlacedInWasteland}"
CFGFUNCinfo "iTotalUniqueTallBuildings=$iTotalUniqueTallBuildings"
CFGFUNCinfo "iMaxAllowedReservablePOIsInWasteland=$iMaxAllowedReservablePOIsInWasteland"
CFGFUNCinfo "iUndergroundPOIs=$iUndergroundPOIs"
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
  CFGFUNCprompt "to add all (or most) missing POIs, try to run this script again like: iReservedWastelandPOICountForMissingPOIs=${iSuggestReservedAmount} $0"
fi

strModGenWorlTNMPath="GeneratedWorlds.ManualInstallRequired/${strCFGGeneratedWorldTNM}"
CFGFUNCgencodeApply "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"

CFGFUNCinfo "MAIN:adding extra prefabs" #TODO: add missing traders in the corners of the world, or below some lake
#echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >>"${strFlPatched}${strGenTmpSuffix}" #as this file will be copied to outside this modlet folder
echo '  <decoration type="model" name="bombshelter_02" position="-3131,3,-3131" rotation="2" help="oasis teleport is on the ground above, this prefab will be placed further underground than vanilla, teleport -3131 37 -3131"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
echo '  <decoration type="model" name="ranger_station_04" position="-2105,43,-2313" rotation="0" help="extra spawn point (todo: explain why)"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
#while ! CFGFUNCgencodeApply "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}";do

CFGFUNCgencodeApply --subTokenId "ManuallyAddedPrefabs" "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#while ! CFGFUNCgencodeApply "${strFlPatched}" "${strFlPatched}";do
  #CFGFUNCprompt "the merger app will be run. on the left is the data that will be placed on the right file. you need to paste the above tokens (copy them now) on the right file to let the merge happens automatically on the next loop."
  #CFGFUNCmeld "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}"
  ##CFGFUNCinfo "waiting you place the above tokens on the required file: ${strFlPatched}"
#done

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
    ##cd ../..;
    ##cp -v "$strFlGenPrefabsOrig" "${strFlGenPrefabsOrig}.`date +"${strCFGDtFmt}"`.bkp"
    ##cp -vf "$strFlPatched" "$strFlGenPrefabsOrig"
    ##trash -v "$strFlPatched"
  ##)
  #CFGFUNCexec cp -vf "$strFlPatched" "$strFlGenPrefabsOrig"
  ##echo "SUCCESS!!!"
#fi

CFGFUNCinfo "MAIN:Listing to check for dups (tho town in wasteland shall not be touched!)"
egrep "decoration" "${strModGenWorlTNMPath}/${strPrefabsXml}" |egrep 'name="[^"]*"' -o |sort #todo try to list just the dups

CFGFUNCinfo "MAIN:SUCCESS! now run the install script to install the improved file '${strModGenWorlTNMPath}/${strPrefabsXml}' at the game folder (outside this modlet folder)"

CFGFUNCinfo "MAIN:After installing the prefabs file, run ./createSpawnPoints.sh to update the spawn points file"

CFGFUNCwriteTotalScriptTimeOnSuccess
exit





######################################## OLD CODE

#strBN="${strTmpPath}/.`basename "$0"`.TMP."

#(
  #cd ../../Data/Prefabs/POIs
  #ls *.xml |sort |tr -d "[0-9]" |sort -u |sed -r 's@[.]xml@@' |sed -r 's"_$""' >"${strBN}.AllPOIs.txt"
  #pwd
  #ls -l "${strBN}.AllPOIs.txt"
#)

#cat "../../_7DaysToDie.UserData/GeneratedWorlds/East Nikazohi Territory/${strPrefabsXml}" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@' |sort >"${strBN}.GenWorldPOIs.txt"
#ls -l "${strBN}.GenWorldPOIs.txt"

#IFS=$'\n' read -d '' -r -a astrFlList < <(cat "${strBN}.AllPOIs.txt");for strFl in "${astrFlList[@]}";do if ! egrep -q "^$strFl" "${strBN}.GenWorldPOIs.txt";then echo "$strFl";fi;done
