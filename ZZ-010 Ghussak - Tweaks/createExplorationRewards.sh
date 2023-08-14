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
eval "`CFGFUNCloadCaches`"
#CFGFUNCwriteCaches;exit #TODO comment
#CFGFUNCchkNum "1.0";exit

: ${iRewardValueMult:=15} #help x15 is like the trader price for a tier 6 item just after entering the game the first time (so no trading bonuses)
: ${iModGenericPrice:=100} #help iModGenericPrice*fMultPriceTier4to6*iRewardValueMult, ex.: 100*1.6*15=2400
: ${iEndGameValue:=1500} #help end game items are tier6, but this is the sell price of tier4 weapons that will still be converted into tier6 (*fMultPriceTier4to6) and further increased (*iRewardValueMult). In other words, just keep in sync with the sell price of tier4 weapons.
: ${nPriceDecSize:=5} #help this controls zeros on the left for low prices and nice sorting on the craft list

source "createExplorationRewards.InputData.sh"

######## calc example:
### autoshotgun sell prices each tier +-: 120 570 1030 1488 2000 2400
###  trader prices are 15*sellPrice just after you enter the game. It may vary after you sell/buy many things from traders as I saw it lower to 9xSellPrice. The sell price increased also! So better just ignore it here.
###  configured EconomicValue property is 1500 (about tier 4)
###  tier 1 seem to be like trash item
###  tier 2 begins to be a good item
###  tier 4 is average price configured at EconomicValue property
###  so tier 4 = EconomicValue property. EconomicValue*1.6=maxTierSellPrice
### right???
: ${fMultPriceTier4to6:=1.6} #help

function FUNCchkPropCanPickup() { # req strItem
  strCanPickup="${CFGastrCacheItem1CanPickup2List[${strItem}]-false}" #tries the cache
  if CFGFUNCrecursiveSearchPropertyValueAllFiles "CanPickup" "$strItem";then
    strCanPickup="$iFRSPV_PropVal_OUT"
    strCanPickup="`echo "$strCanPickup" |tr "[:upper:]" "[:lower:]"`"
  fi
  CFGastrCacheItem1CanPickup2List["${strItem}"]="$strCanPickup"
  ((iUpdateCanPickupCache++))&&:
  if [[ "$strCanPickup" == "false" ]];then
    CFGFUNCinfo "skip block '$strItem' that cannot be picked up"
    return 1
  fi
  return 0
}
function FUNCchkPropCreativeMode() { # req strItem
  strCreativeMode="${CFGastrCacheItem1CreativeMode2List[${strItem}]-}" #tries the cache
  if [[ -z "$strCreativeMode" ]];then
    if CFGFUNCrecursiveSearchPropertyValueAllFiles --no-recursive "CreativeMode" "$strItem";then
      strCreativeMode="$iFRSPV_PropVal_OUT"
      strCreativeMode="`echo "$strCreativeMode" |tr "[:upper:]" "[:lower:]"`"
    fi
    if [[ -z "$strCreativeMode" ]];then
      strCreativeMode="player" #when it is not set in the xml, it defaults to 'player' hardcoded in the game engine
    fi
    CFGastrCacheItem1CreativeMode2List["${strItem}"]="$strCreativeMode"
    ((iUpdateCreativeModeCache++))&&:
  fi
  if [[ "$strCreativeMode" =~ .*(none|dev|test).* ]];then
    CFGFUNCinfo "skip $strItem strCreativeMode='$strCreativeMode'"
    return 1
  fi
  return 0
}

iCallCourierEnergyReq=10
astrCustomIconIsSelfId=()
astrLocList=()

iUpdateEcoItemValCache=0
iUpdateItemHasTiersCache=0
iUpdateCreativeModeCache=0
iUpdateCanPickupCache=0

