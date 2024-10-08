#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2024, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
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

source ../*" Ghussak - Base LIB/libSrcCfgGenericToImport.sh" --LIBgencodeTrashLast

#strPathWork="GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory"

# trash special files that are not at --LIBgencodeTrashLast option:
CFGFUNCtrash "${strFlGenBuf}TeleportQuadrant${strGenTmpSuffix}"&&:
CFGFUNCtrash "${strFlGenBuf}TeleQuadrantLog${strGenTmpSuffix}"&&:

#strBiomeFileInfo="`identify "${strCFGGeneratedWorldTNMFolder}/biomes.png" |egrep " [0-9]*x[0-9]* " -o |tr -d ' ' |tr 'x' ' '`";
#nBiomesW="`echo "$strBiomeFileInfo" |cut -d' ' -f1`";
#nBiomesH="`echo "$strBiomeFileInfo" |cut -d' ' -f2`";
#declare -p nBiomesW nBiomesH

iTeleportIndexBase=55000 #TODO: collect thru xmlstarlet from buffs.xml: IMPORTANT! this must be in sync with the value at buffs: .iGSKElctrnTeleSpawnBEGIN
iTeleportIndex=$iTeleportIndexBase
iTeleportMaxAllowed=100 # was 200(?) on A20, but seems to be 100 on A22, or it wont work. TODO: a buff with too many tests may simply fail right? may be it could be split into buffs with range of 100 checks each
iTeleportMaxAllowedIndex=$((iTeleportIndex + iTeleportMaxAllowed))&&: 
iTeleportMaxIndex=$iTeleportIndex
iTeleportIndexFirst=-1

: ${iMapSize:=10240} #help for X and Z
: ${iDivMapSizeBy:=9} #help for X and Z. could be 10x10, but using the max possible (right?) limit of buff's triggered_effect list iTeleportMaxAllowed #was 13 on A20, had to lower to 9 on A22
: ${iMarginMapEdges:=250} #help for X and Z, consider a good distance away from the radiactive borders
: ${iTeleAtY:=260} #help just above max placeable block

if(( (iDivMapSizeBy+1) * (iDivMapSizeBy+1) > iTeleportMaxAllowed ));then
	CFGFUNCerrorExit "PROBLEM: (iDivMapSizeBy+1) * (iDivMapSizeBy+1) must be less than iTeleportMaxAllowed"
fi

iDistQuadrant=$(( (iMapSize - (iMarginMapEdges * 2)) / iDivMapSizeBy ))
bStop=false
for((iIndexZ=0; iIndexZ<=iDivMapSizeBy; iIndexZ++));do
	for((iIndexX=0; iIndexX<=iDivMapSizeBy; iIndexX++));do
		#iX=$((iMarginMapEdges + (iDistQuadrant * (iIndexX - 1)) - iMapSize/2))
		#iY=$((iTeleAtY))
		#iZ=$((iMarginMapEdges + (iDistQuadrant * (iIndexZ - 1)) - iMapSize/2))
		iX=$((iMarginMapEdges + (iDistQuadrant * iIndexX) - iMapSize/2))
		iY=$((iTeleAtY))
		iZ=$((iMarginMapEdges + (iDistQuadrant * iIndexZ) - iMapSize/2))
		
		((iTeleportIndex++))&&:
		#iIndexCalcChk=$(( ((iIndexZ * iDivMapSizeBy)+1) + (iIndexX+1) ))
		iIndexCalcChk=$(( (iIndexZ * (iDivMapSizeBy+1)) + (iIndexX) + 1 ))
		if(( (iTeleportIndex - iTeleportIndexBase) != iIndexCalcChk ));then
			CFGFUNCerrorExit "$(declare -p iTeleportIndex iIndexX iIndexZ iIndexCalcChk) mismatched";
		fi
		
		strSpawnPos="$iX,$iY,$iZ"
		
		strHelp="index=${iTeleportIndex};Quadrant:${iIndexX},${iIndexZ};teleQuadrantPos=${strSpawnPos};iDistQuadrant=${iDistQuadrant}"
		
		if((iTeleportIndexFirst==-1));then iTeleportIndexFirst=$iTeleportIndex;fi
		strTeleportIndex="$iTeleportIndex"
		
		echo '
			<triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeleport'"${strTeleportIndex}"'" help="'"${strHelp}"'">
				<requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
			</triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
		echo '
			<triggered_effect trigger="onSelfBuffUpdate" action="LogMessage" message="GSK:'"${strHelp}"'">
				<requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
			</triggered_effect>' >>"${strFlGenBuf}TeleQuadrantLog${strGenTmpSuffix}"
		echo '
      <effect_group>
				<requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'" help="'"${strHelp}"'"/>
        <triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".fGSKCFGTMPval1" operation="set" value="'"${iX}"'"/>
        <triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".fGSKCFGTMPval2" operation="set" value="'"${iZ}"'"/>
      </effect_group>' >>"${strFlGenBuf}TeleQuadrantHUD${strGenTmpSuffix}"
		
		echo '
			<action_sequence name="eventGSKTeleport'"${strTeleportIndex}"'"><action class="Teleport">
				<property name="target_position" value="'"${strSpawnPos}"'" help="'"${strHelp}"'"/>
			</action></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
		
		echo -e "$strHelp" >/dev/stderr
		
		iTeleportMaxIndex=$iTeleportIndex
		if((iTeleportMaxIndex > iTeleportMaxAllowedIndex));then bStop=true;break;fi
	done
	if $bStop;then CFGFUNCerrorExit "PROBLEM: it was not possible to make all quadrant tele targets available, try lowering iTeleportMaxAllowed value";fi
done

CFGFUNCgencodeApply "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
#CFGFUNCgencodeApply --subTokenId "TeleportQuadrant" "${strFlGenBuf}TeleportQuadrant${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "TeleQuadrantLog" "${strFlGenBuf}TeleQuadrantLog${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "TeleQuadrantHUD" "${strFlGenBuf}TeleQuadrantHUD${strGenTmpSuffix}" "${strFlGenBuf}"

CFGFUNCgencodeApply "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"

CFGFUNCgencodeApply --xmlcfg                                                                                      \
	".iGSKElctrnTeleQuadrantBASE"  "${iTeleportIndexBase}"                                                           \
  ".iGSKElctrnTeleQuadrantFIRST" "${iTeleportIndexFirst}"                                                           \
  ".iGSKElctrnTeleQuadrantLAST"  "${iTeleportMaxIndex}"                                                              \
  ".iGSKElctrnTeleQuadrantMinINDEX"    "0"                      \
  ".iGSKElctrnTeleQuadrantMaxINDEX"    "$((iDivMapSizeBy))"      \
  ".iGSKElctrnTeleQuadrantTotXorZ"    "$((iDivMapSizeBy+1))"      \
  ".iGSKElctrnTeleQuadrantMARGIN"      "${iMarginMapEdges}"                                                              \
  ".iGSKElctrnTeleQuadrantHalfMapSIZE" "$((iMapSize/2))"                                                                  \
  ".iGSKElctrnTeleQuadrantDIST"        "${iDistQuadrant}"            \
  ".iGSKTeleToRandomQuadrant"          "randomInt(${iTeleportIndexFirst},${iTeleportMaxIndex})"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
