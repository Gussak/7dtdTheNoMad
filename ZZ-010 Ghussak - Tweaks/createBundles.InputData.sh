####################### DATA
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
  foodRawMeat 3 #for dog companion
  GSKspawnDogCompanion 3
  GSKCFGNPCproperSneakingWorkaround 1
  GSKNPCHiredHeals30perc 13
  GSKNPCHiredHeals180perc 1
  GSKNPCHiredGetsPowerArmor 1
  NPCCfgAllInOne 1
  NPCPreventDismiss60s 3
  RepairNPCArmor 6
  vehicleGSKNPChelperPlaceable 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles "ExploringNPC" "bundleVehicle4x4" "${strExploringBase}Use this if you want a friendly hand (or paw)." "${astr[@]}"
astr=(
  apparelNightvisionGoggles 1
  GlowStickGreen       33
  GSKfireFuelFull 1
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
  drinkCanMegaCrush 2
  drinkJarBoiledWater 33 #for the desert
  drugGSKPsyonicsResist 13 #to be able to ignore mutants
  drugGSKmutantEssence 3
  GSKteleportLikeAMutantPower 1
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
  drugFortBites 3 # to help on getting a few good POI rewards
  drugJailBreakers 3
  thrownTimedCharge 9
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
  drugGSKwightEssence 3
  gunHandgunT1PistolPartsRepair 33
  gunHandgunT3SMG5 1
  modGunScopeSmall 1
  thrownAmmoMolotovCocktail6s 13
  thrownAmmoStunGrenade 13
  trapSpikesIronDmg0    33
  resourceNail 66
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
  drugGSKvampireEssence 3
  medicalFirstAidBandage 13
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  foodBoiledMeatBundleSchematic 1
  medicalFirstAidBandageSchematic 1
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
  # maps
  qt_taylor 1
  qt_nickole 1
  qt_stephan 1
  qt_jennifer 1
  qt_claude 1
  qt_sarah 1
  qt_raphael 1
  # underground location
  startNewGameOasisHint 1
  # etc
  thrownDynamite 8 #1 per treasure map
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
  GSKNoteInfoDeviceExtra 1
  GSKNoteStartNewGameSurvivingFirstDay 1
  GSKTheNoMadOverhaulBundleNoteBkp 1 # this last bundle description bkp
  
  #vanilla
  #keystoneBlock 1 
  
  #all previous bundles
  # this is not good, it should be controlled by the respawn cvar "${astrBundlesItemsLeastLastOne[@]}"
  "${astrCBItemsLeastLastOne[@]}"
  
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCprepareBundles --noExpLoss --noCB --ExternalDK "$strModNameForIDs" "cntStorageGeneric" "DUMMY_DESC_IGNORED" "${astr[@]}"
#);FUNCprepareBundles --noCheckMissingItemIds --noCB "$strModNameForIDs" "cntStorageGeneric" --ExternalDK "${astr[@]}"
