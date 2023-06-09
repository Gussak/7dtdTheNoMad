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

#egrep "[#]help" $0

bUndergroundAutoPlaceMode=false #help this works only for the 1st spawn, the engine will fix the position. But for the device toSky activation it will ignore the wrong negative y value and will just not teleport at all.
bParachuteMode=true #help on the 1st spawn, the engine will place the player on ground automatically. the  toSky later activations will be ok on the sky, but not so high.
#: ${bParachuteMode:=true} #h elp bParachuteMode=false to spawn on the ground in the original elevation, but you may end inside the building what may not be a good idea. bParachuteMode does not work, player is always placed on ground (never on sky), but this is good to try to place player above buildings at least on first spawn (if the first spawn location is not modified by some buff). This is only good later when using the tele to sky feature.

#help after death, player seems to respawn always on the nearest spawnpoints.xml if having no bed placed

source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

strPathWork="GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory"
strFlGenSpa="${strPathWork}/spawnpoints.xml"

if [[ "${1-}" == "-e" ]];then #help prefab elevations
  anPrefabPosXYZList=(`cat GeneratedWorlds.ManualInstallRequired/East\ Nikazohi\ Territory/spawnpoints.xml |tr -d '\r' |egrep -o 'teleport[^"]*' |sed -r 's@teleport (.*)@\1@'`);
  #for nPrefabPosXYZ in "${anPrefabPosXYZList[@]}";do echo ${nPrefabPosXYZ};done
  for((i=0;i<"${#anPrefabPosXYZList[@]}";i+=3));do
    nX=${anPrefabPosXYZList[i]}
    nY=${anPrefabPosXYZList[i+1]}
    nZ=${anPrefabPosXYZList[i+2]}
    if((nY>=60));then
      echo "$nX $nY $nZ"
    fi
    #declare -p nX nY nZ
  done |sort -n
  exit 0
fi

# trash special files that are not at --LIBgencodeTrashLast option:
CFGFUNCtrash "${strFlGenSpa}${strGenTmpSuffix}"
CFGFUNCtrash "${strFlGenBuf}TeleSpawnLog${strGenTmpSuffix}"&&:
CFGFUNCtrash "${strFlGenBuf}TeleSpawnBiomeId${strGenTmpSuffix}"&&:
CFGFUNCtrash "${strFlGenBuf}ChooseRandomSpawnInBiome${strGenTmpSuffix}"&&:
CFGFUNCtrash "${strFlGenBuf}TeleportUnder${strGenTmpSuffix}"&&:

#astrPrefabsList evals: strNm iX iY iZ iRot
IFS=$'\n' read -d '' -r -a astrPrefabsList < <( \
  cat "${strPathWork}/prefabs.xml" \
    |egrep 'position="[^"]*"' \
    |sed -r 's@.*name="([^"]*)".*position="([0-9-]*)[.]*[0-9]*, *([0-9-]*)[.]*[0-9]*, *([0-9-]*)[.]*[0-9]*".*rotation="([0-9-]*)".*@strNm="\1";iX=\2;iY=\3;iZ=\4;iRot=\5;@' \
  )&&:

astrDeny=( #Too good or grantedly underground or IDK
  apartment_
  apartments_
  army_
  auto_mechanic_
  bank_
  bar_
  barn_
  body_shop_
  bombshelter_
  bridge_
  business_
  canyon_car_wreck
  cave_
  docks_
  downtown_
  factory_lg_
  farm_
  football_stadium
  garage_
  gas_station_
  hospital_
  hotel_
  housing_development_
  industrial_
  installation_red_mesa
  large_park_
  lodge_
  lot_
  mp_waste_bldg_
  office_
  oldwest_
  park_
  park_skate
  parking_
  part_
  perishton_median_
  police_station
  post_office_
  potatofield_sm
  prison_
  remnant_gas_station_
  remnant_industrial_
  remnant_skyscraper_
  restaurant_
  roadblock_
  road_
  rural_
  rwg_tile_
  sawmill_
  school_
  settlement_
  spider_
  spider_cave_
  skate_park_
  skyscraper_
  store_
  street_
  streets_
  trader_
  utility_
  warehouse_
)
strDeny="`echo "${astrDeny[@]}" |tr ' ' '|'`";declare -p strDeny
astrAllow=(
  "^cabin_"
  "_cabin_"
  "^house_"
  "_house_"
  "^trailer_"
  "_trailer_"
)
strAllow="`echo "${astrAllow[@]}" |tr ' ' '|'`";declare -p strAllow
eval "`./getBiomeData.sh -w`" #gets world size
nVanillaDeadlyRadiationMargin=128
astrRect=( #this is the region spawn points are allowed to be created
  -$((nWorldW/2 + nVanillaDeadlyRadiationMargin))  $((nWorldH/2 - nVanillaDeadlyRadiationMargin)) #top left XZ
   $((nWorldW/2 - nVanillaDeadlyRadiationMargin)) -$((nWorldH/2 + nVanillaDeadlyRadiationMargin)) #bottom right XZ
)
#astrRectNormal=(
  #-$((nWorldW/2 + nVanillaDeadlyRadiationMargin))  $((nWorldH/2 - nVanillaDeadlyRadiationMargin)) #top left XZ
  #-2300 -2000 #bottom right XZ
