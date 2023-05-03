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

strGenPrefabsData="`(
  cd ../..;
  cat "$strFlGenPrefabsOrig"
)`"

CFGFUNCinfo "TODO: delete all prefabs from towns that are outside wasteland: '${strFlGenPrefabsOrig}'" #TODO keep only one there tho

CFGFUNCinfo "collecting POIs originally placed by RWG: '${strFlGenPrefabsOrig}'"
IFS=$'\n' read -d '' -r -a astrGenPOIsList < <(
  cd ../..; # bash uses the symlinked path while ls and cat use the realpath
  pwd >/dev/stderr;
  #cat "$strFlGenPrefabsOrig" 
  echo "$strGenPrefabsData" \
    |egrep 'name="[^"]*"' -o \
    |tr -d '"' |sed 's@name=@@' \
    |egrep -v "${strRegexIgnoreGen}"\
    |sort)&&: # sort (non unique) is essential here to make replacing easier
if((${#astrGenPOIsList[@]}==0));then echo "ERROR: astrGenPOIsList empty";exit 1;fi

CFGFUNCinfo "colleting all possible POIs from prefabs xmls to see if any was ignored by RWG"
IFS=$'\n' read -d '' -r -a astrAllPOIsList < <(
  cd ../../Data/Prefabs/POIs;
  pwd >/dev/stderr;
  ls *.xml|sed 's@[.]xml@@'|egrep -v "${strRegexIgnoreOrig}"|sort)&&:
if((${#astrAllPOIsList[@]}==0));then echo "ERROR: astrAllPOIsList empty";exit 1;fi

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

CFGFUNCinfo "searching for missing POIs (that RWG ignored)"
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

: ${nSeedRandomPOIs:=1337} #help this seed placed the hospital on the wasteland biome (radiated) zone what is great! this seed wont give the same result on other game versions that have a different ammount of POIs.
CFGFUNCinfo "randomizing POIs order with seed '$nSeedRandomPOIs'"
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
  #strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
  astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
done
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  if((${astrGenPOIsDupCountList[$strGPD]}==1));then
    unset astrGenPOIsDupCountList[$strGPD]
  fi
done

CFGFUNCinfo "preparing patch file: copying decorations"
#"${strFlPatched}${strGenTmpSuffix}"
: ${strFlPatched:="${strTmpPath}/tmp.`basename "$0"`.`date +"${strCFGDtFmt}"`.${strPrefabsXml}${strGenTmpSuffix}"} #help
echo '  <!-- HELPGOOD: '"${strCFGInstallToken}"' -->' >"$strFlPatched" #as this file will be copied to outside this modlet folder
egrep "<decoration " "$strFlGenPrefabsOrig" >>"$strFlPatched" #this way it becomes a sector patch for gencodeApply.sh!
#(cd ../..;cp -fv "$strFlGenPrefabsOrig" "$strFlPatched")

CFGFUNCinfo "preparing patch file: replacing repeated POIs with random new POIs"
bEnd=false
iCountAtMissingPOIs=0
iSkipped=0
strFlRunLog="`basename "$0"`.LastRun.log.txt"
echo -n >"$strFlRunLog"
astrRestoredPOIs=()
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  for((i=${astrGenPOIsDupCountList[$strGPD]};i>1;i--));do
    # get 2nd match pos data
    strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
    eval "$strPos" #nX nY nZ
    #declare -p nX nY nZ
    
    # TODO make these regions configurable
    bSkip=false
    if((nX>=645 && nX<=1019 && nZ<=-523 && nZ>=-899));then
      # town 1 in radiated area wasteland OK
      # x 662 645 1019 962
      # z -899 -530 -523 -899
      # topLeftXZ=645,-523;bottomRightXZ=1019,-899
      echo " >>> WARN:SKIPPING:InTown1Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    # t2 x 2285 2516 2434 z -738 -730 -588
    if((nX>=2285 && nX<=2516 && nZ<=-588 && nZ>=-738));then
      #TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      echo " >>> WARN:SKIPPING:InTown2Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    # t3 x 3359 3338 3451 z -1259 -1351 -1359
    if((nX>=3338 && nX<=3451 && nZ<=-1259 && nZ>=-1359));then
      #TODO not good as is not in the wasteland, replace all POIs with difficult POIs or just remove them, or leave only one there
      echo " >>> WARN:SKIPPING:InTown3Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    
    if $bSkip;then
      #add ignore mark @@@ so when perl runs, trying the 2nd match will ignore this one
      perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"@@@${strGPD}"'"/s' "$strFlPatched"
      ((iSkipped++))&&:
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
sed -i -r 's"@@@""' "$strFlPatched" #clean ignore mark

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
if((iStillMissingPOIs>0));then
  read -n 1 -p "list still missing POIs(y/...)?" strResp;echo
  if [[ "$strResp" == y ]];then
    for((i=iCountAtMissingPOIs;i<${#astrMissingPOIsList[@]};i++));do
      echo "${astrMissingPOIsList[i]}"
    done
  fi
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

CFGFUNCinfo "SUCCESS! now run the install script to install the improved file '${strModGenWorlTNMPath}/${strPrefabsXml}' at the game folder (outside this modlet folder)"

exit





######################################## OLD CODE

#strBN="${strTmpPath}/.`basename "$0"`.TMP."

#(
  #cd ../../Data/Prefabs/POIs
  #ls *.xml |sort |tr -d "[0-9]" |sort -u |sed 's@[.]xml@@' |sed -r 's"_$""' >"${strBN}.AllPOIs.txt"
  #pwd
  #ls -l "${strBN}.AllPOIs.txt"
#)

#cat "../../_7DaysToDie.UserData/GeneratedWorlds/East Nikazohi Territory/${strPrefabsXml}" |egrep 'name="[^"]*"' -o |tr -d '"' |sed 's@name=@@' |sort >"${strBN}.GenWorldPOIs.txt"
#ls -l "${strBN}.GenWorldPOIs.txt"

#IFS=$'\n' read -d '' -r -a astrFlList < <(cat "${strBN}.AllPOIs.txt");for strFl in "${astrFlList[@]}";do if ! egrep -q "^$strFl" "${strBN}.GenWorldPOIs.txt";then echo "$strFl";fi;done
