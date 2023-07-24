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
: ${iModGenericPrice:=100} #help iModGenericPrice*fMultPriceTier4to6*iRewardValueMult, ex.: 100*1.6*15=2400
: ${iEndGameValue:=1500} #help end game items are tier6, but this is the sell price of tier4 weapons that will still be converted into tier6 (*fMultPriceTier4to6) and further increased (*iRewardValueMult). In other words, just keep in sync with the sell price of tier4 weapons.

iDataColumns=5;astrItemList=( 
  #place here mainly the best items of the game that may not be found otherwise as trader's inv is empty for TNM
   #strShortNameId can be empty
   #iSellPriceTier4 is for player lvl1 and tier 4 quality if it has tiers. if 0 will be automatic if possible
   
  #Columns:
  #token          id                      shortNameId   iSellPriceTier4   addhelp
  
  #"item_modifier" modGunScopeMedium       "Scope4x"                  61    ""
  #"item_modifier" modGunScopeLarge        "Scope8x"                  68    ""
  
  #CODEGEN: xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="gun[^"]*t3[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(gun.*T3)(.*)@"item" \2\3 "WT3\3" 0@' |tr -d '\r\0' |sort -u
  "item" gunBotT3JunkDrone "WT3JunkDrone" 0 ""
  "item" gunBowT3CompoundBow "WT3CompoundBow" 0 ""
  "item" gunBowT3CompoundCrossbow "WT3CompoundCrossbow" 0 ""
  "item" gunExplosivesT3RocketLauncher "WT3RocketLauncher" 0 ""
  "item" gunHandgunT3DesertVulture "WT3DesertVulture" 0 ""
  "item" gunHandgunT3SMG5 "WT3SMG5" 0 ""
  "item" gunMGT3M60 "WT3M60" 0 ""
  "item" gunRifleT3SniperRifle "WT3SniperRifle" 0 ""
  "item" gunShotgunT3AutoShotgun "WT3AutoShotgun" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="melee[^"]*t3[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(melee.*T3)(.*)@"item" \2\3 "WT3\3" 0@' |tr -d '\r\0' |sort -u
  "item" meleeToolAxeT3Chainsaw "WT3Chainsaw" 0 ""
  "item" meleeToolPickT3Auger "WT3Auger" 0 ""
  "item" meleeToolRepairT3Nailgun "WT3Nailgun" 0 ""
  "item" meleeToolSalvageT3ImpactDriver "WT3ImpactDriver" 0 ""
  #"item" meleeWpnBatonT3PlasmaBaton "PlasmaBaton" 0 ""
  "item" meleeWpnBladeT3Machete "WT3Machete" 0 ""
  "item" meleeWpnClubT3SteelClub "WT3SteelClub" 0 ""
  "item" meleeWpnKnucklesT3SteelKnuckles "WT3SteelKnuckles" 0 ""
  "item" meleeWpnSledgeT3SteelSledgehammer "WT3SteelSledgehammer" 0 ""
  "item" meleeWpnSpearT3SteelSpear "WT3SteelSpear" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="melee[^"]*t2[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic" |sed -r 's@(<item *name=")(melee.*T2)(.*)@"item" \2\3 "WT2\3" 0@' |tr -d '\r\0' |sort -u
  "item" meleeToolAxeT2SteelAxe "WT2SteelAxe" 0 ""
  "item" meleeToolPickT2SteelPickaxe "WT2SteelPickaxe" 0 ""
  "item" meleeToolSalvageT2Ratchet "WT2Ratchet" 0 ""
  "item" meleeToolShovelT2SteelShovel "WT2SteelShovel" 0 ""
  "item" meleeWpnBatonT2StunBaton "WT2StunBaton" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armorSteel[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorSteel)(.*)@"item" \2\3 "OTF\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorSteelBoots "OTFBoots" 0 ""
  "item" armorSteelChest "OTFChest" 0 ""
  "item" armorSteelGloves "OTFGloves" 0 ""
  "item" armorSteelHelmet "OTFHelmet" 0 ""
  "item" armorSteelLegs "OTFLegs" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armorMilitary[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorMilitary)(.*)@"item" \2\3 "OTF\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorMilitaryBoots "OTFBoots" 0 ""
  "item" armorMilitaryGloves "OTFGloves" 0 ""
  "item" armorMilitaryHelmet "OTFHelmet" 0 ""
  "item" armorMilitaryLegs "OTFLegs" 0 ""
  "item" armorMilitaryStealthBoots "OTFStealthBoots" 0 ""
  "item" armorMilitaryVest "OTFVest" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armor[^"]*Helmet[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armor)(.*)(Helmet)(.*)@"item" \2\3\4\5 "OTFHelmet\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorFirefightersHelmet "OTFHelmetFirefighters" 0 ""
  "item" armorFootballHelmet "OTFHelmetFootball" 0 ""
  #"item" armorFootballHelmetZU "OTFHelmetFootball" 0 ""
  #"item" armorIronHelmet "OTFHelmetIron" 0 ""
  #"item" armorMilitaryHelmet "OTFHelmetMilitary" 0 ""
  "item" armorMiningHelmet "OTFHelmetMining" 0 ""
  #"item" armorScrapHelmet "OTFHelmetScrap" 0 ""
  #"item" armorSteelHelmet "OTFHelmetSteel" 0 ""
  "item" armorSwatHelmet "OTFHelmetSwat" 0 ""
  
  "item" apparelGhillieSuitJacket "OTFGhillieJacket" ${iEndGameValue} "todo: create as armor mods too like hazmat mods"
  "item" apparelGhillieSuitPants "OTFGhilliePants" ${iEndGameValue} ""
  "item" apparelGhillieSuitHood "OTFGhillieHood" ${iEndGameValue} ""
  
  "item" apparelHazmatMask "OTFHazmatMask" ${iEndGameValue} ""
  "item" apparelHazmatGloves "OTFHazmatGloves" ${iEndGameValue} ""
  "item" apparelHazmatJacket "OTFHazmatJacket" ${iEndGameValue} ""
  "item" apparelHazmatPants "OTFHazmatPants" ${iEndGameValue} ""
  "item" apparelHazmatBoots "OTFHazmatBoots" ${iEndGameValue} ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item_modifier.*name="mod[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item_modifier *name=")(mod)(.*)@"item_modifier" \2\3 "Mod\3" 0@' |sort -u |sed 's@Mod"@"@'
  "item_modifier" modArmorAdvancedMuffledConnectors "ModArmorAdvancedMuffledConnectors" 0 ""
  "item_modifier" modArmorBallCap "ModArmorBallCap" 0 ""
  "item_modifier" modArmorBandolier "ModArmorBandolier" 0 ""
  "item_modifier" modArmorCoolingMesh "ModArmorCoolingMesh" 0 ""
  "item_modifier" modArmorCowboyHat "ModArmorCowboyHat" 0 ""
  "item_modifier" modArmorCustomizedFittings "ModArmorCustomizedFittings" $((iModGenericPrice*1/2)) "1/2 of improved"
  "item_modifier" modArmorDoubleStoragePocket "ModArmorDoubleStoragePocket" $((iModGenericPrice*2/3)) "2/3 of default iModGenericPrice that is tripple storagepocket"
  "item_modifier" modArmorHelmetLight "ModArmorHelmetLight" 0 ""
  "item_modifier" modArmorImpactBracing "ModArmorImpactBracing" 0 ""
  "item_modifier" modArmorImprovedFittings "ModArmorImprovedFittings" 0 ""
  "item_modifier" modArmorInsulatedLiner "ModArmorInsulatedLiner" 0 ""
  "item_modifier" modArmorJumpJets "ModArmorJumpJets" 0 ""
  "item_modifier" modArmorMuffledConnectors "ModArmorMuffledConnectors" $((iModGenericPrice*1/2)) "1/2 of advanced"
  "item_modifier" modArmorPlatingBasic "ModArmorPlatingBasic" $((iModGenericPrice*1/2)) "1/2 of reinforced"
  "item_modifier" modArmorPlatingReinforced "ModArmorPlatingReinforced" 0 ""
  "item_modifier" modArmorPressboyCap "ModArmorPressboyCap" 0 ""
  "item_modifier" modArmorSkullCap "ModArmorSkullCap" 0 ""
  "item_modifier" modArmorStoragePocket "ModArmorStoragePocket" $((iModGenericPrice*1/3)) "1/3 of default 100 that is tripple storagepocket"
  "item_modifier" modArmorTripleStoragePocket "ModArmorTripleStoragePocket" 0 ""
  "item_modifier" modArmorWaterPurifier "ModArmorWaterPurifier" 0 ""
  "item_modifier" modClothingCargoStoragePocket "ModClothingCargoStoragePocket" 0 ""
  "item_modifier" modClothingStoragePocket "ModClothingStoragePocket" $((iModGenericPrice*1/2)) "1/2 of cargo"
  "item_modifier" modCosmicRayShield "ModCosmicRayShield" 410 "collected sell price in-game"
  "item_modifier" modCowboyHat "ModCowboyHat" 0 ""
  "item_modifier" modDyeBlack "ModDyeBlack" 0 ""
  "item_modifier" modDyeBlue "ModDyeBlue" 0 ""
  "item_modifier" modDyeBrown "ModDyeBrown" 0 ""
  "item_modifier" modDyeGreen "ModDyeGreen" 0 ""
  "item_modifier" modDyePink "ModDyePink" 0 ""
  "item_modifier" modDyePurple "ModDyePurple" 0 ""
  "item_modifier" modDyeRed "ModDyeRed" 0 ""
  "item_modifier" modDyeWhite "ModDyeWhite" 0 ""
  "item_modifier" modDyeYellow "ModDyeYellow" 0 ""
  "item_modifier" modFuelTankLarge "ModFuelTankLarge" 0 ""
  "item_modifier" modFuelTankSmall "ModFuelTankSmall" $((iModGenericPrice*1/2)) "1/2 of large"
  "item_modifier" modGunBarrelExtender "ModGunBarrelExtender" 0 ""
  "item_modifier" modGunBipod "ModGunBipod" 0 ""
  "item_modifier" modGunBowArrowRest "ModGunBowArrowRest" 0 ""
  "item_modifier" modGunBowPolymerString "ModGunBowPolymerString" 0 ""
  "item_modifier" modGunButtkick3000 "ModGunButtkick3000" 0 ""
  "item_modifier" modGunButtkick4000 "ModGunButtkick4000" 0 ""
  "item_modifier" modGunChoke "ModGunChoke" 0 ""
  "item_modifier" modGunCrippleEm "ModGunCrippleEm" 0 ""
  "item_modifier" modGunDrumMagazineExtender "ModGunDrumMagazineExtender" 0 ""
  "item_modifier" modGunDuckbill "ModGunDuckbill" 0 ""
  "item_modifier" modGunFlashlight "ModGunFlashlight" 0 ""
  "item_modifier" modGunForegrip "ModGunForegrip" 0 ""
  "item_modifier" modGunLaserSight "ModGunLaserSight" 0 ""
  "item_modifier" modGunMagazineExtender "ModGunMagazineExtender" $((iModGenericPrice*1/2)) "1/2 of drum"
  "item_modifier" modGunMeleeBlessedMetal "ModGunMeleeBlessedMetal" 0 ""
  "item_modifier" modGunMeleeFlammableOil "ModGunMeleeFlammableOil" 0 ""
  "item_modifier" modGunMeleeLiquidNitrogen "ModGunMeleeLiquidNitrogen" 0 ""
  "item_modifier" modGunMeleeNiCdBattery "ModGunMeleeNiCdBattery" 0 ""
  "item_modifier" modGunMeleeRadRemover "ModGunMeleeRadRemover" 0 ""
  "item_modifier" modGunMeleeTheHunter "ModGunMeleeTheHunter" 0 ""
  "item_modifier" modGunMuzzleBrake "ModGunMuzzleBrake" 0 ""
  "item_modifier" modGunReflexSight "ModGunReflexSight" 0 ""
  "item_modifier" modGunRetractingStock "ModGunRetractingStock" 0 ""
  "item_modifier" modGunScopeLarge "ModGunScopeLarge" 0 ""
  "item_modifier" modGunScopeMedium "ModGunScopeMedium" $((iModGenericPrice*3/4)) ""
  "item_modifier" modGunScopeSmall "ModGunScopeSmall" $((iModGenericPrice*1/2)) ""
  "item_modifier" modGunShotgunTubeExtenderMagazine "ModGunShotgunTubeExtenderMagazine" 0 ""
  "item_modifier" modGunSoundSuppressorSilencer "ModGunSoundSuppressorSilencer" 0 ""
  "item_modifier" modGunTriggerGroupAutomatic "ModGunTriggerGroupAutomatic" 0 ""
  "item_modifier" modGunTriggerGroupBurst3 "ModGunTriggerGroupBurst3" 0 ""
  "item_modifier" modGunTriggerGroupSemi "ModGunTriggerGroupSemi" 0 ""
  "item_modifier" modHazmatBoots "ModHazmatBoots" ${iEndGameValue} ""
  "item_modifier" modHazmatGloves "ModHazmatGloves" ${iEndGameValue} ""
  "item_modifier" modHazmatMask "ModHazmatMask" ${iEndGameValue} ""
  "item_modifier" modMeleeBunkerBuster "ModMeleeBunkerBuster" 0 ""
  "item_modifier" modMeleeClubBarbedWire "ModMeleeClubBarbedWire" 0 ""
  "item_modifier" modMeleeClubBurningShaft "ModMeleeClubBurningShaft" 0 ""
  "item_modifier" modMeleeClubMetalChain "ModMeleeClubMetalChain" 0 ""
  "item_modifier" modMeleeClubMetalSpikes "ModMeleeClubMetalSpikes" 0 ""
  "item_modifier" modMeleeDiamondTip "ModMeleeDiamondTip" 400 "collected sell price in-game"
  "item_modifier" modMeleeErgonomicGrip "ModMeleeErgonomicGrip" 0 ""
  "item_modifier" modMeleeFiremansAxeMod "ModMeleeFiremansAxe" 0 ""
  "item_modifier" modMeleeFortifyingGrip "ModMeleeFortifyingGrip" 0 ""
  "item_modifier" modMeleeGraveDigger "ModMeleeGraveDigger" 0 ""
  "item_modifier" modMeleeGunToolDecapitizer "ModMeleeGunToolDecapitizer" 0 ""
  "item_modifier" modMeleeIronBreaker "ModMeleeIronBreaker" 0 ""
  "item_modifier" modMeleeSerratedBlade "ModMeleeSerratedBlade" 0 ""
  "item_modifier" modMeleeStructuralBrace "ModMeleeStructuralBrace" 0 ""
  "item_modifier" modMeleeStunBatonRepulsor "ModMeleeStunBatonRepulsor" 0 ""
  "item_modifier" modMeleeTemperedBlade "ModMeleeTemperedBlade" 0 ""
  "item_modifier" modMeleeWeightedHead "ModMeleeWeightedHead" 0 ""
  "item_modifier" modMeleeWoodSplitter "ModMeleeWoodSplitter" 0 ""
  "item_modifier" modRadiationReady "ModRadiationReady" 0 ""
  "item_modifier" modRoboticDroneArmorPlatingMod "ModRoboticDroneArmorPlating" 0 ""
  "item_modifier" modRoboticDroneCargoMod "ModRoboticDroneCargo" 0 ""
  "item_modifier" modRoboticDroneHeadlampMod "ModRoboticDroneHeadlamp" 0 ""
  "item_modifier" modRoboticDroneMedicMod "ModRoboticDroneMedic" 0 ""
  "item_modifier" modRoboticDroneMoraleBoosterMod "ModRoboticDroneMoraleBooster" 0 ""
  "item_modifier" modRoboticDroneStunWeaponMod "ModRoboticDroneStunWeapon" 0 ""
  "item_modifier" modRoboticDroneWeaponMod "ModRoboticDroneWeapon" 0 ""
  "item_modifier" modShotgunSawedOffBarrel "ModShotgunSawedOffBarrel" 0 ""
  "item_modifier" modVehicleExpandedSeat "ModVehicleExpandedSeat" 0 ""
  "item_modifier" modVehicleFuelSaver "ModVehicleFuelSaver" 0 ""
  "item_modifier" modVehicleMega "ModVehicleMega" 0 ""
  "item_modifier" modVehicleOffRoadHeadlights "ModVehicleOffRoadHeadlights" 0 ""
  "item_modifier" modVehicleReserveFuelTank "ModVehicleReserveFuelTank" 0 ""
  "item_modifier" modVehicleSuperCharger "ModVehicleSuperCharger" 0 ""
  
  "item" potionRespec "CSMRebirthElixir" 360 "cheap compared to drinkJarGrandpasForgettingElixir as  it has many debuffs and the player may need it"
  #clear;xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="(drink|drug)[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "Empty|Admin|Schematic|drugHealInfectedCharacter|drugHealthBar|(GSK.*essence)|drinkJarGrandpasForgettingElixir" |sed -r 's@(<item *name=")(drink|drug)(.*)@  "item" \2\3 "CSM\3" 0@' |tr -d '\r\0' |sort -u
  "item" drinkCanMegaCrush "CSMCanMegaCrush" 0 ""
  "item" drinkJarBeer "CSMJarBeer" 0 ""
  "item" drinkJarBlackStrapCoffee "CSMJarBlackStrapCoffee" 0 ""
  "item" drinkJarBoiledWater "CSMJarBoiledWater" 0 ""
  "item" drinkJarCoffee "CSMJarCoffee" 0 ""
  "item" drinkJarGoldenRodTea "CSMJarGoldenRodTea" 0 ""
  "item" drinkJarGrandpasAwesomeSauce "CSMJarGrandpasAwesomeSauce" 0 ""
  "item" drinkJarGrandpasLearningElixir "CSMJarGrandpasLearningElixir" 0 ""
  "item" drinkJarGrandpasMoonshine "CSMJarGrandpasMoonshine" 0 ""
  "item" drinkJarPureMineralWater "CSMJarPureMineralWater" 0 ""
  "item" drinkJarRedTea "CSMJarRedTea" 0 ""
  "item" drinkJarRiverWater "CSMJarRiverWater" 0 ""
  "item" drinkJarYuccaCocktail "CSMJarYuccaCocktail" 0 ""
  "item" drinkJarYuccaJuice "CSMJarYuccaJuice" 0 ""
  "item" drinkYuccaJuiceSmoothie "CSMYuccaJuiceSmoothie" 0 ""
  "item" drugAntibiotics "CSMAntibiotics" 0 ""
  "item" drugAtomJunkies "CSMAtomJunkies" 0 ""
  "item" drugCovertCats "CSMCovertCats" 0 ""
  "item" drugEyeKandy "CSMEyeKandy" 1000 "CSM final price override, some advantage on finding items (was EcV100)"
  "item" drugFortBites "CSMFortBites" 0 ""
  "item" drugGSKAntiRadiation "CSMGSKAntiRadiation" 0 ""
  "item" drugGSKAntiRadiationSlow "CSMGSKAntiRadiationSlow" 0 ""
  "item" drugGSKAntiRadiationStrong "CSMGSKAntiRadiationStrong" 0 ""
  "item" drugGSKHealthTreatment "CSMGSKHealthTreatment" 0 ""
  "item" drugGSKPsyonicsResist "CSMGSKPsyonicsResist" 0 ""
  "item" drugGSKRadiationResist "CSMGSKRadiationResist" 0 ""
  "item" drugGSKsnakePoisonAntidote "CSMGSKsnakePoisonAntidote" 0 ""
  "item" drugHackers "CSMHackers" 0 ""
  "item" drugHerbalAntibiotics "CSMHerbalAntibiotics" 0 ""
  "item" drugJailBreakers "CSMJailBreakers" 3000 "CSM final price override, as it lasts enough to open many locks w/o losing the lockpick"
  "item" drugNerdTats "CSMNerdTats" 0 ""
  "item" drugOhShitzDrops "CSMOhShitzDrops" 0 ""
  "item" drugPainkillers "CSMPainkillers" 0 ""
  "item" drugRecog "CSMRecog" 0 ""
  "item" drugRockBusters "CSMRockBusters" 0 ""
  "item" drugSkullCrushers "CSMSkullCrushers" 0 ""
  "item" drugSteroids "CSMSteroids" 0 ""
  "item" drugSugarButts "CSMSugarButts" 1000 "CSM final price override, good advantage on trading (was EcV100)"
  "item" drugVitamins "CSMVitamins" 0 ""
  
  #clear;xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="[^"]*Schematic"' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi '^GSK|WerewolftoHuman|Faction|ZombieW7WalkStyle|IsInfected' |sed -r 's@(<item *name=")(.*)(Schematic)"@  "item" \2\3 "SCH\2" 0@' |tr -d '\r\0' |sort -u
  "item" ammoGasCanSchematic "SCHammoGasCan" 0 ""
  "item" armorIronSetSchematic "SCHarmorIronSet" 0 ""
  "item" armorLeatherSetSchematic "SCHarmorLeatherSet" 0 ""
  "item" armorMilitarySetSchematic "SCHarmorMilitarySet" 0 ""
  "item" armorSteelSetSchematic "SCHarmorSteelSet" 0 ""
  "item" autoTurretSchematic "SCHautoTurret" 0 ""
  "item" batterybankSchematic "SCHbatterybank" 0 ""
  "item" bladeTrapSchematic "SCHbladeTrap" 0 ""
  "item" cementMixerSchematic "SCHcementMixer" 0 ""
  "item" chemistryStationSchematic "SCHchemistryStation" 0 ""
  "item" dartTrapSchematic "SCHdartTrap" 0 ""
  "item" drinkJarBeerSchematic "SCHdrinkJarBeer" 0 ""
  "item" drinkJarCoffeeSchematic "SCHdrinkJarCoffee" 0 ""
  "item" drinkJarGoldenRodTeaSchematic "SCHdrinkJarGoldenRodTea" 0 ""
  "item" drinkJarGrandpasAwesomeSauceSchematic "SCHdrinkJarGrandpasAwesomeSauce" 0 ""
  "item" drinkJarGrandpasLearningElixirSchematic "SCHdrinkJarGrandpasLearningElixir" 0 ""
  "item" drinkJarGrandpasMoonshineSchematic "SCHdrinkJarGrandpasMoonshine" 0 ""
  "item" drinkJarRedTeaSchematic "SCHdrinkJarRedTea" 0 ""
  "item" drinkYuccaJuiceSmoothieSchematic "SCHdrinkYuccaJuiceSmoothie" 0 ""
  "item" drugAntibioticsSchematic "SCHdrugAntibiotics" 0 ""
  "item" drugHerbalAntibioticsSchematic "SCHdrugHerbalAntibiotics" 0 ""
  "item" electricfencepostSchematic "SCHelectricfencepost" 0 ""
  "item" electrictimerrelaySchematic "SCHelectrictimerrelay" 0 ""
  "item" foodBaconAndEggsSchematic "SCHfoodBaconAndEggs" 0 ""
  "item" foodBakedPotatoSchematic "SCHfoodBakedPotato" 0 ""
  "item" foodBlueberryPieSchematic "SCHfoodBlueberryPie" 0 ""
  "item" foodBoiledMeatBundleSchematic "SCHfoodBoiledMeatBundle" 0 ""
  "item" foodBoiledMeatSchematic "SCHfoodBoiledMeat" 0 ""
  "item" foodCanShamSchematic "SCHfoodCanSham" 0 ""
  "item" foodChiliDogSchematic "SCHfoodChiliDog" 0 ""
  "item" foodCornBreadSchematic "SCHfoodCornBread" 0 ""
  "item" foodCornOnTheCobSchematic "SCHfoodCornOnTheCob" 0 ""
  "item" foodFishTacosSchematic "SCHfoodFishTacos" 0 ""
  "item" foodGrilledMeatSchematic "SCHfoodGrilledMeat" 0 ""
  "item" foodGumboStewSchematic "SCHfoodGumboStew" 0 ""
  "item" foodHoboStewSchematic "SCHfoodHoboStew" 0 ""
  "item" foodMeatStewSchematic "SCHfoodMeatStew" 0 ""
  "item" foodPumpkinBreadSchematic "SCHfoodPumpkinBread" 0 ""
  "item" foodPumpkinCheesecakeSchematic "SCHfoodPumpkinCheesecake" 0 ""
  "item" foodPumpkinPieSchematic "SCHfoodPumpkinPie" 0 ""
  "item" foodShamChowderSchematic "SCHfoodShamChowder" 0 ""
  "item" foodShepardsPieSchematic "SCHfoodShepardsPie" 0 ""
  "item" foodSpaghettiSchematic "SCHfoodSpaghetti" 0 ""
  "item" foodSteakAndPotatoSchematic "SCHfoodSteakAndPotato" 0 ""
  "item" foodTunaFishGravyToastSchematic "SCHfoodTunaFishGravyToast" 0 ""
  "item" foodVegetableStewSchematic "SCHfoodVegetableStew" 0 ""
  "item" forgeSchematic "SCHforge" 0 ""
  "item" generatorbankSchematic "SCHgeneratorbank" 0 ""
  "item" gunBotT1JunkSledgeSchematic "SCHgunBotT1JunkSledge" 0 ""
  "item" gunBotT2JunkTurretSchematic "SCHgunBotT2JunkTurret" 0 ""
  "item" gunBotT3JunkDroneSchematic "SCHgunBotT3JunkDrone" 0 ""
  "item" gunBowT1IronCrossbowSchematic "SCHgunBowT1IronCrossbow" 0 ""
  "item" gunBowT1WoodenBowSchematic "SCHgunBowT1WoodenBow" 0 ""
  "item" gunBowT3CompoundBowSchematic "SCHgunBowT3CompoundBow" 0 ""
  "item" gunBowT3CompoundCrossbowSchematic "SCHgunBowT3CompoundCrossbow" 0 ""
  "item" gunExplosivesT3RocketLauncherSchematic "SCHgunExplosivesT3RocketLauncher" 0 ""
  "item" gunHandgunT1PistolSchematic "SCHgunHandgunT1Pistol" 0 ""
  "item" gunHandgunT2Magnum44Schematic "SCHgunHandgunT2Magnum44" 0 ""
  "item" gunHandgunT3DesertVultureSchematic "SCHgunHandgunT3DesertVulture" 0 ""
  "item" gunHandgunT3SMG5Schematic "SCHgunHandgunT3SMG5" 0 ""
  "item" gunMGT1AK47Schematic "SCHgunMGT1AK47" 0 ""
  "item" gunMGT2TacticalARSchematic "SCHgunMGT2TacticalAR" 0 ""
  "item" gunMGT3M60Schematic "SCHgunMGT3M60" 0 ""
  "item" gunRifleT1HuntingRifleSchematic "SCHgunRifleT1HuntingRifle" 0 ""
  "item" gunRifleT2LeverActionRifleSchematic "SCHgunRifleT2LeverActionRifle" 0 ""
  "item" gunRifleT3SniperRifleSchematic "SCHgunRifleT3SniperRifle" 0 ""
  "item" gunShotgunT1DoubleBarrelSchematic "SCHgunShotgunT1DoubleBarrel" 0 ""
  "item" gunShotgunT2PumpShotgunSchematic "SCHgunShotgunT2PumpShotgun" 0 ""
  "item" gunShotgunT3AutoShotgunSchematic "SCHgunShotgunT3AutoShotgun" 0 ""
  "item" HumantoWerewolfSchematic "SCHHumantoWerewolf" 0 ""
  "item" medicalFirstAidBandageSchematic "SCHmedicalFirstAidBandage" 0 ""
  "item" medicalFirstAidKitSchematic "SCHmedicalFirstAidKit" 0 ""
  "item" medicalPlasterCastSchematic "SCHmedicalPlasterCast" 0 ""
  "item" meleeToolAxeT3ChainsawSchematic "SCHmeleeToolAxeT3Chainsaw" 0 ""
  "item" meleeToolFarmT1IronHoeSchematic "SCHmeleeToolFarmT1IronHoe" 0 ""
  "item" meleeToolIronSetSchematic "SCHmeleeToolIronSet" 0 ""
  "item" meleeToolPickT3AugerSchematic "SCHmeleeToolPickT3Auger" 0 ""
  "item" meleeToolRepairT3NailgunSchematic "SCHmeleeToolRepairT3Nailgun" 0 ""
  "item" meleeToolSalvageT1WrenchSchematic "SCHmeleeToolSalvageT1Wrench" 0 ""
  "item" meleeToolSalvageT2RatchetSchematic "SCHmeleeToolSalvageT2Ratchet" 0 ""
  "item" meleeToolSalvageT3ImpactDriverSchematic "SCHmeleeToolSalvageT3ImpactDriver" 0 ""
  "item" meleeToolSteelSetSchematic "SCHmeleeToolSteelSet" 0 ""
  "item" meleeWpnBatonT2StunBatonSchematic "SCHmeleeWpnBatonT2StunBaton" 0 ""
  "item" meleeWpnBladeT1HuntingKnifeSchematic "SCHmeleeWpnBladeT1HuntingKnife" 0 ""
  "item" meleeWpnBladeT3MacheteSchematic "SCHmeleeWpnBladeT3Machete" 0 ""
  "item" meleeWpnClubT1BaseballBatSchematic "SCHmeleeWpnClubT1BaseballBat" 0 ""
  "item" meleeWpnKnucklesT1IronKnucklesSchematic "SCHmeleeWpnKnucklesT1IronKnuckles" 0 ""
  "item" meleeWpnKnucklesT3SteelKnucklesSchematic "SCHmeleeWpnKnucklesT3SteelKnuckles" 0 ""
  "item" meleeWpnSledgeT1IronSledgehammerSchematic "SCHmeleeWpnSledgeT1IronSledgehammer" 0 ""
  "item" meleeWpnSledgeT3SteelSledgehammerSchematic "SCHmeleeWpnSledgeT3SteelSledgehammer" 0 ""
  "item" meleeWpnSpearT1IronSpearSchematic "SCHmeleeWpnSpearT1IronSpear" 0 ""
  "item" modArmorAdvancedMuffledConnectorsSchematic "SCHmodArmorAdvancedMuffledConnectors" 0 ""
  "item" modArmorBandolierSchematic "SCHmodArmorBandolier" 0 ""
  "item" modArmorCoolingMeshSchematic "SCHmodArmorCoolingMesh" 0 ""
  "item" modArmorCustomizedFittingsSchematic "SCHmodArmorCustomizedFittings" 0 ""
  "item" modArmorDoubleStoragePocketSchematic "SCHmodArmorDoubleStoragePocket" 0 ""
  "item" modArmorHelmetLightSchematic "SCHmodArmorHelmetLight" 0 ""
  "item" modArmorImpactBracingSchematic "SCHmodArmorImpactBracing" 0 ""
  "item" modArmorImprovedFittingsSchematic "SCHmodArmorImprovedFittings" 0 ""
  "item" modArmorInsulatedLinerSchematic "SCHmodArmorInsulatedLiner" 0 ""
  "item" modArmorMuffledConnectorsSchematic "SCHmodArmorMuffledConnectors" 0 ""
  "item" modArmorPlatingBasicSchematic "SCHmodArmorPlatingBasic" 0 ""
  "item" modArmorPlatingReinforcedSchematic "SCHmodArmorPlatingReinforced" 0 ""
  "item" modArmorStoragePocketSchematic "SCHmodArmorStoragePocket" 0 ""
  "item" modArmorTripleStoragePocketSchematic "SCHmodArmorTripleStoragePocket" 0 ""
  "item" modArmorWaterPurifierSchematic "SCHmodArmorWaterPurifier" 0 ""
  "item" modFuelTankLargeSchematic "SCHmodFuelTankLarge" 0 ""
  "item" modFuelTankSmallSchematic "SCHmodFuelTankSmall" 0 ""
  "item" modGunBarrelExtenderSchematic "SCHmodGunBarrelExtender" 0 ""
  "item" modGunBipodSchematic "SCHmodGunBipod" 0 ""
  "item" modGunBowArrowRestSchematic "SCHmodGunBowArrowRest" 0 ""
  "item" modGunBowPolymerStringSchematic "SCHmodGunBowPolymerString" 0 ""
  "item" modGunChokeSchematic "SCHmodGunChoke" 0 ""
  "item" modGunCrippleEmSchematic "SCHmodGunCrippleEm" 0 ""
  "item" modGunDuckbillSchematic "SCHmodGunDuckbill" 0 ""
  "item" modGunFlashlightSchematic "SCHmodGunFlashlight" 0 ""
  "item" modGunForegripSchematic "SCHmodGunForegrip" 0 ""
  "item" modGunLaserSightSchematic "SCHmodGunLaserSight" 0 ""
  "item" modGunMagazineExtenderSchematic "SCHmodGunMagazineExtender" 0 ""
  "item" modGunMeleeBlessedMetalSchematic "SCHmodGunMeleeBlessedMetal" 0 ""
  "item" modGunMeleeRadRemoverSchematic "SCHmodGunMeleeRadRemover" 0 ""
  "item" modGunMeleeTheHunterSchematic "SCHmodGunMeleeTheHunter" 0 ""
  "item" modGunMuzzleBrakeSchematic "SCHmodGunMuzzleBrake" 0 ""
  "item" modGunReflexSightSchematic "SCHmodGunReflexSight" 0 ""
  "item" modGunRetractingStockSchematic "SCHmodGunRetractingStock" 0 ""
  "item" modGunScopeLargeSchematic "SCHmodGunScopeLarge" 0 ""
  "item" modGunScopeMediumSchematic "SCHmodGunScopeMedium" 0 ""
  "item" modGunScopeSmallSchematic "SCHmodGunScopeSmall" 0 ""
  "item" modGunSoundSuppressorSilencerSchematic "SCHmodGunSoundSuppressorSilencer" 0 ""
  "item" modGunTriggerGroupAutomaticSchematic "SCHmodGunTriggerGroupAutomatic" 0 ""
  "item" modGunTriggerGroupBurst3Schematic "SCHmodGunTriggerGroupBurst3" 0 ""
  "item" modGunTriggerGroupSemiSchematic "SCHmodGunTriggerGroupSemi" 0 ""
  "item" modMeleeBunkerBusterSchematic "SCHmodMeleeBunkerBuster" 0 ""
  "item" modMeleeClubBarbedWireSchematic "SCHmodMeleeClubBarbedWire" 0 ""
  "item" modMeleeClubBurningShaftSchematic "SCHmodMeleeClubBurningShaft" 0 ""
  "item" modMeleeClubMetalSpikesSchematic "SCHmodMeleeClubMetalSpikes" 0 ""
  "item" modMeleeErgonomicGripSchematic "SCHmodMeleeErgonomicGrip" 0 ""
  "item" modMeleeFortifyingGripSchematic "SCHmodMeleeFortifyingGrip" 0 ""
  "item" modMeleeGraveDiggerSchematic "SCHmodMeleeGraveDigger" 0 ""
  "item" modMeleeIronBreakerSchematic "SCHmodMeleeIronBreaker" 0 ""
  "item" modMeleeSerratedBladeSchematic "SCHmodMeleeSerratedBlade" 0 ""
  "item" modMeleeStructuralBraceSchematic "SCHmodMeleeStructuralBrace" 0 ""
  "item" modMeleeTemperedBladeSchematic "SCHmodMeleeTemperedBlade" 0 ""
  "item" modMeleeWeightedHeadSchematic "SCHmodMeleeWeightedHead" 0 ""
  "item" modMeleeWoodSplitterSchematic "SCHmodMeleeWoodSplitter" 0 ""
  "item" modRoboticDroneArmorPlatingModSchematic "SCHmodRoboticDroneArmorPlatingMod" 0 ""
  "item" modRoboticDroneCargoModSchematic "SCHmodRoboticDroneCargoMod" 0 ""
  "item" modRoboticDroneHeadlampModSchematic "SCHmodRoboticDroneHeadlampMod" 0 ""
  "item" modRoboticDroneMedicModSchematic "SCHmodRoboticDroneMedicMod" 0 ""
  "item" modRoboticDroneMoraleBoosterModSchematic "SCHmodRoboticDroneMoraleBoosterMod" 0 ""
  "item" modShotgunSawedOffBarrelSchematic "SCHmodShotgunSawedOffBarrel" 0 ""
  "item" modVehicleExpandedSeatSchematic "SCHmodVehicleExpandedSeat" 0 ""
  "item" modVehicleFuelSaverSchematic "SCHmodVehicleFuelSaver" 0 ""
  "item" modVehicleOffRoadHeadlightsSchematic "SCHmodVehicleOffRoadHeadlights" 0 ""
  "item" modVehicleReserveFuelTankSchematic "SCHmodVehicleReserveFuelTank" 0 ""
  "item" modVehicleSuperChargerSchematic "SCHmodVehicleSuperCharger" 0 ""
  "item" motionsensorSchematic "SCHmotionsensor" 0 ""
  "item" plantedAloe1Schematic "SCHplantedAloe1" 0 ""
  "item" plantedBlueberry1Schematic "SCHplantedBlueberry1" 0 ""
  "item" plantedChrysanthemum1Schematic "SCHplantedChrysanthemum1" 0 ""
  "item" plantedCoffee1Schematic "SCHplantedCoffee1" 0 ""
  "item" plantedCorn1Schematic "SCHplantedCorn1" 0 ""
  "item" plantedCotton1Schematic "SCHplantedCotton1" 0 ""
  "item" plantedGoldenrod1Schematic "SCHplantedGoldenrod1" 0 ""
  "item" plantedGraceCorn1Schematic "SCHplantedGraceCorn1" 0 ""
  "item" plantedHop1Schematic "SCHplantedHop1" 0 ""
  "item" plantedMushroom1Schematic "SCHplantedMushroom1" 0 ""
  "item" plantedPotato1Schematic "SCHplantedPotato1" 0 ""
  "item" plantedPumpkin1Schematic "SCHplantedPumpkin1" 0 ""
  "item" plantedYucca1Schematic "SCHplantedYucca1" 0 ""
  "item" poweredDoorsSchematic "SCHpoweredDoors" 0 ""
  "item" pressureplateSchematic "SCHpressureplate" 0 ""
  "item" resourceMilitaryFiberSchematic "SCHresourceMilitaryFiber" 0 ""
  "item" resourceOilSchematic "SCHresourceOil" 0 ""
  "item" shotgunTurretSchematic "SCHshotgunTurret" 0 ""
  "item" speakerSchematic "SCHspeaker" 0 ""
  "item" spotlightPlayerSchematic "SCHspotlightPlayer" 0 ""
  "item" switchSchematic "SCHswitch" 0 ""
  "item" thrownAmmoPipeBombSchematic "SCHthrownAmmoPipeBomb" 0 ""
  "item" thrownDynamiteSchematic "SCHthrownDynamite" 0 ""
  "item" thrownGrenadeContactSchematic "SCHthrownGrenadeContact" 0 ""
  "item" thrownGrenadeSchematic "SCHthrownGrenade" 0 ""
  "item" toolAnvilSchematic "SCHtoolAnvil" 0 ""
  "item" toolBellowsSchematic "SCHtoolBellows" 0 ""
  "item" toolForgeCrucibleSchematic "SCHtoolForgeCrucible" 0 ""
  "item" vehicle4x4TruckAccessoriesSchematic "SCHvehicle4x4TruckAccessories" 0 ""
  "item" vehicle4x4TruckChassisSchematic "SCHvehicle4x4TruckChassis" 0 ""
  "item" vehicleAnySchematic "SCHvehicleAny" 0 ""
  "item" vehicleBicycleChassisSchematic "SCHvehicleBicycleChassis" 0 ""
  "item" vehicleBicycleHandlebarsSchematic "SCHvehicleBicycleHandlebars" 0 ""
  "item" vehicleGyroCopterAccessoriesSchematic "SCHvehicleGyroCopterAccessories" 0 ""
  "item" vehicleGyroCopterChassisSchematic "SCHvehicleGyroCopterChassis" 0 ""
  "item" vehicleMinibikeChassisSchematic "SCHvehicleMinibikeChassis" 0 ""
  "item" vehicleMinibikeHandlebarsSchematic "SCHvehicleMinibikeHandlebars" 0 ""
  "item" vehicleMotorcycleChassisSchematic "SCHvehicleMotorcycleChassis" 0 ""
  "item" vehicleMotorcycleHandlebarsSchematic "SCHvehicleMotorcycleHandlebars" 0 ""
  "item" workbenchSchematic "SCHworkbench" 0 ""

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