#)
function FUNCisAllowedZone() {
  if((iX > ${astrRect[0]} && iX < ${astrRect[2]}));then
    if((iZ < ${astrRect[1]} && iZ > ${astrRect[3]}));then
      return 0
    fi
  fi
  return 1
}

#strBiomeFileInfo="`identify "${strCFGGeneratedWorldTNMFolder}/biomes.png" |egrep " [0-9]*x[0-9]* " -o |tr -d ' ' |tr 'x' ' '`";
#nBiomesW="`echo "$strBiomeFileInfo" |cut -d' ' -f1`";
#nBiomesH="`echo "$strBiomeFileInfo" |cut -d' ' -f2`";
#declare -p nBiomesW nBiomesH

iTeleportIndex=50000 #TODO: collect thru xmlstarlet from buffs.xml: IMPORTANT! this must be in sync with the value at buffs: .iGSKElctrnTeleSpawnBEGIN
iTeleportMaxAllowed=200 #TODO: a buff with too many tests may simply fail right? may be it could be split into buffs with range of 100 checks each
iTeleportMaxAllowedIndex=$((iTeleportIndex+iTeleportMaxAllowed))&&: 
iTeleportMaxIndex=$iTeleportIndex
iTeleportIndexFirst=-1

iUnderSimpleIndex=0

#strFlPosVsBiomeColorCACHE="`basename "$0"`.PosVsBiomeColor.CACHE.sh" #help if you delete the cache file it will be recreated
#declare -A astrPosVsBiomeColor=()
#source "${strFlPosVsBiomeColorCACHE}"&&:
#if [[ -f "${strFlPosVsBiomeColorCACHE}" ]];then source "${strFlPosVsBiomeColorCACHE}";fi

if [[ ! -f "./getBiomeData.sh.PosVsBiomeColor.CACHE.sh" ]];then
  if ! CFGFUNCprompt -q "it is better if you run ./rwgImprovePOIs.sh first, continue anyway?";then
    exit 0
  fi
fi
source "./getBiomeData.sh.PosVsBiomeColor.CACHE.sh"&&:

for str in "${astrPrefabsList[@]}";do #astrPrefabsList evals: strNm iX iY iZ iRot
#for((i=0;i<"${#astrPrefabsList[@]}";i+=2));do
  #iX=${astrPrefabsList[i]}
  #iZ=${astrPrefabsList[i+1]}
  #declare -p str
  eval "$str" #the rotation is of the prefab not the lookat
  #if echo "$strNm" |egrep "^(${strDeny})";then continue;fi
  if ! echo "$strNm" |egrep "${strAllow}";then continue;fi
  if ! FUNCisAllowedZone;then continue;fi
  
  #NORMAL DIFFICULTY SPAWNS from -5000 5000 to -2300 -2000
  iYOrig=$iY
  bModY=false
  if $bParachuteMode;then iYNew=260;bModY=true;fi #help it is a bit above the blocks limit (255 right?), but as the engine may lag on repositionings, this seems a safe dist from highest ground til the engine stabilizes. this is intended to be above any terrain, to let the engine auto place the player on ground on the 1st spawn. later toSky activations will further teleport to above locations
  
  #he lp the spawns on sky are elevation 2000 because the idea is not about relocation but to let player choose just an area nearby that spawn spot on the ground
  if $bUndergroundAutoPlaceMode;then iYNew=-2;bModY=true;fi #help this negative Y elevation will quickly use the engine auto placement ray cast from sky
  if $bModY;then
    iY=$iYNew
  else
    iY=$((iYOrig+2))&&:;
  fi
  
  #: ${bUseAll:=true} #help
  #if $bUseAll;then
    #astrRect=("${astrRectAll[@]}")
  #else
    #astrRect=("${astrRectNormal[@]}")
  #fi
  #declare -p iX iZ astrRect
  #set -x
  iDisplacementXZ=20 #minimum =3 to avoid the corners of POIs that may bug the auto player placent. 20 will try to place player above buildings
  #if((iX > ${astrRect[0]} && iX < ${astrRect[2]}));then
    #if((iZ < ${astrRect[1]} && iZ > ${astrRect[3]}));then
  #bAllowedZone=false;if FUNCisAllowedZone;then bAllowedZone=true;fi
  #if $bUseAll || $bAllowedZone;then
      #strPos="$((iX+iDisplacementXZ)),$iY,$((iZ+iDisplacementXZ))"
      #strTeleport="original teleport $iX $iYOrig $iZ"
      #strHelp="index=${iTeleportIndex};prefab=${strNm};${strTeleport}"
      #echo '    <spawnpoint helpSort="'"${strNm},Z=${iZ}"'" position="'"${strPos}"'" rotation="0,0,0" help="'"${strHelp}"'"/>' >>"${strFlGenSpa}${strGenTmpSuffix}"
  #fi
  
  #bCreateAutoTeleport=false
  #: ${bUseOnlyNormalDifficultySpawns:=false} #help
