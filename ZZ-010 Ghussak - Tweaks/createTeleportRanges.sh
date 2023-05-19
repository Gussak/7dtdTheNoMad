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

    #<action_sequence name="eventGSKElctrnTeleNo" template="eventGSKElctrnTele"><variable name="v3Dir" value="0,0,'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSo" template="eventGSKElctrnTele"><variable name="v3Dir" value="0,0,-'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleWe" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRange}"',0,0"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleEa" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRange}"',0,0"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleNW" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRng45}"',0,'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleNE" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRng45}"',0,'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSW" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRng45}"',0,-'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSE" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRng45}"',0,-'"${nRng45}"'"/></action_sequence>

    #<action_sequence name="eventGSKElctrnTeleNoDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="0,-'"${nRange}"','"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSoDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="0,-'"${nRange}"',-'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleWeDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRange}"',-'"${nRange}"',0"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleEaDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRange}"',-'"${nRange}"',0"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleNWDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRng45}"',-'"${nRange}"','"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleNEDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRng45}"',-'"${nRange}"','"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSWDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="-'"${nRng45}"',-'"${nRange}"',-'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKElctrnTeleSEDw" template="eventGSKElctrnTele"><variable name="v3Dir" value="'"${nRng45}"',-'"${nRange}"',-'"${nRng45}"'"/></action_sequence>
    
      #<action_sequence name="eventGSKElctrnTeleDn" template="eventGSKElctrnTele"><variable name="v3Dir" value="0,-'"${nRange}"',0"/></action_sequence>
      
: ${nBaseDist:=7} #help the minimum distance to teleport, will be multiplied by the current index limited by teleport mod level
: ${nEnergyPerBlock:=60} #help

nOptsMax=6 # the optional distances amount you can choose in-game that multiplies nBaseDist for final dist calc. 6 is like teleport mod lvl 0 allows index 1... lvl5 allows index 6.

if((nBaseDist<1));then CFGFUNCerrorExit "invalid nBaseDist<1";fi
if((nOptsMax<1));then CFGFUNCerrorExit "invalid nOptsMax<1";fi

strCodeCfgOpts=""
anRangeList=()
for((nOpts=1;nOpts<=nOptsMax;nOpts++));do
  anRangeList+=($((nOpts*nBaseDist)))
  strCodeCfgOpts+='
  <triggered_effect trigger="onSelfPrimaryActionEnd" action="ShowToolbeltMessage" message="Teleport Distance index '"${nOpts}"'"><requirement name="CVarCompare" cvar="iGSKElctrnTeleportDistIndex" operation="Equals" value="'"${nOpts}"'" /></triggered_effect>
  <triggered_effect trigger="onSelfSecondaryActionEnd" action="ShowToolbeltMessage" message="Teleport Distance index '"${nOpts}"'"><requirement name="CVarCompare" cvar="iGSKElctrnTeleportDistIndex" operation="Equals" value="'"${nOpts}"'" /></triggered_effect>
  '
done

astrElevationList=("Dn" "" "Up")
declare -p astrElevationList
iEl=0

iCVarIndexIni=100
iCVarIndexRange=100

astrDirList=(
  No "North"        #1
  NE "Nort East"    #2
  Ea "East"         #3
  SE "South East"   #4
  So "South"        #5
  SW "South West"   #6
  We "West"         #7
  NW "North West"   #8
  #9 is Down(9) or Up(29) (19 would be no elevation so is ignored)
)

#: ${bUseDummyIncrement:=true} #h elp this is useful to make it easier to understand the directions vs cvar values
#: ${iDummyRange:=10} #h elp around directions are 1to8

strMayhemRnd='
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="set" value="'"${iCVarIndexRange}"'"/>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="set" value="randomInt(1,'"${nOptsMax}"')" help="distances">
    <requirement name="CVarCompare" cvar=".iGSKTeleRndDistIndexMax" operation="Equals" value="0" help="no limit, and if .iGSKTeleRndDistIndexMax==1 it will just not multiply"/>
  </triggered_effect>'
for((iOptCurrent=2;iOptCurrent<=nOptsMax;iOptCurrent++));do
  strCmdMaxMode="Equals";if((iOptCurrent==nOptsMax));then strCmdMaxMode="GTE";fi
  strMayhemRnd+='
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="set" value="randomInt(1,'"${iOptCurrent}"')" help="distances">
    <requirement name="CVarCompare" cvar=".iGSKTeleRndDistIndexMax" operation="'"${strCmdMaxMode}"'" value="'"${iOptCurrent}"'"/>
  </triggered_effect>'
