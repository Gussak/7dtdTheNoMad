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

source ./libSrcCfgGenericToImport.sh --gencodeTrashLast

    #<action_sequence name="eventGSKTeslaTeleNo" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,0,'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSo" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,0,-'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleWe" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRange}"',0,0"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleEa" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRange}"',0,0"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleNW" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"',0,'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleNE" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"',0,'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSW" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"',0,-'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSE" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"',0,-'"${nRng45}"'"/></action_sequence>

    #<action_sequence name="eventGSKTeslaTeleNoDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,-'"${nRange}"','"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSoDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,-'"${nRange}"',-'"${nRange}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleWeDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRange}"',-'"${nRange}"',0"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleEaDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRange}"',-'"${nRange}"',0"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleNWDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"',-'"${nRange}"','"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleNEDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"',-'"${nRange}"','"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSWDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"',-'"${nRange}"',-'"${nRng45}"'"/></action_sequence>
    #<action_sequence name="eventGSKTeslaTeleSEDw" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"',-'"${nRange}"',-'"${nRng45}"'"/></action_sequence>
    
      #<action_sequence name="eventGSKTeslaTeleDn" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,-'"${nRange}"',0"/></action_sequence>
      
: ${nBaseDist:=7} #help the minimum distance to teleport
: ${nOptsMax:=5} #help the optional distances amount you can choose in-game

#TODO update iGSKTeslaTeleportDistIndexMax=${nOptsMax} at buffs generic cfg thru xmlstarlet

if((nBaseDist<1));then CFGFUNCerrorExit "invalid nBaseDist<1";fi
if((nOptsMax<1));then CFGFUNCerrorExit "invalid nOptsMax<1";fi

anRangeList=()
for((nOpts=1;nOpts<=nOptsMax;nOpts++));do
  anRangeList+=($((nOpts*nBaseDist)))
done

astrElevationList=("Dn" "" "Up")
declare -p astrElevationList
iEl=0

iCVarIndexRangeIni=100
iCVarIndexRangeMaxVal=100

astrDirList=(
  No "North"
  NE "Nort East"
  Ea "East"
  SE "South East"
  So "South"
  SW "South West"
  We "West"
  NW "North West"
)

: ${bUseDummyIncrement:=true} #help this is useful to make it easier to understand the directions vs cvar values

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
  iCV=$((iCVarIndexRangeIni+(iIndex*iCVarIndexRangeMaxVal)))&&: #only increment this at event code gen lines!
  for((nYRng=-nRange;nYRng<=nRange;nYRng+=nRange));do
    strEl="${astrElevationList[iEl]}"
    
    if $bUseDummyIncrement;then
      if [[ "$strEl" == "Dn" ]];then
        :
      elif [[ -z "$strEl" ]];then # no elevation
        ((iCV+=1))&&:
      elif [[ "$strEl" == "Up" ]];then
        ((iCV+=2))&&:
      fi
    fi
    
    declare -p nRange nRng45 nYRng iEl strEl
    echo '        <!-- HELPGOOD: nRange='"${nRange}"' strEl='"${strEl}"' -->' >>"${strFlGenEve}${strGenTmpSuffix}"
    #for strDir in "${astrDirList[@]}";do
    for((iDir=0;iDir<${#astrDirList[@]};iDir+=2));do
      strDir="${astrDirList[$iDir]}"
      echo '  <action_sequence name="eventGSKTeslaTele'"${nUserIndex}${strDir}${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"','"${nRange}"'"/></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      echo '        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeslaTele'"${nUserIndex}${strDir}${strEl}"'"><requirement name="CVarCompare" cvar=".iGSKTeslaTeleDir" operation="Equals" value="'"${iCV}"'"/></triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
      if [[ "$strDir" == "No" ]];then
        nUpDown=0;if [[ "$strEl" == "Dn" ]];then nUpDown=-1;fi;if [[ "$strEl" == "Up" ]];then nUpDown=1;fi
        strGenCodeItemTeleCvarRanges+='
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".iGSKTeslaTeleDir" operation="set" value="'"${iCV}"'" help="'"$nUserIndex: ${astrDirList[$((iDir+1))]} $strEl"'">
          <requirement name="CVarCompare" cvar="iGSKTeslaTeleportMixUpDown" operation="Equals" value="'"${nUpDown}"'" />
          <requirement name="CVarCompare" cvar="iGSKTeslaTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
          <requirement name="CVarCompare" cvar="_crouching" operation="Equals" value="0" />
        </triggered_effect>'
      fi
    done
    
    #echo '<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'No'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"','"${nRange}"'"/></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'NE'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'Ea'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'SE'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'So'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"',-'"${nRange}"'"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'SW'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'We'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      #<action_sequence name="eventGSKTeslaTele'"${nUserIndex}"'NW'"${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      #' >>"${strFlGenEve}${strGenTmpSuffix}"
    #strGenCodeItemTeleCvarRanges+='
  #<triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".iGSKTeslaTeleDir" operation="set" value="'"$((iCV+1))"'" help="North">
    #<requirement name="CVarCompare" cvar="iGSKTeslaTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
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
      <action_sequence name="eventGSKTeslaTele'"${nUserIndex}${strEl}"'" template="eventGSKTeslaTele" help="'"${nUserIndex}:cvdir=$((++iCV))"'"><variable name="v3Dir" value="0,'"${nYRng}"',0"/></action_sequence>'
      strGenCodeItemTeleCvarRangesUpDn+='
      <triggered_effect trigger="onSelfSecondaryActionEnd" action="ModifyCVar" cvar=".iGSKTeslaTeleDir" operation="set" value="'"$((iCV))"'">
        <requirement name="CVarCompare" cvar="iGSKTeslaTeleportDistIndex" operation="Equals" value="'"${nUserIndex}"'" />
        <requirement name="CVarCompare" cvar="_crouching" operation="Equals" value="'"${iCrouch}"'" />
      </triggered_effect>'
      echo '        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeslaTele'"${nUserIndex}${strEl}"'"><requirement name="CVarCompare" cvar=".iGSKTeslaTeleDir" operation="Equals" value="'"${iCV}"'"/></triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
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
./gencodeApply.sh "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"

#echo '    <!-- HELPGOOD: indexes 1 to '"${nOptsMax}"' -->
#' >>"${strFlGenIte}${strGenTmpSuffix}"
#./gencodeApply.sh --subTokenId "CONFIGURATORS" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

echo "$strGenCodeItemTeleCvarRanges" >>"${strFlGenIte}${strGenTmpSuffix}"
./gencodeApply.sh --subTokenId "TELEDIRECTIONS" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

./gencodeApply.sh --subTokenId "TELEDIRECTIONS" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"

echo "$strGenCodeItemTeleCvarRangesUpDn" >>"${strFlGenIte}${strGenTmpSuffix}"
./gencodeApply.sh --subTokenId "TELEDIRECTIONSUPDOWN" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

