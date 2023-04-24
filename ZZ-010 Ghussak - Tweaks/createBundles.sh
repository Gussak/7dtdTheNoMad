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

strCraftBundlePrefixID="GSK${strModNameForIDs}CreateRespawnBundle"

strPartToken="_TOKEN_NEWPART_MARKER_"
strSchematics="Schematics"
strSCHEMATICS_BEGIN_TOKEN="${strPartToken}:${strSchematics}"
astrDKAndDescList=()
astrBundlesItemsLeastLastOne=()
astrBundlesSchematics=()

# sub sections
strXmlCraftBundleCreateItemsXml=""
strXmlCraftBundleCreateRecipesXml=""
strXmlCraftBundleCreateBuffsXml=""
strDKCraftAvailableBundles=""
astrCraftBundleNameList=()

function FUNCprepareCraftBundle() {
  local lbLightColor=false
  local lbSchematic=false
  while [[ "${1:0:2}" == "--" ]];do
    if [[ "$1" == "--lightcolor" ]];then lbLightColor=true;shift;fi
    if [[ "$1" == "--schematic" ]];then lbSchematic=true;shift;fi
  done
  local lbIgnTopList="$1";shift
  local lstrBundleID="$1";shift
  local lstrBundleShortName="$1";shift
  local lstrIcon="$1";shift
  local lstrType="$1";shift
  
  local liR=90 liG=90 liB=90
  if $lbLightColor;then ((liR+=20,liG+=20,liB+=20))&&:;fi
  if $lbSchematic;then ((liB+=130));fi
  local lstrColor="$liR,$liG,$liB"
  local lstrCvar="iGSKRespawnItemsBundleHelper${lstrBundleShortName}"
  strFUNCprepareCraftBundle_CraftBundleID_OUT="${strCraftBundlePrefixID}${lstrBundleShortName}"
  strXmlCraftBundleCreateItemsXml+='
    <!-- HELPGOOD:Respawn:CreateBundle:'"${lstrBundleID}"' -->
    <item name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" help="on death free items helper">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />'"${lstrType}"'
      <property name="CustomIconTint" value="'"${lstrColor}"'" />
      <property name="DescriptionKey" value="dkGSKTheNoMadCreateRespawnBundle" />
      <property class="Action0">
        <requirement name="CVarCompare" cvar="'"${lstrCvar}"'" operation="GT" value="0" />
        <property name="Create_item" value="'"${lstrBundleID}"'" />
        <property name="Create_item_count" value="1" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" target="self" cvar="'"${lstrCvar}"'" operation="add" value="-1"/>
      </effect_group>
    </item>'
  strXmlCraftBundleCreateRecipesXml+='
    <recipe name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" count="1"></recipe>'
  # not using onSelfDied anymore, unnecessary
  if ! $lbSchematic;then
    strXmlCraftBundleCreateBuffsXml+='
        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="add" value="1"/>'
  else
    strXmlCraftBundleCreateBuffsXml+='
        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="add" value="1">
          <requirement name="CVarCompare" cvar="bGSKRespawnSchematicsOnlyOnce" operation="Equals" value="1" />
        </triggered_effect>'
  fi
  if [[ -z "$strDKCraftAvailableBundles" ]];then
    strDKCraftAvailableBundles+='dkGSKTheNoMadCreateRespawnBundle,"After you die, '"'"'CB:'"'"' items can be crafted for free. You dont need to rush to your dropped backpack. Open each bundle only when you need it. Respawning adds 1 to the remaining bundles (least schematics) that you can open (up to more {cvar(iGSKFreeBundlesRemaining:0)} now): '
  fi
  strDKCraftAvailableBundles+=" ${lstrBundleShortName}={cvar(${lstrCvar}:0)},"
  astrCraftBundleNameList+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT},\"${strModName}CB:${lstrBundleShortName}\"")
  if $lbSchematic;then
    astrBundlesSchematics+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT}" 1)
  else
    if ! $lbIgnTopList;then
      astrCBItemsLeastLastOne+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT}" 1)
    fi
  fi
}