done
strMayhemRnd+='
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="set" value="@iGSKTeleRndDistIndexMax" help="a negative value is meant to force that specific abs positive distance">
    <requirement name="CVarCompare" cvar=".iGSKTeleRndDistIndexMax" operation="LT" value="0"/>
  </triggered_effect>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="multiply" value="-1">
    <requirement name="CVarCompare" cvar=".iGSKTeleRndDistIndexMax" operation="LT" value="0"/>
  </triggered_effect>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKTeleRndDistIndexMax" operation="set" value="0" help="consume/reset/default for next call if it does not cfg it"/>
  
  <triggered_effect trigger="onSelfBuffStart" action="CVarLogValue" cvar=".iGSKElctrnTeleRndDist" compare_type="or" help="log invalid to help fix the logic">
    <requirement name="CVarCompare" cvar=".iGSKElctrnTeleRndDist" operation="LT" value="1"/>
    <requirement name="CVarCompare" cvar=".iGSKElctrnTeleRndDist" operation="GT" value="'"${nOptsMax}"'"/>
  </triggered_effect>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="set" value="1">
    <requirement name="CVarCompare" cvar=".iGSKElctrnTeleRndDist" operation="LT" value="1"/>
  </triggered_effect>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleRndDist" operation="set" value="'"${nOptsMax}"'">
    <requirement name="CVarCompare" cvar=".iGSKElctrnTeleRndDist" operation="GT" value="'"${nOptsMax}"'"/>
  </triggered_effect>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="multiply" value="@.iGSKElctrnTeleRndDist" help="distances"/>
  
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKTTDUpMidDown" operation="set" value="randomInt(0,2)" help="0down 1noElevation 2up"/>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKTTDUpMidDown" operation="multiply" value="10" help="1-9down 11-19noElevantion 21-29up"/>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="add" value="@.iGSKTTDUpMidDown"/>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="add" value="randomInt(1,8)" help="around directions"/>
  <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="add" value="1" help="straight up or down">
    <requirement name="CVarCompare" cvar=".iGSKTTDUpMidDown" operation="NotEquals" value="1" help="00 is down (1to8) and 9 is straight down, 10 is no elevation (11to18), 20 is up (21to28) and 29 is straight up"/>
    <requirement name="RandomRoll" seed_type="Random" min_max="1,9" operation="Equals" value="9"/>
  </triggered_effect>'

