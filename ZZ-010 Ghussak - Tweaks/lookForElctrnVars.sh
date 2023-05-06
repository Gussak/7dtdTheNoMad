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

# this helps when creating a new Elctrn mod

astrElctrnVarsSuffix=(TA TB TH TP TR TS TT)
strElctrnVarsSuffixRegex="`echo ${astrElctrnVarsSuffix[*]} |tr ' ' '|'`"
for strSuffix in "${astrElctrnVarsSuffix[@]}";do
  strElctrnVarsSuffixRegex+="|${strSuffix}Show"
done
declare -p strElctrnVarsSuffixRegex
IFS=$'\n' read -d '' -r -a astrVarList < <(egrep '[^"]*('"${strElctrnVarsSuffixRegex}"')[":]' * -rIoh --include="*.xml" |egrep -v "^[_@]"|sort -u |tr -d '"')&&:
for strSuffix in "${astrElctrnVarsSuffix[@]}";do
  strAllVarWithSuffixRegex=""
  for strVar in "${astrVarList[@]}";do
    if [[ "$strVar" =~ ^.*${strSuffix}$ ]];then
      strAllVarWithSuffixRegex+="$strVar|"
    fi
  done
  strAllVarWithSuffixRegex="${strAllVarWithSuffixRegex%|}"
  #strAllVarWithSuffixRegex+="|EnergyHarvest|EnergyBattery|EnergyHero|EnergyTeleport|ShockArrow|EnergyThorns|EnergyShield"
  strAllVarWithSuffixRegex+='|((Energy|Elctrn)[a-zA-Z0-9_]*(Harvest|Battery|Hero|Teleport|ShockArrow|Thorns|Shield))'
  strAllVarWithSuffixRegex="[a-zA-Z0-9_]*(${strAllVarWithSuffixRegex})[a-zA-Z0-9_]*"
  echo "===============$strAllVarWithSuffixRegex:"
  egrep "$strAllVarWithSuffixRegex" * -wiRI -c --include="*.xml" --include="Localization.txt" |egrep -v :0 2>/dev/null
done
#while read strId;do echo "===============$strId:";egrep "$strId" * -iRI -c --include="*.xml" |egrep -v :0;done 2>/dev/null
