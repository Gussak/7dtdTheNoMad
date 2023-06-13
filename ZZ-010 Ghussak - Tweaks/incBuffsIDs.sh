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

source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

echo "HELP:
  This script is important (for developers) when making tests in a running game (instead of creating a new game) or when releasing an updated mod version for end users.
  Buffs with stack_type 'ignore' will directly benefit from this script, right? TODO chk
  Buffs with stack_type 'replace' will also benefit from this script because only the duration is reset but the running code wouldnt be replaced, right? TODO chk
  Buffs with values being set onSelfBuffStart and with other kinds of stack_type than 'ignore' also seem to require this script to be run or the changes on that trigger wont kick in, right? TODO chk
  Buffs must be between '' when in comments or other strings, so they will be ignored when trying to detect special files to force show meld.
"

set -eu
trap 'echo ERROR nLnErr=${nLnErr-} >&2' ERR
#trap 'echo "!!!!DO_NOT_INTERRUPT_THIS!!!!"' INT #todo make this work reversible, apply the patch on new files first and ask in the end if you want to apply it

bDecrement=false;
if [[ "${1-}" == --dec ]];then #help decrement instead
  bDecrement=true
fi

#HELP to get most of them: egrep 'buffGSKCalcPercRound[^"]*"' * -irI --include="*.xml" -oh |sort -u |tr -d '"' |sed -r 's@.*@  "&"@'

astrBuffBNList=(
  "buffBloodMoonLastsLonger"
  "buffDrinkRainWater"
  "buffGSKAllHazardsCheck"
  "buffGSKBkpWaterVal"
  "buffGSKBloodmoonZombiesPowerChk"
  "buffGSKBloodMoonStuff"
  "buffGSKCalcPercRoundHL"
  "buffGSKCalcPercRoundNV"
  "buffGSKCalcPercRoundTA"
  "buffGSKCalcPercRoundTH"
  "buffGSKCalcPercRoundTS"
  "buffGSKCalcPercRoundTT"
  "buffGSKCalcPercRoundWL"
  "buffGSKChemUseSideEffects"
  "buffGSKCosmicBloodMoon"
  "buffGSKCosmicRayStrike"
  "buffGSKCosmicRayStrikeChk"
  "buffGSKElctrnExplodeExtra"
  "buffGSKElctrnOverchargeDmg"
  "buffGSKFallOverLandingHit"
  "buffGSKGasMaskWork"
  "buffGSKHazardousWBloodLoss"
  #"buffGSKHazardousWCold"
  #"buffGSKHazardousWDesert"
  "buffGSKHazardousWeather"
  "buffGSKHazardousWElementColdHook"
  "buffGSKHazardousWElementHotHook"
  "buffGSKHazardousWHot"
  "buffGSKHazardousWMiasmaDirtyB"
  "buffGSKHazardousWRadiation"
  "buffGSKHazardousWSnow"
  "buffGSKHazardWDryness"
  "buffGSKHazardWeatherMiasmaDirty"
  "buffGSKHazardWWetFreezingAndHunger"
  "buffGSKHeatColdProtClothDmgAdd"
  "buffGSKHeatColdProtClothDmgKeep"
  "buffGSKInPineForestBiomeMonstersThrive"
  "buffGSKMeleeParry"
  "buffGSKMutant_ChkAndApplyOnMobs"
  "buffGSKNearDeath"
  #"buffGSKNPClimitLoot"
  "buffGSKNPClimitLootHired"
  "buffGSKNPCproperSneaking"
  "buffGSKNPCsStartSneak"
  "buffGSKNPCsStopSneak"
  "buffGSKNPCstumble"
  "buffGSKPermanentGenericCheck"
  "buffGSKProperSwimming"
  "buffGSKProperSwimmingWork"
  "buffGSKPsyResistWork"
  "buffGSKRadLowerSlow"
  "buffGSKRadRemover"
  "buffGSKRadResistWork"
  "buffGSKRespawnPreventWaterBkp"
  "buffGSKShowWaterBkp"
  "buffGSKSnakePoisonWork"
  "buffGSKSpawnTreasure"
  "buffGSKSpiderNet"
  "buffGSKWornArmor"
  "buffHiredNPCdamageArmor"
  "buffHiredNPCnoFallDamage"
  "buffLeaderCollectExpDebitFromNPC"
  "buffLeaderLimitsHiredNPCsAmount"
  "buffNightVisionUsesBatteries"
  "buffNPCAddExpDebitToLeader"
  "buffPlayerEnhancesNearbyFriendlyNPCs"
)
astrBuffBNList=(`echo "${astrBuffBNList[@]}" |tr " " "\n" |sort -u`) # grant unique entries
declare -p astrBuffBNList |tr '[' '\n'
#astrBuffBNList=(buffGSKNPClimitLoot) #todo RM

