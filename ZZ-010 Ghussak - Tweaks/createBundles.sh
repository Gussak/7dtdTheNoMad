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
#set -x
#declare -p CFGastrFlCfgChkList CFGstrFlCfgChkRegex CFGastrFlCfgChkFullPathList CFGastrXmlToken1VsFile2List;exit

strCraftBundlePrefixID="GSK${strModNameForIDs}CreateRespawnBundle"

strPartToken="_TOKEN_NEWPART_MARKER_"
strSchematics="Schematics"
strSCHEMATICS_BEGIN_TOKEN="${strPartToken}:${strSchematics}"
strExpLossInfo="CurrentExpLoss: {cvar(.fGSKExpDebtPercx100:0)}%\n CurrentExpDebit: {cvar(fGSKExpDebt:0.00)}/{cvar(fGSKAllFreeBundlesSumExpDebit:0)}\n RealTimeHoursRemainingToEndExpLoss: {cvar(.fGSKExpDebtTmRemain:0.0)}\nOpening free bundles that increase exp loss beyond the maximum will only increase the remaining time."
astrDKAndDescList=("dkGSKFreeBundleExpLossInfo_NOTE,\"${strExpLossInfo}\"")
astrBundlesItemsLeastLastOne=()
astrBundlesSchematics=()

iCallCourierEnergyReq=10

iAllFreeBundlesSumExpDebit=0

# sub sections
strXmlCraftBundleCreateItemsXml=""
strXmlCraftBundleCreateRecipesXml=""
strXmlCraftBundleCreateBuffsXml=""
strDKCraftAvailableBundles=""
astrCraftBundleNameList=()

## these files at astrFlCfgChkFullPathList are to be queried for useful data
#CFGastrFlCfgChkList=(block item item_modifier)
#CFGstrFlCfgChkRegex="`echo "${astrFlCfgChkList[@]}" |tr ' ' '|'`"
#CFGastrFlCfgChkFullPathList=()
#CFGastrXmlToken1VsFile2List=() # key value
#for strFlCfgChk in "${astrFlCfgChkList[@]}";do
  #strFlRelatModCfgXml="Config/${strFlCfgChk}s.xml"
  #CFGastrFlCfgChkFullPathList+=("${strFlRelatModCfgXml}") # this is the xml modlet file on this mod's folder
  #CFGastrXmlToken1VsFile2List+=("$strFlCfgChk" "${strFlRelatModCfgXml}")
  #if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
    #strFlXmlFinalChk="${strCFGNewestSavePathConfigsDumpIgnorable}/${strFlCfgChk}s.xml"
    #CFGastrFlCfgChkFullPathList+=("$strFlXmlFinalChk") # this is the xml final dump of the last save
    #CFGastrXmlToken1VsFile2List+=("$strFlCfgChk" "$strFlXmlFinalChk")
  #fi
#done #for strFlCfgChkFullPath in "${astrFlCfgChkFullPathList[@]}";do
declare -p CFGastrXmlToken1VsFile2List |tr '[' '\n'

#function CFGFUNCloadCaches() {
  ## ItemEconomicValue
  #declare -Agx astrItem1Value2List
  #declare -gx CFGstrFlItemEconomicValueCACHE="cache.ItemEconomicValue.sh" #help if you delete the cache file it will be recreated
  ##if [[ -f "${CFGstrFlItemEconomicValueCACHE}" ]];then source "${CFGstrFlItemEconomicValueCACHE}";fi
  #source "${CFGstrFlItemEconomicValueCACHE}"&&:
  ## checks
  #strIVChk="`declare -p astrItem1Value2List |tr '[' '\n' |egrep -v "^ *$" |egrep -v "${strCraftBundlePrefixID}" |sort -u`"
  #echo "$strIVChk" |egrep '="1"' >&2 &&: # just to check if they should really be value 1
  #if((`echo "$strIVChk" |egrep '="0*"' |wc -l`>0));then # matches "" or "0"
    #echo "$strIVChk" >&2
    #CFGFUNCprompt "there are the above entries that could be improved (at least EconomicValue 1)" #let/wait user know about it
  #fi
  
  ## OUTPUT all caches
  #echo "`declare -p astrItem1Value2List CFGstrFlItemEconomicValueCACHE`"