##  if $bUseOnlyNormalDifficultySpawns && $bAllowedZone;then bCreateAutoTeleport=true;fi
  #if $bUseOnlyNormalDifficultySpawns;then
    #if $bAllowedZone;then
      #bCreateAutoTeleport=true
    #fi
  #else # allow all spawns everywhere
    #bCreateAutoTeleport=true 
  #fi
  
  #if $bCreateAutoTeleport;then #create initial spawns to teleport to
    ((iTeleportIndex++))&&:
    
    #if $bUseAll || $bAllowedZone;then
        iXSP=$((iX+iDisplacementXZ))
        iZSP=$((iZ+iDisplacementXZ))
        strSpawnPos="$iXSP,$iY,$iZSP"
        strPrefabPos="$iXSP,$iYOrig,$iZSP"
        
        #strColorAtBiomeFile="${astrPosVsBiomeColor[${strSpawnPos}]-}"&&:
        #if [[ -z "${strColorAtBiomeFile}" ]];then
          #strColorAtBiomeFile="`convert "${strCFGGeneratedWorldTNMFolder}/biomes.png" -format '%[hex:u.p{'"$(((nBiomesW/2)+iXSP)),$(((nBiomesH/2)-iZSP))"'}]' info:-`" #the center of the map is X,Z=0,0. North from center is Z positive in game, but for imagemagick convert, it is inverted because the topleft image picture is the 0,0 origin
        #fi
        #if [[ "$strColorAtBiomeFile" == "FFFFFFFF" ]];then 
          #strBiome="Snow";iBiome=1
        #elif [[ "$strColorAtBiomeFile" == "004000FF" ]];then 
          #strBiome="PineForest";iBiome=3
        #elif [[ "$strColorAtBiomeFile" == "FFE477FF" ]];then 
          #strBiome="Desert";iBiome=5
        #elif [[ "$strColorAtBiomeFile" == "FFA800FF" ]];then 
          #strBiome="Wasteland";iBiome=8
        #elif [[ "$strColorAtBiomeFile" == "does not exist on rgw generated worlds right?" ]];then 
          #strBiome="BurntForest";iBiome=9
        #else
          #CFGFUNCerrorExit "not implemented biome for ${strColorAtBiomeFile}"
        #fi
        #astrPosVsBiomeColor["${strSpawnPos}"]="${strColorAtBiomeFile}"
        if [[ -n "${astrPosVsBiomeColor[${strSpawnPos}]-}" ]];then
          # faster
          eval "`./getBiomeData.sh -t ${astrPosVsBiomeColor["${strSpawnPos}"]}`" # iBiome strBiome strColorAtBiomeFile
        else
          # much slower
          eval "`./getBiomeData.sh "${strSpawnPos}"`" # strColorAtBiomeFile strBiome iBiome
        fi
        
        strTeleport="prefabPosCmd: teleport $iX $iYOrig $iZ"
        strHelp="index=${iTeleportIndex};prefab=${strNm};biome=${strColorAtBiomeFile},${strBiome},${iBiome};spawnPos=${strSpawnPos};${strTeleport}"
        echo '    <spawnpoint helpSort="'"${strNm},Z=${iZ}"'" position="'"${strSpawnPos}"'" rotation="0,0,0" help="'"${strHelp}"'"/>' >>"${strFlGenSpa}${strGenTmpSuffix}"
    #fi
    
    if((iTeleportIndexFirst==-1));then iTeleportIndexFirst=$iTeleportIndex;fi
    strTeleportIndex="`printf %03d $iTeleportIndex`"
    #strMsg="spawn point index ${strTeleportIndex}"
    #echo '      <!-- '"${strMsg}"' -->'
    echo '
        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeleport'"${strTeleportIndex}"'" help="'"${strHelp}"'">
          <requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
    if((iYOrig>=60));then
      ((iUnderSimpleIndex++))&&:
      echo '
    <action_sequence name="eventGSKTeleportToPrefab'"${strTeleportIndex}"'"><action class="Teleport">
      <property name="target_position" value="'"${strPrefabPos}"'" help="'"${strHelp}"'"/>
    </action></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
      echo '
        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeleportToPrefab'"${strTeleportIndex}"'" help="'"${strHelp}"'">
          <requirement name="CVarCompare" cvar=".iGSKTTUnderSpawnSimpleIndex" operation="Equals" value="'"${iUnderSimpleIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}TeleportUnder${strGenTmpSuffix}"
    fi
    echo '
        <triggered_effect trigger="onSelfBuffUpdate" action="LogMessage" message="GSK:'"${strHelp}"'">
          <requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}TeleSpawnLog${strGenTmpSuffix}"
    echo '
        <triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar="iGSKTeleportedToSpawnPointBiomeId" operation="set" value="'"${iBiome}"'" help="'"${strHelp}"'">
          <requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}TeleSpawnBiomeId${strGenTmpSuffix}"
    echo '
        <triggered_effect trigger="onSelfBuffUpdate" action="ModifyCVar" cvar=".iGSKNewTeleToSpawnPointIndex" operation="set" value="'"${iTeleportIndex}"'" help="'"${strHelp}"'">
          <requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointBiomeId" operation="Equals" value="'"${iBiome}"'"/>
          <requirement name="CVarCompare" cvar=".iGSKRandomSpawnPointIndexCheckForBiomeIdTmp" operation="Equals" value="'"${iTeleportIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}ChooseRandomSpawnInBiome${strGenTmpSuffix}"
    echo '
    <action_sequence name="eventGSKTeleport'"${strTeleportIndex}"'"><action class="Teleport">
      <property name="target_position" value="'"${strSpawnPos}"'" help="'"${strHelp}"'"/>
    </action></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
    iTeleportMaxIndex=$iTeleportIndex
    if((iTeleportMaxIndex==iTeleportMaxAllowedIndex));then echo "PROBLEM: not all spawns were made available";break;fi
    #((iTeleportIndex++))&&:
  #fi
  
  
  
    #fi
  #fi