astrLocList=()
iUpdateEcoItemValCache=0
iUpdateItemHasTiersCache=0
declare -A astrPrevItemNameList
#for strItem in "${astrItemList[@]}";do
#set -x
for((iDataLnIniIndex=0;iDataLnIniIndex<${#astrItemList[@]};iDataLnIniIndex+=iDataColumns));do
  declare -p iDataLnIniIndex
  strXmlToken="${astrItemList[iDataLnIniIndex]}";echo ">>>>>>>>>> $strXmlToken" #item type
  strItem="${astrItemList[iDataLnIniIndex+1]}"
  strShortNameId="${astrItemList[iDataLnIniIndex+2]}" #shall begin with a 3 letter unique group token
  iSellPriceTier4="${astrItemList[iDataLnIniIndex+3]}";CFGFUNCchkNum "$iSellPriceTier4"
  strAddHelp="${astrItemList[iDataLnIniIndex+4]}"
  
  strHelp=""
  
  strCreativeMode="${CFGastrCacheItem1CreativeMode2List[${strItem}]-}" #tries the cache
  if [[ -z "$strCreativeMode" ]];then
    if CFGFUNCrecursiveSearchPropertyValueAllFiles --no-recursive "CreativeMode" "$strItem";then
      strCreativeMode="$iFRSPV_PropVal_OUT"
      strCreativeMode="`echo "$strCreativeMode" |tr "[:upper:]" "[:lower:]"`"
    fi
    if [[ -z "$strCreativeMode" ]];then
      strCreativeMode="player"
    fi
    CFGastrCacheItem1CreativeMode2List["${strItem}"]="$strCreativeMode"
  fi
  if [[ "$strCreativeMode" =~ .*(none|dev|test).* ]];then
    CFGFUNCinfo "skip $strItem strCreativeMode='$strCreativeMode'"
    continue
  fi
  
  iCountOrTier=0
  
  if [[ -z "$strShortNameId" ]];then strShortNameId="$strItem";fi
  
  if [[ "$strXmlToken" == "item_modifier" ]] && ((iSellPriceTier4==0));then
    iSellPriceTier4=100 # most mods have and average price about 33 I think. a few are around 75 to 115. anyway, this will be an ok value to most as there seem to have no other way to collect than in-game clicking one by one... So overall, the cheaper ones being costy will compensate for the costier ones being cheap ;).
    strHelp+=",Mod:UsingADefaultAverageValue"
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
        CFGFUNCerrorExit "strItem='$strItem' auto price 'EconomicValue' failed, assign a custom price, collet it from ingame sell price at inventory";
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
  if [[ "$strItem" =~ .*Dye.* ]];then #cosmetics (have no advantages, unless if PVP as cammo)
    ((iRewardValue/=10))&&: #240 (based on the collected value)
  fi
  if [[ "${strShortNameId:0:3}" == "CSM" ]];then #consumables (may be used often w/o problems)
    if((iSellPriceTier4==0));then #cfg=0 means to use automatic values
      iRewardValue=$((iEconomicValue*3))
    else
      iRewardValue=$iSellPriceTier4 # is a direct override for CSM
    fi
  fi
  
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
    fi
    if [[ -z "$strCustomIcon" ]];then
      strCustomIcon="${strItem}" #default
    fi
    CFGastrCacheItem1CustomIcon2List["${strItem}"]="$strCustomIcon"
    #declare -p strCustomIcon iFRSPV_PropVal_OUT strItem;exit #TODORM
  fi
  
  strItemName='GSKTNMER'"`printf "%05d" "$iRewardValue"`${strShortNameId}"''
  #for((iChkItemNm=0;iChkItemNm<${#astrPrevItemNameList[@]};iChkItemNm++));do if [[ "${astrPrevItemNameList[iChkItemNm]}" == "$strItemName" ]];then CFGFUNCerrorExit "item name clash: $strItemName, $strItem";fi;done
  for strItemChk in ${!astrPrevItemNameList[@]};do if [[ "${astrPrevItemNameList[$strItemChk]}" == "$strItemName" ]];then CFGFUNCerrorExit "item name clash: '$strItemName' $strItemChk vs $strItem";fi;done
  astrPrevItemNameList[${strItem}]="$strItemName"
  
  strDk='dkGSKTNMExplrRwd'"${strItem}"''
  
  
  ##################### COMPLETE IT ############################
  
  # egrep 'GSKTNMER' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/items.xml |sort
  strCourier="eventGSKSpwCourier" # most good mods
  if((iRewardValue>3000));then strCourier="eventGSKSpwCourierStrong";fi # top tier
  if((iRewardValue<1000));then strCourier="eventGSKSpwCourierWeak";fi # cheap stuff
  echo '
    <item name="'"${strItemName}"'">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${strCustomIcon}"'" />
      <property name="CustomIconTint" value="200,200,100" help="was 180,180,128"/>
      <property name="ItemTypeIcon" value="treasure" />
      <property name="DescriptionKey" value="'"${strDk}"'" />
      <property class="Action0">
        <requirement name="CVarCompare" cvar="iGSKexplorationCredits" operation="GTE" value="'"${iRewardValue}"'" help="'"${strHelp}; ${strAddHelp}; Dbg:EcV=${iEconomicValue},t4=${iSellPriceTier4},t6=${iSellPriceTier6}"'"/>
        <property name="Create_item" value="'"${strItem}"'" />
        <property name="Create_item_count" value="'"${iCountOrTier}"'" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" target="self" cvar="iGSKexplorationCredits" operation="add" value="-'"${iRewardValue}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="CallGameEvent" event="'"${strCourier}"'"/>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ShowToolbeltMessage" message="[TNM] A courier brings the package to you."/>
      </effect_group>
    </item>' >>"${strFlGenIte}${strGenTmpSuffix}"
  echo '<recipe name="'"${strItemName}"'" count="1"/>' >>"${strFlGenRec}${strGenTmpSuffix}"
#dkGSKTNMExplrRewardScope8x,"This exploring reward requires 5160, and you have {cvar(iGSKexplorationCredits:0)} exploring credits."
  astrLocList+=("${strDk},\"[TheNoMad:ExploringReward]\nThis exploring reward requires ${iRewardValue} credits.\nYou still have {cvar(iGSKexplorationCredits:0)} exploring credits.\nA courier will bring the reward to you.\nTo collect POI exploring reward credits you must be careful, read exploring tip about such rewards if you need.\n It is not possible to get all rewards, so chose wisely.\"")
  if((iUpdateEcoItemValCache%10==0)) || ((iUpdateItemHasTiersCache%10==0));then CFGFUNCwriteCaches;fi
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

CFGFUNCgencodeApply "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"

for strLoc in "${astrLocList[@]}";do
  echo "$strLoc" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
done
CFGFUNCgencodeApply "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
