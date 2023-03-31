#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

strScriptName="`basename "$0"`"

source ./gencodeInitSrcCONFIG.sh

#strModName="The NoMad"
#strModNameForIDs="TheNoMadOverhaul"
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

function FUNCcraftBundle() {
  local lstrBundleID="$1";shift
  local lstrBundleShortName="$1";shift
  local lstrIcon="$1";shift
  
  local lstrCvar="bGSKRespawnItemsBundleHelper${lstrBundleShortName}"
  local lstrCraftBundleID="GSKTheNoMadCreateRespawnBundle${lstrBundleShortName}"
  strXmlCraftBundleCreateItemsXml+='
    <!-- HELPGOOD:Respawn:CreateBundle:'"${lstrBundleID}"' -->
    <item name="'"${lstrCraftBundleID}"'" help="on death free items helper">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />
      <property name="CustomIconTint" value="64,64,64" />
      <property name="DescriptionKey" value="dkGSKTheNoMadCreateRespawnBundle" />
      <property class="Action0">
        <requirement name="CVarCompare" cvar="'"${lstrCvar}"'" operation="Equals" value="1" />
        <property name="Create_item" value="'"${lstrBundleID}"'" />
        <property name="Create_item_count" value="1" />
        <property name="Delay" value="0.25" />
        <property name="Use_time" value="0.25" />
        <property name="Sound_start" value="nightvision_toggle" />
      </property>
      <effect_group tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" target="self" cvar="'"${lstrCvar}"'" operation="set" value="0"/>
      </effect_group>
    </item>'
  strXmlCraftBundleCreateRecipesXml+='
    <recipe name="'"${lstrCraftBundleID}"'" count="1"></recipe>'
  # not using onSelfDied anymore, unnecessary
  strXmlCraftBundleCreateBuffsXml+='
        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${lstrCvar}"'" operation="set" value="1"/>'
  if [[ -z "$strDKCraftAvailableBundles" ]];then
    strDKCraftAvailableBundles+='dkGSKTheNoMadCreateRespawnBundle,"After you die, this can be crafted for free (search for '"'"'CB:'"'"')and opened once (once per death), so you will not need to rush respawn in your bed to be near your dropped backpack, be careful when trying to recover it to not die again. If you think that opening this full kit again will make things too easy, just do not open it (or at least do not open all the sub-bundles if this is the top bundle). These bundles (=1) were not opened yet this life: '
  fi
  strDKCraftAvailableBundles+=" ${lstrBundleShortName}={cvar(${lstrCvar}:0)},"
  astrCraftBundleNameList+=("${lstrCraftBundleID},\"${strModName}CB:${lstrBundleShortName}\"")
  astrCBItemsLeastLastOne+=("${lstrCraftBundleID}" 1)
}

function FUNCspecificItemsCode() {
  local strItemID="$1"
  local fDmg=0.75
  if [[ "$strItemID" == "apparelNightvisionGoggles" ]];then
    echo '      <!-- HELPGOOD: initially damaged items below -->
      <effect_group name="damaged starter item: '"$strItemID"'" tiered="false">
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercNV" operation="set" value="0">
          <requirement name="CVarCompare" cvar="fGSKDmgPercNV" operation="LTE" value="'$fDmg'" />
        </triggered_effect>
        <triggered_effect trigger="onSelfPrimaryActionEnd" action="ModifyCVar" cvar="fGSKDmgPercNV" operation="add" value="'$fDmg'">
          <requirement name="CVarCompare" cvar="fGSKDmgPercNV" operation="LTE" value="0.01" />
        </triggered_effect>
      </effect_group>'
  fi
  if [[ "$strItemID" == "meleeToolFlashlight02" ]];then
    echo '      <!-- HELPGOOD: initially damaged items below -->
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
      </effect_group>'
  fi
  #if [[ "$strItemID" == "GSKTheNoMadOverhaulBundleNoteBkp" ]];then
    #echo '      <!-- HELPGOOD: allows opening the CreateBundle items -->
      #<effect_group name="allows opening the CreateBundle items, hint item: '"$strItemID"'" tiered="false">
        #<triggered_effect trigger="onSelfPrimaryActionEnd" action="AddBuff" buff="buffGSKRespawnNoMadBundlesAllowCrafting"/>
      #</effect_group>'
  #fi
}

