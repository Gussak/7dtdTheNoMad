#!/bin/bash

# The Clear BSD License
#
# Copyright (c) 2026, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the disclaimer
# below) provided that the following conditions are met:
#
#      * Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#
#      * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#      * Neither the name of the copyright holder nor the names of its
#      contributors may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
# THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#PREPARE_RELEASE:REVIEWED:OK

strBaseLibPath="$(ls -1d ../*"Ghussak"*"TheNoMad"*"Code Base Library")"
source "${strBaseLibPath}/libSrcCfgGenericToImport.sh" --LIBgencodeTrashLast

################################

# TODO: multilines mode

declare -A astrNameListA astrLabelListA astrXUItoolTipIDListA astrCVarBNA astrColorTextListA astrColorAlertListA astrColorWarnListA astrColorGoodListA
## KEEP_TEMPLATE !!!!!!!!!!!!!!!
#strID=""
#astrNameListA[$strID]=""
#astrLabelListA[$strID]=""
#astrXUItoolTipIDListA[$strID]=""
#astrCVarBNA[$strID]="" #requires ...Warn cvar too
#astrColorTextListA[$strID]=""
#astrColorAlertListA[$strID]=""
#astrColorWarnListA[$strID]=""
#astrColorGoodListA[$strID]=""
astrOrder=(Battery Miasma SpidersSM FireFuel Shaman)
# Battery
strID=Battery
astrNameListA[$strID]="Battery"
astrLabelListA[$strID]="Battery"
astrXUItoolTipIDListA[$strID]="xuiGSKbatteryPerc"
astrCVarBNA[$strID]="fGSKBatteryChargePerc"
astrColorTextListA[$strID]="[green]"
astrColorAlertListA[$strID]="255,128,128,255"
astrColorWarnListA[$strID]="255,255,0,255"
astrColorGoodListA[$strID]="0,0,255,255"
# Miasma
strID=Miasma
astrNameListA[$strID]="Miasma"
astrLabelListA[$strID]="Miasma"
astrXUItoolTipIDListA[$strID]="xuiGSKmiasmaPerc"
astrCVarBNA[$strID]="fGSKMiasmaDirtyPerc"
astrColorTextListA[$strID]="80,0,0,255"
astrColorAlertListA[$strID]="255,128,128,255"
astrColorWarnListA[$strID]="255,255,0,255"
astrColorGoodListA[$strID]="0,255,255,255"
# SpidersSM
strID=SpidersSM
astrNameListA[$strID]="SpidersSM"
astrLabelListA[$strID]="Spiders' Repelent"
astrXUItoolTipIDListA[$strID]="xuiGSKspiderRepelPerc"
astrCVarBNA[$strID]="iGSKSpawnSpiderMiniTmoutPerc"
astrColorTextListA[$strID]="255,255,255,255"
astrColorAlertListA[$strID]="255,128,128,255"
astrColorWarnListA[$strID]="200,200,0,255"
astrColorGoodListA[$strID]="0,128,255,255"
# FireFuel
strID=FireFuel
astrNameListA[$strID]="FireFuel"
astrLabelListA[$strID]="Torch Fuel"
astrXUItoolTipIDListA[$strID]="xuiGSKtorchFuel"
astrCVarBNA[$strID]="fGSKFireFuelPerc"
astrColorTextListA[$strID]="255,255,255,255"
astrColorAlertListA[$strID]="180,0,0,255"
astrColorWarnListA[$strID]="255,80,0,255"
astrColorGoodListA[$strID]="255,180,0,255"
# ShamanPower !!!!!!!!!!!!!!!
strID=Shaman
astrNameListA[$strID]="Shaman"
astrLabelListA[$strID]="Shaman Power"
astrXUItoolTipIDListA[$strID]="xuiGSKshamanPower"
astrCVarBNA[$strID]="iGSKNearDeathShamanPowerLvlPerc" #requires ...Warn cvar too
astrColorTextListA[$strID]="255,128,128,255"
astrColorAlertListA[$strID]="255,128,0,255"
astrColorWarnListA[$strID]="255,255,0,255"
astrColorGoodListA[$strID]="0,128,128,255"

# calc the HUD space
nTotalWidth=300 # could be 450 but the remaining ammo is at that edge
nGapBetween=10
nTot="${#astrCVarBNA[@]}"
nWidth=$(( ((nTotalWidth - (nGapBetween*(nTot-1))) / nTot)  ))
declare -p nTotalWidth nTot nWidth

nPosX=0
#for((j=0;j<nTot;j++));do
echo "${!astrCVarBNA[@]}"
echo "${astrOrder[@]}"
#for j in "${!astrCVarBNA[@]}";do
for j in "${astrOrder[@]}";do
	strName="StatBarFor_${astrNameListA[$j]}"
	strLabel="${astrLabelListA[$j]}"
	strXUItt="${astrXUItoolTipIDListA[$j]}"
	strCVar="${astrCVarBNA[$j]}"
	
	strColorText="${astrColorTextListA[$j]}"
	strColorAlert="${astrColorAlertListA[$j]}"
	strColorWarn="${astrColorWarnListA[$j]}"
	strColorGood="${astrColorGoodListA[$j]}"
	
	echo \
'					<rect name="'"${strName}"'" pos="'"${nPosX}"',0" rows="1" cols="1" side="left" width="'"${nWidth}"'" height="20">
						<label        depth="7" name="Title" text="'"${strLabel}"'" font_size="21" color="'"${strColorText}"'" tooltip_key="'"${strXUItt}"'"/>
						<filledsprite depth="4" name="IndicatorAlert" color="'"${strColorAlert}"'" type="filled" fillcenter="true" fill="1.00" tooltip_key="'"${strXUItt}"'"/>
						<filledsprite depth="5" name="IndicatorWarn"  color="'"${strColorWarn}"'"   type="filled" fillcenter="true" fill="{cvar('"${strCVar}"'Warn:0.00)}"  controller="Quartz.HUDCVar, Quartz" cvar_name="'"${strCVar}"'Warn" tooltip_key="'"${strXUItt}"'"/>
						<filledsprite depth="6" name="Percent"        color="'"${strColorGood}"'"     type="filled" fillcenter="true" fill="{cvar('"${strCVar}"':0.00)}"      controller="Quartz.HUDCVar, Quartz" cvar_name="'"${strCVar}"'" tooltip_key="'"${strXUItt}"'"/>
					</rect>
' >>"${strFlGenWin}${strGenTmpSuffix}"

	((nPosX+=nWidth+nGapBetween))&&:
done

################################

CFGFUNCgencodeApply "${strFlGenWin}${strGenTmpSuffix}" "${strFlGenWin}"

################################

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
