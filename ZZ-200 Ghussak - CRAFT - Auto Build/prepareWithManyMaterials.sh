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

astrMatshape=(
	frameShapes 
	woodShapes 
	cobblestoneShapes 
	concreteShapes 
	steelShapes
)
astrMaterial=(
	Mwood_weak_shapes 
	Mwood_shapes 
	Mcobblestone_shapes 
	Mconcrete_shapes 
	Msteel_shapes
)
astrResource=(
	"resourceWood=12"
	resourceWood
	resourceCobblestones
	resourceConcreteMix
	resourceForgedSteel
)
if((${#astrMatshape[@]} != ${#astrMaterial[@]}));then echo "ERROR $LINENO";exit;fi
if((${#astrMatshape[@]} != ${#astrResource[@]}));then echo "ERROR $LINENO";exit;fi

astrVariant=(   A B)
astrVarGrowMax=(5 5)

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
	iMaxGrow="${astrVarGrowMax[j]}"
	if [[ "$strVariant" == A ]];then
		astrShape=(railing railing ladderSquare plateCornerRound1m plateCornerRound1m catwalkPlate)
	fi
	if [[ "$strVariant" == B ]];then
		astrShape=(railing railing ladderSquare cube3x3x1Destroyed cube3x3x1Destroyed "@looseBoardsTrapBlock3x3")
	fi
	#for strMatshape in "${astrMatshape[@]}";do
	for((i=0;i<${#astrMatshape[@]};i++));do
		strMatshape="${astrMatshape[i]}"
		strMaterial="${astrMaterial[i]}"
		strResource="${astrResource[i]}"
		strCommentMaterial="			<!-- Mini Fortress Pole $strVariant $strMatshape -->"
		echo "$strCommentMaterial"
		#iMaxGrow=5
		for((iGrowIndex=1;iGrowIndex<=iMaxGrow;iGrowIndex++));do
			if((iGrowIndex<iMaxGrow));then
				strGrowOnTop="@autoBuildMiniFortress${strMatshape%Shapes}${strVariant}$((iGrowIndex+1))";
			else
				strGrowOnTop="${astrShape[iGrowIndex]}";
			fi
			if((iGrowIndex==1));then strCreativeMode="Player";else strCreativeMode="None";fi
			#if [[ "${strGrowOnTop:0:1}" != "@" ]];then strGrowOnTop="${strMatshape}:${strGrowOnTop}";fi
			echo \
'			<block name="'"autoBuildMiniFortress${strMatshape%Shapes}${strVariant}$((iGrowIndex))"'">
				<property name="Extends" value="AutoBuild:MiniFortressBase"/>
				<property name="CustomIcon" value="7dtdShockTip" />
				<property name="CreativeMode" value="'"${strCreativeMode}"'"/>
				<property name="Material" value="'"${strMaterial}"'"/>
				<property name="PlantGrowing.Next" value="'"$(FUNCshape "${strMatshape}" "${astrShape[iGrowIndex-1]}")"'"/>
				<property name="PlantGrowing.GrowOnTop" value="'"$(FUNCshape "${strMatshape}" "${strGrowOnTop}")"'"/>
			</block>'
			
			iCount=60
			#declare -p strResource iCount
			if [[ "$strResource" =~ .*=.* ]];then
				iCount="${strResource#*=}";
				strResource="${strResource%=*}";
			fi
			strOutputRecipes+=\
'			<recipe name="'"autoBuildMiniFortress${strMatshape%Shapes}${strVariant}$((iGrowIndex))"'" count="1" craft_time="13">
				<ingredient name="'"${strResource}"'" count="'"${iCount}"'"/>
				<ingredient name="resourceMechanicalParts" count="6" help="6 for lifting mechanism"/>
			</recipe>
'
		done
	done
	echo
done
echo "$strOutputRecipes"