#};export -f CFGFUNCloadCaches
eval "`CFGFUNCloadCaches`"
#declare -p astrItem1Value2List 
#declare -p CFGstrFlItemEconomicValueCACHE
#declare -p CFGastrItem1Value2List
#CFGFUNCwriteCaches
#echo "${#CFGastrItem1Value2List[@]}"
#CFGastrItem1Value2List["TstRmMeuaua"]=123
#echo "${#CFGastrItem1Value2List[@]}"
#declare -p CFGastrItem1Value2List
#CFGFUNCwriteCaches
#exit

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
  local lstrCB="'CB:' items are craftable freely (can be dropped). Don't rush to your backpack. Each bundle has (exp penalty). Resurrecting adds 1 to remaining bundles (least a few like schematics, maps..) that you can open (up to {cvar(iGSKFreeBundlesRemaining:0)} now. (See *Delivery notes). "
  strFUNCprepareCraftBundle_CraftBundleID_OUT="${strCraftBundlePrefixID}${lstrBundleShortName}"
  strCourier="`CFGFUNCcourier ${liExpDebt} 1000 3000`"
  strXmlCraftBundleCreateItemsXml+='
    <!-- HELPGOOD:Respawn:CreateBundle:'"${lstrBundleID}"' -->
    <item name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" help="on death free items helper">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />'"${lstrType}"'
      <property name="CustomIconTint" value="'"${lstrColor}"'" />
      <property name="DescriptionKey" value="'"${lstrBundleDK}"'" />
      <property class="Action0">
        <requirement name="!IsBloodMoon"/>
        <requirement name="CVarCompare" cvar="iGSKPlayerNPCNonHireableNearby" operation="LT" value="@.iGSKMaxCouriersNearby"/>
        <requirement name="CVarCompare" cvar="'"${lstrCvar}"'" operation="GT" value="0" />
        <requirement name="CVarCompare" cvar="iGSKBatteryCharges" operation="GTE" value="'"${iCallCourierEnergyReq}"'" />
        <property name="Create_item" value="'"${lstrBundleID}"'" />
        <property name="Create_item_count" value="1" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="iGSKBatteryCharges" operation="subtract" value="'"${iCallCourierEnergyReq}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="add" value="-1"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="CallGameEvent" event="'"${strCourier}"'" help="COURIER_DELIVERY"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="iGSKNPCCourierForPlayerEntId" operation="set" value="@EntityID" target="selfAOE" range="5" help="TODO: the player can set a @var on NPCs? or only constant values? so this wont right?">
          <requirement name="CVarCompare" cvar="iGSKNPCCourierForPlayerEntId" target="other" operation="Equals" value="0" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ShowToolbeltMessage" message="[TNM] A courier brings the package to you."/>
      </effect_group>
    </item>'
  strXmlCraftBundleCreateRecipesXml+='
    <recipe name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" count="1"><ingredient name="electronicsParts" count="1"/></recipe>
    <recipe name="electronicsParts" count="1"><ingredient name="'"${strFUNCprepareCraftBundle_CraftBundleID_OUT}"'" count="1"/></recipe>'
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

#function FUNCidWithoutVariant() {
  #echo "${1}" |cut -d: -f1 #TODO check for the "VariantHelper" string if it is valid like in "cobblestoneShapes:VariantHelper"
#}

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
    local lstrChkItemId="`CFGFUNCidWithoutVariant "${strItemID}"`"
    if ! egrep '< *('"${CFGstrFlCfgChkRegex}"') *name *= *"'"${lstrChkItemId}"'"' "${CFGastrFlCfgChkFullPathList[@]}" -inw;then CFGFUNCerrorExit "item id lstrChkItemId='${lstrChkItemId}' is missing (or was changed): strItemID='${strItemID}'. try: egrep 'TypePreviousIdHere' * -iRnI --include=\"*.xml\"";fi
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

