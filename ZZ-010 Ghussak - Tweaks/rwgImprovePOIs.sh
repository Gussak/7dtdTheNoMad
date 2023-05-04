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

egrep "[#]help" $0

#set -x
set -Eeu

source ./libSrcCfgGenericToImport.sh --gencodeTrashLast

strPrefabsXml="prefabs.xml"

strFlRunLog="`basename "$0"`.LastRun.log.txt"
echo -n >"$strFlRunLog"

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

astrIgnoreTmp=( #these wont be used to create variety, they will be ignored when looking for missing POIs on the original file created by the game engine RWG
  "house_new_mansion_03" #there is no data for this POI and it cause errors on log when loading the game
  "trader_"
  "part_"
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
strRegexIgnoreOrig="^(`echo "${astrIgnoreOrig[@]}" |tr " " "|"`)"

astrIgnoreGen=("${astrIgnoreTmp[@]}")
: ${bIgnoreCavesToo:=true} #help keep RWG caves as they are a nice break from the overworld even when repeated. But missing caves will still be added
if $bIgnoreCavesToo;then astrIgnoreGen+=("cave_" ".*_cave_");fi
strRegexIgnoreGen="^(`echo "${astrIgnoreGen[@]}" |tr " " "|"`)"
astrIgnoreTmp=();unset astrIgnoreTmp # just to make it sure not to use a tmp array elsewhere

astrTallBuildingPrefix=( #they are like a whole small town to explore
  apartment_
  apartments_
  business_
  factory_lg_
  hospital_
  hotel_
  industrial_
  installation_red_mesa
  #lodge_
  #lot_
  office_
  remnant_gas_station_
  remnant_industrial_
  remnant_skyscraper_
  skyscraper_
  #trader_
)

#strGenPrefabsData="`(
  #cd ../..;
  #cat "$strFlGenPrefabsOrig"
#)`"

function FUNCchkPosIsInTown() { # [--ignoreWasteland] <lnX> <lnZ>
  local lbIgnoreWasteland=false;if [[ "$1" == --ignoreWasteland ]];then lbIgnoreWasteland=true;shift;fi #this will let wasteland town rectangles be ignored when checking if it is in town
  local lnX=$1;shift
  local lnZ=$1;shift
  local lstrMsg=" >>> WARN:SKIPPING:X=$lnX,Z=$lnZ:"
  # TODO make these regions configurable, and let more regions be added: astrTownRectangles
  if((lnX>=645 && lnX<=1019 && lnZ<=-523 && lnZ>=-899));then
    if $lbIgnoreWasteland;then return 1;fi
    # town 1 in radiated area wasteland OK
    # x 662 645 1019 962
    # z -899 -530 -523 -899
    # topLeftXZ=645,-523;bottomRightXZ=1019,-899
    echo "${lstrMsg}InTown1Limits" |tee -a "$strFlRunLog" >/dev/stderr
    return 0
  fi
  # t2 x 2285 2516 2434 z -738 -730 -588
  if((lnX>=2285 && lnX<=2516 && lnZ<=-588 && lnZ>=-738));then
    #TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
    #echo " >>> WARN:SKIPPING:InTown2Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
    echo "${lstrMsg}InTown2Limits" |tee -a "$strFlRunLog" >/dev/stderr
    return 0
  fi
  # t3 x 3359 3338 3451 z -1259 -1351 -1359
  if((lnX>=3338 && lnX<=3451 && lnZ<=-1259 && lnZ>=-1359));then
    #TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
    #echo " >>> WARN:SKIPPING:InTown3Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
    echo "${lstrMsg}InTown3Limits" |tee -a "$strFlRunLog" >/dev/stderr
    return 0
  fi
  return 1
}

function FUNCgetXYZfromLine() { #<lstrLine>
  local lstrLine="$1";shift
  local lstrPos="`echo "${lstrLine}" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  eval "$lstrPos" #nX nY nZ
}

function FUNCgetName() {
  echo "$1" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
}

IFS=$'\n' read -d '' -r -a astrGenPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig")&&:

strFlCACHE="`basename "$0"`.CACHE.sh" #help if you delete the cache file it will be recreated
source "$strFlCACHE"&&: #this file contents can be like: the last value appended for the save variable will win

: ${iTotalChkBiome:=0}
if((iTotalChkBiome==0));then
  CFGFUNCinfo "updating all biomes info for all prefabs originally placed by RWG at '${strFlGenPrefabsOrig}'. This happens only once and will take a lot of time. Please wait this step end."
  for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
    ((iTotalChkBiome++))&&:
    echo "UpdateBiomeDataFor(${iTotalChkBiome}/${#astrGenPOIdataLineList[@]}): ${strGenPOIdataLine}"
    FUNCgetXYZfromLine "${strGenPOIdataLine}"
    ./getBiomeData.sh "$nX,$nY,$nZ" #just to create the database
  done
  
  echo "#PREPARE_RELEASE:REVIEWED:OK" >>"${strFlCACHE}"
  echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"${strFlCACHE}"
  declare -p iTotalChkBiome >>"${strFlCACHE}"
fi
source "./getBiomeData.sh.PosVsBiomeColor.CACHE.sh" #this can fail, do not protect with &&:

CFGFUNCinfo "delete all prefabs from TOWNS that are outside wasteland and were originally placed by RWG at '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
astrPatchedPOIdataLineList=()
for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
  FUNCgetXYZfromLine "${strGenPOIdataLine}"
  if ! FUNCchkPosIsInTown --ignoreWasteland $nX $nZ;then
    astrPatchedPOIdataLineList+=("${strGenPOIdataLine}")
    echo -n "."
  else
    echo "INFO:RemovingNonWastelandTownPrefabFromList: ${strGenPOIdataLine}"
  fi
done

CFGFUNCinfo "colleting all valid POIs from prefabs xmls (later will check if any was ignored by RWG or removed from non wasteland town areas)"
IFS=$'\n' read -d '' -r -a astrAllPOIsList < <(
  cd ../../Data/Prefabs/POIs;
  pwd >/dev/stderr;
  ls *.xml|sed -r 's@[.]xml@@'|egrep -v "${strRegexIgnoreOrig}"|sort)&&:
if((${#astrAllPOIsList[@]}==0));then echo "ERROR: astrAllPOIsList empty";exit 1;fi

CFGFUNCinfo "collecting tall building special POIs that shall all be placed only in the wasteland"
astrTallBuildingList=()
#for strPOI in "${astrAllPOIsList[@]}";do
for((i=0;i<"${#astrAllPOIsList[@]}";i++));do
  strPOI="${astrAllPOIsList[i]}"
  for strTallBuildingPrefix in "${astrTallBuildingPrefix[@]}";do
    if [[ "${strPOI}" =~ ^${strTallBuildingPrefix} ]];then
      echo "TallBuildingFound: $strPOI"
      astrTallBuildingList+=("$strPOI")
      unset astrAllPOIsList[$i] #removing tall buildings from the full list
    fi
  done
done
astrAllPOIsList=("${astrAllPOIsList[@]}") #fixes the array after removing the entries

function FUNCarrayContains() { # <lstrChk> <array values...>
  local lstrChk="$1";shift
  local lstr
  for lstr in "${@}";do
    if [[ "$lstrChk" == "$lstr" ]];then return 0;fi
  done
  return 1
}

CFGFUNCinfo "replacing tall buildings outside wasteland with a dup to be replaced again later"
iRemovedTallBuildingsFromNonWasteland=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  FUNCgetXYZfromLine "${strPatchedPOIdataLine}"
  eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" != "Wasteland" ]];then
    if FUNCarrayContains "`FUNCgetName "$strPatchedPOIdataLine"`" "${astrTallBuildingList[@]}";then
      echo "BEFORE:$strBiome: $strPatchedPOIdataLine"
      strSedReplaceId='s/name="[^"]*"/name="abandoned_house_01"/'
      astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
      echo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
      ((iRemovedTallBuildingsFromNonWasteland++))&&:
    fi
  fi
done

CFGFUNCinfo "replacing POIs inside wasteland with a dup so the remaining ones will be replaced again later"
iTotalWastelandPOIsLeastInTowns=0
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
  
  FUNCgetXYZfromLine "${strPatchedPOIdataLine}"
  if FUNCchkPosIsInTown $nX $nZ;then echo -n .;continue;fi #skip the wasteland town!
  
  eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
  if [[ "$strBiome" == "Wasteland" ]];then
    echo "BEFORE:$strBiome: $strPatchedPOIdataLine"
    strSedReplaceId='s/name="[^"]*"/name="abandoned_house_01"/'
    astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
    echo "AFTER_:$strBiome: ${astrPatchedPOIdataLineList[i]}"
    ((iTotalWastelandPOIsLeastInTowns++))&&:
  fi
done

CFGFUNCinfo "placing tall buildings in the wasteland"
strMarkToSkip="_MARKED_TO_BE_SKIPPED_"
iLastPPOIindexReplaced=0
: ${iReservedWastelandPOICountForMissingPOIs:=0} #help after running the script, if there is missing POIs, put that value on this var TODO check the prefabs ignored thru strRegexIgnoreGen, may be some of them could be used instead of preventing buildings being added on the wasteland below
iTotalTallBuildingsPlacedInWasteland=0
while true;do #this loop will try to populate the whole wasteland (least the RGW town) with tall buildings 
  bTryFitMore=true
  for strTallBuilding in "${astrTallBuildingList[@]}";do
    #for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    bReplaced=false
    for((i=iLastPPOIindexReplaced;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
      if(( iTotalTallBuildingsPlacedInWasteland >= (iTotalWastelandPOIsLeastInTowns - iReservedWastelandPOICountForMissingPOIs) ));then
        CFGFUNCinfo "Keeping ${iReservedWastelandPOICountForMissingPOIs} wasteland places to use with missing POIs"
        bReplaced=false;
        bTryFitMore=false;
        break;
      fi
      
      echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
      strPatchedPOIdataLine="${astrPatchedPOIdataLineList[i]}"
      if [[ "$strPatchedPOIdataLine" =~ name=\"${strMarkToSkip}[^\"]*\" ]];then echo -n .;continue;fi
      
      FUNCgetXYZfromLine "${strPatchedPOIdataLine}"
      if FUNCchkPosIsInTown $nX $nZ;then echo -n .;continue;fi #skip the wasteland town!
      
      eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
      if [[ "$strBiome" == "Wasteland" ]];then
        echo "BEFORE:$i: $strPatchedPOIdataLine"
        strSedReplaceId='s/name="[^"]*"/name="'"${strMarkToSkip}${strTallBuilding}"'"/'
        astrPatchedPOIdataLineList[i]="`echo "$strPatchedPOIdataLine" |sed -r "${strSedReplaceId}"`"
        echo "AFTER_:$i: ${astrPatchedPOIdataLineList[i]}"
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
CFGFUNCinfo "placing tall buildings in the wasteland: remove skip marker from IDs"
for((i=0;i<"${#astrPatchedPOIdataLineList[@]}";i++));do
  echo -en "$i/${#astrPatchedPOIdataLineList[@]}.\r"
  astrPatchedPOIdataLineList[i]="`echo "${astrPatchedPOIdataLineList[i]}" |sed -r "s/${strMarkToSkip}//"`"
done
declare -p astrPatchedPOIdataLineList |tr '[' '\n'

CFGFUNCinfo "collecting remaining POIs originally placed by RWG"
IFS=$'\n' read -d '' -r -a astrGenPOIsList < <(
  #cd ../..; # bash uses the symlinked path while ls and cat use the realpath
  #pwd >/dev/stderr;
  #cat "$strFlGenPrefabsOrig" 
  #echo "$strGenPrefabsData"           \
  #
  for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
    #echo "$strPatchedPOIdataLine" |egrep 'name="[^"]*"' -o |tr -d '"' |sed -r 's@name=@@'
    FUNCgetName "$strPatchedPOIdataLine"
  done |egrep -v "${strRegexIgnoreGen}" |sort
)&&: # sort (non unique) is essential here to make replacing easier
if((${#astrGenPOIsList[@]}==0));then echo "ERROR: astrGenPOIsList empty";exit 1;fi

CFGFUNCinfo "colleting all POIs Y offset from prefabs"
#strFlTmp="`mktemp`"
strFlTmp="`pwd`/`basename "$0"`.POIsYOS.tmp.txt"
echo -n >"$strFlTmp"
declare -A astrAllPOIsYOS
(
  cd ../../Data/Prefabs/POIs;
  pwd >/dev/stderr;
  for strPOI in "${astrAllPOIsList[@]}";do
    iYOS="`egrep '"YOffset"' "$strPOI.xml" |egrep 'value="[^"]*"' -o |tr -d '[a-zA-Z"=]'`"
    echo "astrAllPOIsYOS[$strPOI]=$iYOS" >>"$strFlTmp"
  done
)
source "$strFlTmp"

CFGFUNCinfo "searching for missing POIs (that RWG ignored or were removed from non wasteland town areas)"
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
  echo "No missing POIs."
  exit 0
fi

CFGFUNCinfo "granting POIs IDs (from filenames) have no spaces (if they have, this script must be updated to prevent errors)"
#echo "DEBUG:$LINENO:astrMissingPOIsList:Size:${#astrMissingPOIsList[@]}"
astrMPOItmp=("${astrMissingPOIsList[@]}")
astrMissingPOIsList=(`echo "${astrMPOItmp[@]}" |tr " " "\n" |sort -u`)
if((${#astrMissingPOIsList[@]}!=${#astrMPOItmp[@]}));then
  CFGFUNCerrorExit "Ln$LINENO: arrays sizes should match, some prefab has space(s) on the filename" >/dev/stderr
  #exit 1
fi

astrMPOIbkp=("${astrMissingPOIsList[@]}")

: ${nSeedRandomPOIs:=1337} #help this seed wont give the same result on other game versions that have a different ammount of POIs (or if you added new custom POIs)
#1337 seed, on this old code version, placed the hospital on the wasteland biome (radiated) zone, what was good but now... TODO: place all tall buildings in the wasteland using
CFGFUNCinfo "randomizing POIs order using seed '$nSeedRandomPOIs'"
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

CFGFUNCinfo "detecting repetead POIs"
declare -A astrGenPOIsDupCountList=()
for strGenPOI in "${astrGenPOIsList[@]}";do
  #strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
  astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
done
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  if((${astrGenPOIsDupCountList[$strGPD]}==1));then
    unset astrGenPOIsDupCountList[$strGPD]
  fi
done

#CFGFUNCinfo "delete all prefabs from towns that are outside wasteland: '${strFlGenPrefabsOrig}'" #TODO keep only one there tho
#IFS=$'\n' read -d '' -r -a astrGenPOIdataLineList < <(egrep "<decoration " "$strFlGenPrefabsOrig")&&:
#astrPatchedPOIdataLineList=()
#for strGenPOIdataLine in "${astrGenPOIdataLineList[@]}";do
  #FUNCgetXYZfromLine "${strGenPOIdataLine}"
  #if ! FUNCchkPosIsInTown --ignoreWasteland $nX $nZ;then
    #astrPatchedPOIdataLineList+=("${strGenPOIdataLine}")
  #else
    #echo "INFO:RemovingNonWastelandTownPrefabFromList: ${strGenPOIdataLine}"
  #fi
#done

CFGFUNCinfo "preparing patch file: only decorations lines"
#"${strFlPatched}${strGenTmpSuffix}"
: ${strFlPatched:="${strTmpPath}/tmp.`basename "$0"`.`date +"${strCFGDtFmt}"`.${strPrefabsXml}${strGenTmpSuffix}"} #help
echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >"$strFlPatched" #as this file will be copied to outside this modlet folder
for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do
  echo "$strPatchedPOIdataLine" >>"$strFlPatched" #this way it becomes a sector patch for gencodeApply.sh!
done
#egrep "<decoration " "$strFlGenPrefabsOrig" >>"$strFlPatched" #this way it becomes a sector patch for gencodeApply.sh!
#(cd ../..;cp -fv "$strFlGenPrefabsOrig" "$strFlPatched")

function FUNCgetXYZforPrefab() { #<lstrPrefab>
  local lstrPrefab="$1";shift
  #local lstrPos="`echo "$strGenPrefabsData" |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  local lstrPos="`for strPatchedPOIdataLine in "${astrPatchedPOIdataLineList[@]}";do echo "${strPatchedPOIdataLine}";done |grep "$lstrPrefab" |head -n 2 |tail -n 1`"
  FUNCgetXYZfromLine "$lstrPos"
}
#function FUNCgetXYZforPrefab() { #<strPrefab>
  #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@declare -g nX=\1 nY=\2 nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
#}

CFGFUNCinfo "preparing patch file: replacing repeated POIs with random new POIs"
bEnd=false
iCountAtMissingPOIs=0
iSkipped=0
astrRestoredPOIs=()
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  for((i=${astrGenPOIsDupCountList[$strGPD]};i>1;i--));do
    # get 2nd match pos data
    FUNCgetXYZforPrefab "$strGPD"
    #strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed -r  's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
    #eval "$strPos" #nX nY nZ
    #declare -p nX nY nZ
    
    bSkip=false;
    
    if FUNCchkPosIsInTown $nX $nZ;then bSkip=true;fi # skip locations in towns to keep the RGW good looking quality
    
    eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["$nX,$nY,$nZ"]}`" # iBiome strBiome strColorAtBiomeFile
    if [[ "$strBiome" == "Wasteland" ]];then bSkip=true;fi # skip wasteland that was already filled up with tall buildings
    
    if $bSkip;then
      #strMarkToSkip
      #strMarkToSkip="@@@";#add IGNORE mark @@@ so when perl runs, trying the 2nd match will ignore this one
      #if FUNCchkPosIsInTown --ignoreWasteland $nX $nZ;then strMark="@D@";fi #this is a DELETE mark, to remove the entry
      perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"${strMarkToSkip}${strGPD}"'"/s' "$strFlPatched"
      ((iSkipped++))&&: #add IGNORE mark strMarkToSkip so when perl runs, trying the 2nd match will ignore this one just because it will be different and invalid for now
    else
      strMissingPOI="${astrMissingPOIsList[$iCountAtMissingPOIs]}"
      echo "$strGPD:$i:$strMissingPOI($iCountAtMissingPOIs):($nX,$nY,$nZ):YOS[no-TODO](${astrAllPOIsYOS[$strGPD]-}/${astrAllPOIsYOS[$strMissingPOI]-})" |tee -a "$strFlRunLog"&&: >/dev/stderr
      # this will change the 2nd match only of a dup entry strGPD
      perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"$strMissingPOI"'"/s' "$strFlPatched"
      
      : ${bApplyYOSDiff:=true} #help Wont TODO change prefab Y pos to be the difference between old and new prefab YOS
      if $bApplyYOSDiff;then
        : #Wont TODO: Better use xmlstarlet for YOS ...
        # BUT THERE IS A BIGGER PROBLEM: the rwg game engine considers several things to make it look good and fit perfectly on the surrounding environment. What is impossible to do with this script.
      fi
      
      if echo " ${astrRestoredPOIs[@]} " |grep " $strMissingPOI ";then
        echo "ERROR: using again a missing POI $strMissingPOI"
        exit 1
      fi
      astrRestoredPOIs+=("$strMissingPOI")
      
      ((iCountAtMissingPOIs++))&&:
      if((iCountAtMissingPOIs>=${#astrMissingPOIsList[@]}));then bEnd=true;break;fi
    fi
  done
  if $bEnd;then break;fi
done
#sed -i -r 's"@@@""' "${strFlPatched}" #clean ignore mark to let game accept the data
sed -i -r "s/${strMarkToSkip}//" "${strFlPatched}" #clean ignore mark to let game accept the data

#CFGFUNCinfo "Remove prefabs from town areas outside the wasteland"
#cat "${strFlPatched}" |egrep -v "@D@" >"${strFlPatched}.DeleteTowns.tmp"
#ls -l "${strFlPatched}" "${strFlPatched}.DeleteTowns.tmp"
#CFGFUNCmeld "${strFlPatched}" "${strFlPatched}.DeleteTowns.tmp"
#CFGFUNCexec mv -vf "${strFlPatched}.DeleteTowns.tmp" "${strFlPatched}"
#ls -l "${strFlPatched}"

#echo;echo "#####################################################################################"
#declare -p astrAllPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrMissingPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsDupCountList |tr '[' '\n' #|egrep -v '="1"'

iStillMissingPOIs=$((${#astrMissingPOIsList[@]}-iCountAtMissingPOIs))

CFGFUNCinfo "REPORT RESULTS:"
echo "Totals:"
echo "missing POIs: ${#astrMissingPOIsList[@]}"
echo "astrGenPOIsList: ${#astrGenPOIsList[@]}"
echo "astrAllPOIsList: ${#astrAllPOIsList[@]}"
echo "changed POIs: $iCountAtMissingPOIs"
echo "skipped in town limits: $iSkipped"
echo "still missing POIs: $iStillMissingPOIs"
echo "ETC:"
echo "iRemovedTallBuildingsFromNonWasteland=${iRemovedTallBuildingsFromNonWasteland}"
echo "iTotalWastelandPOIsLeastInTowns=${iTotalWastelandPOIsLeastInTowns}"
echo "iTotalTallBuildingsPlacedInWasteland=${iTotalTallBuildingsPlacedInWasteland}"
echo "TotalUniqueTallBuildings=${#astrTallBuildingList[@]}"
if((iStillMissingPOIs>0));then
  #read -n 1 -p "list still missing POIs(y/...)?" strResp;echo
  #if [[ "$strResp" == y ]];then
  if CFGFUNCprompt -q "list still missing POIs";then
    for((i=iCountAtMissingPOIs;i<${#astrMissingPOIsList[@]};i++));do
      echo "${astrMissingPOIsList[i]}"
    done |sort
  fi
  CFGFUNCprompt "to add all missing POIs, try to run this script again like: iReservedWastelandPOICountForMissingPOIs=${iStillMissingPOIs} $0"
fi

strModGenWorlTNMPath="GeneratedWorlds.ManualInstallRequired/${strCFGGeneratedWorldTNM}"
./gencodeApply.sh "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"




CFGFUNCinfo "adding extra prefabs" #TODO: add missing traders in the corners of the world, or below some lake
#echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >>"${strFlPatched}${strGenTmpSuffix}" #as this file will be copied to outside this modlet folder
echo '  <decoration type="model" name="bombshelter_02" position="-3131,3,-3131" rotation="2" help="oasis teleport is on the ground above, this prefab will be placed further underground than vanilla, teleport -3131 37 -3131"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
echo '  <decoration type="model" name="ranger_station_04" position="-2105,43,-2313" rotation="0" help="extra spawn point"/>' >>"${strFlPatched}" #${strGenTmpSuffix}"
#while ! ./gencodeApply.sh "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}";do
./gencodeApply.sh --subTokenId "ManuallyAddedPrefabs" "${strFlPatched}" "${strModGenWorlTNMPath}/${strPrefabsXml}"
#while ! ./gencodeApply.sh "${strFlPatched}" "${strFlPatched}";do
  #CFGFUNCprompt "the merger app will be run. on the left is the data that will be placed on the right file. you need to paste the above tokens (copy them now) on the right file to let the merge happens automatically on the next loop."
  #CFGFUNCmeld "${strFlPatched}${strGenTmpSuffix}" "${strFlPatched}"
  ##CFGFUNCinfo "waiting you place the above tokens on the required file: ${strFlPatched}"
#done

#CFGFUNCinfo "updating this mod's prefabs file"
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

CFGFUNCinfo "Listing to check for dups (tho town in wasteland shall not be touched!)"
egrep "decoration" "${strModGenWorlTNMPath}/${strPrefabsXml}" |egrep 'name="[^"]*"' -o |sort #todo try to list just the dups

CFGFUNCinfo "SUCCESS! now run the install script to install the improved file '${strModGenWorlTNMPath}/${strPrefabsXml}' at the game folder (outside this modlet folder)"

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
