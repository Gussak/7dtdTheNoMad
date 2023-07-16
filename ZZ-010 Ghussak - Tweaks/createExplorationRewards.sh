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

: ${iRewardValueMult:=15} #help x15 is like the trader price for a tier 6 item just after entering the game the first time (so no trading bonuses)

astrItemList=( 
  #place here mainly the best items of the game that may not be found otherwise as trader's inv is empty for TNM
   #strShortNameId can be empty
   #iSellPriceTier4 is for player lvl1 and tier 4 quality if it has tiers. if 0 will be automatic if possible
   
  #Columns:
  #token          id                      shortNameId   iSellPriceTier4
  #"item_modifier" modGunScopeMedium       "Scope4x"                  61
  #"item_modifier" modGunScopeLarge        "Scope8x"                  68
  
  #CODEGEN: grep '<item .*name="gun[^"]*t3[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(gun.*T3)(.*)@"item" \2\3 "\3" 0@' |tr -d '\r\0' |sort -u
  "item" gunBotT3JunkDrone "JunkDrone" 0
  "item" gunBowT3CompoundBow "CompoundBow" 0
  "item" gunBowT3CompoundCrossbow "CompoundCrossbow" 0
  "item" gunExplosivesT3RocketLauncher "RocketLauncher" 0
  "item" gunHandgunT3DesertVulture "DesertVulture" 0
  "item" gunHandgunT3SMG5 "SMG5" 0
  "item" gunMGT3M60 "M60" 0
  "item" gunRifleT3SniperRifle "SniperRifle" 0
  "item" gunShotgunT3AutoShotgun "AutoShotgun" 0

  #grep '<item .*name="melee[^"]*t3[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(melee.*T3)(.*)@"item" \2\3 "\3" 0@' |tr -d '\r\0' |sort -u
  "item" meleeToolAxeT3Chainsaw "Chainsaw" 0
  "item" meleeToolPickT3Auger "Auger" 0
  "item" meleeToolRepairT3Nailgun "Nailgun" 0
  "item" meleeToolSalvageT3ImpactDriver "ImpactDriver" 0
  #"item" meleeWpnBatonT3PlasmaBaton "PlasmaBaton" 0
  "item" meleeWpnBladeT3Machete "Machete" 0
  "item" meleeWpnClubT3SteelClub "SteelClub" 0
  "item" meleeWpnKnucklesT3SteelKnuckles "SteelKnuckles" 0
  "item" meleeWpnSledgeT3SteelSledgehammer "SteelSledgehammer" 0
  "item" meleeWpnSpearT3SteelSpear "SteelSpear" 0

  #grep '<item .*name="melee[^"]*t2[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(melee.*T2)(.*)@"item" \2\3 "\3" 0@' |tr -d '\r\0' |sort -u
  "item" meleeToolAxeT2SteelAxe "SteelAxe" 0
  "item" meleeToolPickT2SteelPickaxe "SteelPickaxe" 0
  "item" meleeToolSalvageT2Ratchet "Ratchet" 0
  "item" meleeToolShovelT2SteelShovel "SteelShovel" 0
  "item" meleeWpnBatonT2StunBaton "StunBaton" 0

  #grep '<item .*name="armorSteel[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorSteel)(.*)@"item" \2\3 "\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorSteelBoots "Boots" 0
  "item" armorSteelChest "Chest" 0
  "item" armorSteelGloves "Gloves" 0
  "item" armorSteelHelmet "Helmet" 0
  "item" armorSteelLegs "Legs" 0

  #grep '<item .*name="armorMilitary[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorMilitary)(.*)@"item" \2\3 "\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorMilitaryBoots "Boots" 0
  "item" armorMilitaryGloves "Gloves" 0
  "item" armorMilitaryHelmet "Helmet" 0
  "item" armorMilitaryLegs "Legs" 0
  "item" armorMilitaryStealthBoots "StealthBoots" 0
  "item" armorMilitaryVest "Vest" 0

  #grep '<item .*name="armor[^"]*Helmet[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armor)(.*)(Helmet)(.*)@"item" \2\3\4\5 "Helmet\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorFirefightersHelmet "HelmetFirefighters" 0
  "item" armorFootballHelmet "HelmetFootball" 0
  #"item" armorFootballHelmetZU "HelmetFootball" 0
  #"item" armorIronHelmet "HelmetIron" 0
  #"item" armorMilitaryHelmet "HelmetMilitary" 0
  "item" armorMiningHelmet "HelmetMining" 0
  #"item" armorScrapHelmet "HelmetScrap" 0
  #"item" armorSteelHelmet "HelmetSteel" 0
  "item" armorSwatHelmet "HelmetSwat" 0

  #grep '<item_modifier.*name="mod[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item_modifier *name=")(mod)(.*)@"item_modifier" \2\3 "Mod\3" 0@' |sort -u |sed 's@Mod"@"@'
  "item_modifier" modArmorAdvancedMuffledConnectors "ModArmorAdvancedMuffledConnectors" 0
  "item_modifier" modArmorBallCap "ModArmorBallCap" 0
  "item_modifier" modArmorBandolier "ModArmorBandolier" 0
  "item_modifier" modArmorCoolingMesh "ModArmorCoolingMesh" 0
  "item_modifier" modArmorCowboyHat "ModArmorCowboyHat" 0
  "item_modifier" modArmorCustomizedFittings "ModArmorCustomizedFittings" 0
  "item_modifier" modArmorDoubleStoragePocket "ModArmorDoubleStoragePocket" 0
  "item_modifier" modArmorHelmetLight "ModArmorHelmetLight" 0
  "item_modifier" modArmorImpactBracing "ModArmorImpactBracing" 0
  "item_modifier" modArmorImprovedFittings "ModArmorImprovedFittings" 0
  "item_modifier" modArmorInsulatedLiner "ModArmorInsulatedLiner" 0
  "item_modifier" modArmorJumpJets "ModArmorJumpJets" 0
  "item_modifier" modArmorMuffledConnectors "ModArmorMuffledConnectors" 0
  "item_modifier" modArmorPlatingBasic "ModArmorPlatingBasic" 0
  "item_modifier" modArmorPlatingReinforced "ModArmorPlatingReinforced" 0
  "item_modifier" modArmorPressboyCap "ModArmorPressboyCap" 0
  "item_modifier" modArmorSkullCap "ModArmorSkullCap" 0
  "item_modifier" modArmorStoragePocket "ModArmorStoragePocket" 0
  "item_modifier" modArmorTripleStoragePocket "ModArmorTripleStoragePocket" 0
  "item_modifier" modArmorWaterPurifier "ModArmorWaterPurifier" 0
  "item_modifier" modClothingCargoStoragePocket "ModClothingCargoStoragePocket" 0
  "item_modifier" modClothingStoragePocket "ModClothingStoragePocket" 0
  "item_modifier" modCosmicRayShield "ModCosmicRayShield" 410  #collected in-game
  "item_modifier" modCowboyHat "ModCowboyHat" 0
  "item_modifier" modDyeBlack "ModDyeBlack" 0
  "item_modifier" modDyeBlue "ModDyeBlue" 0
  "item_modifier" modDyeBrown "ModDyeBrown" 0
  "item_modifier" modDyeGreen "ModDyeGreen" 0
  "item_modifier" modDyeOrange "ModDyeOrange" 0
  "item_modifier" modDyePink "ModDyePink" 0
  "item_modifier" modDyePurple "ModDyePurple" 0
  "item_modifier" modDyeRed "ModDyeRed" 0
  "item_modifier" modDyeWhite "ModDyeWhite" 0
  "item_modifier" modDyeYellow "ModDyeYellow" 0
  "item_modifier" modFuelTankLarge "ModFuelTankLarge" 0
  "item_modifier" modFuelTankSmall "ModFuelTankSmall" 0
  "item_modifier" modGunBarrelExtender "ModGunBarrelExtender" 0
  "item_modifier" modGunBipod "ModGunBipod" 0
  "item_modifier" modGunBoreYouToDeath "ModGunBoreYouToDeath" 0
  "item_modifier" modGunBowArrowRest "ModGunBowArrowRest" 0
  "item_modifier" modGunBowPolymerString "ModGunBowPolymerString" 0
  "item_modifier" modGunButtkick3000 "ModGunButtkick3000" 0
  "item_modifier" modGunButtkick4000 "ModGunButtkick4000" 0
  "item_modifier" modGunChoke "ModGunChoke" 0
  "item_modifier" modGunCrippleEm "ModGunCrippleEm" 0
  "item_modifier" modGunDrumMagazineExtender "ModGunDrumMagazineExtender" 0
  "item_modifier" modGunDuckbill "ModGunDuckbill" 0
  "item_modifier" modGunFlashlight "ModGunFlashlight" 0
  "item_modifier" modGunFlashSuppressor "ModGunFlashSuppressor" 0
  "item_modifier" modGunFoldingStock "ModGunFoldingStock" 0
  "item_modifier" modGunForegrip "ModGunForegrip" 0
  "item_modifier" modGunLaserSight "ModGunLaserSight" 0
  "item_modifier" modGunMagazineExtender "ModGunMagazineExtender" 0
  "item_modifier" modGunMeleeBlessedMetal "ModGunMeleeBlessedMetal" 0
  "item_modifier" modGunMeleeFeelTheHeat "ModGunMeleeFeelTheHeat" 0
  "item_modifier" modGunMeleeFlammableOil "ModGunMeleeFlammableOil" 0
  "item_modifier" modGunMeleeLiquidNitrogen "ModGunMeleeLiquidNitrogen" 0
  "item_modifier" modGunMeleeNamePlate "ModGunMeleeNamePlate" 0
  "item_modifier" modGunMeleeNiCdBattery "ModGunMeleeNiCdBattery" 0
  "item_modifier" modGunMeleeRadRemover "ModGunMeleeRadRemover" 0
  "item_modifier" modGunMeleeTheHunter "ModGunMeleeTheHunter" 0
  "item_modifier" modGunMuzzleBrake "ModGunMuzzleBrake" 0
  "item_modifier" modGunReflexSight "ModGunReflexSight" 0
  "item_modifier" modGunRetractingStock "ModGunRetractingStock" 0
  "item_modifier" modGunScopeLarge "ModGunScopeLarge" 0
  "item_modifier" modGunScopeMedium "ModGunScopeMedium" 0
  "item_modifier" modGunScopeSmall "ModGunScopeSmall" 0
  "item_modifier" modGunShotgunTubeExtenderMagazine "ModGunShotgunTubeExtenderMagazine" 0
  "item_modifier" modGunSoundSuppressorSilencer "ModGunSoundSuppressorSilencer" 0
  "item_modifier" modGunTriggerGroupAutomatic "ModGunTriggerGroupAutomatic" 0
  "item_modifier" modGunTriggerGroupBurst3 "ModGunTriggerGroupBurst3" 0
  "item_modifier" modGunTriggerGroupSemi "ModGunTriggerGroupSemi" 0
  "item_modifier" modHazmatBoots "ModHazmatBoots" 0
  "item_modifier" modHazmatGloves "ModHazmatGloves" 0
  "item_modifier" modHazmatMask "ModHazmatMask" 0
  "item_modifier" modMeleeBunkerBuster "ModMeleeBunkerBuster" 0
  "item_modifier" modMeleeClubBarbedWire "ModMeleeClubBarbedWire" 0
  "item_modifier" modMeleeClubBurningShaft "ModMeleeClubBurningShaft" 0
  "item_modifier" modMeleeClubMetalChain "ModMeleeClubMetalChain" 0
  "item_modifier" modMeleeClubMetalSpikes "ModMeleeClubMetalSpikes" 0
  "item_modifier" modMeleeDiamondTip "ModMeleeDiamondTip" 400 #collected in-game
  "item_modifier" modMeleeErgonomicGrip "ModMeleeErgonomicGrip" 0
  "item_modifier" modMeleeFiremansAxeMod "ModMeleeFiremansAxe" 0
  "item_modifier" modMeleeFortifyingGrip "ModMeleeFortifyingGrip" 0
  "item_modifier" modMeleeGraveDigger "ModMeleeGraveDigger" 0
  "item_modifier" modMeleeGunToolDecapitizer "ModMeleeGunToolDecapitizer" 0
  "item_modifier" modMeleeIronBreaker "ModMeleeIronBreaker" 0
  "item_modifier" modMeleeSerratedBlade "ModMeleeSerratedBlade" 0
  "item_modifier" modMeleeStructuralBrace "ModMeleeStructuralBrace" 0
  "item_modifier" modMeleeStunBatonRepulsor "ModMeleeStunBatonRepulsor" 0
  "item_modifier" modMeleeTemperedBlade "ModMeleeTemperedBlade" 0
  "item_modifier" modMeleeWeightedHead "ModMeleeWeightedHead" 0
  "item_modifier" modMeleeWoodSplitter "ModMeleeWoodSplitter" 0
  "item_modifier" modRadiationReady "ModRadiationReady" 0
  "item_modifier" modRoboticDroneArmorPlatingMod "ModRoboticDroneArmorPlating" 0
  "item_modifier" modRoboticDroneCargoMod "ModRoboticDroneCargo" 0
  "item_modifier" modRoboticDroneHeadlampMod "ModRoboticDroneHeadlamp" 0
  "item_modifier" modRoboticDroneMedicMod "ModRoboticDroneMedic" 0
  "item_modifier" modRoboticDroneMoraleBoosterMod "ModRoboticDroneMoraleBooster" 0
  "item_modifier" modRoboticDroneStunWeaponMod "ModRoboticDroneStunWeapon" 0
  "item_modifier" modRoboticDroneWeaponMod "ModRoboticDroneWeapon" 0
  "item_modifier" modShotgunSawedOffBarrel "ModShotgunSawedOffBarrel" 0
  "item_modifier" modVehicleExpandedSeat "ModVehicleExpandedSeat" 0
  "item_modifier" modVehicleFuelSaver "ModVehicleFuelSaver" 0
  "item_modifier" modVehicleMega "ModVehicleMega" 0
  "item_modifier" modVehicleOffRoadHeadlights "ModVehicleOffRoadHeadlights" 0
  "item_modifier" modVehicleReserveFuelTank "ModVehicleReserveFuelTank" 0
  "item_modifier" modVehicleSuperCharger "ModVehicleSuperCharger" 0
  "item_modifier" modYoureFired "ModYoureFired" 0
)

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