#function FUNCxmlstarletSel() {
  #local lbChkExistsOnly=false;if [[ "$1" == --chk ]];then shift;lbChkExistsOnly=true;fi
  #local lstrPath="$1";shift
  #local lstrFlXml="$1";shift
  
  #local lastrCmd=(xmlstarlet)
  #if $lbChkExistsOnly;then lastrCmd+=(-q);fi
  #lastrCmd+=(sel -t)
  #if $lbChkExistsOnly;then
    #lastrCmd+=(-c)
  #else
    #lastrCmd+=(-v)
  #fi
  #lastrCmd+=("${lstrPath}" "${lstrFlXml}")
  
  #if $lbChkExistsOnly;then
    #if CFGFUNCexec --noErrorExit "${lastrCmd[@]}";then return 0;fi
  #else
    ##CFGFUNCinfo "EXEC: ${lastrCmd[@]}"
    #local lstrResult="`CFGFUNCexec --noErrorExit "${lastrCmd[@]}"`"&&:
    #if((`echo "${lstrResult}" |wc -l`!=1));then CFGFUNCerrorExit "invalid result, more than one match found lstrResult='${lstrResult}', ${lstrPath} ${lstrFlXml}";fi
    
    #if [[ -n "$lstrResult" ]];then
      #echo "$lstrResult"
      #return 0
    #fi
  #fi
  
  #return 1
#}

#function FUNCrecursiveSearchPropertyValue() { # FUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue"
  #local lstrBoolAllowProp="";if [[ "$1" == "--boolAllowProp" ]];then shift;lstrBoolAllowProp="$1";shift;fi
  #local lstrProp="$1";shift
  #local lstrXmlToken="$1";shift
  #local lstrItemID="$1";shift
  #local lstrFlCfgChkFullPath="$1";shift
  
  #declare -g bFRSPV_CanSell_OUT
  #declare -g iFRSPV_PropVal_OUT
  #declare -g strFRSPV_XmlTokenFound_OUT #to help determine what kind of id is this, in what xml file it is
  #declare -g strFRSPV_PreviousItemID
  
  #local lstrChkItem="`CFGFUNCidWithoutVariant "$lstrItemID"`"
  #local lastrItemInheritPath=("$lstrChkItem")
  #local lstrParent=""
  #while [[ -n "$lstrChkItem" ]];do # recursively look for lstrProp at extended parents
    ##if xmlstarlet -q sel -t -c "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
    #if CFGFUNCxmlstarletSel --chk "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
      #strFRSPV_XmlTokenFound_OUT="${lstrXmlToken}"
    #else
      #return 1
    #fi
    
    #if [[ "${strFRSPV_PreviousItemID-}" != "$lstrItemID" ]];then
      #CFGFUNCinfo "initialize new item: $lstrItemID"
      ##strFRSPV_XmlTokenFound_OUT=""
      #strFRSPV_PreviousItemID="$lstrItemID"
      #bFRSPV_CanSell_OUT=true
      #iFRSPV_PropVal_OUT=0
    #fi
    
    #echo "CHK: ${lstrChkItem} ${lstrFlCfgChkFullPath}"
    
    ## check allowed
    ##echo CFGFUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"
    #local lstrAllowVal="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"`" #like SellableToTrader
    ##if((`echo "$lstrAllowVal" |wc -l`!=1));then CFGFUNCerrorExit "invalid result, more than one match found lstrAllowVal='${lstrAllowVal}'";fi
    #if [[ -n "$lstrBoolAllowProp" ]] && [[ "`echo ${lstrAllowVal} |tr '[:upper:]' '[:lower:]'`" == "false" ]];then
      #bFRSPV_CanSell_OUT=false #even if it cant be sold, it may still have a EconomicValue set, that is good for the calc here
      #declare -p bFRSPV_CanSell_OUT
      ##break
    #fi
    
    ## get value
    #if iFRSPV_PropVal_OUT="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrProp}']/@value" "${lstrFlCfgChkFullPath}"`";then
      #break
    #fi
    
    ## get parent to check
    ##echo CFGFUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"
    #if lstrParent="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"`";then
      #lstrChkItem="$lstrParent"
      #lastrItemInheritPath+=("$lstrChkItem")
    #else
      #break
    #fi
  #done
  
  #if $bFRSPV_CanSell_OUT;then
    #if((iFRSPV_PropVal_OUT>0));then 
      #CFGFUNCinfo "${lstrProp}: `echo "${lastrItemInheritPath[@]}"|tr ' ' '>'` ${iFRSPV_PropVal_OUT} ${lstrFlCfgChkFullPath}";
      #return 0
    #fi
  #else
    #CFGFUNCinfo "CannotBeSold: ${lstrItemID}";
    #return 0
  #fi
  
  #return 1
