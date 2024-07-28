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

set -eu
trap 'echo ERROR' ERR
trap 'echo WARN_CtrlC_Pressed_ABORTING;exit 1' INT

source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

#clear;

IFS=$'\n' read -d '' -r -a astrList < <(egrep '<entity_class.*name="npc[^"]*(Axe|Bat|Club|EmptyHand|Knife|Machete)[^"]*' -i _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/entityclasses.xml -o |egrep -vi "npcHarley|npcAdvanced|Template|EmptyHand|.*PA$" |sort -u |sed -r -e 's@<entity_class name="(.*)@\1@')&&:;

declare -p astrList

strModFolder="$(ls -d ../*Ghussak*Warparty)"
declare -p strModFolder

# append the ID cvar to entity
iSpawnIndex=1;
for strNPC in "${astrList[@]}";do
 echo "	<append help=\"ID=$iSpawnIndex\" xpath=\"/entity_classes/entity_class[@name='$strNPC']\"><effect_group><triggered_effect trigger=\"onSelfFirstSpawn\" action=\"ModifyCVar\" cvar=\"iGSKNPCspawnID\" operation=\"set\" value=\"$iSpawnIndex\"/></effect_group></append>" >>"${strFlGenEnt}${strGenTmpSuffix}"
 ((iSpawnIndex++))&&:
done;
CFGFUNCgencodeApply --subTokenId "PrepareNPCID" "${strFlGenEnt}${strGenTmpSuffix}" "${strModFolder}/${strFlGenEnt}"

# create power armor NPCs
egrep -o 'name="npc[^"]+"' "../0-XNPCCore/Config/entityclasses.xml" "../1-NPC."*"/Config/entityclasses.xml" \
	|egrep -v "Ambush|DeusEx|Template|AnimalFox|PowerArmor|\"npc\"" \
	|egrep -v "DummyMatchInfo_TheseAreEntitiesThatCausedErrorOnLogDontKnowWhy|npcBanditLeader" \
	|sort -u |sed -r 's@.*"(.*)".*@\1@g' \
	|while read strNm;do
		nHireCost=750;
		if echo "$strNm" |egrep "AK47|SMG|M60|AShotgun|PShotgun|SRifle|HRifle|TRifle|RocketL" -qi;then ((nHireCost+=150))&&:;fi;
		if echo "$strNm" |egrep "PipeShotgun|Pistol|PipePistol|PipeRifle" -qi;then ((nHireCost+=75))&&:;fi;
		echo -en '
			<entity_class name="'"${strNm}PA"'" extends="'"${strNm}"'">
				<effect_group>
					<triggered_effect trigger="onSelfFirstSpawn" action="AddBuff" target="self" buff="buffGSKNPCHiredFollowingPowerArmorUse"/>
					<passive_effect name="PhysicalDamageResist" operation="base_set" value="90" />
				</effect_group>
				<property name="LootListAlive" value="traderNPCbigBackpack"/>
				<property name="HireCost" value="'"${nHireCost}"'"/>
				<property name="LootDropProb" value="0.05"/>
			</entity_class>' >>"${strFlGenEnt}${strGenTmpSuffix}"
	done
CFGFUNCgencodeApply --subTokenId "CreatePowerArmorNPCs" "${strFlGenEnt}${strGenTmpSuffix}" "${strModFolder}/${strFlGenEnt}"

# inform the player of the NPC spawn ID
for((iID=1;iID<iSpawnIndex;iID++));do
 echo "				<triggered_effect trigger=\"onSelfBuffStart\" action=\"ModifyCVar\" cvar=\".iGSKPlayerNPCInfoSpawnID\" operation=\"set\" value=\"$iID\" target=\"selfAOE\" range=\"2.5\"><requirement name=\"CVarCompare\" cvar=\"iGSKNPCspawnID\" operation=\"Equals\" value=\"$iID\" /><requirement name=\"CVarCompare\" target=\"other\" cvar=\"EntityID\" operation=\"Equals\" value=\"@Leader\" /></triggered_effect>" >>"${strFlGenBuf}${strGenTmpSuffix}"
done;
CFGFUNCgencodeApply --subTokenId "InfoPlayerNPCspawnID" "${strFlGenBuf}${strGenTmpSuffix}" "${strModFolder}/${strFlGenBuf}"

# create spawners for NPCs with the ID
iID=1;for strNPC in "${astrList[@]}";do
 echo "	<action_sequence name=\"eventGSKSpawnNPCPA_${iID}\"><action class=\"SpawnEntity\"><property name=\"entity_names\" value=\"${strNPC}PA\" /><property name=\"spawn_count\" value=\"1\" /><property name=\"safe_spawn\" value=\"true\" /><property name=\"spawn_from_position\" value=\"true\" /><property name=\"min_distance\" value=\"2\" /><property name=\"max_distance\" value=\"3\" /></action></action_sequence>" >>"${strFlGenEve}${strGenTmpSuffix}"
 ((iID++))&&:
done;
CFGFUNCgencodeApply "${strFlGenEve}${strGenTmpSuffix}" "${strModFolder}/${strFlGenEve}"

# spawn the requested NPC with the ID
iID=1;for strNPC in "${astrList[@]}";do
 echo "				<triggered_effect trigger=\"onSelfBuffUpdate\" action=\"CallGameEvent\" event=\"eventGSKSpawnNPCPA_${iID}\" help=\"${strNPC}\"><requirement name=\"CVarCompare\" cvar=\".iGSKNPCspawnIDtmp\" operation=\"Equals\" value=\"$iID\"/></triggered_effect>" >>"${strFlGenBuf}${strGenTmpSuffix}"
 ((iID++))&&:
done
CFGFUNCgencodeApply --subTokenId "SpawnNPCwithID" "${strFlGenBuf}${strGenTmpSuffix}" "${strModFolder}/${strFlGenBuf}"

CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