declare -A astrPrevItemNameList
strIgnoreListRegex="`echo "${astrIgnoreList[@]}" |tr ' ' '|'`"
#for strItem in "${astrItemList[@]}";do
#set -x
for((iDataLnIniIndex=0;iDataLnIniIndex<${#astrItemList[@]};iDataLnIniIndex+=iDataColumns));do
  declare -p iDataLnIniIndex
  strXmlToken="${astrItemList[iDataLnIniIndex]}";echo ">>>>>>>>>> $strXmlToken" #item type
  strItem="${astrItemList[iDataLnIniIndex+1]}"
  strShortNameId="${astrItemList[iDataLnIniIndex+2]}" #shall begin with a 3 letter unique group token
  iSellPriceTier4="${astrItemList[iDataLnIniIndex+3]}";CFGFUNCchkNum "$iSellPriceTier4"
  strAddHelp="${astrItemList[iDataLnIniIndex+4]}"
  
  strBundle=""
  if [[ "$strItem" =~ .*[Bb]undle.* ]];then
    strBundle=" (BUNDLE)" #todo show the Create_item_count value
  fi
  #if [[ "$strItem" =~ .*Bundle.* ]];then
    #CFGFUNCinfo "Ignoring bundles: $strItem. This reward is meant to at most fill the gap, reach the minimum requirements, and not mass create resources."
    #continue;
  #fi
  #if [[ "$strItem" =~ .*POI.* ]];then
    #CFGFUNCinfo "Ignoring POI blocks: $strItem."
    #continue;
  #fi
  if [[ "$strItem" =~ .*(${strIgnoreListRegex}).* ]];then
    CFGFUNCinfo "Ignoring: $strItem. see astrIgnoreList"
    continue;
  fi
  #if [[ "$strXmlToken" == "block" ]] && [[ "$strItem" =~ ^cnt.* ]];then
    #CFGFUNCinfo "Ignoring container blocks: $strItem."
    #continue;
  #fi
  #help blocks can be blocked too by adding this to them: <property name="SellableToTrader" value="false"/>
  #if [[ "$strItem" =~ .*([fF]lagPole|[pP]oolTable|[cC]andelabra|[dD]ogHouse).* ]];then # sync with PreventPlayerCreatingThese at blocks.xml
    #CFGFUNCinfo "Ignoring PreventPlayerCreatingThese: $strItem."
    #continue;
  #fi
  
  strHelp=""
  
  #if [[ "$strXmlToken" == "block" ]];then
    #strCanPickup="${CFGastrCacheItem1CanPickup2List[${strItem}]-false}" #tries the cache
    #if CFGFUNCrecursiveSearchPropertyValueAllFiles "CanPickup" "$strItem";then
      #strCanPickup="$iFRSPV_PropVal_OUT"
      #strCanPickup="`echo "$strCanPickup" |tr "[:upper:]" "[:lower:]"`"
    #fi
    #CFGastrCacheItem1CanPickup2List["${strItem}"]="$strCanPickup"
    #((iUpdateCanPickupCache++))&&:
    
    #if [[ "$strCanPickup" == "false" ]];then
      #CFGFUNCinfo "skip block '$strItem' that cannot be picked up"
      #continue
    #fi
  #fi
  
  #strCreativeMode="${CFGastrCacheItem1CreativeMode2List[${strItem}]-}" #tries the cache
  #if [[ -z "$strCreativeMode" ]];then
    #if CFGFUNCrecursiveSearchPropertyValueAllFiles --no-recursive "CreativeMode" "$strItem";then
      #strCreativeMode="$iFRSPV_PropVal_OUT"
      #strCreativeMode="`echo "$strCreativeMode" |tr "[:upper:]" "[:lower:]"`"
    #fi
    #if [[ -z "$strCreativeMode" ]];then
      #strCreativeMode="player" #when it is not set in the xml, it defaults to 'player' hardcoded in the game engine
    #fi
    #CFGastrCacheItem1CreativeMode2List["${strItem}"]="$strCreativeMode"
    #((iUpdateCreativeModeCache++))&&:
  #fi
  #if [[ "$strCreativeMode" =~ .*(none|dev|test).* ]];then
    #CFGFUNCinfo "skip $strItem strCreativeMode='$strCreativeMode'"
    #continue
  #fi
  if ! FUNCchkPropCreativeMode;then continue;fi
  
  iCountOrTier=0
  
  if [[ -z "$strShortNameId" ]];then strShortNameId="$strItem";fi
  
  if [[ "$strXmlToken" == "item_modifier" ]] && ((iSellPriceTier4==0));then
    iSellPriceTier4=100 # most mods have and average price about 33 I think. a few are around 75 to 115. anyway, this will be an ok value to most as there seem to have no other way to collect than in-game clicking one by one... So overall, the cheaper ones being costy will compensate for the costier ones being cheap ;).
    strHelp+=",Mod:UsingADefaultAverageValue"
  fi
  if((iSellPriceTier4==0));then
    iEconomicValue="${CFGastrItem1Value2List[${strItem}]-0}" #tries the cache
    if((iEconomicValue==0));then # no cache found
      #if CFGFUNCrecursiveSearchPropertyValueAllFiles --boolAllowProp "SellableToTrader" "EconomicValue" "$strItem";then
      if CFGFUNCrecursiveSearchPropertyValueAllFiles "EconomicValue" "$strItem";then
        #iEconomicValue="$iFRSPV_PropVal_OUT"
        CFGFUNCinfo "New iEconomicValue='$iEconomicValue' found for strItem='${strItem}' will be put on cache (iUpdateEcoItemValCache='$iUpdateEcoItemValCache')"
      fi
      if [[ -n "$iFRSPV_PropVal_OUT" ]];then # an empty return value means it was not found
        iEconomicValue="$iFRSPV_PropVal_OUT"
      fi
      
      if((iEconomicValue==0));then
        if [[ "$strItem" =~ .*[Bb]undle.* ]];then
          CFGFUNCinfo "Ignoring bundle that have no economic value: $strItem. TODO: collect property Create_item value, get it's economicvalue, multiply by property Create_item_count value"
          iEconomicValue=-1
        fi
        if [[ "$strXmlToken" == "block" ]];then
          CFGFUNCinfo "this block that have no economic value: $strItem"
          
          #strCanPickup="${CFGastrCacheItem1CanPickup2List[${strItem}]-false}" #tries the cache
          #if CFGFUNCrecursiveSearchPropertyValueAllFiles "CanPickup" "$strItem";then
            #strCanPickup="$iFRSPV_PropVal_OUT"
            #strCanPickup="`echo "$strCanPickup" |tr "[:upper:]" "[:lower:]"`"
          #fi
          #CFGastrCacheItem1CanPickup2List["${strItem}"]="$strCanPickup"
          #((iUpdateCanPickupCache++))&&:
          #if [[ "$strCanPickup" == "false" ]];then
            #CFGFUNCinfo "skip block '$strItem' that cannot be picked up"
            #continue
          #fi
          if ! FUNCchkPropCanPickup;then continue;fi
          #CFGFUNCinfo "Ignoring block that have no economic value: $strItem. They probably cannot be picked up anyway."
          #iEconomicValue=-1
        fi
        if((iEconomicValue==0));then
          iEconomicValue="`CFGFUNCgetCustomEconomicValue "$strItem"`"
        fi
      fi
      
      CFGastrItem1Value2List["${strItem}"]=$iEconomicValue
      ((iUpdateEcoItemValCache++))&&:
    fi
    if((iEconomicValue==-1));then # using the cache
      CFGFUNCinfo "Skipping item that was set to be ignored (iEconomicValue=${iEconomicValue}): strItem='${strItem}'"
      continue;
    fi
      
    #if CFGFUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue" "$strXmlToken" "$strItem" "$lstrFlCfgChkFullPath";then # FRSPV
      #:
    #fi
    #CFGFUNCerrorExit "not implemented auto price";
  else
    iEconomicValue="$iSellPriceTier4" #I think price is like playerSellVal*15=traderSellVal=EcoVal*3
  fi
  iSellPriceTier6=$(printf "%.0f" "`bc <<< "scale=0;${iEconomicValue}*${fMultPriceTier4to6}"`") #no problem for items that have no tier
  #iEconomicValue=$((iTraderPrice/3)) #I think price is like playerSellVal*15=traderSellVal=EcoVal*3
  iRewardValue=$((iSellPriceTier6*iRewardValueMult)) #even if the item has no tiers, that price increase is good
  if [[ "$strItem" =~ .*Dye.* ]];then #cosmetics (have no advantages, unless if PVP as cammo)
    ((iRewardValue/=10))&&: #240 (based on the collected value)
  fi
  if [[ "${strShortNameId:0:3}" =~ (CSM|RSC) ]];then #consumables (may be used often w/o problems)
    if((iSellPriceTier4==0));then #cfg=0 means to use automatic values
      iRewardValue=$((iEconomicValue*3))
    else
      iRewardValue=$iSellPriceTier4 # is a direct override for CSM
    fi
  fi
  if [[ "${strShortNameId:0:3}" =~ (MDH|DRG) ]];then #consumables (may be used often w/o problems)
    if((iSellPriceTier4==0));then #cfg=0 means to use automatic values
      iRewardValue=$((iEconomicValue*6))
    else
      iRewardValue=$iSellPriceTier4 # is a direct override for CSM
    fi
  fi
  
  : ${iPriceCap:=36000} #help
  if((iRewardValue>iPriceCap));then
    CFGFUNCinfo "strItem='$strItem' above price cap ($iPriceCap) iRewardValue='$iRewardValue', limiting it."
    iRewardValue="$iPriceCap"
  fi
  
  if((iRewardValue==0));then CFGFUNCerrorExit "iRewardValue==0";fi
  #if((iRewardValue>99999));then
  if(("${#iRewardValue}">nPriceDecSize));then
    CFGFUNCerrorExit "strItem='$strItem' iRewardValue='$iRewardValue' bigger than expected (you should increase the nPriceDecSize='$nPriceDecSize' to ${#iRewardValue} as it is used to have a nice list sorting by price with zeros on the left)";
  fi
  
  strItemType=""
  if [[ "${strShortNameId:0:3}" == "AMO" ]];then strItemType="Ammunition";fi
  if [[ "${strShortNameId:0:3}" == "TRW" ]];then strItemType="Throwable";fi
  if [[ "${strShortNameId:0:3}" == "CSM" ]];then strItemType="Consumable";fi
  if [[ "${strShortNameId:0:3}" == "SCH" ]];then strItemType="Schematic";fi
  if [[ "${strShortNameId:0:3}" == "ARO" ]];then strItemType="Armor and Outfit";fi
  if [[ "${strShortNameId:0:3}" == "Mod" ]];then strItemType="Item Modification";fi
  if [[ "${strShortNameId:0:3}" == "RSC" ]];then strItemType="Resource";fi
  if [[ "${strShortNameId:0:3}" == "WT0" ]];then strItemType="Weapon/Tool Tier 0";fi
  if [[ "${strShortNameId:0:3}" == "WT1" ]];then strItemType="Weapon/Tool Tier I";fi
  if [[ "${strShortNameId:0:3}" == "WT2" ]];then strItemType="Weapon/Tool Tier II";fi
  if [[ "${strShortNameId:0:3}" == "WT3" ]];then strItemType="Weapon/Tool Tier III";fi
  if [[ "${strShortNameId:0:3}" == "BLK" ]];then strItemType="Block";fi
  if [[ "${strShortNameId:0:3}" == "MDH" ]];then strItemType="Medical Healing";fi
  if [[ "${strShortNameId:0:3}" == "DRG" ]];then strItemType="Medicinal Drug";fi
  if [[ -z "$strItemType" ]];then CFGFUNCerrorExit "invalid undefined strItemType='$strItemType'";fi
  
  if((iCountOrTier==0));then
    bItemHasTiers="${CFGastrItem1HasTiers2List[${strItem}]-}" #tries the cache
    if [[ -z "$bItemHasTiers" ]];then
      #CFGFUNCrecursiveSearchPropertyValue "ShowQuality" "item" "$strItem" "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/items.xml"&&:;declare -p iFRSPV_PropVal_OUT
      if CFGFUNCrecursiveSearchPropertyValueAllFiles "ShowQuality" "$strItem";then
        strChkIHV="`echo "$iFRSPV_PropVal_OUT" |tr "[:upper:]" "[:lower:]"`"
        if [[ "$strChkIHV" == "true" ]] || [[ "$strChkIHV" == "false" ]];then
          bItemHasTiers="${strChkIHV}"
        else
          CFGFUNCerrorExit "strItem='$strItem' chk bItemHasTiers(ShowQuality) invalid value should not be diff than 'true|false' iFRSPV_PropVal_OUT='$iFRSPV_PropVal_OUT'='$strChkIHV'"
        fi
      else
        bItemHasTiers=false #not found is default false
      fi
      CFGastrItem1HasTiers2List["${strItem}"]="$bItemHasTiers"
      ((iUpdateItemHasTiersCache++))&&:
    fi
    
    if $bItemHasTiers;then
      CFGFUNCinfo "'$strItem' has tiers, so iEconomicValue='$iEconomicValue' is the tier4 player sell price (at 1st time game join)."
      iCountOrTier=6
    else
      CFGFUNCinfo "'$strItem' doe not have tiers, so iEconomicValue='$iEconomicValue' should be the trader sell price (at 1st time game join)."
      iCountOrTier=1
    fi
  fi
  
  strCustomIcon="${CFGastrCacheItem1CustomIcon2List[${strItem}]-}" #tries the cache
  if [[ -z "$strCustomIcon" ]];then
    if CFGFUNCrecursiveSearchPropertyValueAllFiles --no-recursive "CustomIcon" "$strItem";then
      strCustomIcon="$iFRSPV_PropVal_OUT"
      CFGFUNCinfo "strItem='$strItem' strCustomIcon='$strCustomIcon'"
    fi
    if [[ -z "$strCustomIcon" ]];then
      strCustomIcon="${strItem}" #default
      CFGFUNCinfo "strItem='$strItem' using default self id CustomIcon='$strItem'"
    fi
    CFGastrCacheItem1CustomIcon2List["${strItem}"]="$strCustomIcon"
    #declare -p strCustomIcon iFRSPV_PropVal_OUT strItem;exit #TODORM
  fi
  if [[ "$strCustomIcon" == "$strItem" ]];then astrCustomIconIsSelfId+=("$strItem");fi
  
  #strItemName='GSKTNMWER_'"`printf "%0${nPriceDecSize}d" "$iRewardValue"`_${strShortNameId}"''
  strItemName='zGTW'"`printf "%0${nPriceDecSize}d" "$iRewardValue"`${strShortNameId}"'' # prefix z is important to put them as last in the list to not mess it
  #for((iChkItemNm=0;iChkItemNm<${#astrPrevItemNameList[@]};iChkItemNm++));do if [[ "${astrPrevItemNameList[iChkItemNm]}" == "$strItemName" ]];then CFGFUNCerrorExit "item name clash: $strItemName, $strItem";fi;done
  for strItemChk in ${!astrPrevItemNameList[@]};do
    if [[ "${astrPrevItemNameList[$strItemChk]}" == "$strItemName" ]];then
      CFGFUNCerrorExit "item name clash: '$strItemName' $strItemChk vs $strItem";
    fi;
  done
  astrPrevItemNameList[${strItem}]="$strItemName"
  
  strDk='dkGSKTNMExplrRwd'"${strItem}"''
  
  
  ##################### COMPLETE IT ############################
  
  # egrep 'GSKTNMER' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/items.xml |sort
#function CFGFUNCcourier() { #helpf <liDeliveryPrice> chooses an adequate courier depending on the delivery value
  #local liDeliveryPrice="$1"
  #local lstrCourier="eventGSKSpwCourier" # most good mods
  #if((liDeliveryPrice>3000));then lstrCourier="eventGSKSpwCourierStrong";fi # top tier
  #if((liDeliveryPrice<1000));then lstrCourier="eventGSKSpwCourierWeak";fi # cheap stuff
  #echo "$lstrCourier"
#}
  strCourier="`CFGFUNCcourier ${iRewardValue} 1000 3000`"
  #strCourier="eventGSKSpwCourier" # most good mods
  #if((iRewardValue>3000));then strCourier="eventGSKSpwCourierStrong";fi # top tier
  #if((iRewardValue<1000));then strCourier="eventGSKSpwCourierWeak";fi # cheap stuff
  echo '
    <item name="'"${strItemName}"'">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${strCustomIcon}"'" />
      <property name="CustomIconTint" value="200,200,100" help="was 180,180,128"/>
      <property name="ItemTypeIcon" value="treasure" />
      <property name="DescriptionKey" value="'"${strDk}"'" />
      <property class="Action0">
        <requirement name="!IsBloodMoon"/>
        <requirement name="CVarCompare" cvar="iGSKPlayerNPCNonHireableNearby" operation="LT" value="@.iGSKMaxCouriersNearby"/>
        <requirement name="CVarCompare" cvar="iGSKexplorationCredits" operation="GTE" value="'"${iRewardValue}"'" help="'"${strHelp}; ${strAddHelp}; Dbg:EcV=${iEconomicValue},t4=${iSellPriceTier4},t6=${iSellPriceTier6}"'"/>
        <requirement name="CVarCompare" cvar="iGSKBatteryCharges" operation="GTE" value="'"${iCallCourierEnergyReq}"'" />
        <property name="Create_item" value="'"${strItem}"'" />
        <property name="Create_item_count" value="'"${iCountOrTier}"'" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="iGSKBatteryCharges" operation="subtract" value="'"${iCallCourierEnergyReq}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" target="self" cvar="iGSKexplorationCredits" operation="add" value="-'"${iRewardValue}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="CallGameEvent" event="'"${strCourier}"'" help="COURIER_DELIVERY"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="iGSKNPCCourierForPlayerEntId" operation="set" value="@EntityID" target="selfAOE" range="5" help="TODO: the player can set a @var on NPCs? or only constant values? so this wont right?">
          <requirement name="CVarCompare" cvar="iGSKNPCCourierForPlayerEntId" target="other" operation="Equals" value="0" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ShowToolbeltMessage" message="[TNM] A courier brings the package to you."/>
      </effect_group>
    </item>' >>"${strFlGenIte}${strGenTmpSuffix}"
  echo '<recipe name="'"${strItemName}"'" count="1"><ingredient name="electronicsParts" count="1"/></recipe>' >>"${strFlGenRec}${strGenTmpSuffix}"
  echo '<recipe name="electronicsParts" count="1"><ingredient name="'"${strItemName}"'" count="1"/></recipe>' >>"${strFlGenRec}${strGenTmpSuffix}"
#dkGSKTNMExplrRewardScope8x,"This exploring reward requires 5160, and you have {cvar(iGSKexplorationCredits:0)} exploring credits."
  astrLocList+=("${strDk},\"[TheNoMad:WorldExplorationReward] ${strItemType}: ${strItemName}${strBundle}\nThis exploring reward requires ${iRewardValue} credits.\nYou still have {cvar(iGSKexplorationCredits:0)} exploring credits.\nA courier will bring the reward to you (See *Delivery notes).\nTo collect POI exploring reward credits you must be careful, read exploring tip about such rewards if you need.\n It is not possible to get all rewards, so chose wisely.\"")
  
  if((iUpdateEcoItemValCache==10));then CFGFUNCwriteCaches;iUpdateEcoItemValCache=0;fi
  if((iUpdateItemHasTiersCache==10));then CFGFUNCwriteCaches;iUpdateItemHasTiersCache=0;fi
  if((iUpdateCreativeModeCache==10));then CFGFUNCwriteCaches;iUpdateCreativeModeCache=0;fi
  if((iUpdateCanPickupCache==10));then CFGFUNCwriteCaches;iUpdateCanPickupCache=0;fi
done
if(("${#astrCustomIconIsSelfId[@]}">0));then
  declare -p astrCustomIconIsSelfId |tr '[' '\n'
fi

CFGFUNCwriteCaches
#if((iUpdateEcoItemValCache>0));then
  #declare -p iUpdateEcoItemValCache
  #ls -l "$CFGstrFlItemEconomicValueCACHE"
  #CFGFUNCtrash "$CFGstrFlItemEconomicValueCACHE"
  #declare -p CFGastrItem1Value2List >"$CFGstrFlItemEconomicValueCACHE"
  #ls -l "$CFGstrFlItemEconomicValueCACHE"
#fi
#if((iUpdateItemHasTiersCache>0));then
  #declare -p iUpdateItemHasTiersCache
  #ls -l "$CFGstrFlItemHasTiersCACHE"
  #CFGFUNCtrash "$CFGstrFlItemHasTiersCACHE"
  #declare -p CFGastrItem1HasTiers2List >"$CFGstrFlItemHasTiersCACHE"
  #ls -l "$CFGstrFlItemHasTiersCACHE"
#fi

CFGFUNCgencodeApply "${strFlGenIte}${strGenTmpSuffix}" "${strFlGenIte}"

CFGFUNCgencodeApply "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

for strLoc in "${astrLocList[@]}";do
  echo "$strLoc" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done
CFGFUNCgencodeApply "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
