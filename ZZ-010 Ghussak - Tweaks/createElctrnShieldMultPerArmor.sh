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

#strFlGenLoc="Config/Localization.txt"
#strFlGenXml="Config/items.xml"
#strFlGenRec="Config/recipes.xml"
#strGenTmpSuffix=".GenCode.TMP"
#trash "${strFlGenLoc}${strGenTmpSuffix}"&&:
#trash "${strFlGenRec}${strGenTmpSuffix}"&&:
#trash "${strFlGenXml}${strGenTmpSuffix}"&&:
source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

astrArmorTypes=( # values based on protection value, so if they change the protection it should be updated here
  "Cloth|Santa" 0.20
  Leather 0.40
  "Scrap|Military|Iron|Football|Swat|Mining" 0.70
  Steel 1.00
)

astrBodyParts=(
  Head "Hat|Helmet|Hood"
  Torso "Chest|Jacket|Vest"
  Hands "Gloves"
  Legs "Pants|Legs"
  Feet "Boots"
)

function FUNCor() {
  local lstrChk="$1"
  astr=(`echo "$lstrChk" |tr '|' ' '`)
  iCount=0
  for str in "${astr[@]}";do
    if((iCount>0));then strNameMatch+="or ";fi
    strNameMatch+="@name='$str' "
    ((iCount++))&&:
  done
  strNameMatch+=")"
}

for((j=0;j<"${#astrArmorTypes[@]}";j+=2));do
  strATList="${astrArmorTypes[j]}"
  fATMult="${astrArmorTypes[j+1]}"
  for((i=0;i<"${#astrBodyParts[@]}";i+=2));do
    strBP="${astrBodyParts[i]}"
    strBPSuffixList="${astrBodyParts[i+1]}"
    
    strNameMatch=""
    astrAT=(`echo "$strATList" |tr '|' ' '`)
    astrBPSuffix=(`echo "$strBPSuffixList" |tr '|' ' '`)
    iCount=0
    for strAT in "${astrAT[@]}";do
      for strBPSuffix in "${astrBPSuffix[@]}";do
        if((iCount>0));then strNameMatch+="or ";fi
        strNameMatch+="@name='armor${strAT}${strBPSuffix}' "
        ((iCount++))&&:
      done
    done
    
    echo '  <!-- HELPGOOD: CODEGEN:'"`basename "$0"`"' -->
  <append xpath="/items/item['"$strNameMatch"']">
    <effect_group tiered="false">
      <triggered_effect trigger="onSelfEquipStart" action="ModifyCVar" cvar="fGSKarmorAddToMultTS'"${strBP}"'" operation="set" value="'"$fATMult"'"/>
      <triggered_effect trigger="onSelfEquipStop"  action="ModifyCVar" cvar="fGSKarmorAddToMultTS'"${strBP}"'" operation="set" value="'"$fATMult"'"/>
    </effect_group>
  </append>' |tee -a "${strFlGenXml}${strGenTmpSuffix}"
  done
done

#CFGFUNCgencodeApply "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
CFGFUNCgencodeApply "${strFlGenXml}${strGenTmpSuffix}" "${strFlGenXml}"
#CFGFUNCgencodeApply "AUTO_GENERATED_CODE" "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

CFGFUNCgencodeApply --cleanChkDupTokenFiles

CFGFUNCwriteTotalScriptTimeOnSuccess
