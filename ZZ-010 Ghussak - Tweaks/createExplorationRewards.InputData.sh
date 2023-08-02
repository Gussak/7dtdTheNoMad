iDataColumns=5;
astrItemList=( 
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

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armorSteel[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorSteel)(.*)@"item" \2\3 "ARO\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorSteelBoots "AROBoots" 0 ""
  "item" armorSteelChest "AROChest" 0 ""
  "item" armorSteelGloves "AROGloves" 0 ""
  "item" armorSteelHelmet "AROHelmet" 0 ""
  "item" armorSteelLegs "AROLegs" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armorMilitary[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armorMilitary)(.*)@"item" \2\3 "ARO\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorMilitaryBoots "AROBoots" 0 ""
  "item" armorMilitaryGloves "AROGloves" 0 ""
  "item" armorMilitaryHelmet "AROHelmet" 0 ""
  "item" armorMilitaryLegs "AROLegs" 0 ""
  "item" armorMilitaryStealthBoots "AROStealthBoots" 0 ""
  "item" armorMilitaryVest "AROVest" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item .*name="armor[^"]*Helmet[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item *name=")(armor)(.*)(Helmet)(.*)@"item" \2\3\4\5 "AROHelmet\3" 0@' |tr -d '\r\0' |sort -u
  "item" armorFirefightersHelmet "AROHelmetFirefighters" 0 ""
  "item" armorFootballHelmet "AROHelmetFootball" 0 ""
  #"item" armorFootballHelmetZU "AROHelmetFootball" 0 ""
  #"item" armorIronHelmet "AROHelmetIron" 0 ""
  #"item" armorMilitaryHelmet "AROHelmetMilitary" 0 ""
  "item" armorMiningHelmet "AROHelmetMining" 0 ""
  #"item" armorScrapHelmet "AROHelmetScrap" 0 ""
  #"item" armorSteelHelmet "AROHelmetSteel" 0 ""
  "item" armorSwatHelmet "AROHelmetSwat" 0 ""
  
  "item" apparelGhillieSuitJacket "AROGhillieJacket" ${iEndGameValue} "todo: create as armor mods too like hazmat mods"
  "item" apparelGhillieSuitPants "AROGhilliePants" ${iEndGameValue} ""
  "item" apparelGhillieSuitHood "AROGhillieHood" ${iEndGameValue} ""
  
  "item" apparelHazmatMask "AROHazmatMask" ${iEndGameValue} ""
  "item" apparelHazmatGloves "AROHazmatGloves" ${iEndGameValue} ""
  "item" apparelHazmatJacket "AROHazmatJacket" ${iEndGameValue} ""
  "item" apparelHazmatPants "AROHazmatPants" ${iEndGameValue} ""
  "item" apparelHazmatBoots "AROHazmatBoots" ${iEndGameValue} ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item.*name="resource[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "schematic|Master|GSK" |sed -r 's@(<item *name=")(resource)(.*)@"item" \2\3 "RSC\3" 0@' |sort -u |sed -r -e 's@RSC"@"@' -e 's@.*@& ""@'
  "item" resourceAcid "RSCAcid" 0 ""
  "item" resourceAirFilter "RSCAirFilter" 0 ""
  "item" resourceAnimalFatBall "RSCAnimalFatBall" 0 ""
  "item" resourceAnimalFat "RSCAnimalFat" 0 ""
  "item" resourceArrowHeadIron "RSCArrowHeadIron" 0 ""
  "item" resourceArrowHeadSteelAP "RSCArrowHeadSteelAP" 0 ""
  "item" resourceBone "RSCBone" 0 ""
  "item" resourceBrokenGlass "RSCBrokenGlass" 0 ""
  "item" resourceBuckshot "RSCBuckshot" 0 ""
  "item" resourceBulletCasing "RSCBulletCasing" 0 ""
  "item" resourceBulletTip "RSCBulletTip" 0 ""
  "item" resourceCandleStick "RSCCandleStick" 0 ""
  "item" resourceCandyTin "RSCCandyTin" 0 ""
  "item" resourceCement "RSCCement" 0 ""
  "item" resourceClayLump "RSCClayLump" 0 ""
  "item" resourceCloth "RSCCloth" 0 ""
  "item" resourceCoalBundle "RSCCoalBundle" 0 ""
  "item" resourceCoal "RSCCoal" 0 ""
  "item" resourceCobblestones "RSCCobblestones" 0 ""
  "item" resourceConcreteMix "RSCConcreteMix" 0 ""
  "item" resourceCropAloeLeaf "RSCCropAloeLeaf" 0 ""
  "item" resourceCropChrysanthemumPlant "RSCCropChrysanthemumPlant" 0 ""
  "item" resourceCropCoffeeBeans "RSCCropCoffeeBeans" 0 ""
  "item" resourceCropCottonPlant "RSCCropCottonPlant" 0 ""
  "item" resourceCropGoldenrodPlant "RSCCropGoldenrodPlant" 0 ""
  "item" resourceCropHopsFlower "RSCCropHopsFlower" 0 ""
  "item" resourceCrushedSand "RSCCrushedSand" 0 ""
  "item" resourceDoorKnob "RSCDoorKnob" 0 ""
  "item" resourceDuctTape "RSCDuctTape" 0 ""
  "item" resourceElectricParts "RSCElectricParts" 0 ""
  "item" resourceElectronicParts "RSCElectronicParts" 0 ""
  "item" resourceFeather "RSCFeather" 0 ""
  "item" resourceFishingWeight "RSCFishingWeight" 0 ""
  "item" resourceForgedIron "RSCForgedIron" 0 ""
  "item" resourceForgedSteel "RSCForgedSteel" 0 ""
  "item" resourceGlue "RSCGlue" 0 ""
  "item" resourceGoldNugget "RSCGoldNugget" 0 ""
  "item" resourceGunPowderBundle "RSCGunPowderBundle" 0 ""
  "item" resourceGunPowder "RSCGunPowder" 0 ""
  "item" resourceHeadlight "RSCHeadlight" 0 ""
  "item" resourceHubcap "RSCHubcap" 0 ""
  "item" resourceIronFragmentBundle "RSCIronFragmentBundle" 0 ""
  "item" resourceIronFragment "RSCIronFragment" 0 ""
  "item" resourceLeadBundle "RSCLeadBundle" 0 ""
  "item" resourceLeather "RSCLeather" 0 ""
  "item" resourceLockPickBundle "RSCLockPickBundle" 0 ""
  "item" resourceLockPick "RSCLockPick" 0 ""
  "item" resourceMechanicalParts "RSCMechanicalParts" 0 ""
  "item" resourceMetalPipe "RSCMetalPipe" 0 ""
  "item" resourceMilitaryFiber "RSCMilitaryFiber" 0 ""
  "item" resourceNail "RSCNail" 0 ""
  "item" resourceOil "RSCOil" 0 ""
  "item" resourceOilShaleBundle "RSCOilShaleBundle" 0 ""
  "item" resourceOilShale "RSCOilShale" 0 ""
  "item" resourcePaint "RSCPaint" 0 ""
  "item" resourcePaper "RSCPaper" 0 ""
  "item" resourcePotassiumNitratePowderBundle "RSCPotassiumNitratePowderBundle" 0 ""
  "item" resourcePotassiumNitratePowder "RSCPotassiumNitratePowder" 0 ""
  "item" resourceRadiator "RSCRadiator" 0 ""
  "item" resourceRawDiamond "RSCRawDiamond" 0 ""
  "item" resourceRepairKit "RSCRepairKit" 0 ""
  "item" resourceRocketCasing "RSCRocketCasing" 0 ""
  "item" resourceRocketTip "RSCRocketTip" 0 ""
  "item" resourceRockSmallBundle "RSCRockSmallBundle" 0 ""
  "item" resourceRockSmall "RSCRockSmall" 0 ""
  "item" resourceScrapBrass "RSCScrapBrass" 0 ""
  "item" resourceScrapIronBundle "RSCScrapIronBundle" 0 ""
  "item" resourceScrapIron "RSCScrapIron" 0 ""
  "item" resourceScrapLead "RSCScrapLead" 0 ""
  "item" resourceScrapPolymers "RSCScrapPolymers" 0 ""
  "item" resourceSewingKit "RSCSewingKit" 0 ""
  "item" resourceSilverNugget "RSCSilverNugget" 0 ""
  "item" resourceSnowBall "RSCSnowBall" 0 ""
  "item" resourceSpring "RSCSpring" 0 ""
  "item" resourceTestosteroneExtract "RSCTestosteroneExtract" 0 ""
  "item" resourceTrophy1 "RSCTrophy1" 0 ""
  "item" resourceTrophy2 "RSCTrophy2" 0 ""
  "item" resourceTrophy3 "RSCTrophy3" 0 ""
  "item" resourceWoodBundle "RSCWoodBundle" 0 ""
  "item" resourceWood "RSCWood" 0 ""
  "item" resourceYuccaFibers "RSCYuccaFibers" 0 ""

  #xmlstarlet ed -L -d '//comment()' "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/"*".xml";egrep '<item_modifier.*name="mod[^"]*' _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/*.xml -oih |egrep -vi "parts|schematic|Master|GSK" |sed -r 's@(<item_modifier *name=")(mod)(.*)@"item_modifier" \2\3 "Mod\3" 0@' |sort -u |sed -r -e 's@Mod"@"@' -e 's@.*@& ""@'
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
