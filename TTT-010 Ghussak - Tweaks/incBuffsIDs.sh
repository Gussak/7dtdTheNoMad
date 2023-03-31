#!/bin/bash

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
  "buffGSKNearDeath"
  "buffGSKProperSwimming"
  "buffGSKProperSwimmingWork"
  "buffGSKPsyResistWork"
  "buffGSKRadLowerSlow"
  "buffGSKRadRemover"
  "buffGSKRadResistWork"
  "buffGSKSnakePoisonWork"
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