iDataColumns=4
astrLocList=()
iUpdateEcoItemValCache=0
iUpdateItemHasTiersCache=0
#for strItem in "${astrItemList[@]}";do
#set -x
for((iDataLnIniIndex=0;iDataLnIniIndex<${#astrItemList[@]};iDataLnIniIndex+=iDataColumns));do
  declare -p iDataLnIniIndex
  strXmlToken="${astrItemList[iDataLnIniIndex]}";echo ">>>>>>>>>> $strXmlToken" #item type
  strItem="${astrItemList[iDataLnIniIndex+1]}"
  strShortNameId="${astrItemList[iDataLnIniIndex+2]}"
  iSellPriceTier4="${astrItemList[iDataLnIniIndex+3]}";CFGFUNCchkNum "$iSellPriceTier4"
  
  iCountOrTier=0
  
  if [[ -z "$strShortNameId" ]];then strShortNameId="$strItem";fi
  
  if [[ "$strXmlToken" == "item_modifier" ]] && ((iSellPriceTier4==0));then
    iSellPriceTier4=100 # most mods have and average price about 33 I think. a few are around 75 to 115. anyway, this will be an ok value to most as there seem to have no other way to collect than in-game clicking one by one... So overall, the cheaper ones being costy will compensate for the costier ones being cheap ;).
  fi
  if((iSellPriceTier4==0));then
    iEconomicValue="${CFGastrItem1Value2List[${strItem}]-0}" #tries the cache
    
    if((iEconomicValue==0));then
      if CFGFUNCrecursiveSearchPropertyValueAllFiles --boolAllowProp "SellableToTrader" "EconomicValue" "$strItem";then
        iEconomicValue="$iFRSPV_PropVal_OUT"
        CFGastrItem1Value2List["${strItem}"]=$iEconomicValue
        ((iUpdateEcoItemValCache++))&&:
        declare -p iUpdateEcoItemValCache
      else
        CFGFUNCerrorExit "auto price failed";
      fi
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
  
  if((iCountOrTier==0));then
    bItemHasTiers="${CFGastrItem1HasTiers2List[${strItem}]-}" #tries the cache
    if [[ -z "$bItemHasTiers" ]];then
      if CFGFUNCrecursiveSearchPropertyValueAllFiles "ShowQuality" "$strItem";then
        strChkIHV="`echo "$iFRSPV_PropVal_OUT" |tr "[:upper:]" "[:lower:]"`"
        if [[ "$strChkIHV" == "true" ]] || [[ "$strChkIHV" == "false" ]];then
          bItemHasTiers="${strChkIHV}"
        else
          CFGFUNCerrorExit "chk bItemHasTiers invalid value iFRSPV_PropVal_OUT='$iFRSPV_PropVal_OUT'"
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
  
  strDk='dkGSKTNMExplrRwd'"${strShortNameId}"''
  echo '
    <item name="GSKTNMExplrRwd'"${strShortNameId}"'">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${strItem}"'" />
      <property name="CustomIconTint" value="180,180,128" />
      <property name="ItemTypeIcon" value="treasure" />
      <property name="DescriptionKey" value="'"${strDk}"'" />
      <property class="Action0">
        <requirement name="CVarCompare" cvar="iGSKexplorationCredits" operation="GTE" value="'"${iRewardValue}"'" help="'"Dbg:EcV=${iEconomicValue},t4=${iSellPriceTier4},t6=${iSellPriceTier6}"'"/>
        <property name="Create_item" value="'"${strItem}"'" />
        <property name="Create_item_count" value="'"${iCountOrTier}"'" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" target="self" cvar="iGSKexplorationCredits" operation="add" value="-'"${iRewardValue}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="CallGameEvent" event="eventGSKSpwCourier"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ShowToolbeltMessage" message="[TNM] A courier brings you the package."/>
      </effect_group>
    </item>' >>"${strFlGenIte}${strGenTmpSuffix}"
#dkGSKTNMExplrRewardScope8x,"This exploring reward requires 5160, and you have {cvar(iGSKexplorationCredits:0)} exploring credits."
  astrLocList+=("${strDk},\"This exploring reward requires ${iRewardValue} credits\n.You still have {cvar(iGSKexplorationCredits:0)} exploring credits.\nA courier will bring the reward to you.\nTo collect POI exploring rewards you must be careful, read exploring tip about such rewards if you need.\"")
  CFGFUNCwriteCaches
done

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

for strLoc in "${astrLocList[@]}";do
  echo "$strLoc" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done
CFGFUNCgencodeApply "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