function FUNCgetCurrentIndex() {
#  egrep "${1}[0-9]*" --include="*.xml" -irIho |sort -u |egrep "[0-9]*" -o
  local lstr
  local lastrCmdGrep=(egrep "<buff +name=\"${1}[0-9]+\"[ >]" --include="*.xml" --exclude-dir="_*" -rI)
  CFGFUNCinfo "${lastrCmdGrep[@]}"
  nLnErr=$LINENO;lstr="$("${lastrCmdGrep[@]}"h)"
  CFGFUNCinfo "$lstr"
  nLnErr=$LINENO;lstr="$(echo "$lstr" |egrep "${1}[0-9]+" -ow)"
  CFGFUNCinfo "$lstr"
  nLnErr=$LINENO;lstr="$(echo "$lstr" |sort -u)"
  CFGFUNCinfo "$lstr"
  nLnErr=$LINENO;lstr="$(echo "$lstr" |egrep "[0-9]+" -o)"
  CFGFUNCinfo "$lstr"
  echo "$lstr"
}

iErrorCount=0
strErr=""
#set -x
iVal=1;if $bDecrement;then iVal=-1;fi
#for strBuffBN in "${astrBuffBNList[@]}";do
  #iId="$(FUNCgetCurrentIndex "${strBuffBN}")"
  #declare -p iId strBuffBN
  #if((`echo "$iId" |wc -l`!=1));then 
    #egrep "${strBuffBN}[0-9]*" --include="*.xml" -rIwn
    #echo "$LINENO:ERROR:should be just one line result for the current index numeric value";
    #exit 1;
  #fi
  
  #IFS=$'\n' read -d '' -r -a astrFlList < <(egrep "${strBuffBN}${iId}" --include="*.xml" -rnIc |grep -v :0 |cut -d: -f1)&&:
  #declare -p astrFlList |tr '[' '\n'
  #for strFl in "${astrFlList[@]}";do
    #declare -p strFl
    #iIdNew=$((iId+iVal))&&:
    #if((iIdNew<1));then iIdNew=1;fi
    #sed -i.bkp -r "s@(${strBuffBN})${iId}@\1${iIdNew}@" "$strFl"
    #if colordiff "${strFl}.bkp" "${strFl}";then
      #strErr+="ERROR: should have patched for $strBuffBN"
      #echo "$strErr"
      #((iErrorCount++))&&:
    #fi
  #done
