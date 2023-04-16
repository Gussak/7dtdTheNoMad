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

echo "HELP:"
echo " this script is important when making tests in a running game or when releasing an updated mod version, because the savegame may keep an outdated running buff that prevents the new one from running right?"
echo " also, some buffs may completely fail to kick in, so create a debug item to make them start working or, may be, restart the game application (close and run it again)"

set -eu
trap 'echo ERROR nLnErr=$nLnErr' ERR

#HELP to get most of them: egrep 'buffGSKCalcPercRound[^"]*"' * -irI --include="*.xml" -oh |sort -u |tr -d '"' |sed -r 's@.*@  "&"@'

astrBuffBNList=(
  "buffBloodMoonLastsLonger"
  "buffDrinkRainWater"
  "buffGSKAllHazardsCheck"
  "buffGSKBkpWaterVal"
  "buffGSKBloodmoonZombiesPowerChk"
  "buffGSKCalcPercRoundHL"
  "buffGSKCalcPercRoundNV"
  "buffGSKCalcPercRoundTA"
  "buffGSKCalcPercRoundTH"
  "buffGSKCalcPercRoundTS"
  "buffGSKCalcPercRoundTT"
  "buffGSKCalcPercRoundWL"
  "buffGSKChemUseSideEffects"
  "buffGSKHazardousWBloodLoss"
  "buffGSKHazardousWCold"
  "buffGSKHazardousWDesert"
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
  "buffGSKMutant_ChkAndApplyOnMobs"
  "buffGSKNearDeath"
  "buffGSKPermanentGenericCheck"
  "buffGSKProperSwimming"
  "buffGSKProperSwimmingWork"
  "buffGSKPsyResistWork"
  "buffGSKRadLowerSlow"
  "buffGSKRadRemover"
  "buffGSKRadResistWork"
  "buffGSKShowWaterBkp"
  "buffGSKSnakePoisonWork"
  "buffGSKTeslaExplodeExtra"
  "buffGSKTeslaOverchargeDmg"
  "buffGSKWornArmor"
  "buffHiredNPCdamageArmor"
  "buffLeaderLimitsHiredNPCsAmount"
  "buffNightVisionUsesBatteries"
)
astrBuffBNList=(`echo "${astrBuffBNList[@]}" |tr " " "\n" |sort -u`) # grant unique entries
declare -p astrBuffBNList |tr '[' '\n'

function FUNCgetCurrentIndex() {
#  egrep "${1}[0-9]*" --include="*.xml" -irIho |sort -u |egrep "[0-9]*" -o
  local lstr
  nLnErr=$LINENO;lstr="$(egrep "${1}[0-9]*" --include="*.xml" -rIowh)"
  nLnErr=$LINENO;lstr="$(echo "$lstr" |sort -u)"
  nLnErr=$LINENO;lstr="$(echo "$lstr" |egrep "[0-9]*" -o)"
  echo "$lstr"
}

iErrorCount=0
strErr=""
#set -x
for strBuffBN in "${astrBuffBNList[@]}";do
  iId="$(FUNCgetCurrentIndex "${strBuffBN}")"
  declare -p iId strBuffBN
  if((`echo "$iId" |wc -l`!=1));then 
    egrep "${strBuffBN}[0-9]*" --include="*.xml" -rIwn
    echo "$LINENO:ERROR:should be just one line result for the current index numeric value";
    exit 1;
  fi
  
  IFS=$'\n' read -d '' -r -a astrFlList < <(egrep "${strBuffBN}${iId}" --include="*.xml" -rnIc |grep -v :0 |cut -d: -f1)&&:
  declare -p astrFlList |tr '[' '\n'
  for strFl in "${astrFlList[@]}";do
    declare -p strFl
    sed -i.bkp -r "s@(${strBuffBN})${iId}@\1$((iId+1))@" "$strFl"
    if colordiff "${strFl}.bkp" "${strFl}";then
      strErr+="ERROR: should have patched for $strBuffBN"
      echo "$strErr"
      ((iErrorCount++))&&:
    fi
  done
done

if((iErrorCount==0));then
  echo "SUCCESS!!!"
else
  echo "PROBLEM: iErrorCount=$iErrorCount"
  echo "$strErr"
fi
