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

source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

strCraftBundlePrefixID="GSK${strModNameForIDs}CreateRespawnBundle"

strPartToken="_TOKEN_NEWPART_MARKER_"
strSchematics="Schematics"
strSCHEMATICS_BEGIN_TOKEN="${strPartToken}:${strSchematics}"
strExpLossInfo="CurrentExpLoss: {cvar(.fGSKExpDebtPercx100:0)}%\n CurrentExpDebit: {cvar(fGSKExpDebt:0.00)}/{cvar(fGSKAllFreeBundlesSumExpDebit:0)}\n RealTimeHoursRemainingToEndExpLoss: {cvar(.fGSKExpDebtTmRemain:0.0)}\nOpening free bundles that increase exp loss beyond the maximum will only increase the remaining time."
astrDKAndDescList=("dkGSKFreeBundleExpLossInfo_NOTE,\"${strExpLossInfo}\"")
astrBundlesItemsLeastLastOne=()
astrBundlesSchematics=()

iAllFreeBundlesSumExpDebit=0

# sub sections
strXmlCraftBundleCreateItemsXml=""
strXmlCraftBundleCreateRecipesXml=""
strXmlCraftBundleCreateBuffsXml=""
strDKCraftAvailableBundles=""
astrCraftBundleNameList=()

# these files at astrFlCfgChkFullPathList are to be queried for useful data
astrFlCfgChkList=(block item item_modifier)
strFlCfgChkRegex="`echo "${astrFlCfgChkList[@]}" |tr ' ' '|'`"
astrFlCfgChkFullPathList=()
astrXmlToken1VsFile2List=() # key value
for strFlCfgChk in "${astrFlCfgChkList[@]}";do
  strFlRelatModCfgXml="Config/${strFlCfgChk}s.xml"
  astrFlCfgChkFullPathList+=("${strFlRelatModCfgXml}") # this is the xml modlet file on this mod's folder
  astrXmlToken1VsFile2List+=("$strFlCfgChk" "${strFlRelatModCfgXml}")
  if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
    strFlXmlFinalChk="${strCFGNewestSavePathConfigsDumpIgnorable}/${strFlCfgChk}s.xml"
    astrFlCfgChkFullPathList+=("$strFlXmlFinalChk") # this is the xml final dump of the last save
    astrXmlToken1VsFile2List+=("$strFlCfgChk" "$strFlXmlFinalChk")
  fi
done #for strFlCfgChkFullPath in "${astrFlCfgChkFullPathList[@]}";do
declare -p astrXmlToken1VsFile2List |tr '[' '\n'

declare -A astrItem1Value2List=()
strFlItemEconomicValueCACHE="`basename "$0"`.ItemEconomicValue.CACHE.sh" #help if you delete the cache file it will be recreated
#if [[ -f "${strFlItemEconomicValueCACHE}" ]];then source "${strFlItemEconomicValueCACHE}";fi
source "${strFlItemEconomicValueCACHE}"&&:
strIVChk="`declare -p astrItem1Value2List |tr '[' '\n' |egrep -v "^ *$" |egrep -v "${strCraftBundlePrefixID}" |sort -u`"
echo "$strIVChk" |egrep '="1"'&&: # just to check if they should really be value 1
if((`echo "$strIVChk" |egrep '="0*"' |wc -l`>0));then # matches "" or "0"
  echo "$strIVChk"
  CFGFUNCprompt "there are the above entries that could be improved (at least EconomicValue 1)"
fi

