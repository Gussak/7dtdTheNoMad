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

#help existing ModifyScreenEffect options (?) from resources.assets, read also Data/Config/XML.txt
#help egrep 'ModifyScreenEffect' ../* -rIn --include="*.xml" |egrep 'effect_name="[^"]*"' -o |sort -u

astrScrEffList=( # the '#?' means nothing changed on the screen...
  #AtDeath #?
  #Beer #?
  Blur
  Bright #(no)
  #Cold #?
  Cold2
  #Crouched #?
  #Crouching #?
  Dark #(weak)
  #Death #?
  Distortion #0=off;>0=on no in-between :(
  #Drugs #?
  Drunk
  #FireSmallLoop #?
  Greyscale
  #HalfHealth #?
  Hot
  Hot2
  Infected
  NightVision #0=off;>0=on no in-between :(
  #Painkillers #?
  Radiation 
  #Spawn #?
  #SpawnIn #?
  Stealth
  #Tonemapping #?
  Vibrant #works more like heavy dark effect
  VibrantDeSat #  (nice but too bright at 1.0)
)

strCodeResetAll='
      <!-- HELPGOOD: ResetAllEffects -->
      <item name="GSKDbgTestScreenEffectResetAllEffects">
        <property name="Extends" value="GSKDbgBASE" />
        <effect_group tiered="false">'

iAddPerc=20
for strScrEff in "${astrScrEffList[@]}";do
  strCVar=".fGSKDbgScrEff${strScrEff}"
  echo '      <!-- HELPGOOD: effect: '"${strScrEff}"' -->
      <item name="GSKDbgTestScreenEffect'"${strScrEff}"'">
        <property name="Extends" value="GSKDbgBASE" />
        <effect_group tiered="false">
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="'"${strCVar}"'" operation="add" value="0.'"${iAddPerc}"'"/>
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="0">
            <requirement name="CVarCompare" cvar="'"${strCVar}"'" operation="GT" value="1.0" />
          </triggered_effect>
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="LogMessage" message="GSK:ScrEff:'"${strScrEff}"'"/>
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="CVarLogValue" cvar="'"${strCVar}"'"/>
          <triggered_effect trigger="onSelfSecondaryActionEnd" action="ModifyCVar" cvar="'"${strCVar}"'" operation="subtract" value="0.'"${iAddPerc}"'"/>
          <triggered_effect trigger="onSelfSecondaryActionEnd" action="ModifyCVar" cvar="'"${strCVar}"'" operation="set" value="1.0">
            <requirement name="CVarCompare" cvar="'"${strCVar}"'" operation="LT" value="0.0" />
          </triggered_effect>
          <triggered_effect trigger="onSelfSecondaryActionEnd" action="LogMessage" message="GSK:ScrEff:'"${strScrEff}"'"/>
          <triggered_effect trigger="onSelfSecondaryActionEnd" action="CVarLogValue" cvar="'"${strCVar}"'"/>' >>"${strFlGenIte}${strGenTmpSuffix}"
  for((i=0;i<=100;i+=iAddPerc));do
    if((i==0));then
      strCodeResetAll+='
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyScreenEffect" effect_name="'"${strScrEff}"'" intensity="0" fade="0.1"/>'
    fi
    fPerc="`bc <<< "scale=2;${i}/100"`"
    echo -n '
          <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyScreenEffect" effect_name="'"${strScrEff}"'" intensity="'"${fPerc}"'" fade="0.1">
            <requirement name="CVarCompare" cvar="'"${strCVar}"'" operation="Equals" value="'"${fPerc}"'" />
          </triggered_effect>
          <triggered_effect trigger="onSelfSecondaryActionEnd" action="ModifyScreenEffect" effect_name="'"${strScrEff}"'" intensity="'"${fPerc}"'" fade="0.1">
            <requirement name="CVarCompare" cvar="'"${strCVar}"'" operation="Equals" value="'"${fPerc}"'" />
          </triggered_effect>' >>"${strFlGenIte}${strGenTmpSuffix}"
  done
  echo '
        </effect_group>
      </item>' >>"${strFlGenIte}${strGenTmpSuffix}"
done
strCodeResetAll+='
        </effect_group>
      </item>'
echo "$strCodeResetAll" >>"${strFlGenIte}${strGenTmpSuffix}"

./gencodeApply.sh "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"