done

#echo "#PREPARE_RELEASE:REVIEWED:OK" >"$strFlPosVsBiomeColorCACHE"
#echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"$strFlPosVsBiomeColorCACHE"
#declare -p astrPosVsBiomeColor >>"$strFlPosVsBiomeColorCACHE" #TODO sha1sum the biome file and if it changes, recreate the array

# this file can be sorted because each entry is one line!
strSorted="`cat "${strFlGenSpa}${strGenTmpSuffix}" |sort`"
echo "$strSorted" >"${strFlGenSpa}${strGenTmpSuffix}"
cat "${strFlGenSpa}${strGenTmpSuffix}"

CFGFUNCgencodeApply "${strFlGenSpa}${strGenTmpSuffix}" "${strFlGenSpa}"

CFGFUNCgencodeApply "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "TeleSpawnLog" "${strFlGenBuf}TeleSpawnLog${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "TeleSpawnBiomeId" "${strFlGenBuf}TeleSpawnBiomeId${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "ChooseRandomSpawnInBiome" "${strFlGenBuf}ChooseRandomSpawnInBiome${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --subTokenId "TeleportUnder" "${strFlGenBuf}TeleportUnder${strGenTmpSuffix}" "${strFlGenBuf}"

CFGFUNCgencodeApply "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"

##xmlstarlet ed -L -d "//triggered_effect[@help='SPAWNPOINT_RANDOM_AUTOMATIC']" "${strFlGenBuf}"
#CFGFUNCtrash "${strFlGenBuf}${strGenTmpSuffix}"
#echo '        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="iGSKTeleportedToSpawnPointIndex" operation="set" value="randomInt('"${iTeleportIndexFirst},${iTeleportMaxIndex}"')"/>' >>"${strFlGenBuf}${strGenTmpSuffix}"
#CFGFUNCgencodeApply --subTokenId "TeleportCfgs" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
CFGFUNCgencodeApply --xmlcfg                                                                                      \
  iGSKTeleportedToSpawnPointIndex 'randomInt('"${iTeleportIndexFirst},${iTeleportMaxIndex}"')'                  \
  ".iGSKRandomSpawnPointIndexCheckForBiomeIdTmp" 'randomInt('"${iTeleportIndexFirst},${iTeleportMaxIndex}"')'   \
  ".iGSKElctrnTeleSpawnFIRST" "${iTeleportIndexFirst}"                                                           \
  ".iGSKElctrnTeleSpawnLAST" "${iTeleportMaxIndex}"                                                              \
  ".iGSKTTUnderSpawnSimpleIndex" "randomInt(1,${iUnderSimpleIndex})"

CFGFUNCgencodeApply --cleanChkDupTokenFiles

CFGFUNCwriteTotalScriptTimeOnSuccess
