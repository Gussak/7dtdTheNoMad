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

set -eu
trap 'echo ERROR' ERR
trap 'echo WARN_CtrlC_Pressed_ABORTING;exit 1' INT

echo "This script will patch this mod's buffs.xml file automatically replacing existing related content there."
echo "HELP: EASY: add an entry with the values you want at astrVarsList to create code for a new lightsource based on player's battery"
echo "HELP: ADVANCED: edit createEnergyBlinks.xml to modify the logic for all lightsouces at once"
egrep "[#]help" $0

#strFlGenLoc="Config/Localization.txt"
#strFlGenXml="Config/items.xml"
#strFlGenRec="Config/recipes.xml"
#strFlGenBuf="Config/buffs.xml"
#strGenTmpSuffix=".GenCode.TMP"
#trash "${strFlGenLoc}${strGenTmpSuffix}"&&:
#trash "${strFlGenRec}${strGenTmpSuffix}"&&:
#trash "${strFlGenXml}${strGenTmpSuffix}"&&:
#trash "${strFlGenBuf}${strGenTmpSuffix}"&&:
source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

strFl="./Config/buffs.xml"
astrGetVarValueList=(
  fGSKNVEnUseUpdRate
  fGSKEnHLCfgRO
  fGSKEnWLCfgRO
  fGSKEnNVCfgRO
)
echo "ENERGY SPENT PER SECOND:"
for strVV in "${astrGetVarValueList[@]}";do
  eval ${strVV}="$(egrep "${strVV}.*set.*value" "$strFl" |tr -d '[a-zA-Z=<>_/]" \r\n')"
  declare -p LINENO ${strVV}
done

fGSKNVEnUseUpdRateCVARVALUE=0.25 #TODOA collect value with xmlstarlet

function Fbc() {
  local lstrCalc="$1"
  local lstrResult="`bc -sw <<< "scale=6;${lstrCalc}" 2>&1`"
  if echo "$lstrResult" |egrep error -i;then
    echo "ERROR: bc below" >&2
    declare -p LINENO lstrCalc >&2
    echo "$lstrResult" >&2
    echo "ERROR: bc error above" >&2
    exit 1
  fi
  if [[ "${lstrResult:0:1}" == "." ]];then lstrResult="0${lstrResult}";fi
  echo "$lstrResult"
}

echo "THE CONFIG FOR WEAK AND STANDBY ENERGY SPENT:"
astrVarsList=( 
  #iFailLowEnergy: consider that it must be divided by the consumedEnergy/s to know the time this value will last
  #fStandbyEnergySpent: energy spent trying to charge capacitors to turn on the light
  #energy spent is per second!!!!
  #strVar iFailLowEnergy fStandbyEnergySpent iWeakLowEnergy fWeakEnergySpent
  "HL   2 `Fbc "$fGSKEnHLCfgRO/10"`  1 `Fbc "$fGSKEnHLCfgRO/2"`" #Helmet Light
  "WL  15 `Fbc "$fGSKEnWLCfgRO/10"`  7 `Fbc "$fGSKEnWLCfgRO/2"`" #Weapon Flashlight Mod
  "NV 100 `Fbc "$fGSKEnNVCfgRO/10"` 50 `Fbc "$fGSKEnNVCfgRO*0.75"`" #Night Vision (the low light is still too good, so spend just a bit less than the full value)
)

declare -p LINENO
#strCodeToken="GENERATED_CODE:DO_NOT_MODIFY:RUN:$0"
#strCodeTokenBegin="DUMMY:BELOW:${strCodeToken}"
#strCodeTokenEnd="DUMMY:ABOVE:${strCodeToken}"
#strFlOut="${0}.xml.tmp"
strFlOut="${strFlGenBuf}${strGenTmpSuffix}"
trash "${strFlOut}"&&:
#echo "<!-- ! ! ! ${strCodeTokenBegin} ! ! ! -->" >>"${strFlOut}"
#echo "<effect_group name=\"${strCodeTokenBegin}\"/>"  >>"${strFlOut}"
declare -p LINENO
for strVars in "${astrVarsList[@]}";do
  eval "$(echo "$strVars" |awk '{print "strVar="$1";" "iFailLowEnergy="$2";" "fStandbyEnergySpent="$3";" "iWeakLowEnergy="$4";" "fWeakEnergySpent="$5";"}')"
  declare -p LINENO strVar iFailLowEnergy fStandbyEnergySpent iWeakLowEnergy fWeakEnergySpent
  fStandbyEnergySpent="$(Fbc "${fStandbyEnergySpent} * ${fGSKNVEnUseUpdRate}")"
  fWeakEnergySpent="$(Fbc    "${fWeakEnergySpent}    * ${fGSKNVEnUseUpdRate}")"
  declare -p fStandbyEnergySpent fWeakEnergySpent
  source createEnergyBlinks.xml # it is much better to edit xml there with syntax highlight!
done
#echo "<!-- ! ! ! ${strCodeTokenEnd} ! ! ! -->" >>"${strFlOut}"
#echo "<effect_group name=\"${strCodeTokenEnd}\"/>"  >>"${strFlOut}"
unix2dos "$strFlOut" # to grant CR LF
cat "$strFlOut"

CFGFUNCgencodeApply "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"

## apply patch (recreated code)
## find begin and end of the patch
#nHead="`egrep "${strCodeTokenBegin}" "${strFl}" -n |cut -d: -f1`"
#nTail="`egrep "${strCodeTokenEnd}"   "${strFl}" -n |cut -d: -f1`"
#declare -p LINENO nHead nTail
## create the new file to check
#trash "${strFl}.NEW"&&:
#head -n $((nHead-1)) "${strFl}" >>"${strFl}.NEW";wc -l "${strFl}.NEW"
#cat "$strFlOut" >>"${strFl}.NEW";wc -l "${strFl}.NEW"
#tail -n +$((nTail+1)) "${strFl}" >>"${strFl}.NEW";wc -l "${strFl}.NEW"
#declare -p LINENO
#if ! cmp "${strFl}" "${strFl}.NEW";then
  #: ${bSkipMeld:=false} #help
  #if ! $bSkipMeld;then 
    #echo "WARN: hit ctrl+c to abort, closing meld will accept the patch!!! "
    #meld "${strFl}" "${strFl}.NEW";
  #fi
  ## "overwrite" the old with new file
  #trash "${strFl}.OLD"&&:
  #mv -v "${strFl}" "${strFl}.OLD"
  #mv -v "${strFl}.NEW" "${strFl}"
  #echo "PATCHING expectedly WORKED! now test it!"
#else
  #echo "WARN: nothing changed"
#fi

#trash "$strFlOut"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
