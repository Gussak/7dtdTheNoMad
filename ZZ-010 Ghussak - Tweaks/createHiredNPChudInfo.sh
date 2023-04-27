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

strLeaderReq='<requirement name="CVarCompare" target="other" cvar="EntityID" operation="Equals" value="@Leader" />'

astrCVarList=(
  ".iGSKPlayerNPCInfoAmmoLeftPerc"
  ".iGSKPlayerNPCInfoArmorDmgPercent"
  ".iGSKPlayerNPCInfoPermanentArmorDmg"
  ".iGSKPlayerNPCInfoRepairSelfArmor"
)

# PERCENTS
for strCVar in "${astrCVarList[@]}";do
  strIndent="      "
  echo "${strIndent}"'<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="0" target="selfAOE" range="60">
'"${strIndent}"'  <requirement name="CVarCompare" cvar=".fNPCCalcPercTmp" operation="LTE" value="0.0" />
'"${strIndent}"'  '"${strLeaderReq}"'
'"${strIndent}"'</triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"

  iStep=10
  for((i=0;i<100;i+=iStep));do
    fMin="`bc <<< "scale=2;$i/100"`"
    fMax="`bc <<< "scale=2;$((i+iStep))/100"`"
    echo "${strIndent}"'<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="'$((i+(iStep/2)))'" target="selfAOE" range="60">
'"${strIndent}"'  <requirement name="CVarCompare" cvar=".fNPCCalcPercTmp" operation="GT" value="'$fMin'" />
'"${strIndent}"'  <requirement name="CVarCompare" cvar=".fNPCCalcPercTmp" operation="LT" value="'$fMax'" />
'"${strIndent}"'  '"${strLeaderReq}"'
'"${strIndent}"'</triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
  done
  
  echo "${strIndent}"'<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="100" target="selfAOE" range="60">
'"${strIndent}"'  <requirement name="CVarCompare" cvar=".fNPCCalcPercTmp" operation="GTE" value="1.00" />
'"${strIndent}"'  '"${strLeaderReq}"'
'"${strIndent}"'</triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
  
  ./gencodeApply.sh --subTokenId "`echo ${strCVar} |tr -d '.'`" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
done

# SECONDS
iStep=15
iLim=666
strCVar=".iGSKPlayerNPCInfoSelfPreventDismissSecs"
bBreak=false
for((i=13;i<=iLim;i+=iStep));do
  if((i+iStep>=iLim));then
    i=$iLim
    iStep=99999; #any absurd value will work
    bBreak=true
  fi
  echo '      <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="'$i'" target="selfAOE" range="60">
        <requirement name="CVarCompare" cvar="fGSKNPCSelfPreventDismissSecs" operation="GTE" value="'$i'" />
        <requirement name="CVarCompare" cvar="fGSKNPCSelfPreventDismissSecs" operation="LT" value="'$((i+iStep))'" />
        <requirement name="CVarCompare" target="other" cvar="EntityID" operation="Equals" value="@Leader" />
      </triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
  if $bBreak;then break;fi
done
./gencodeApply.sh --subTokenId "`echo ${strCVar} |tr -d '.'`" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