function FUNCprepareBundlePart_specificItemsChk_MULTIPLEOUTPUTVALUES() { # OUT vars are to avoid subshell. if the bundle contains any of these items, specific code shall be added
  local lbCheckMissingItemIds="$1";shift
  local strItemID="$1";shift
  
  strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT=""
  #strFUNCspecificItemsCode_AddDesc=""
  
  local lastrFlCfgChkList=(block item item_modifier)
  local lstrFlCfgChkRegex="`echo "${lastrFlCfgChkList[@]}" |tr ' ' '|'`"
  local lastrFlCfgChkFullPathList=()
  for strFlCfgChk in "${lastrFlCfgChkList[@]}";do
    lastrFlCfgChkFullPathList+=("Config/${strFlCfgChk}s.xml")
    if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
      lastrFlCfgChkFullPathList+=("${strCFGNewestSavePathConfigsDumpIgnorable}/${strFlCfgChk}s.xml")
    fi
  done
  
  if [[ "$strItemID" =~ ^${strCraftBundlePrefixID} ]];then
    lbCheckMissingItemIds=false
  fi
  
  if $lbCheckMissingItemIds;then
    local lstrChkItemId="`echo "${strItemID}" |cut -d: -f1`" #TODO check for the "VariantHelper" string if it is valike like in "cobblestoneShapes:VariantHelper"
    if ! egrep '< *('"${lstrFlCfgChkRegex}"') *name *= *"'"${lstrChkItemId}"'"' "${lastrFlCfgChkFullPathList[@]}" -inw;then CFGFUNCerrorExit "item id lstrChkItemId='${lstrChkItemId}' is missing (or was changed): strItemID='${strItemID}'. try: egrep 'TypePreviousIdHere' * -iRnI --include=\"*.xml\"";fi
  fi
  
  local fDmg=0.75
  if [[ "$strItemID" == "apparelNightvisionGoggles" ]];then
    bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=true
    strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT+='      <!-- HELPGOOD: initially damaged items below -->
      <effect_group name="damaged starter item: '"$strItemID"'" tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercNV" operation="set" value="0">
          <requirement name="CVarCompare" cvar="fGSKDmgPercNV" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercNV" operation="add" value="'$fDmg'">
          <requirement name="CVarCompare" cvar="fGSKDmgPercNV" operation="LTE" value="0.01" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRecalcDegradations"/>
      </effect_group>'
  fi
  if [[ "$strItemID" == "meleeToolFlashlight02" ]];then
    bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=true
    strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT+='      <!-- HELPGOOD: initially damaged items below -->
      <effect_group name="damaged starter item: '"$strItemID"'" tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercHL" operation="set" value="0" >
          <requirement name="CVarCompare" cvar="fGSKDmgPercHL" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercHL" operation="add" value="'$fDmg'" >
          <requirement name="CVarCompare" cvar="fGSKDmgPercHL" operation="LTE" value="0.01" />
        </triggered_effect>
        
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercWL" operation="set" value="0" >
          <requirement name="CVarCompare" cvar="fGSKDmgPercWL" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercWL" operation="add" value="'$fDmg'" >
          <requirement name="CVarCompare" cvar="fGSKDmgPercWL" operation="LTE" value="0.01" />
        </triggered_effect>
        
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRecalcDegradations"/>
      </effect_group>'
  fi
  if [[ "$strItemID" == "modGSKTeslaTeleport" ]];then
    bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=true
    strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT+='      <!-- HELPGOOD: initially damaged items below -->
      <effect_group name="damaged starter item: '"$strItemID"'" tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercTP" operation="set" value="0">
          <requirement name="CVarCompare" cvar="fGSKDmgPercTP" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercTP" operation="add" value="'$fDmg'">
          <requirement name="CVarCompare" cvar="fGSKDmgPercTP" operation="LTE" value="0.01" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRecalcDegradations"/>
      </effect_group>'
  fi
  if [[ "$strItemID" == "modGSKEnergyThorns" ]];then
    bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=true
    strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT+='      <!-- HELPGOOD: initially damaged items below -->
      <effect_group name="damaged starter item: '"$strItemID"'" tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercTT" operation="set" value="0">
          <requirement name="CVarCompare" cvar="fGSKDmgPercTP" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercTT" operation="add" value="'$fDmg'">
          <requirement name="CVarCompare" cvar="fGSKDmgPercTP" operation="LTE" value="0.01" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRecalcDegradations"/>
      </effect_group>'
  fi
  
  #if [[ "$strItemID" == "GSKTheNoMadOverhaulBundleNoteBkp" ]];then
    #strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT+='      <!-- HELPGOOD: allows opening the CreateBundle items -->
      #<effect_group name="allows opening the CreateBundle items, hint item: '"$strItemID"'" tiered="false">
        #<triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRespawnNoMadBundlesAllowCrafting"/>
      #</effect_group>'
  #fi
}