function FUNCprepareCraftBundle() {
  local lbLightColor=false
  local lbSchematic=false
  while [[ "${1:0:2}" == "--" ]];do
    if [[ "$1" == --lightcolor ]];then lbLightColor=true;shift;fi
    if [[ "$1" == --schematic ]];then lbSchematic=true;shift;fi
  done
  local lbIgnTopList="$1";shift
  local lstrBundleID="$1";shift
  local lstrBundleShortName="$1";shift
  local lstrIcon="$1";shift
  local lstrType="$1";shift
  local liExpDebt="$1";shift
  local lbOpenOnceOnly="$1";shift
  local lstrBundleDK="$1";shift
  local lstrCvar="$1";shift
  
  local liR=90 liG=90 liB=90
  if $lbLightColor;then ((liR+=20,liG+=20,liB+=20))&&:;fi
  if $lbSchematic;then ((liB+=130));fi
  local lstrColor="$liR,$liG,$liB"
  #local lstrCvar="iGSKRespawnItemsBundleHelper${lstrBundleShortName}"
  local lstrCB="'CB:' items are craftable freely (can be dropped). Don't rush to your backpack. Each bundle has (exp penalty). Resurrecting adds 1 to remaining bundles (least a few like schematics, maps..) that you can open (up to {cvar(iGSKFreeBundlesRemaining:0)} now). "
  strFUNCprepareCraftBundle_CraftBundleID_OUT="${strCraftBundlePrefixID}${lstrBundleShortName}"
  strXmlCraftBundleCreateItemsXml+='
    <!-- HELPGOOD:Respawn:CreateBundle:'"${lstrBundleID}"' -->
    <item name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" help="on death free items helper">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />'"${lstrType}"'
      <property name="CustomIconTint" value="'"${lstrColor}"'" />
      <property name="DescriptionKey" value="'"${lstrBundleDK}"'" />
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
  if $lbSchematic || $lbOpenOnceOnly;then
    strXmlCraftBundleCreateBuffsXml+='
        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="add" value="1">
          <requirement name="CVarCompare" cvar="bGSKRespawnSchematicsOnlyOnce" operation="Equals" value="1" />
        </triggered_effect>'
  else
    strXmlCraftBundleCreateBuffsXml+='
        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="add" value="1"/>'
  fi
  if [[ -z "$strDKCraftAvailableBundles" ]];then
    #strDKCraftAvailableBundles+='dkGSKTheNoMadCreateRespawnBundle,"After you die, '"'"'CB:'"'"' items can be crafted for free. You dont need to rush to your dropped backpack. Open each bundle only when you need it as it has experience penalty time (inside parenthesis). Respawning adds 1 to the remaining bundles (least schematics) that you can open (up to more {cvar(iGSKFreeBundlesRemaining:0)} now): '
    strDKCraftAvailableBundles+="dkGSKTheNoMadCreateRespawnBundle,\"${lstrCB}: "
  fi
  strDKCraftAvailableBundles+=" ${lstrBundleShortName}={cvar(${lstrCvar}:0)}(${liExpDebt}),"
  astrCraftBundleNameList+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT},\"${strModName}CB:${lstrBundleShortName}\"")
  if $lbSchematic;then
    astrBundlesSchematics+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT}" 1)
  else
    if ! $lbIgnTopList;then
      astrCBItemsLeastLastOne+=("${strFUNCprepareCraftBundle_CraftBundleID_OUT}" 1)
    fi
  fi
}

function FUNCidWithoutVariant() {
  echo "${1}" |cut -d: -f1 #TODO check for the "VariantHelper" string if it is valid like in "cobblestoneShapes:VariantHelper"
}

