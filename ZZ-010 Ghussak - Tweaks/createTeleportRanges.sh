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

if((nBaseDist<1));then CFGFUNCerrorExit "invalid nBaseDist<1";fi
if((nOptsMax<1));then CFGFUNCerrorExit "invalid nOptsMax<1";fi

anRangeList=()
for((nOpts=1;nOpts<=nOptsMax;nOpts++));do
  anRangeList+=($((nOpts*nBaseDist)))
done

astrElevationList=("Dn" "" "Up")
declare -p astrElevationList
iEl=0

strCodeUpDown=""
#for nRange in "${anRangeList[@]}";do
for iIndex in "${!anRangeList[@]}";do
  nRange="${anRangeList[iIndex]}"
  strIndex=$((iIndex+1))&&: # this is the distance index that the user will choose in-game
  echo
  #nRng45="`bc <<< "scale=0;${nRange}-(${nRange}*0.15)"`" # +- dist at 45 degrees around
  nRng45="`bc <<< "scale=0;((${nRange}-(${nRange}*0.13))*100)/100"`" # +- dist at 45 degrees around (this is a bc trunc trick) TODO proper calc sin cos etc...
  if((nRng45==nRange));then nRng45=$((nRange-1))&&:;fi
  for((nYRng=-nRange;nYRng<=nRange;nYRng+=nRange));do
    strEl="${astrElevationList[iEl]}"
    declare -p nRange nRng45 nYRng iEl strEl
    echo '      <!-- HELPGOOD: nRange='"${nRange}"' strEl='"${strEl}"' -->
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'No'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,'"${nYRng}"','"${nRange}"'"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'So'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,'"${nYRng}"',-'"${nRange}"'"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'We'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'Ea'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRange}"','"${nYRng}"',0"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'NW'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'NE'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"','"${nRng45}"'"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'SW'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="-'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"'SE'"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="'"${nRng45}"','"${nYRng}"',-'"${nRng45}"'"/></action_sequence>
      ' >>"${strFlGenEve}${strGenTmpSuffix}"
      
    if((nYRng!=0));then
      strCodeUpDown+='
      <action_sequence name="eventGSKTeslaTele'"${strIndex}"''"${strEl}"'" template="eventGSKTeslaTele"><variable name="v3Dir" value="0,'"${nYRng}"',0"/></action_sequence>'
    fi
    
    ((iEl++))&&:
    if((iEl>=${#astrElevationList[*]}));then iEl=0;fi
  done
done

echo "<!-- HELPGOOD: straight up and down -->" >>"${strFlGenEve}${strGenTmpSuffix}"
echo "${strCodeUpDown}" >>"${strFlGenEve}${strGenTmpSuffix}"

./gencodeApply.sh "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"
