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

#strScriptName="`basename "$0"`"

source ./libSrcCfgGenericToImport.sh --gencodeTrashLast

: ${fGSKHPBlkChemUseMin:=0.15} #help to start the debuff
: ${fMultPerLvl:=0.666} #help to decrease the next min/max value
: ${iMaxLvl:=5} #help changing this is not advised as requires a lot of maintenance in many places

astrNearDeathList=(
  "ChemUse"
)

for strND in "${astrNearDeathList[@]}";do
  if [[ "$strND" == "ChemUse" ]];then
  fStep="${fGSKHPBlkChemUseMin}"
  fMin="${fGSKHPBlkChemUseMin}"
    for((iLvl=1;iLvl<=iMaxLvl;iLvl++));do
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUMinTmp" operation="set" value="@.fGSKHPBlkChemUseMin"/>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUMaxTmp" operation="set" value="@.fGSKHPBlkChemUseMin"/>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUMaxTmp" operation="multiply" value="0.666"/>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUMaxTmp" operation="add" value="@.fGSKHPBlkChemUseMin"/>
          
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUMaxTmp" operation="set" value="@.fGSKHPBlkChemUseMin"/>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKHPBlkCUTmp" operation="multiply" value="0.666"/>
          
          #fStep="`printf "%.2f" $(bc <<< "(${fStep}*${fMultPerLvl})")`"
          #fMax="`printf "%.2f" $(bc <<< "${fMin}+${fStep}")`"
          fStep="`CFGFUNCcalc "(${fStep}*${fMultPerLvl})"`"
          fMax="`CFGFUNCcalc "${fMin}+${fStep}"`"
          fMaxFinal="${fMax}"
          
          if((iLvl==iMaxLvl));then fMax="10000";fi #anything unexpectedly high will work, just to have no limit.
          
      echo '        <!-- HELPGOOD: lvl '"${iLvl}"' -->
          <triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKNearDeathChemUse" operation="set" value="'"${iLvl}"'">
            <requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="GTE" value="'"${fMin}"'" />
            <requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="LT"  value="'"${fMax}"'"  help="'"min+${fStep}"'"/>
          </triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
          
          fMin="${fMax}"
          
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKNearDeathChemUse" operation="set" value="2">
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="GTE" value="0.25" />
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="LT" value="0.32" />
          #</triggered_effect>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKNearDeathChemUse" operation="set" value="3">
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="GTE" value="0.32" />
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="LT" value="0.37" />
          #</triggered_effect>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKNearDeathChemUse" operation="set" value="4">
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="GTE" value="0.37" />
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="LT" value="0.40" />
          #</triggered_effect>
          #<triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKNearDeathChemUse" operation="set" value="5">
            #<requirement name="CVarCompare" cvar="fGSKHitpointsBlockageChemUse" operation="GTE" value="0.40" />
          #</triggered_effect>  
    done
  fi
  CFGFUNCgencodeApply --subTokenId "`echo ${strND} |tr -d '.'`" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
done

  #".fGSKHPBlkChemUseMinx100" "`bc <<< "scale=0;${fGSKHPBlkChemUseMin}*100" |cut -d. -f1`" 
  #".fGSKHPBlkChemUseMaxx100" "`bc <<< "scale=0;${fMaxFinal}*100" |cut -d. -f1`"
CFGFUNCgencodeApply --xmlcfg                                                                \
  ".fGSKHPBlkChemUseMin"     "${fGSKHPBlkChemUseMin}"                                     \
  ".fGSKHPBlkChemUseMinx100" "`CFGFUNCcalc -s 0 "${fGSKHPBlkChemUseMin}*100"`"            \
  ".fGSKHPBlkChemUseMax"     "${fMaxFinal}"                                               \
  ".fGSKHPBlkChemUseMaxx100" "`CFGFUNCcalc -s 0 "${fMaxFinal}*100"`"

CFGFUNCwriteTotalScriptTimeOnSuccess