function FUNCprepareBundlePart_specificItemsChk_MULTIPLEOUTPUTVALUES() { # OUT vars are to avoid subshell. if the bundle contains any of these items, specific code shall be added
  local lbCheckMissingItemIds="$1";shift
  local strItemID="$1";shift
  
  strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT=""
  #strFUNCspecificItemsCode_AddDesc=""
  
  if [[ "$strItemID" =~ ^${strCraftBundlePrefixID} ]];then
    lbCheckMissingItemIds=false
  fi
  
  if $lbCheckMissingItemIds;then
    #local lstrChkItemId="`echo "${strItemID}" |cut -d: -f1`" #TODO check for the "VariantHelper" string if it is valid like in "cobblestoneShapes:VariantHelper"
    local lstrChkItemId="`FUNCidWithoutVariant "${strItemID}"`"
    if ! egrep '< *('"${strFlCfgChkRegex}"') *name *= *"'"${lstrChkItemId}"'"' "${astrFlCfgChkFullPathList[@]}" -inw;then CFGFUNCerrorExit "item id lstrChkItemId='${lstrChkItemId}' is missing (or was changed): strItemID='${strItemID}'. try: egrep 'TypePreviousIdHere' * -iRnI --include=\"*.xml\"";fi
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
  if [[ "$strItemID" == "modGSKElctrnTeleport" ]];then
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

function FUNCxmlstarletSel() {
  local lbChkExistsOnly=false;if [[ "$1" == --chk ]];then shift;lbChkExistsOnly=true;fi
  local lstrPath="$1";shift
  local lstrFlXml="$1";shift
  
  local lastrCmd=(xmlstarlet)
  if $lbChkExistsOnly;then lastrCmd+=(-q);fi
  lastrCmd+=(sel -t)
  if $lbChkExistsOnly;then
    lastrCmd+=(-c)
  else
    lastrCmd+=(-v)
  fi
  lastrCmd+=("${lstrPath}" "${lstrFlXml}")
  
  if $lbChkExistsOnly;then
    if CFGFUNCexec --noErrorExit "${lastrCmd[@]}";then return 0;fi
  else
    #CFGFUNCinfo "EXEC: ${lastrCmd[@]}"
    local lstrResult="`CFGFUNCexec --noErrorExit "${lastrCmd[@]}"`"&&:
    if((`echo "${lstrResult}" |wc -l`!=1));then CFGFUNCerrorExit "invalid result, more than one match found lstrResult='${lstrResult}', ${lstrPath} ${lstrFlXml}";fi
    
    if [[ -n "$lstrResult" ]];then
      echo "$lstrResult"
      return 0
    fi
  fi
  
  return 1
}

function FUNCrecursiveSearchPropertyValue() { # FUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue"
  local lstrBoolAllowProp="";if [[ "$1" == "--boolAllowProp" ]];then shift;lstrBoolAllowProp="$1";shift;fi
  local lstrProp="$1";shift
  local lstrXmlToken="$1";shift
  local lstrItemID="$1";shift
  local lstrFlCfgChkFullPath="$1";shift
  
  declare -g bFRSPV_CanSell_OUT
  declare -g iFRSPV_EcVal_OUT
  declare -g strFRSPV_XmlTokenFound_OUT #to help determine what kind of id is this, in what xml file it is
  declare -g strFRSPV_PreviousItemID
  
  local lstrChkItem="`FUNCidWithoutVariant "$lstrItemID"`"
  local lastrItemInheritPath=("$lstrChkItem")
  local lstrParent=""
  while [[ -n "$lstrChkItem" ]];do # recursively look for lstrProp at extended parents
    #if xmlstarlet -q sel -t -c "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
    if FUNCxmlstarletSel --chk "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
      strFRSPV_XmlTokenFound_OUT="${lstrXmlToken}"
    else
      return 1
    fi
    
    if [[ "${strFRSPV_PreviousItemID-}" != "$lstrItemID" ]];then
      CFGFUNCinfo "initialize new item: $lstrItemID"
      #strFRSPV_XmlTokenFound_OUT=""
      strFRSPV_PreviousItemID="$lstrItemID"
      bFRSPV_CanSell_OUT=true
      iFRSPV_EcVal_OUT=0
    fi
    
    echo "CHK: ${lstrChkItem} ${lstrFlCfgChkFullPath}"
    
    # check allowed
    #echo FUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"
    local lstrAllowVal="`FUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"`" #like SellableToTrader
    #if((`echo "$lstrAllowVal" |wc -l`!=1));then CFGFUNCerrorExit "invalid result, more than one match found lstrAllowVal='${lstrAllowVal}'";fi
    if [[ -n "$lstrBoolAllowProp" ]] && [[ "`echo ${lstrAllowVal} |tr '[:upper:]' '[:lower:]'`" == "false" ]];then
      bFRSPV_CanSell_OUT=false #even if it cant be sold, it may still have a EconomicValue set, that is good for the calc here
      declare -p bFRSPV_CanSell_OUT
      #break
    fi
    
    # get value
    if iFRSPV_EcVal_OUT="`FUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrProp}']/@value" "${lstrFlCfgChkFullPath}"`";then
      break
    fi
    
    # get parent to check
    #echo FUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"
    if lstrParent="`FUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"`";then
      lstrChkItem="$lstrParent"
      lastrItemInheritPath+=("$lstrChkItem")
    else
      break
    fi
  done
  
  if $bFRSPV_CanSell_OUT;then
    if((iFRSPV_EcVal_OUT>0));then 
      CFGFUNCinfo "${lstrProp}: `echo "${lastrItemInheritPath[@]}"|tr ' ' '>'` ${iFRSPV_EcVal_OUT} ${lstrFlCfgChkFullPath}";
      return 0
    fi
  else
    CFGFUNCinfo "CannotBeSold: ${lstrItemID}";
    return 0
  fi
  
  return 1
}

function FUNCchkNum() {
  if [[ -n "${1-}" ]] && [[ "${1}" =~ ^[0-9]*$ ]] && ((${1}>0));then return 0;fi
  return 1
}

function FUNCprepareBundlePart() {
  local lbIgnTopList="$1";shift
  local lbRnd="$1";shift
  local lstrBundleName="$1";shift
  local lstrBundlePartName="$1";shift
  local lstrIcon="$1";shift
  local lstrColor="$1";shift
  local lbCB="$1";shift
  local lstrBundleDesc="$1";shift
  local lbCheckMissingItemIds="$1";shift
  local lbExpLoss="$1";shift
  local lbOpenOnceOnly="$1";shift
  local lbExternalDK="$1";shift
  local lastrItemAndCountList=("$@")
  
  local lastrOpt=()
  
  local lstrBundleShortName="${lstrBundleName}${lstrBundlePartName}"
  local lstrCvar="iGSKRespawnItemsBundleHelper${lstrBundleShortName}"
  
  if [[ "${lstrBundleName}" =~ .*\ .* ]];then
    echo "ERROR: cant have spaces lstrBundleName='$lstrBundleName'"
    exit 1
  fi
  
  strFUNCprepareBundlePart_BundleID_OUT="GSK${lstrBundleName}${lstrBundlePartName}Bundle"
  astrDKAndDescList+=("${strFUNCprepareBundlePart_BundleID_OUT},\"${strModName}BD:${lstrBundleName} ${lstrBundlePartName}\"")
  
  bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT=false
  strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT=""
  local lstrItems="" lstrCounts="" lstrSep="" lstrSpecifiItemsCode="" liExpDebt=0 liTotItems=0 lstrDkItems=""
  for((i=0;i<${#lastrItemAndCountList[@]};i+=2));do 
    ((liTotItems++))&&:
    if((i>0));then lstrSep=",";fi;
    local lstrItemID="${lastrItemAndCountList[i]}"
    local liItemCount="${lastrItemAndCountList[i+1]}"
    
    lstrItems+="${lstrSep}${lstrItemID}"
    lstrDkItems+="${lstrSep} ${lstrItemID}+${liItemCount}"
    #local lstrParent=""
    #local liEcVal=0
    #local lbCanSell=true
    if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
      iFRSPV_EcVal_OUT="${astrItem1Value2List[${lstrItemID}]-}" #tries the cache
      #if [[ -n "${iFRSPV_EcVal_OUT-}" ]] && [[ "${liItemCount}" =~ ^[0-9]*$ ]] && ((iFRSPV_EcVal_OUT>0));then
      if FUNCchkNum "${iFRSPV_EcVal_OUT}";then
        : #successfully used the cache
      elif [[ "$lstrItemID" =~ ^${strCraftBundlePrefixID} ]];then
        iFRSPV_EcVal_OUT=1 # craft bundles are pseudo temporary items created by this script
      else
        #for lstrFlCfgChkFullPath in "${astrFlCfgChkFullPathList[@]}";do
        local bFoundSomething=false
        for((j=0;j<${#astrXmlToken1VsFile2List[@]};j+=2));do 
          local lstrXmlToken="${astrXmlToken1VsFile2List[j]}"
          local lstrFlCfgChkFullPath="${astrXmlToken1VsFile2List[j+1]}"
          if FUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then # FRSPV
          #if FUNCrecursiveSearchPropertyValue "EconomicValue" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then
            bFoundSomething=true
            break
          fi
        done
        if ! $bFoundSomething;then 
          CFGFUNCinfo "WARN: nothing found for lstrItemID='$lstrItemID'";
          #bFRSPV_CanSell_OUT=true
        fi
        #lbCanSell="${bFRSPV_CanSell_OUT}"
        #liEcVal="${iFRSPV_EcVal_OUT}"
        #if $lbCanSell && [[ -z "$liEcVal" ]];then CFGFUNCerrorExit "Can be sold but missing economic value for lstrItemID='${lstrItemID}'";fi
        if ! $bFoundSomething || $bFRSPV_CanSell_OUT;then #if nothing was found, the user can enter a value manually too now.
          if ((iFRSPV_EcVal_OUT==0));then
            #if [[ "$lstrItemID" == "modGunScopeSmall" ]];then
              #iFRSPV_EcVal_OUT=378
            #elif [[ "$lstrItemID" == "candleTableLight" ]];then
              #iFRSPV_EcVal_OUT=72
            #else
              CFGFUNCinfo "WARN: Can be sold but missing economic value for lstrItemID='${lstrItemID}'"
              while true;do
                local liItemValueResp;read -p "INPUT: run the game and collect the item '${lstrItemID}' trader value (and paste here) for player lvl 1 w/o trading skills (I think it is like EcoVal/5=playerSellVal*15=traderSellVal or EcoVal=traderSellVal/3 right?):" liItemValueResp&&:
                #if [[ "$liItemValueResp" =~ ^[0-9]*$ ]] && ((liItemValueResp>0));then
                if FUNCchkNum "${liItemValueResp}";then
                  iFRSPV_EcVal_OUT="${liItemValueResp}"
                  iFRSPV_EcVal_OUT=$((iFRSPV_EcVal_OUT*5/15))&&:
                  if CFGFUNCprompt -q "guessed economic value is ${iFRSPV_EcVal_OUT}, is that ok? (if not, put 3x the much you think it should be)";then
                    break
                  fi
                else
                  CFGFUNCinfo "WARN: invalid value '$liItemValueResp' must be positive integer."
                fi
              done
            #if [[ "${strFRSPV_XmlTokenFound_OUT}" == "item_modifier" ]];then
              #CFGFUNCprompt "auto value for ${lstrItemID} 2500"
              #iFRSPV_EcVal_OUT=2500 #help this value is based on prices shown on the trader inventory for player lvl 1 w/o trading skills. it is not an average. No problem it being a high value as will be used just to create a experience debuff.
            #elif [[ "${strFRSPV_XmlTokenFound_OUT}" == "block" ]];then
              #CFGFUNCprompt "auto value for ${lstrItemID} 20"
              #iFRSPV_EcVal_OUT=20 #help this is just to not leave it empty as many blocks (when they have a price) worth almost nothing TODO: create some check for high priced blocks like steel
            #else
            #fi
          fi
        else
          if ((iFRSPV_EcVal_OUT==0));then
            iFRSPV_EcVal_OUT=1 #just to have something
          fi
        fi
        astrItem1Value2List["${lstrItemID}"]=$iFRSPV_EcVal_OUT
        CFGFUNCinfo "NEW: astrItem1Value2List[${lstrItemID}]=${astrItem1Value2List[${lstrItemID}]}"
      fi
    else
      CFGFUNCinfo "WARN: configsdump path not being used, using generic value, not good tho..."
      ((liExpDebt+=100))&&:
    fi
    
    if ! [[ "${liItemCount}" =~ ^[0-9]*$ ]];then CFGFUNCerrorExit "invalid liItemCount='${liItemCount-}', should be a positive integer";fi
    if((iFRSPV_EcVal_OUT>0));then
      (( liExpDebt+=(iFRSPV_EcVal_OUT*liItemCount) ))&&:
    else
      #(( liExpDebt+=(liItemCount/10) ))&&:
      (( liExpDebt+=liItemCount ))&&:
    fi
    lstrCounts+="$lstrSep${liItemCount}";
    #echo "          ${lstrItemID} ${liItemCount}"
    FUNCprepareBundlePart_specificItemsChk_MULTIPLEOUTPUTVALUES "$lbCheckMissingItemIds" "${lstrItemID}"
    lstrSpecifiItemsCode+="${strFUNCprepareBundlePart_specificItemsChk_AddCode_OUT}"
    #if [[ "${lstrBundleDesc:0:2}" != "dk" ]];then
      #if [[ -n "${strFUNCspecificItemsCode_AddDesc}" ]];then
        #: 
      #fi
    #fi
  done;
  
  if $lbExpLoss;then 
    if $lbRnd;then # the random option is to choose one from many, so it will be the average value of all the items in the bundle
      ((liExpDebt/=liTotItems))&&:
    fi
  else
    liExpDebt=1;
  fi
  
  local lstrAddDesc=""
  if $bFUNCprepareBundlePart_specificItemsChk_HasDmgDevs_OUT;then
    lstrAddDesc+=" Obs.: Some of these equipment or devices are severely damaged and wont last long w/o repairs."
  fi
  
  #strDK=""
  #astrDescriptionKeyList+=()
  #dkGSKstartNewGameItemsBundle
  local lstrOpenOnceOnly=""
  local lstrType=""
  if [[ "$lstrBundlePartName" == "$strSchematics" ]];then
    #lstrIcon="bundleBooks"
    lstrType='<property name="ItemTypeIcon" value="book" />'
    #astrBundlesSchematics+=("$strFUNCprepareBundlePart_BundleID_OUT" 1)
    lastrOpt+=(--lightcolor)
    lastrOpt+=(--schematic)
    lstrOpenOnceOnly=" (This bundle can only be opened ONCE!)"
    #((liExpDebt*=5))&&:
  else
    if ! $lbIgnTopList;then
      astrBundlesItemsLeastLastOne+=("$strFUNCprepareBundlePart_BundleID_OUT" 1)
    fi
    #astrCBItemsLeastLastOne
  fi
  if [[ -z "${lstrIcon}" ]];then
    lstrIcon="cntStorageGeneric"
  fi
  if $lbOpenOnceOnly;then # not adding the lbOpenOnceOnly bundles will make it more difficult because reaching max exp debit will happen faster. Also the lbOpenOnceOnly items are only once and make no sense anyway to be part of the sum for bundles that can be opened many times.
    lstrOpenOnceOnly=" (This bundle can only be opened ONCE!)"
  else
    ((iAllFreeBundlesSumExpDebit+=liExpDebt))&&:
  fi
  
  local lstrBundleCountID="i${strFUNCprepareBundlePart_BundleID_OUT}Count"
  local lstrBundleDK="dk${strFUNCprepareBundlePart_BundleID_OUT}"
  #if $lbExternalDK;then
    #lstrBundleDesc="$lstrBundleDK" #todo this is a bit confusing, improve it
  #fi
  if [[ "${lstrBundleDesc:0:2}" == "dk" ]];then #NO... the description is static at Localization.txt
    #lstrBundleDK="$lstrBundleDesc"
    CFGFUNCerrorExit "lstrBundleDesc='${lstrBundleDesc}' code gets too confusing, not supported anymore... put the description on this script or cfg instead of just saying it is at the Localization.txt by starting it with 'dk'."
  fi
  #else #dynamic description
  if ! $lbExternalDK;then
    astrDKAndDescList+=("${lstrBundleDK},\"${lstrBundleDesc}\n Experience Penalty when opening this bundle${lstrOpenOnceOnly}(Remaining open count {cvar(${lstrCvar}:0)}): ${liExpDebt}*({cvar(${lstrBundleCountID}:0)}+1)/{cvar(fGSKAllFreeBundlesSumExpDebit:0)}\n ${strExpLossInfo}\n ${lstrDkItems}\n ${lstrAddDesc}\"")
  fi
  #fi
  #if [[ -n "$lstrAddDesc" ]] && [[ "${lstrBundleDesc:0:2}" == "dk" ]];then
    #if ! CFGFUNCprompt -q "has external bundle description '$lstrBundleDesc' and also has added description '$lstrAddDesc' that will be lost! ignore this now?";then
       #CFGFUNCerrorExit "ugh..."
    #fi
  #fi
  
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
        #<property name="Create_item" help="it has '"$((${#lastrItemAndCountList[@]}/2))"' diff items" value="'"${lstrItems}"'" />
    echo '
        <property name="Create_item" help="it has '"${liTotItems}"' diff items" value="'"${lstrItems}"'" />
        <property name="Create_item_count" value="'"${lstrCounts}"'" />' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  fi
  echo '
      </property>'"${lstrSpecifiItemsCode}"'
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="GiveExp" exp="-'"${liExpDebt}"'" help="this could work but does not actually work tho, so using the fGSKExpDebt workaround"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="'"${lstrBundleCountID}"'" operation="add" value="1" help="as default cvar value is 0, first is 100%, 2nd 200% ..."/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".fGSKExpDebtBundleTmp" operation="set" value="'"${liExpDebt}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar=".fGSKExpDebtBundleTmp" operation="multiply" value="@'"${lstrBundleCountID}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKExpDebt" operation="add" value="@.fGSKExpDebtBundleTmp"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKExpDebtMaxAllTime" operation="add" value="'"${liExpDebt}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="CVarLogValue" cvar="fGSKExpDebt"/>
      </effect_group>
    </item>' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  
  if $lbCB;then
    FUNCprepareCraftBundle ${lastrOpt[*]} "$lbIgnTopList" "${strFUNCprepareBundlePart_BundleID_OUT}" "${lstrBundleShortName}" "${lstrIcon}" "${lstrType}" "${liExpDebt}" "${lbOpenOnceOnly}" "${lstrBundleDK}" "${lstrCvar}"
  fi
}

function FUNCprepareBundles() {
  local lbRnd=false
  local lbCB=true
  local lstrColor="192,192,192"
  local lbIgnTopList=false
  local lbCheckMissingItemIds=true
  local lbExpLoss=true
  local lbOpenOnceOnly=false
  local lbExternalDK=false
  while [[ "${1:0:2}" == "--" ]];do
    if [[ "$1" == --ExternalDK ]];then shift;lbExternalDK=true;fi
    if [[ "$1" == --ignoreTopList ]];then shift;lbIgnTopList=true;fi
    if [[ "$1" == --choseRandom ]];then shift;lbRnd=true;fi
    if [[ "$1" == --noCB ]];then shift;lbCB=false;fi
    if [[ "$1" == --color ]];then shift;lstrColor="$1";shift;fi #help <lstrColor>
    if [[ "$1" == --noCheckMissingItemIds ]];then shift;lbCheckMissingItemIds=false;fi #help <lstrColor>
    if [[ "$1" == --noExpLoss ]];then shift;lbExpLoss=false;fi
    if [[ "$1" == --openOnceOnly ]];then lbOpenOnceOnly=true;shift;fi
  done
  
  local lstrBundleName="$1";shift
  local lstrIcon="$1";shift
  local lstrBundleDesc="$1";shift
  local lastrItemAndCountList=("$@")
  
  local lastrParams=("$lstrIcon" "$lstrColor" "$lbCB" "$lstrBundleDesc" "$lbCheckMissingItemIds" "$lbExpLoss" "$lbOpenOnceOnly" "$lbExternalDK")
  
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
  if [[ -n "$strNextPartName" ]] && ((${#lastrItemAndCountListPart[*]}>0));then # the 2nd part of the list is for schematics currently
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

strExploringBase="Use this if you think exploring the world is unreasonably difficult (there is no vehicle in it tho).\n"
astr=(
  casinoCoin 666
  foodRawMeat 1 #for dog companion
  GSKspawnDogCompanion 1
  GSKCFGNPCproperSneakingWorkaround 1
  vehicleGSKNPChelperPlaceable 1
  GSKNPCHiredHeals30perc 13
  GSKNPCHiredHeals180perc 1
  GSKNPCHiredGetsPowerArmor 1
  RepairNPCArmor 6
  NPCPreventDismiss60s 3
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "ExploringNPC" "bundleVehicle4x4" "${strExploringBase}Use this if you want a friendly hand (or paw)." "${astr[@]}"
astr=(
  apparelNightvisionGoggles 1
  GlowStickGreen       33
  GSKfireFuel 13
  meleeToolFlashlight02 1
  meleeToolTorch 1
  NightVisionBattery    66
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  modArmorHelmetLightSchematic 1
  modGunFlashlightSchematic 1
);FUNCprepareBundles "ExploringVisibility" "bundleVehicle4x4" "${strExploringBase}This helps on seeing the world." "${astr[@]}"
astr=(
  bedrollBlue 33 #cant be directly scrapped
  "cobblestoneShapes:VariantHelper" 66 #for the tiny fortress trick
  drinkJarBoiledWater 33 #for the desert
  drugGSKPsyonicsResist 13 #to be able to ignore mutants
  drugSteroids  13
  GSKsimpleBeer        33
  ladderWood            66
  RepairColdProt 13 #w/o this you wont go far overheating or freezing
  RepairHeatProt 13
  resourceCloth 33 #to help fix cold/heat protection cloths, and create bandana etc
  resourceRockSmall    222 #to lure mobs away
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  vehicleBicycleChassisSchematic 1
  vehicleBicycleHandlebarsSchematic 1
  vehicleGSKNPChelperPlaceable 1
);FUNCprepareBundles "ExploringMobility" "bundleVehicle4x4" "${strExploringBase}This helps on moving thru the world." "${astr[@]}"
astr=(
  drinkCanEmptyCookingOneUse 33
  drugJailBreakers 3
  #meleeWpnSpearT0StoneSpear 1
  resourceDuctTape 1
  resourceMechanicalParts 1
  resourceFeather        1
  resourceLockPick 1
  resourceWood         66
  resourceYuccaFibers  33
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "ExploringETC" "bundleVehicle4x4" "${strExploringBase}This have a few other things to help open locked containers, cooking, etc" "${astr[@]}"

astr=( #TEMPLATE
  ammo9mmBulletBall $((666*3)) # this is a good amount to let the player be able to explore a bit and find something useful to help on continue surviving
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
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "CombatArmor" "bundleArmorLight" "$strCombatArmorHelp" "${astr[@]}"

astr=(
  GSKElctrnTeleportToBiomeFreeAndSafeCall 1
  GSKteleToBackpackFreeAndSafeCall 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "TeleportHelpers" "bundleBatteryBank" "Use this if you want to relocate thru the world." "${astr[@]}"

# these are already on the player inventory from entity_classes.xml
#astr=(
  #GSKElctrnTeleportUndergroundFreeAndSafeCall 1 #this is meant only for the first time the player joins the game, to give time to read understand the new things of it. Allowing more will let the player tele underground just before bloodmoons making it too easy to survive.
  #GSKCFGTeleUndergroundFreeDelay 1 #for GSKElctrnTeleportUndergroundFreeAndSafeCall
  #"$strSCHEMATICS_BEGIN_TOKEN" 0
#);FUNCprepareBundles --openOnceOnly --color "220,148,128" "TeleHelp1stSpawn" "bundleBatteryBank" "Use this if it is the first time you join The NoMad world." "${astr[@]}"

astr=(
  ammoJunkTurretRegular 666
  armorClothHat 1 # this is to be able to install one of the mods
  drugOhShitzDrops 1 # just in case the auto protection doesnt kick in..
  gunBotT2JunkTurret 1
  GSKNoteElctrnTeleporToSkyFirstTime 1
  #GSKElctrnTeleportDirection 1
  #GSKElctrnTeleportToSky 1
  modGSKEnergyThorns     1
  #modGSKElctrnTeleport 1
  NightVisionBattery    13
  #NightVisionBatteryStrong 2 #uneccessarry now, tele to sky will just make energy negative and will work.
  NVBatteryCreate 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  batterybankSchematic 1
  bookTechJunkie5Repulsor 1
  generatorbankSchematic 1
  gunBotT2JunkTurretSchematic 1
);FUNCprepareBundles "ElctrnEnergy" "bundleBatteryBank" "Use this if you want to start using and crafting Elctrn mods, this will increase your combat survival chances." "${astr[@]}"

#astr=(
  #bucketRiverWater 1
  #drinkJarGrandpasMoonshine 1
  #drinkJarPureMineralWater 2
  #drinkJarBoiledWater 13
  #drugAntibiotics 4
  #drugPainkillers 1
  #drugVitamins 1
  #foodHoney 1
  #drugGSKAntiRadiation 13
  #drugGSKAntiRadiationSlow 13
  #drugGSKAntiRadiationStrong 13
  #drugGSKPsyonicsResist 13
  #drugGSKRadiationResist 13
  #drugGSKsnakePoisonAntidote 3
  #medicalBloodBag 13
  #medicalBloodBagEmpty 9
  #medicalFirstAidBandage 13
  #medicalSplint 3
  #potionRespec 1
  #resourceSewingKit 1
  #toolBeaker 1
  #treePlantedMountainPine1m 13
  #foodSpaghetti 1
  #"$strSCHEMATICS_BEGIN_TOKEN" 0
  ##bookWasteTreasuresWater 1
  #bookWasteTreasuresHoney 1 #because it is cool
  #drinkJarGoldenRodTeaSchematic 1 #for disyntery
  #drugAntibioticsSchematic 1 #because it is part of the health treatment and foodShamSandwich is very rare so when found will be cool
  #drugHerbalAntibioticsSchematic 1
  #foodBoiledMeatBundleSchematic 1
  #foodBoiledMeatSchematic 1
  #modArmorWaterPurifierSchematic 1
#);FUNCprepareBundles "Healing" "bundleFood" "Use this if you have not managed to heal yourself yet or is having trouble doing that or has any disease or infection and is almost dieing, don't wait too much tho!" "${astr[@]}"
astr=(
  #HealingHarm
  drinkJarPureMineralWater 2
  drugPainkillers 1
  drugVitamins 1
  drugAntibiotics 4
  #drugGSKPsyonicsResist 13
  drugGSKsnakePoisonAntidote 3
  foodHoney 1
  medicalSplint 3
  resourceSewingKit 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  #bookWasteTreasuresWater 1
  bookWasteTreasuresHoney 1 #because it is cool
  drinkJarGoldenRodTeaSchematic 1 #for disyntery
  drugAntibioticsSchematic 1 #because it is part of the health treatment and foodShamSandwich is very rare so when found will be cool
  drugHerbalAntibioticsSchematic 1
);FUNCprepareBundles "HealingHarm" "bundleFood" "Use this if you have any disease or infection and is almost dieing, don't wait too much tho!" "${astr[@]}"
astr=(
  #HealingRads
  drugGSKAntiRadiation 13
  drugGSKAntiRadiationSlow 13
  drugGSKAntiRadiationStrong 13
  drugGSKRadiationResist 13
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "HealingRads" "bundleFood" "Use this if you are having trouble dealing with radiation." "${astr[@]}"
astr=(
  #HealingFeed
  drinkJarBoiledWater 13
  treePlantedMountainPine1m 13
  foodSpaghetti 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  modArmorWaterPurifierSchematic 1
);FUNCprepareBundles "HealingFeed" "bundleFood" "Use this if you need food and water." "${astr[@]}"
astr=(
  #HealingHP
  medicalBloodBag 13
  medicalBloodBagEmpty 9
  drinkJarGrandpasMoonshine 1
  medicalFirstAidBandage 13
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  foodBoiledMeatBundleSchematic 1
  #foodBoiledMeatSchematic 1
);FUNCprepareBundles "HealingHP" "bundleFood" "Use this if you have not managed to heal yourself yet or is having trouble doing that, don't wait too much tho!" "${astr[@]}"
astr=(
  #HealingCraft
  bucketRiverWater 1
  toolBeaker 1
  potionRespec 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "HealingCraft" "bundleFood" "Use this if you want to craft or redistribute skill points." "${astr[@]}"

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
  candleTableLightPlayer 1
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
  NOTE_LostTribe 1
  qt_taylor 1
  qt_nickole 1
  qt_stephan 1
  qt_jennifer 1
  qt_claude 1
  qt_sarah 1
  qt_raphael 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --openOnceOnly --color "166,148,128" "Maps" "bundleBooks" "My tribe is gone, what will I do now.." "${astr[@]}"

#########################################################################################
#########################################################################################
###################################### KEEP AS LAST ONES!!! ##############################
#########################################################################################
#########################################################################################
astr=(
  "${astrBundlesSchematics[@]}" # these are the bundles of schematics, not schematics themselves so they must be in the astrBundlesItemsLeastLastOne list
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --noExpLoss "SomeSchematicBundles" "bundleBooks" "Open this to get some schematics bundles related to the item's bundles." "${astr[@]}"
#);FUNCprepareBundles --noCheckMissingItemIds "SomeSchematicBundles" "bundleBooks" "Open this to get some schematics bundles related to the item's bundles." "${astr[@]}"

astr=(
  # notes
  GSKTRNotesBundle 1 #from createNotesTips.sh
  NOTE_GSKTheNoMadCreateRespawnBundleList 1
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
);FUNCprepareBundles --noExpLoss --noCB --ExternalDK "$strModNameForIDs" "cntStorageGeneric" "DUMMY_DESC_IGNORED" "${astr[@]}"
#);FUNCprepareBundles --noCheckMissingItemIds --noCB "$strModNameForIDs" "cntStorageGeneric" --ExternalDK "${astr[@]}"

#############################################
echo "#PREPARE_RELEASE:REVIEWED:OK" >"$strFlItemEconomicValueCACHE"
echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"$strFlItemEconomicValueCACHE"
declare -p astrItem1Value2List >>"$strFlItemEconomicValueCACHE"

################## DESCRIPTIONS ####################
echo
for strDKAndDesc in "${astrDKAndDescList[@]}";do
  echo "${strDKAndDesc}" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done

############ APPLY CHANGES AT SECTIONS ################
#ls -l *"${strGenTmpSuffix}"&&:
CFGFUNCgencodeApply "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
CFGFUNCgencodeApply "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

# CRAFT BUNDLES SECTIONS
strSubToken="CRAFTBUNDLES"

echo "$strXmlCraftBundleCreateItemsXml"   >"${strFlGenIte}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "${strSubToken}" "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

echo "$strXmlCraftBundleCreateRecipesXml" >"${strFlGenRec}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "${strSubToken}" "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

echo "$strXmlCraftBundleCreateBuffsXml"   >"${strFlGenBuf}${strGenTmpSuffix}"
CFGFUNCgencodeApply --subTokenId "${strSubToken}" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"

strDKCraftAvailableBundles+='"' #closes the prepared description text
echo "$strDKCraftAvailableBundles"        >"${strFlGenLoc}${strGenTmpSuffix}"
for strDKCraftBundleName in "${astrCraftBundleNameList[@]}";do
  echo "$strDKCraftBundleName" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done
CFGFUNCgencodeApply --subTokenId "${strSubToken}" "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"

CFGFUNCgencodeApply --xmlcfg \
  fGSKAllFreeBundlesSumExpDebit "${iAllFreeBundlesSumExpDebit}"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles

CFGFUNCwriteTotalScriptTimeOnSuccess