strGenCodeItemTeleCvarRanges=""
strGenCodeEventUpDown=""
strGenCodeItemTeleCvarRangesUpDn=""
strGenCodeBuffDirs=""
#for nRange in "${anRangeList[@]}";do
for iIndex in "${!anRangeList[@]}";do
  nRange="${anRangeList[iIndex]}"
  nUserIndex=$((iIndex+1))&&: # this is the distance index that the user will choose in-game
  echo
  #nRng45="`bc <<< "scale=0;${nRange}-(${nRange}*0.15)"`" # +- dist at 45 degrees around
  nRng45="`bc <<< "scale=0;((${nRange}-(${nRange}*0.13))*100)/100"`" # +- dist at 45 degrees around (this is a bc trunc trick) TODO proper calc sin cos etc...
  if((nRng45==nRange));then nRng45=$((nRange-1))&&:;fi
  iCV=$((iCVarIndexIni+(iIndex*iCVarIndexRange)))&&: #only increment this at event code gen lines!
  for((nYRng=-nRange;nYRng<=nRange;nYRng+=nRange));do
    strEl="${astrElevationList[iEl]}"
    
    #if $bUseDummyIncrement;then
      if [[ "$strEl" == "Dn" ]];then
        :
      elif [[ -z "$strEl" ]];then # no elevation
        ((iCV+=1))&&:
      elif [[ "$strEl" == "Up" ]];then
        ((iCV+=2))&&:
      fi
    #fi
    
    declare -p nRange nRng45 nYRng iEl strEl
    echo '        <!-- HELPGOOD: nRange='"${nRange}"' strEl='"${strEl}"' -->' >>"${strFlGenEve}${strGenTmpSuffix}"
    #for strDir in "${astrDirList[@]}";do
    for((iDir=0;iDir<${#astrDirList[@]};iDir+=2));do
      strDir="${astrDirList[$iDir]}"
      echo '  <action_sequence name="eventGSKElctrnTele'"${nUserIndex}${strDir}${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"','"${nRange}"'"/></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      echo '        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKElctrnTele'"${nUserIndex}${strDir}${strEl}"'"><requirement name="CVarCompare" cvar=".iGSKElctrnTeleDir" operation="Equals" value="'"${iCV}"'"/></triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
      if [[ "$strDir" == "No" ]];then
        nUpDown=0;if [[ "$strEl" == "Dn" ]];then nUpDown=-1;fi;if [[ "$strEl" == "Up" ]];then nUpDown=1;fi
        strGenCodeItemTeleCvarRanges+='
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="set" value="'"${iCV}"'" help="'"$nUserIndex: ${astrDirList[$((iDir+1))]} $strEl"'">
          <requirement name="CVarCompare" cvar="iGSKElctrnTeleportMixUpDown" operation="Equals" value="'"${nUpDown}"'" />
          <requirement name="CVarCompare" cvar="iGSKElctrnTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
          <requirement name="CVarCompare" cvar="_crouching" operation="Equals" value="0" />
        </triggered_effect>'
      fi
    done
    
    #echo '<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'No'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"','"${nRange}"'"/></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'NE'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'Ea'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'SE'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'So'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"',-'"${nRange}"'"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'SW'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'We'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      #<action_sequence name="eventGSKElctrnTele'"${nUserIndex}"'NW'"${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      #' >>"${strFlGenEve}${strGenTmpSuffix}"
    #strGenCodeItemTeleCvarRanges+='
  #<triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="set" value="'"$((iCV+1))"'" help="North">
    #<requirement name="CVarCompare" cvar="iGSKElctrnTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
    #<requirement name="CVarCompare" cvar="_crouching" operation="Equals" value="0" />
  #</triggered_effect>
    #'
      
    if((nYRng!=0));then
      #if((nYRng<0));then
      if [[ "$strEl" == "Dn" ]];then
        #iCVud=$((iCV+9))&&: #down
        iCrouch=1
      elif [[ "$strEl" == "Up" ]];then
        #iCVud=$((iCV+10))&&: #up
        iCrouch=0
      fi
      strGenCodeEventUpDown+='
      <action_sequence name="eventGSKElctrnTele'"${nUserIndex}${strEl}"'" template="eventGSKElctrnTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"',0"/></action_sequence>'
      strGenCodeItemTeleCvarRangesUpDn+='
      <triggered_effect trigger="onSelfSecondaryActionEnd" action="ModifyCVar" cvar=".iGSKElctrnTeleDir" operation="set" value="'"$((iCV))"'">
        <requirement name="CVarCompare" cvar="iGSKElctrnTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
        <requirement name="CVarCompare" cvar="_crouching" operation="Equals" value="'"${iCrouch}"'" />
      </triggered_effect>'
      echo '        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKElctrnTele'"${nUserIndex}${strEl}"'"><requirement name="CVarCompare" cvar=".iGSKElctrnTeleDir" operation="Equals" value="'"${iCV}"'"/></triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
    fi
    
    ((iEl++))&&:
    if((iEl>=${#astrElevationList[*]}));then iEl=0;fi
    
    #if $bUseDummyIncrement;then
      #((iCV+=1))&&:
    #fi
  done
done
echo "<!-- HELPGOOD: straight up and down -->" >>"${strFlGenEve}${strGenTmpSuffix}"
echo "${strGenCodeEventUpDown}" >>"${strFlGenEve}${strGenTmpSuffix}"

CFGFUNCgencodeApply "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"

#echo '    <!-- HELPGOOD: indexes 1 to '"${nOptsMax}"' -->
#' >>"${strFlGenIte}${strGenTmpSuffix}"
#CFGFUNCgencodeApply --subTokenId "CONFIGURATORS" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

echo "$strGenCodeItemTeleCvarRanges" >>"${strFlGenIte}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "TeleDirections" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"
echo "$strCodeCfgOpts" >>"${strFlGenIte}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "TeleDirectionsCfgOptsMsgs" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

CFGFUNCgencodeApply --subTokenId "TeleDirections" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
#echo '
  #<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="iGSKElctrnTeleportDistIndexMax" operation="set" value="'"${nOptsMax}"'"/>
  #<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="iGSKElctrnTeleportBaseDist" operation="set" value="'"${nBaseDist}"'"/>
  #' >>"${strFlGenBuf}${strGenTmpSuffix}"
#CFGFUNCgencodeApply --subTokenId "TeleDirectionsTOT" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --xmlcfg                                          \
  iGSKElctrnTeleportDistIndexMax "${nOptsMax}"                       \
  iGSKElctrnTeleportBaseDist "${nBaseDist}"                          \
  iGSKElctrnTeleportEnergy "$((nBaseDist*nEnergyPerBlock))"

echo "$strMayhemRnd" >>"${strFlGenBuf}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "TeleDirectionsMayhemRnd" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"

echo "$strGenCodeItemTeleCvarRangesUpDn" >>"${strFlGenIte}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "TeleDirectionsUPDOWN" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

CFGFUNCgencodeApply --cleanChkDupTokenFiles

CFGFUNCwriteTotalScriptTimeOnSuccess