function FUNCprepareBundlePart() {
  local lbIgnTopList="$1";shift
  local lbRnd="$1";shift
  local lstrBundleName="$1";shift
  local lstrBundlePartName="$1";shift
  local lstrIcon="$1";shift
  local lstrColor="$1";shift
  local lbCB=$1;shift
  local lstrBundleDesc="$1";shift
  local lbCheckMissingItemIds="$1";shift
  local lastrItemAndCountList=("$@")
  
  local lastrOpt=()
  
  if [[ "${lstrBundleName}" =~ .*\ .* ]];then
    echo "ERROR: cant have spaces lstrBundleName='$lstrBundleName'"
    exit 1
  fi
  
  strFUNCprepareBundlePart_BundleID_OUT="GSK${lstrBundleName}${lstrBundlePartName}Bundle"
  astrDKAndDescList+=("${strFUNCprepareBundlePart_BundleID_OUT},\"${strModName}BD:${lstrBundleName} ${lstrBundlePartName}\"")
  
  bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=false
  strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT=""
  local lstrItems="" lstrCounts="" lstrSep="" lstrSpecifiItemsCode=""
  for((i=0;i<${#lastrItemAndCountList[@]};i+=2));do 
    if((i>0));then lstrSep=",";fi;
    lstrItems+="$lstrSep${lastrItemAndCountList[i]}"
    local liItemCount="${lastrItemAndCountList[i+1]}"
    if ! [[ "${liItemCount}" =~ ^[0-9]*$ ]];then CFGFUNCerrorExit "invalid liItemCount='${liItemCount-}', should be a positive integer";fi
    lstrCounts+="$lstrSep${liItemCount}";
    #echo "          ${lastrItemAndCountList[i]} ${lastrItemAndCountList[i+1]}"
    FUNCprepareBundlePart_specificItemsChk_MULTIPLEOUTPUTVALUES "$lbCheckMissingItemIds" "${lastrItemAndCountList[i]}"
    lstrSpecifiItemsCode+="${strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT}"
    #if [[ "${lstrBundleDesc:0:2}" != "dk" ]];then
      #if [[ -n "${strFUNCspecificItemsCode_AddDesc}" ]];then
        #: 
      #fi
    #fi
  done;
  local lstrAddDesc=""
  if $bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT;then
    lstrAddDesc+="\nObs.: Some of these equipment or devices are severely damaged and wont last long w/o repairs.\n"
  fi
  
  local lstrBundleDK="dk${strFUNCprepareBundlePart_BundleID_OUT}"
  if [[ "${lstrBundleDesc}" == "--autoDK" ]];then
    lstrBundleDesc="$lstrBundleDK"
  fi
  if [[ "${lstrBundleDesc:0:2}" == "dk" ]];then
    lstrBundleDK="$lstrBundleDesc"
  else
    astrDKAndDescList+=("${lstrBundleDK},\"${lstrBundleDesc}${lstrAddDesc}\"")
  fi
  if [[ -n "$lstrAddDesc" ]] && [[ "${lstrBundleDesc:0:2}" == "dk" ]];then
    if ! CFGFUNCprompt -q "has external bundle description '$lstrBundleDesc' and also has added description '$lstrAddDesc' that will be lost! ignore this now?";then
       CFGFUNCerrorExit "ugh..."
    fi
  fi
  
  #strDK=""
  #astrDescriptionKeyList+=()
  #dkGSKstartNewGameItemsBundle
  local lstrType=""
  if [[ "$lstrBundlePartName" == "$strSchematics" ]];then
    #lstrIcon="bundleBooks"
    lstrType='<property name="ItemTypeIcon" value="book" />'
    #astrBundlesSchematics+=("$strFUNCprepareBundlePart_BundleID_OUT" 1)
    lastrOpt+=(--lightcolor)
    lastrOpt+=(--schematic)
  else
    if ! $lbIgnTopList;then
      astrBundlesItemsLeastLastOne+=("$strFUNCprepareBundlePart_BundleID_OUT" 1)
    fi
    #astrCBItemsLeastLastOne
  fi
  if [[ -z "${lstrIcon}" ]];then
    lstrIcon="cntStorageGeneric"
  fi
  
  
  
  #if [[ "$lstrBundleName" == "$strModNameForIDs" ]];then
    ##strColor="220,180,128" #TODO use same color of GSKTheNoMadOverhaulBundleNoteBkp thru xmlstarlet get value
    #strIcon="cntStorageGeneric"
  #fi
  echo '    <!-- HELPGOOD:GENCODE:'"${strScriptName}: ${lstrBundleName} ${lstrBundlePartName}"' -->
    <item name="'"${strFUNCprepareBundlePart_BundleID_OUT}"'">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />'"${lstrType}"'
      <property name="CustomIconTint" value="'"$lstrColor"'" />
      <property name="DescriptionKey" value="'"${lstrBundleDK}"'" />
      <property class="Action0">' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  if $lbRnd;then
    #TODO: the Create_item seems required to not cause problems?
    echo '
        <property name="Create_item" value="resourcePaper" />
        <property name="Create_item_count" value="0" />
        <property name="Random_item" value="'"${lstrItems}"'" />
        <property name="Random_item_count" value="'"${lstrCounts}"'" />
        <property name="Random_count" value="1" />' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  else
    echo '
        <property name="Create_item" help="it has '"$((${#lastrItemAndCountList[@]}/2))"' diff items" value="'"${lstrItems}"'" />
        <property name="Create_item_count" value="'"${lstrCounts}"'" />' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  fi
  echo '
      </property>'"${lstrSpecifiItemsCode}"'
    </item>' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  
  if $lbCB;then
    FUNCprepareCraftBundle ${lastrOpt[*]} "$lbIgnTopList" "${strFUNCprepareBundlePart_BundleID_OUT}" "${lstrBundleName}${lstrBundlePartName}" "${lstrIcon}" "${lstrType}"
  fi
}

function FUNCprepareBundles() {
  local lbRnd=false
  local lbCB=true
  local lstrColor="192,192,192"
  local lbIgnTopList=false
  local lbCheckMissingItemIds=true
  while [[ "${1:0:2}" == "--" ]];do
    if [[ "$1" == --ignoreTopList ]];then shift;lbIgnTopList=true;fi
    if [[ "$1" == --choseRandom ]];then shift;lbRnd=true;fi
    if [[ "$1" == --noCB ]];then shift;lbCB=false;fi
    if [[ "$1" == --color ]];then shift;lstrColor="$1";shift;fi #help <lstrColor>
    if [[ "$1" == --noCheckMissingItemIds ]];then shift;lbCheckMissingItemIds=false;fi #help <lstrColor>
  done
  
  local lstrBundleName="$1";shift
  local lstrIcon="$1";shift
  local lstrBundleDesc="$1";shift
  local lastrItemAndCountList=("$@")
  
  local lastrParams=("$lstrIcon" "$lstrColor" "$lbCB" "$lstrBundleDesc" "$lbCheckMissingItemIds")
  
  declare -p lastrItemAndCountList |tr '[' '\n'
  
  strNextPartName=""
  local lastrItemAndCountListPart=()
  for((i=0;i<${#lastrItemAndCountList[@]};i+=2));do 
    strNm="${lastrItemAndCountList[i]}"
    #declare -p strNm
    if [[ "${strNm}" =~ ^${strPartToken}.* ]];then
      if((${#lastrItemAndCountListPart[*]}>0));then
        FUNCprepareBundlePart "$lbIgnTopList" "$lbRnd" "$lstrBundleName" "" "${lastrParams[@]}" "${lastrItemAndCountListPart[@]}"
      fi
      # init next part
      lastrItemAndCountListPart=()
      strNextPartName="`echo "$strNm" |cut -d: -f2`"
      continue
    fi
    local liItemCount="${lastrItemAndCountList[i+1]}"
    if ! [[ "${liItemCount}" =~ ^[0-9]*$ ]];then CFGFUNCerrorExit "invalid liItemCount='${liItemCount-}', should be a positive integer";fi
    lastrItemAndCountListPart+=("${lastrItemAndCountList[i]}" "${liItemCount}")
  done
  if [[ -n "$strNextPartName" ]] && ((${#lastrItemAndCountListPart[*]}>0));then
    FUNCprepareBundlePart "$lbIgnTopList" "$lbRnd" "$lstrBundleName" "${strNextPartName}" "${lastrParams[@]}" "${lastrItemAndCountListPart[@]}"
  fi
}

#function CFGFUNCchkNumber() {
  #if ! [[ "${1-}" =~ ^[0-9]*$ ]];then
    #CFGFUNCerrorExit "invalid '${1-}', should be a positive integer";fi
  #fi
#}

#astr=( #TEMPLATE
#  "$strSCHEMATICS_BEGIN_TOKEN" 0
#);FUNCprepareBundles "" "${astr[@]}"

astr=(
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  cementMixerSchematic 1 
  forgeSchematic 1 
  toolAnvilSchematic 1 
  toolBellowsSchematic 1 
  toolForgeCrucibleSchematic 1 
);FUNCprepareBundles "ForgeCrafting" "cntLootChestHeroInsecureT1" "Use this when you want to begin creating and using forges, also has cementmixer." "${astr[@]}"

astr=(
  apparelNightvisionGoggles 1
  bedrollBlue 33
  casinoCoin 666
  "cobblestoneShapes:VariantHelper" 66
  drinkCanEmptyCookingOneUse 33
  drugJailBreakers 3
  GlowStickGreen       33
  GSKfireFuel 13
  GSKsimpleBeer        33
  ladderWood            66
  meleeToolFlashlight02 1
  meleeToolTorch 1
  NightVisionBattery    66
  #meleeWpnSpearT0StoneSpear 1
  resourceCloth 33
  resourceDuctTape 1
  resourceFeather        1
  resourceLockPick 1
  resourceRockSmall    222
  resourceWood         66
  resourceYuccaFibers  33
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  modArmorHelmetLightSchematic 1
  modGunFlashlightSchematic 1
  vehicleBicycleChassisSchematic 1
  vehicleBicycleHandlebarsSchematic 1
);FUNCprepareBundles "Exploring" "bundleVehicle4x4" "Use this if you think exploring the world is unreasonably difficult (there is no vehicle in it tho)." "${astr[@]}"

astr=( #TEMPLATE
  ammo9mmBulletBall 666
  ammoArrowStone 33
  gunHandgunT1PistolParts 33
  gunHandgunT3SMG5 1
  modGunScopeSmall 1
  thrownAmmoMolotovCocktail6s 13
  thrownAmmoStunGrenade 13
  trapSpikesIronDmg0    33
  #trapSpikesWoodDmg0    99
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  bookRangersExplodingBolts 1
  thrownDynamiteSchematic 1
);FUNCprepareBundles "CombatWeapons" "bundleMachineGun" "use this if you are not having a reasonable chance against mobs" "${astr[@]}"

strCombatArmorHelp="Use this if you are taking too much damage."
astrCombatArmorCreateBundleList=()
astr=( #TEMPLATE
  #armorMiningHelmet 1 #not good as will give a easy headlight...
  armorFirefightersHelmet 1
  armorFootballHelmet 1
  armorMilitaryHelmet 1
  armorSwatHelmet 1 # a good helmet is essential against ranged raiders
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --ignoreTopList --choseRandom "CombatArmorHelmet" "bundleArmorLight" "${strCombatArmorHelp} You should use this anyway otherwise ranged raiders become unreasonably difficult." "${astr[@]}";astrCombatArmorCreateBundleList+=("$strFUNCprepareCraftBundle_CraftBundleID_OUT" 1)
astr=( #TEMPLATE
  "${astrCombatArmorCreateBundleList[@]}"
  ##armorSteelHelmet 1
  ##armorMilitaryHelmet 1
  #armorSwatHelmet 1 # a good helmet is essential against ranged raiders
  ##armorClothHat 1
  armorClothJacket 1
  armorClothGloves 1
  #armorScrapGloves 1
  #armorScrapLegs 1
  armorClothPants 1
  armorClothBoots 1
  RepairColdProt 13
  RepairHeatProt 13
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "CombatArmor" "bundleArmorLight" "$strCombatArmorHelp" "${astr[@]}"

astr=(
  ammoJunkTurretRegular 222
  armorClothHat 1 # this is to be able to install one of the mods
  gunBotT2JunkTurret 1
  GSKCFGTeslaTeleportToBiome 1
  GSKNoteTeslaTeleporToSkyFirstTime 1
  #GSKTeslaTeleportDirection 1
  #GSKTeslaTeleportToSky 1
  modGSKEnergyThorns     1
  #modGSKTeslaTeleport 1
  NightVisionBattery    13
  #NightVisionBatteryStrong 2 #uneccessarry now, tele to sky will just make energy negative and will work.
  NVBatteryCreate 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  batterybankSchematic 1
  bookTechJunkie5Repulsor 1
  generatorbankSchematic 1
  gunBotT2JunkTurretSchematic 1
);FUNCprepareBundles "TeslaEnergy" "bundleBatteryBank" "Use this if you want to start using and crafting tesla mods, this will increase your combat survival chances." "${astr[@]}"

astr=(
  bucketRiverWater 1
  drinkJarGrandpasMoonshine 1
  drinkJarPureMineralWater 22
  drugAntibiotics 4
  drugPainkillers 1
  drugSteroids  13
  drugVitamins 1
  foodHoney 1
  drugGSKAntiRadiation 13
  drugGSKAntiRadiationSlow 13
  drugGSKAntiRadiationStrong 13
  drugGSKPsyonicsResist 13
  drugGSKRadiationResist 13
  drugGSKsnakePoisonAntidote 3
  medicalBloodBag 13
  medicalFirstAidBandage 13
  medicalSplint 3
  potionRespec 1
  toolBeaker 1
  treePlantedMountainPine1m 13
  foodSpaghetti 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  bookWasteTreasuresHoney 1
  bookWasteTreasuresWater 1
  drugAntibioticsSchematic 1
  drugHerbalAntibioticsSchematic 1
  foodBoiledMeatBundleSchematic 1
  foodBoiledMeatSchematic 1
);FUNCprepareBundles "Healing" "bundleFood" "Use this if you have not managed to heal yourself yet or is having trouble doing that or has any disease or infection and is almost dieing, don't wait too much tho!" "${astr[@]}"

astr=(
  farmPlotBlockVariantHelper 13
  plantedBlueberry1 15
  plantedMushroom1 9
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  plantedBlueberry1Schematic 1
  plantedMushroom1Schematic 1
);FUNCprepareBundles "Farming" "bundleFarm" "Use this if you need to be able to harvest and craft antibiotics." "${astr[@]}"

astr=(
  bedrollBlue 1
  campfire 1 
  drinkCanEmptyCookingOneUse 3
  candleTableLight 1
  cntSecureStorageChest 1
  meleeToolRepairT0StoneAxe 1
  resourceRockSmall 13
  resourceWood 33
  drinkCanEmpty 3
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "BasicCampingKit" "bundleTraps" "Some basic things to quickly set a tiny camp with shelter and cook a bit." "${astr[@]}"

astr=(
  bedrollBlue 1
  drinkCanEmptyCookingOneUse 3
  drinkJarBoiledWater 2
  drugSteroids 1
  GlowStickGreen       13
  drugGSKAntiRadiationStrong 2
  drugGSKPsyonicsResist 3
  drugGSKsnakePoisonAntidote 1
  GSKfireFuel 5
  GSKsimpleBeer        3
  medicalFirstAidBandage 3
  medicalSplint 1
  meleeToolTorch 1
  resourceRockSmall    15
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --color "128,180,128" "MinimalSurvivalKit" "cntStorageGeneric" "Minimal helpful stuff." "${astr[@]}"

astr=(
  "${astrBundlesSchematics[@]}" # these are the bundles of schematics, not schematics themselves so they must be in the astrBundlesItemsLeastLastOne list
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "SomeSchematicBundles" "bundleBooks" "Open this to get some schematics bundles related to the item's bundles." "${astr[@]}"
#);FUNCprepareBundles --noCheckMissingItemIds "SomeSchematicBundles" "bundleBooks" "Open this to get some schematics bundles related to the item's bundles." "${astr[@]}"

#########################################################################################
#########################################################################################
###################################### KEEP AS LAST ONE!!! ##############################
#########################################################################################
#########################################################################################
astr=(
  # notes
  GSKTRNotesBundle 1 #from createNotesTips.sh
  GSKTRSpecialNotesBundle 1 #from createNotesTips.sh
  GSKNoteInfoDevice 1 
  GSKNoteStartNewGameSurvivingFirstDay 1
  GSKTheNoMadOverhaulBundleNoteBkp 1 # this last bundle description bkp
  startNewGameOasisHint 1
  
  #vanilla
  #keystoneBlock 1 
  
  #all previous bundles
  # this is not good, it should be controlled by the respawn cvar "${astrBundlesItemsLeastLastOne[@]}"
  "${astrCBItemsLeastLastOne[@]}"
  
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --noCB "$strModNameForIDs" "cntStorageGeneric" --autoDK "${astr[@]}"
#);FUNCprepareBundles --noCheckMissingItemIds --noCB "$strModNameForIDs" "cntStorageGeneric" --autoDK "${astr[@]}"

################## DESCRIPTIONS ####################
echo
for strDKAndDesc in "${astrDKAndDescList[@]}";do
  echo "${strDKAndDesc}" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done

############ APPLY CHANGES AT SECTIONS ################
#ls -l *"${strGenTmpSuffix}"&&:
./gencodeApply.sh "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
./gencodeApply.sh "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

# CRAFT BUNDLES SECTIONS
strSubToken="CRAFTBUNDLES"

echo "$strXmlCraftBundleCreateItemsXml"   >"${strFlGenIte}${strGenTmpSuffix}"
./gencodeApply.sh --subTokenId "${strSubToken}" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

echo "$strXmlCraftBundleCreateRecipesXml" >"${strFlGenRec}${strGenTmpSuffix}"
./gencodeApply.sh --subTokenId "${strSubToken}" "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

echo "$strXmlCraftBundleCreateBuffsXml"   >"${strFlGenBuf}${strGenTmpSuffix}"
./gencodeApply.sh --subTokenId "${strSubToken}" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"

strDKCraftAvailableBundles+='"' #closes the prepared description text
echo "$strDKCraftAvailableBundles"        >"${strFlGenLoc}${strGenTmpSuffix}"
for strDKCraftBundleName in "${astrCraftBundleNameList[@]}";do
  echo "$strDKCraftBundleName" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done
./gencodeApply.sh --subTokenId "${strSubToken}" "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"

./gencodeApply.sh --cleanChkDupTokenFiles