#}

#function CFGFUNCchkNumGT0() {
  #if [[ -n "${1-}" ]] && [[ "${1}" =~ ^[0-9]*$ ]] && ((${1}>0));then return 0;fi
  #return 1
#}

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
    local liEconomicValue=0
    #local lbCanSell=true
    if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
      liEconomicValue="${CFGastrItem1Value2List[${lstrItemID}]-0}" #tries the cache. 0 is an indicator that there is no cache
      #if [[ -n "${liEconomicValue-}" ]] && [[ "${liItemCount}" =~ ^[0-9]*$ ]] && ((liEconomicValue>0));then
      if CFGFUNCchkNumGT0 "${liEconomicValue}";then
        : #successfully used the cache
      elif [[ "$lstrItemID" =~ ^${strCraftBundlePrefixID} ]];then
        liEconomicValue=1 # craft bundles are pseudo temporary items created by this script
      else
        #for lstrFlCfgChkFullPath in "${CFGastrFlCfgChkFullPathList[@]}";do
        #local bFoundSomething=false
        #for((j=0;j<${#CFGastrXmlToken1VsFile2List[@]};j+=2));do 
          #local lstrXmlToken="${CFGastrXmlToken1VsFile2List[j]}"
          #local lstrFlCfgChkFullPath="${CFGastrXmlToken1VsFile2List[j+1]}"
          #if CFGFUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then # FRSPV
          ##if CFGFUNCrecursiveSearchPropertyValue "EconomicValue" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then
            #bFoundSomething=true
            #break
          #fi
        #done
        #if ! $bFoundSomething;then 
          #CFGFUNCinfo "WARN: nothing found for lstrItemID='$lstrItemID'";
          ##bFRSPV_CanSell_OUT=true
        #fi
        local bFoundSomething=false;
        if CFGFUNCrecursiveSearchPropertyValueAllFiles --boolAllowProp "SellableToTrader" "EconomicValue" "$lstrItemID";then
          bFoundSomething=true; #the economic  value for items with tier is like item tier4, but the free bundles will only create tier1 items, so they end up overpriced, but that is good to increase the challenge.
          liEconomicValue="$iFRSPV_PropVal_OUT";
        else
          liEconomicValue=-1 #this means the item cannot be sold or no inherited value could be found
        fi 
        
        #lbCanSell="${bFRSPV_CanSell_OUT}"
        #liEconomicValue="${iFRSPV_PropVal_OUT}"
        #if $lbCanSell && [[ -z "$liEconomicValue" ]];then CFGFUNCerrorExit "Can be sold but missing economic value for lstrItemID='${lstrItemID}'";fi
        if $bFoundSomething;then
          if ((liEconomicValue==0));then # if found but value is 0. -1 means cannot be sold and have other uses on other scripts
            liEconomicValue=1 #just to have some value
          fi
        else
          if $bFRSPV_CanSell_OUT && ((liEconomicValue==0 || liEconomicValue==-1));then #if nothing was found, the user can enter a value manually too now.
            CFGFUNCinfo "WARN: Can be sold. But it is missing economic value for lstrItemID='${lstrItemID}' liEconomicValue='$liEconomicValue'"
            while true;do
              #local liItemValueResp;read -p "INPUT: run the game and collect the item '${lstrItemID}' trader value (and paste here) for player lvl 1 w/o trading skills (I think price is like EcoVal/5=playerSellVal*15=traderSellVal or EcoVal=traderSellVal/3 right?):" liItemValueResp&&:
              local liItemValueResp;read -p "INPUT: Start a new game. Add to your inventory item '${lstrItemID}'. If the item has tiers, collect the sell price for tier4. If the item has no tiers (like gun mods), collect the trader sell price for it. So, the player must be  lvl 1 w/o any trading bonuses (just after you enter the game the 1st time and w/o any skills or other bonuses from consumables or equipment) (I think price is like +- sellValue=itemTier4SellValue=EconomicValue. sellValue*15=traderSellValue (right?):" liItemValueResp&&:
              #if [[ "$liItemValueResp" =~ ^[0-9]*$ ]] && ((liItemValueResp>0));then
              if CFGFUNCchkNumGT0 "${liItemValueResp}";then
                liEconomicValue="$liItemValueResp" #this is a player override
                #liEconomicValue="$((liItemValueResp/15))"
                #liEconomicValue=$((liEconomicValue*5/15))&&:
                if CFGFUNCprompt -q "economic value for '${lstrItemID}' will be ${liEconomicValue}, is that ok?";then
                  break
                fi
              else
                CFGFUNCinfo "WARN: invalid value '$liItemValueResp' must be positive integer."
              fi
            done
          fi
        fi
        CFGastrItem1Value2List["${lstrItemID}"]=$liEconomicValue
        CFGFUNCinfo "NEW: CFGastrItem1Value2List[${lstrItemID}]=${CFGastrItem1Value2List[${lstrItemID}]}"
      fi
    else
      CFGFUNCinfo "WARN: configsdump path not being used, using generic value, not good tho..."
      ((liExpDebt+=100))&&:
    fi
    
    if ! [[ "${liItemCount}" =~ ^[0-9]*$ ]];then CFGFUNCerrorExit "invalid liItemCount='${liItemCount-}', should be a positive integer";fi
    if((liEconomicValue>0));then
      (( liExpDebt+=(liEconomicValue*liItemCount) ))&&:
    else
      #(( liExpDebt+=(liItemCount/10) ))&&:
      (( liExpDebt+=liItemCount ))&&: #if value is 0 or -1 it is like it is worth at least 1
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
    astrDKAndDescList+=("${lstrBundleDK},\"${lstrBundleDesc}\n Activating this will call a courier that will bring the package to you (but not if there are too many couriers nearby). That call requires ${iCallCourierEnergyReq} battery energy.\n Experience Penalty when opening this bundle${lstrOpenOnceOnly}(Remaining open count {cvar(${lstrCvar}:0)}): ${liExpDebt}*({cvar(${lstrBundleCountID}:0)}+1)/{cvar(fGSKAllFreeBundlesSumExpDebit:0)}\n ${strExpLossInfo}\n ${lstrDkItems}\n ${lstrAddDesc}\"")
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
  
  CFGFUNCwriteCaches
}

#function CFGFUNCchkNumber() {
  #if ! [[ "${1-}" =~ ^[0-9]*$ ]];then
    #CFGFUNCerrorExit "invalid '${1-}', should be a positive integer";fi
  #fi
#}

#astr=( #TEMPLATE
#  "$strSCHEMATICS_BEGIN_TOKEN" 0
#);FUNCprepareBundles "" "${astr[@]}"

source "./createBundles.InputData.sh"

#############################################
#CFGFUNCwriteCaches
#echo "#PREPARE_RELEASE:REVIEWED:OK" >"$CFGstrFlItemEconomicValueCACHE"
#echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"$CFGstrFlItemEconomicValueCACHE"
#declare -p CFGastrItem1Value2List >>"$CFGstrFlItemEconomicValueCACHE"

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
