#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2026, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
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

strBaseLibPath="$(ls -1d ../*"Ghussak"*"TheNoMad"*"Code Base Library")"
source "${strBaseLibPath}/libSrcCfgGenericToImport.sh" --LIBgencodeTrashLast

################################

# TODO: multilines mode

# config each CVar
#astrNameList=(Battery Miasma SpidersSpawnMini FireFuel)
#astrLabelList=(Battery Miasma "Spiders' Repelent" "Torch Fuel")
#astrXUItoolTipIDList=(xuiGSKbatteryPerc xuiGSKmiasmaPerc xuiGSKspiderRepelPerc xuiGSKtorchFuel)
#astrCVarBN=(fGSKBatteryChargePerc fGSKMiasmaDirtyPerc iGSKSpawnSpiderMiniTmoutPerc fGSKFireFuelPercPerc) #requires ...Warn cvar too
#astrColorTextList=("[green]" "80,0,0,255" "255,255,255,255" "255,0,0,255")
#astrColorAlertList=("255,128,128,255" "255,128,128,255" "255,128,128,255" "255,80,0,255")
#astrColorWarnList=("255,255,0,255" "255,255,0,255" "200,200,0,255" "255,128,0,255")
#astrColorGoodList=("0,0,255,255" "0,255,255,255" "0,128,255,255" "255,180,0,255")

## while the entry ID can be ignored, the index will still work
declare -A astrNameListA astrLabelListA astrXUItoolTipIDListA astrCVarBNA astrColorTextListA astrColorAlertListA astrColorWarnListA astrColorGoodListA
## KEEP_TEMPLATE !!!!!!!!!!!!!!!
#astrNameList[]=""
#astrLabelList[]=""
#astrXUItoolTipIDListA[]=""
#astrCVarBNA[]="" #requires ...Warn cvar too
#astrColorTextListA[]=""
#astrColorAlertListA[]=""
#astrColorWarnListA[]=""
#astrColorGoodListA[]=""
astrOrder=(Battery Miasma SpidersSM FireFuel)
# Battery
astrNameListA[Battery]="Battery"
astrLabelListA[Battery]="Battery"
astrXUItoolTipIDListA[Battery]="xuiGSKbatteryPerc"
astrCVarBNA[Battery]="fGSKBatteryChargePerc"
astrColorTextListA[Battery]="[green]"
astrColorAlertListA[Battery]="255,128,128,255"
astrColorWarnListA[Battery]="255,255,0,255"
astrColorGoodListA[Battery]="0,0,255,255"
# Miasma
astrNameListA[Miasma]="Miasma"
astrLabelListA[Miasma]="Miasma"
astrXUItoolTipIDListA[Miasma]="xuiGSKmiasmaPerc"
astrCVarBNA[Miasma]="fGSKMiasmaDirtyPerc"
astrColorTextListA[Miasma]="80,0,0,255"
astrColorAlertListA[Miasma]="255,128,128,255"
astrColorWarnListA[Miasma]="255,255,0,255"
astrColorGoodListA[Miasma]="0,255,255,255"
# SpidersSM
astrNameListA[SpidersSM]="SpidersSM"
astrLabelListA[SpidersSM]="Spiders' Repelent"
astrXUItoolTipIDListA[SpidersSM]="xuiGSKspiderRepelPerc"
astrCVarBNA[SpidersSM]="iGSKSpawnSpiderMiniTmoutPerc"
astrColorTextListA[SpidersSM]="255,255,255,255"
astrColorAlertListA[SpidersSM]="255,128,128,255"
astrColorWarnListA[SpidersSM]="200,200,0,255"
astrColorGoodListA[SpidersSM]="0,128,255,255"
# FireFuel
astrNameListA[FireFuel]="FireFuel"
astrLabelListA[FireFuel]="Torch Fuel"
astrXUItoolTipIDListA[FireFuel]="xuiGSKtorchFuel"
astrCVarBNA[FireFuel]="fGSKFireFuelPerc"
astrColorTextListA[FireFuel]="255,255,255,255"
astrColorAlertListA[FireFuel]="180,0,0,255"
astrColorWarnListA[FireFuel]="255,80,0,255"
astrColorGoodListA[FireFuel]="255,180,0,255"

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
