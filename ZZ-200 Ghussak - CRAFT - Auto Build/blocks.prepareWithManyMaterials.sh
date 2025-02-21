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

strBaseLibPath="$(ls -1d *"Ghussak"*"TheNoMad"*"Code Base Library")"
source "../${strBaseLibPath}/libSrcCfgGenericToImport.sh" --LIBgencodeTrashLast

astrMAINMatshape=(
	frameShapes 
	woodShapes 
	cobblestoneShapes 
	concreteShapes 
	steelShapes
)
anEconomicV=( # just equal to the hp or a mult of it
	  100
	  500
	 1500
	 5000
	10000
)
#astrMaterial=(
	#Mwood_weak_shapes 
	#Mwood_shapes 
	#Mcobblestone_shapes 
	#Mconcrete_shapes 
	#Msteel_shapes
	##Mwood_weak
	##Mwood
	##MresourceCobblestones
	##Mconcrete
	##Msteel
#)
astrResource=( # material countPerGrowStep
	resourceWood=2
	resourceWood=10
	resourceCobblestones=10
	resourceConcreteMix=10
	resourceForgedSteel=10
)
#if((${#astrMAINMatshape[@]} != ${#astrMaterial[@]}));then CFGFUNCerrorExit "arrays sizes dont match astrMaterial";fi
if((${#astrMAINMatshape[@]} != ${#astrResource[@]}));then CFGFUNCerrorExit "arrays sizes dont match astrResource";fi

astrVariant=(A B C D E)

function FUNCshape() {
	local lstrMatshape="$1";shift
	local lstrShape="$1";shift
	if [[ "${lstrShape:0:1}" == "@" ]];then # means it is not a subtype is a global type, no variant shape, no ':'
		lstrShape="${lstrShape:1}"
	else
		lstrShape="${lstrMatshape}:${lstrShape}"
	fi
	echo "${lstrShape}"
}

#for strVariant in "${astrVariant[@]}";do
strOutputRecipes=""
for((j=0;j<${#astrVariant[@]};j++));do
	strVariant="${astrVariant[j]}"
	#iMaxGrow="${astrVarGrowMax[j]}"
	if [[ "$strVariant" == A ]];then
		astrShape=(railing railing ladderSquare plateCornerRound1m plateCornerRound1m catwalkPlate)
	fi
	if [[ "$strVariant" == B ]];then
		astrShape=(railing railing ladderSquare cube3x3x1Destroyed cube3x3x1Destroyed "@looseBoardsTrapBlock3x3")
	fi
	if [[ "$strVariant" == C ]];then
		astrShape=(cube3x3x1Destroyed cube3x3x1Destroyed ladderSquare)
	fi
	if [[ "$strVariant" == D ]];then
		astrShape=(cube3x3x1Destroyed cubeHalf3x3x1DestroyedOffset ladderSquare)
	fi
	bStairsToHeaven=false
	if [[ "$strVariant" == E ]];then # stairs to heaven
		astrShape=(
			# railing railing  # these 2 makes make it difficult for zombies to climb, but then they will try to break them making it more difficult to defent this structure
			$(for((i=0;i<150;i++));do echo ladderSquare;done) 
			$(egrep -iRhI --include=*.xml '<block.*cnt[^"]*' ../* |egrep -o 'cntShippingCrate[^"]*|cntHardenedChestSecure' |sort -ur |sed 's!.*!@&!' |tr '\n' ' ') # all possible simpler containers that accept placing another block over them ex.: "@cntShippingCrateHero" , this will keep the player more time there, increasing the challenge of not falling to death # dont use as they do not fill 100% the block space: cntLootChestHero cntLootChestHeroInsecureT1
			"@cntMedicLootPileB"
		) #the last is a chance to find ohShitzDropz
		bStairsToHeaven=true
	fi
	
	iMaxGrow="$((${#astrShape[@]}-1))"
	#for strMatshape in "${astrMAINMatshape[@]}";do
	for((i=0;i<${#astrMAINMatshape[@]};i++));do
		strMatshape="${astrMAINMatshape[i]}"
		#strMaterial="${astrMaterial[i]}"
		strResource="${astrResource[i]}"
		nEconomicValue="${anEconomicV[i]}"
		
		if $bStairsToHeaven && [[ "${strMatshape}" != cobblestoneShapes ]];then continue;fi
		
		strCommentMaterial="			<!-- Mini Fortress Pole $strVariant $strMatshape -->"
		echo "$strCommentMaterial"  >>"${strFlGenBlo}${strGenTmpSuffix}"
		#iMaxGrow=5
		for((iGrowIndex=1;iGrowIndex<=iMaxGrow;iGrowIndex++));do
			strBaseContextName="MiniFortress"
			if $bStairsToHeaven;then strBaseContextName="StairsToHeaven";fi
			
			strMaterialName=${strMatshape%Shapes}
			strMaterialName="$(echo "${strMaterialName:0:1}" |tr '[:lower:]' '[:upper:]')${strMaterialName:1}"
			if $bStairsToHeaven;then strMaterialName="";fi
			
			if $bStairsToHeaven;then ((nEconomicValue/=10))&&:;fi
			
			strBlockBaseName="autoBuild${strBaseContextName}${strMaterialName}${strVariant}H$((iMaxGrow+1))" # H is +1 because the last placed block is not a growing one
			
			if((iGrowIndex<iMaxGrow));then
				strGrowOnTop="@${strBlockBaseName}G$((iGrowIndex+1))";
			else
				strGrowOnTop="${astrShape[iGrowIndex]}";
			fi
			
			if((iGrowIndex==1));then
				strDesc='
				<property name="DescriptionKey" value="dkAutoBuild" />'
				strCustomIcon='
				<property name="CustomIcon" value="7dtdShockTip" />'
				strCreativeMode="Player";
				strEconomicValue='
				<property name="EconomicValue" value="'"$(( (nEconomicValue*iMaxGrow)/10 ))"'"/>'
			else
				strCustomIcon=""
				strCreativeMode="None";
				strEconomicValue=""
			fi
			
			#makes no difference: <property name="Material" value="'"${strMaterial}"'"/>
			strBlockName="${strBlockBaseName}G$((iGrowIndex))"
			echo \
'			<block name="'"$strBlockName"'">
				<property name="Extends" value="AutoBuild:MiniFortressBase"/>'"${strCustomIcon}${strEconomicValue}"'
				<property name="CreativeMode" value="'"${strCreativeMode}"'"/>
				<property name="PlantGrowing.Next" value="'"$(FUNCshape "${strMatshape}" "${astrShape[iGrowIndex-1]}")"'"/>
				<property name="PlantGrowing.GrowOnTop" value="'"$(FUNCshape "${strMatshape}" "${strGrowOnTop}")"'"/>
			</block>' >>"${strFlGenBlo}${strGenTmpSuffix}"
			
			if((iGrowIndex==1));then # one recipe per initial block
				iCountMainResource="${strResource#*=}"; # BEFORE overwriting strResource!
				(( iCountMainResource*=(iMaxGrow+1) ))&&:
				
				strResource="${strResource%=*}";
				
				((iCountLiftingMechanism=iMaxGrow+1))&&:
				
				iCraftTime=$((iCountLiftingMechanism + iCountMainResource))
				
				strIngredentExtra1=''
				if $bStairsToHeaven;then
					((iCountMainResource/=10))&&:
					((iCountLiftingMechanism/=10))&&:
					((iCraftTime/=10))&&: #iCraftTime=66.6 # was 666 but so much time may just be annoying..
					strIngredentExtra1='
					<ingredient name="resourceLegendaryParts" count="1"/>
					<ingredient name="resourceRawDiamond" count="1"/>
					<ingredient name="plantedGraceCorn1" count="1"/>'
				fi
				
				echo \
'				<recipe name="'"$strBlockName"'" count="1" craft_time="'${iCraftTime}'">
					<ingredient name="'"${strResource}"'" count="'"${iCountMainResource}"'"/>
					<ingredient name="resourceMechanicalParts" count="'"${iCountLiftingMechanism}"'" help="lifting mechanism"/>'"${strIngredentExtra1}"'
				</recipe>
' >>"${strFlGenRec}${strGenTmpSuffix}"
			fi
			
		done #for((iGrowIndex=1;iGrowIndex<=iMaxGrow;iGrowIndex++));do
		
		#break #TODO this is just a test, too many blocks seems to break the engine
		
	done #for((i=0;i<${#astrMAINMatshape[@]};i++));do
	echo
	
	#break #TODO this is just a test, too many blocks seems to break the engine
done #for((j=0;j<${#astrVariant[@]};j++));do

CFGFUNCgencodeApply "${strFlGenBlo}${strGenTmpSuffix}" "${strFlGenBlo}"
CFGFUNCgencodeApply "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