#done
strDtTm="`date +"${strCFGDtFmt}"`"
strFlSpecialGreps="./_tmp/incBuffIDs.SpecialGreps.${strDtTm}.tmp"
echo -n >"$strFlSpecialGreps" #trunc
astrFlAllFilesPatchedList=()
astrBuffNotFoundList=()
astrSpecialFiles=()
for strBuffBN in "${astrBuffBNList[@]}";do
  iId="$(FUNCgetCurrentIndex "${strBuffBN}")"
  if [[ -z "$iId" ]];then 
    astrBuffNotFoundList+=("$strBuffBN")
    CFGFUNCinfo "WARN:iId is empty for '$strBuffBN', you just need to remove it from the array here.";
    continue;
  fi
  
  declare -p iId strBuffBN
  if((`echo "$iId" |wc -l`!=1));then 
    #egrep "${strBuffBN}[0-9]*" --include="*.xml" -rIwn
    echo "iId is (((${iId})))"
    echo "$LINENO:ERROR:should be just one line result for the current index numeric value";
    exit 1;
  fi
  
  IFS=$'\n' read -d '' -r -a astrFlList < <(egrep "${strBuffBN}${iId}" --include="*.xml" --exclude-dir="_*" -rnIc |grep -v :0 |cut -d: -f1)&&:
  declare -p astrFlList |tr '[' '\n'
  for strFl in "${astrFlList[@]}";do
    : ${strFlFilter:=""} #help
    if [[ -n "$strFlFilter" ]] && [[ "$strFlFilter" != "$strFl" ]];then continue;fi
    
    if [[ "${strFl}" =~ .*\ .* ]];then CFGFUNCerrorExit "dir or filename with spaces, not expected..";fi
    declare -p strFl
    strFlPatching="./_tmp/${strFl}.incBuffIDs.${strDtTm}.tmp"
    if egrep -q "[^\"']${strBuffBN}${iId}[^\"']" "$strFl";then
      astrSpecialFiles+=("${strFlPatching}:${strFl}:${strBuffBN}${iId}");
      egrep "[^\"']${strBuffBN}[0-9]*[^\"']" "$strFl" --color=always -nH |tee -a "$strFlSpecialGreps"
    fi
    mkdir -vp "`dirname "${strFlPatching}"`"
    if ! [[ -f "${strFlPatching}" ]];then cat "${strFl}" >"${strFlPatching}";fi
    iIdNew=$((iId+iVal))&&: #may be decrementing
    if((iVal== 1 && iIdNew<2));then CFGFUNCerrorExit "invalid increment where iIdNew=$iIdNew < 2, iId=$iId, iVal=$iVal";fi
    if((iVal==-1 && iIdNew==0));then iIdNew=1;fi
    if((iVal==-1 && iIdNew<0));then CFGFUNCerrorExit "invalid decrement where iIdNew=$iIdNew < 0, iId=$iId, iVal=$iVal";fi
    #strData="`sed -r "s@(${strBuffBN})${iId}@\1${iIdNew}@" "${strFlPatching}"`"
    strData="`sed -r "s@${strBuffBN}${iId}@${strBuffBN}${iIdNew}@g" "${strFlPatching}"`"
    echo "$strData" >"${strFlPatching}"
    ls -l "$strFlPatching"
    if CFGFUNCexec --noErrorExit colordiff "${strFl}" "${strFlPatching}";then
      strErr+="ERROR: should have patched for $strBuffBN"
      echo "$strErr"
      ((iErrorCount++))&&:
    fi
    astrFlAllFilesPatchedList+=("${strFlPatching}:${strFl}")
  done
  #if [[ "$strBuffBN" == "buffGSKNPClimitLoot" ]];then exit 1;fi
done
if [[ -z "${astrFlAllFilesPatchedList[@]}" ]];then CFGFUNCinfo "WARN: nothing changed";exit 0;fi
IFS=$'\n' read -d '' -r -a astrFlAllFilesPatchedList < <(for strFlNew in "${astrFlAllFilesPatchedList[@]}";do echo "${strFlNew}";done |sort -u)&&:
declare -p astrFlAllFilesPatchedList
declare -p astrBuffNotFoundList |tr '[' '\n'
declare -p astrSpecialFiles |tr '[' '\n'

#clear;
declare -p astrFlAllFilesPatchedList |tr '[' '\n'
for strFlOldFlNew in "${astrFlAllFilesPatchedList[@]}";do
  strFlNew="`echo "$strFlOldFlNew" |cut -d: -f1`"
  strFlOld="`echo "$strFlOldFlNew" |cut -d: -f2`"
  CFGFUNCexec --noErrorExit colordiff "${strFlOld}" "${strFlNew}"&&:
  CFGFUNCexec cp -vf "${strFlOld}" "${strFlOld}.incBuffIDs.OLD.bkp"
done
find -name "*.incBuffIDs.OLD.bkp"