function FUNCcreateBundlePart() {
  local lstrBundleName="$1";shift
  local lstrBundlePartName="$1";shift
  local lstrIcon="$1";shift
  local lstrColor="$1";shift
  local lbCB=$1;shift
  local lstrBundleDesc="$1";shift
  local lastrItemAndCountList=("$@")
  
  if [[ "${lstrBundleName}" =~ .*\ .* ]];then
    echo "ERROR: cant have spaces lstrBundleName='$lstrBundleName'"
    exit 1
  fi
  
  local lstrBundleID="GSK${lstrBundleName}${lstrBundlePartName}Bundle"
  astrDKAndDescList+=("${lstrBundleID},\"${strModName}BD:${lstrBundleName} ${lstrBundlePartName}\"")
  
  local lstrBundleDK="dk${lstrBundleID}"
  if [[ "${lstrBundleDesc}" == "--autoDK" ]];then
    lstrBundleDesc="$lstrBundleDK"
  fi
  if [[ "${lstrBundleDesc:0:2}" == "dk" ]];then
    lstrBundleDK="$lstrBundleDesc"
  else
    astrDKAndDescList+=("${lstrBundleDK},\"${lstrBundleDesc}\"")
  fi
  
  strItems="";strCounts="";strSep="";strSpecifiItemsCode=""
  for((i=0;i<${#lastrItemAndCountList[@]};i+=2));do 
    if((i>0));then strSep=",";fi;
    strItems+="$strSep${lastrItemAndCountList[i]}"
    strCounts+="$strSep${lastrItemAndCountList[i+1]}";
    #echo "          ${lastrItemAndCountList[i]} ${lastrItemAndCountList[i+1]}"
    strSpecifiItemsCode+="`FUNCspecificItemsCode "${lastrItemAndCountList[i]}"`"
  done;
  strDK=""
  astrDescriptionKeyList+=()
  #dkGSKstartNewGameItemsBundle
  local lstrType=""
  if [[ "$lstrBundlePartName" == "$strSchematics" ]];then
    #lstrIcon="bundleBooks"
    lstrType='<property name="ItemTypeIcon" value="book" />'
    astrBundlesSchematics+=("$lstrBundleID" 1)
  else
    astrBundlesItemsLeastLastOne+=("$lstrBundleID" 1)
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
    <item name="'"${lstrBundleID}"'">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIcon" value="'"${lstrIcon}"'" />'"${lstrType}"'
      <property name="CustomIconTint" value="'"$lstrColor"'" />
      <property name="DescriptionKey" value="'"${lstrBundleDK}"'" />
      <property class="Action0">
        <property name="Create_item" help="it has '$((${#lastrItemAndCountList[@]}/2))' diff items" value="'"${strItems}"'" />
        <property name="Create_item_count" value="'"${strCounts}"'" />
      </property>'"${strSpecifiItemsCode}"'
    </item>' |tee -a "${strFlGenIte}${strGenTmpSuffix}"
  
  if $lbCB;then
    FUNCcraftBundle "${lstrBundleID}" "${lstrBundleName}${lstrBundlePartName}" "${lstrIcon}"
  fi
}

function FUNCcreateBundles() {
  local lbCB=true;if [[ "$1" == --noCB ]];then shift;lbCB=false;fi
  local lstrColor="192,192,192";if [[ "$1" == --color ]];then shift;lstrColor="$1";shift;fi #help <lstrColor>
  local lstrBundleName="$1";shift
  local lstrIcon="$1";shift
  local lstrBundleDesc="$1";shift
  local lastrItemAndCountList=("$@")
  
  local lastrParams=("$lstrIcon" "$lstrColor" "$lbCB" "$lstrBundleDesc")
  
  declare -p lastrItemAndCountList |tr '[' '\n'
  
  strNextPartName=""
  astrPart=()
  for((i=0;i<${#lastrItemAndCountList[@]};i+=2));do 
    strNm="${lastrItemAndCountList[i]}"
    #declare -p strNm
    if [[ "${strNm}" =~ ^${strPartToken}.* ]];then
      if((${#astrPart[*]}>0));then
        FUNCcreateBundlePart "$lstrBundleName" "" "${lastrParams[@]}" "${astrPart[@]}"
      fi
      # init next part
      astrPart=()
      strNextPartName="`echo "$strNm" |cut -d: -f2`"
      continue
    fi
    astrPart+=("${lastrItemAndCountList[i]}" "${lastrItemAndCountList[i+1]}")
  done
  if [[ -n "$strNextPartName" ]] && ((${#astrPart[*]}>0));then
    FUNCcreateBundlePart "$lstrBundleName" "${strNextPartName}" "${lastrParams[@]}" "${astrPart[@]}"
  fi
}

#astr=( #TEMPLATE
#  "$strSCHEMATICS_BEGIN_TOKEN" 0
#);FUNCcreateBundles "" "${astr[@]}"

astr=(
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  cementMixerSchematic 1 
  forgeSchematic 1 
  toolAnvilSchematic 1 
  toolBellowsSchematic 1 
  toolForgeCrucibleSchematic 1 
);FUNCcreateBundles "ForgeCrafting" "cntLootChestHeroInsecureT1" "use this when you want to begin creating and using forges, also has cementmixer" "${astr[@]}"

astr=(
  apparelNightvisionGoggles 1
  bedrollBlue 103
  casinoCoin 525
  drugJailBreakers 6
  GlowStickGreen       100
  GSKfireFuel 10
  GSKsimpleBeer        102
  ladderWood            98
  meleeToolFlashlight02 1
  meleeToolTorch 1
  #meleeWpnSpearT0StoneSpear 1
  resourceCloth 50
  resourceDuctTape 1
  resourceFeather        1
  resourceLockPick 1
  resourceRockSmall    208
  resourceWood         526
  resourceYuccaFibers  31
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  modArmorHelmetLightSchematic 1
  modGunFlashlightSchematic 1
  vehicleBicycleChassisSchematic 1
  vehicleBicycleHandlebarsSchematic 1
);FUNCcreateBundles "Exploring" "bundleVehicle4x4" "use this if you think exploring the world is unreasonably difficult (there is no vehicle in it tho). Some of these equipment are severely damaged and wont last long w/o repairs tho." "${astr[@]}"

astr=( #TEMPLATE
  ammo9mmBulletBall 998
  ammoArrowStone 53
  gunHandgunT1PistolParts 30
  gunHandgunT3SMG5 1
  modGunScopeSmall 1
  thrownAmmoMolotovCocktail6s 10
  thrownAmmoStunGrenade 10
  trapSpikesIronDmg0    100
  #trapSpikesWoodDmg0    99
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  bookRangersExplodingBolts 1
  thrownDynamiteSchematic 1
);FUNCcreateBundles "CombatWeapons" "bundleMachineGun" "use this if you are not having a reasonable chance against mobs" "${astr[@]}"

astr=( #TEMPLATE
  armorSteelHelmet 1
  #armorClothHat 1
  armorClothJacket 1
  armorClothGloves 1
  #armorScrapGloves 1
  #armorScrapLegs 1
  armorClothPants 1
  armorClothBoots 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCcreateBundles "CombatArmor" "bundleArmorLight" "use this if you are taking too much damage. You should use this anyway otherwise ranged raiders become unreasonable difficult." "${astr[@]}"

astr=(
  modGSKEnergyThorns     1
  NightVisionBattery    16
  NVBatteryCreate 1
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  batterybankSchematic 1
  bookTechJunkie5Repulsor 1
  generatorbankSchematic 1
  gunBotT2JunkTurretSchematic 1
);FUNCcreateBundles "TeslaEnergy" "bundleBatteryBank" "use this if want to start using and crafting tesla mods, this will increase your combat survival chances" "${astr[@]}"

astr=(
  bucketRiverWater 1
  drinkJarPureMineralWater 20
  drugAntibiotics 4
  drugPainkillers 1
  drugSteroids  10
  drugVitamins 1
  GSKAntiRadiation 10
  GSKAntiRadiationSlow 10
  GSKAntiRadiationStrong 10
  GSKPsyonicsResist 10
  GSKRadiationResist 10
  GSKsnakePoisonAntidote 10
  medicalBloodBag 10
  medicalFirstAidBandage 15
  medicalSplint 10
  potionRespec 3
  toolBeaker 1
  treePlantedMountainPine1m 28
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  bookWasteTreasuresHoney 1
  bookWasteTreasuresWater 1
  drugAntibioticsSchematic 1
  drugHerbalAntibioticsSchematic 1
  foodBoiledMeatBundleSchematic 1
  foodBoiledMeatSchematic 1
);FUNCcreateBundles "Healing" "bundleFarm" "use this if you have not managed to heal yourself yet or is having trouble doing that or has any disease or infection and is almost dieing, dont wait too much tho..." "${astr[@]}"

astr=(
  farmPlotBlockVariantHelper 13
  plantedBlueberry1 15
  plantedMushroom1 9
  "$strSCHEMATICS_BEGIN_TOKEN" 0
  plantedBlueberry1Schematic 1
  plantedMushroom1Schematic 1
);FUNCcreateBundles "Farming" "bundleFarm" "use this if you need to be able to harvest and craft antibiotics" "${astr[@]}"

astr=(
  bedrollBlue 1
  campfire 1 
  candleTableLight 1
  cntSecureStorageChest 1
  meleeToolRepairT0StoneAxe 1
  resourceRockSmall 10
  resourceWood 30
  drinkCanEmpty 3
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCcreateBundles "BasicCampingKit" "bundleFarm" "some basic things to quickly set a tiny camp with shelter and cook a bit" "${astr[@]}"

astr=(
  bedrollBlue 1
  drinkJarBoiledWater 2
  drugSteroids 1
  GlowStickGreen       13
  GSKAntiRadiationStrong 2
  GSKPsyonicsResist 3
  GSKsnakePoisonAntidote 2
  GSKfireFuel 5
  GSKsimpleBeer        3
  medicalFirstAidBandage 3
  medicalSplint 1
  meleeToolTorch 1
  resourceRockSmall    15
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCcreateBundles --color "128,180,128" "MinimalSurvivalKit" "cntStorageGeneric" "minimal helpful stuff" "${astr[@]}"

astr=(
  "${astrBundlesSchematics[@]}" # these are the bundles of schematics, not schematics themselves so they must be in the astrBundlesItemsLeastLastOne list
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCcreateBundles "SomeSchematics" "bundleBooks" "open this to get some schematics bundles related to the item's bundles" "${astr[@]}"

###################################### KEEP AS LAST ONE!!! ##############################
astr=(
  # notes
  GSKTRNotesBundle 1 #from createNotesTips.sh
  GSKTRSpecialNotesBundle 1 #from createNotesTips.sh
  GSKNoteInfoDevice 1 
  GSKNoteStartNewGameSurvivingFirstDay 1
  GSKTheNoMadOverhaulBundleNoteBkp 1 # this last bundle description bkp
  startNewGameOasisHint 1
  
  #vanilla
  keystoneBlock 1 
  
  #all previous bundles
  # this is not good, it should be controlled by the respawn cvar "${astrBundlesItemsLeastLastOne[@]}"
  "${astrCBItemsLeastLastOne[@]}"
  
  "$strSCHEMATICS_BEGIN_TOKEN" 0
);FUNCcreateBundles --noCB "$strModNameForIDs" "cntStorageGeneric" --autoDK "${astr[@]}"

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