if true;then #slow but ok, and probably just plain useless if the sed command is 100% correct anyway...
  CFGFUNCinfo "Validating if only numbers were changed where expected, a very restrictive check"
  iValidationErrors=0
  declare -p astrFlAllFilesPatchedList |tr '[' '\n'
  declare -p astrSpecialFiles |tr '[' '\n'
  for strFlOldFlNew in "${astrFlAllFilesPatchedList[@]}";do
    strFlNew="`echo "$strFlOldFlNew" |cut -d: -f1`"
    strFlOld="`echo "$strFlOldFlNew" |cut -d: -f2`"
    declare -p strFlOld strFlNew 
    #strDataOld="`cat "${strFlOld}"`"
    #strDataNew="`cat "${strFlNew}"`"
    strDataOld="`diff "${strFlOld}" "${strFlNew}" |egrep "^<"`"
    strDataNew="`diff "${strFlOld}" "${strFlNew}" |egrep "^>"`"
    iTot=${#strDataOld};if((iTot<${#strDataNew}));then iTot=${#strDataNew};fi
    #for((iOld=0,iNew=0;iOld<iTot;));do
    iOld=0;iNew=0
    while true;do
      if((iOld>=iTot || iNew>=iTot));then break;fi
      echo -ne "Old(${iOld}/${#strDataOld}),New(${iNew}/${#strDataNew})\r"
      if [[ "${strDataOld:iOld:1}" == "${strDataNew:iNew:1}" ]];then ((iOld++,iNew++))&&:;continue;fi #(*1)
      if [[ "${strDataOld:iOld:1}" =~ \< ]] && [[ "${strDataNew:iNew:1}" =~ \> ]];then ((iOld++,iNew++))&&:;continue;fi #accepts diff token char
      if [[ "${strDataOld:iOld:1}" =~ [0-9] ]] && [[ "${strDataNew:iNew:1}" =~ [0-9] ]];then ((iOld++,iNew++))&&:;continue;fi #accepts numeric differences w/o calculating them (blindly)
      if ! [[ "${strDataOld:iOld:1}" =~ [0-9] ]];then #when inrementing the ID, the next char on New file may match the current in Old file (because the  old number could be 9 and the new 10)
        if [[ "${strDataOld:iOld:1}" == "${strDataNew:iNew+1:1}" ]];then ((iNew++));continue;fi #will be success at (*1)
      fi
      if ! [[ "${strDataNew:iNew:1}" =~ [0-9] ]];then #when decrementing the ID (invert the above explanation pls ;))
        if [[ "${strDataOld:iOld+1:1}" == "${strDataNew:iNew:1}" ]];then ((iOld++));continue;fi #will be success at (*1)
      fi
      CFGFUNCinfo "WARN: Unexpected char difference Old[$iOld]='${strDataOld:iOld:1}' != New[$iNew]='${strDataNew:iNew:1}'"
      ((iOld++,iNew++))&&:
      ((iValidationErrors++))&&:
    done
    echo
  done
  if((iValidationErrors>0));then
    CFGFUNCerrorExit "FAILED, see above errors..."
  fi
fi

declare -p astrFlAllFilesPatchedList |tr '[' '\n'
declare -p astrSpecialFiles |tr '[' '\n'
for strFlOldFlNew in "${astrFlAllFilesPatchedList[@]}";do
  strFlNew="$(realpath $(echo "$strFlOldFlNew" |cut -d: -f1))"
  strFlOld="$(realpath $(echo "$strFlOldFlNew" |cut -d: -f2))"
  astrMeldCmd=(meld "${strFlOld}" "${strFlNew}")
  
  bSpecial=false
  strFlOldOrig="$(echo "$strFlOldFlNew" |cut -d: -f2)"
  for strChkSpecialFl in "${astrSpecialFiles[@]}";do
    if [[ "${strChkSpecialFl}" =~ ^${strFlOldFlNew}:.* ]];then
      #CFGFUNCexec --noErrorExit egrep "${strFlOldOrig}" "$strFlSpecialGreps"
      (egrep "${strFlOldOrig}" "$strFlSpecialGreps" |sort)&&:
      CFGFUNCexec "${astrMeldCmd[@]}"
      bSpecial=true
      break
    fi
  done
  if ! $bSpecial;then
    echo "`declare -p astrMeldCmd`;"'"${astrMeldCmd[@]}"'
  fi
done

find -name "*.incBuffIDs.OLD.bkp"
if CFGFUNCprompt -q "everything looks ok? the final files were not changed yet. Accepting will move the new file over the final file. There are backups suffixed with '.incBuffIDs.OLD.bkp'";then
  declare -p astrFlAllFilesPatchedList |tr '[' '\n'
  for strFlOldFlNew in "${astrFlAllFilesPatchedList[@]}";do
    strFlNew="`echo "$strFlOldFlNew" |cut -d: -f1`"
    strFlOld="`echo "$strFlOldFlNew" |cut -d: -f2`"
    CFGFUNCexec mv -vf "${strFlNew}" "${strFlOld}"
  done

  if((iErrorCount==0));then
    echo "SUCCESS!!!"
  else
    echo "PROBLEM: iErrorCount=$iErrorCount"
    echo "$strErr"
  fi
fi

if((${#astrBuffNotFoundList[*]}>0));then
  declare -p astrBuffNotFoundList |tr '[' '\n'
  CFGFUNCinfo "you should remove from the cfg the above buffs not found in files anymore.."
fi

CFGFUNCwriteTotalScriptTimeOnSuccess
