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

bParachuteMode=false
#: ${bParachuteMode:=true} #h elp bParachuteMode=false to spawn on the ground in the original elevation, but you may end inside the building what may not be a good idea. bParachuteMode does not work, player is always placed on ground (never on sky), but this is good to try to place player above buildings at least on first spawn (if the first spawn location is not modified by some buff). This is only good later when using the tele to sky feature.

bUndergroundAutoPlaceMode=true

#help after death, player seems to respawn always on the nearest spawnpoints.xml if having no bed placed

source ./libSrcCfgGenericToImport.sh --gencodeTrashLast

strPathWork="GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory"
strFlGenSpa="${strPathWork}/spawnpoints.xml"
CFGFUNCtrash "${strFlGenSpa}${strGenTmpSuffix}"

IFS=$'\n' read -d '' -r -a astrPrefabsList < <( \
  cat "${strPathWork}/prefabs.xml" \
    |egrep 'position="[^"]*"' \
    |sed -r 's@.*name="([^"]*)".*position="([0-9-]*),([0-9-]*),([0-9-]*)".*rotation="([0-9-]*)".*@strNm="\1";iX=\2;iY=\3;iZ=\4;iRot=\5;@' \
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
astrRectAll=(
  -5000  5000 #top left XZ
   5000 -5000 #bottom right XZ
)
astrRectNormal=(
  -5000  5000 #top left XZ
  -2300 -2000 #bottom right XZ
)
function FUNCisNormalZone() {
  if((iX > ${astrRectNormal[0]} && iX < ${astrRectNormal[2]}));then
    if((iZ < ${astrRectNormal[1]} && iZ > ${astrRectNormal[3]}));then
      return 0
    fi
  fi
  return 1
}
iTeleportIndex=50000 #TODO: collect thru xmlstarlet from buffs.xml: IMPORTANT! this must be in sync with the value at buffs: .iGSKTeslaTeleSpawnBEGIN
iTeleportMaxAllowed=200 #TODO: a buff with too many tests may simply fail right? may be it could be split into buffs with range of 100 checks each
iTeleportMaxAllowedIndex=$((iTeleportIndex+iTeleportMaxAllowed))&&: 
iTeleportMaxIndex=$iTeleportIndex
iTeleportIndexFirst=-1
for str in "${astrPrefabsList[@]}";do
#for((i=0;i<"${#astrPrefabsList[@]}";i+=2));do
  #iX=${astrPrefabsList[i]}
  #iZ=${astrPrefabsList[i+1]}
  #declare -p str
  eval "$str" #the rotation is of the prefab not the lookat
  #if echo "$strNm" |egrep "^(${strDeny})";then continue;fi
  if ! echo "$strNm" |egrep "${strAllow}";then continue;fi
  
  #NORMAL DIFFICULTY SPAWNS from -5000 5000 to -2300 -2000
  iYOrig=$iY
  bModY=false
  if $bParachuteMode;then iYNew=2000;bModY=true;fi #help the spawns on sky are elevation 2000 because the idea is not about relocation but to let player choose just an area nearby that spawn spot on the ground
  if $bUndergroundAutoPlaceMode;then iYNew=-2;bModY=true;fi #help this negative Y elevation will quickly use the engine auto placement ray cast from sky
  if $bModY;then
    iY=$iYNew
  else
    iY=$((iYOrig+2))&&:;
  fi
  
  : ${bUseAll:=true} #help
  if $bUseAll;then
    astrRect=("${astrRectAll[@]}")
  else
    astrRect=("${astrRectNormal[@]}")
  fi
  #declare -p iX iZ astrRect
  #set -x
  iDisplacementXZ=20 #minimum =3 to avoid the corners of POIs that may bug the auto player placent. 20 will try to place player above buildings
  #if((iX > ${astrRect[0]} && iX < ${astrRect[2]}));then
    #if((iZ < ${astrRect[1]} && iZ > ${astrRect[3]}));then
  bNormalZone=false;if FUNCisNormalZone;then bNormalZone=true;fi
  if $bUseAll || $bNormalZone;then
      strPos="$((iX+iDisplacementXZ)),$iY,$((iZ+iDisplacementXZ))"
      strTeleport="original teleport $iX $iYOrig $iZ"
      echo '    <spawnpoint helpSort="'"${strNm},Z=${iZ}"'" position="'"${strPos}"'" rotation="0,0,0" help="'"${strNm} ${strTeleport}"'"/>' >>"${strFlGenSpa}${strGenTmpSuffix}"
  fi
  
  bCreateAutoTeleport=false
  : ${bUseOnlyNormalDifficultySpawns:=false} #help
#  if $bUseOnlyNormalDifficultySpawns && $bNormalZone;then bCreateAutoTeleport=true;fi
  if $bUseOnlyNormalDifficultySpawns;then
    if $bNormalZone;then
      bCreateAutoTeleport=true
    fi
  else # allow all spawns everywhere
    bCreateAutoTeleport=true 
  fi
  if $bCreateAutoTeleport;then #create initial spawns to teleport to
    ((iTeleportIndex++))&&:
    if((iTeleportIndexFirst==-1));then iTeleportIndexFirst=$iTeleportIndex;fi
    strTeleportIndex="`printf %03d $iTeleportIndex`"
    strMsg="first join spawn points normal difficulty index ${strTeleportIndex}"
    echo '      <!-- '"${strMsg}"' -->
        <triggered_effect trigger="onSelfBuffUpdate" action="CallGameEvent" event="eventGSKTeleport'"${strTeleportIndex}"'">
          <requirement name="CVarCompare" cvar="iGSKTeleportedToSpawnPointIndex" operation="Equals" value="'"${iTeleportIndex}"'"/>
        </triggered_effect>' >>"${strFlGenBuf}${strGenTmpSuffix}"
    echo '      <!-- '"${strMsg}"' -->
    <action_sequence name="eventGSKTeleport'"${strTeleportIndex}"'"><action class="Teleport">
      <property name="target_position" value="'"${strPos}"'" help="'"${strNm} ${strTeleport}"'"/>
    </action></action_sequence>' >>"${strFlGenEve}${strGenTmpSuffix}"
    iTeleportMaxIndex=$iTeleportIndex
    if((iTeleportMaxIndex==iTeleportMaxAllowedIndex));then echo "PROBLEM: not all spawns were made available";break;fi
    #((iTeleportIndex++))&&:
  fi
    #fi
  #fi
done
strSorted="`cat "${strFlGenSpa}${strGenTmpSuffix}" |sort`"
echo "$strSorted" >"${strFlGenSpa}${strGenTmpSuffix}"
cat "${strFlGenSpa}${strGenTmpSuffix}"

./gencodeApply.sh "${strFlGenSpa}${strGenTmpSuffix}" "${strFlGenSpa}"
./gencodeApply.sh "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
./gencodeApply.sh "${strFlGenEve}${strGenTmpSuffix}" "${strFlGenEve}"

##xmlstarlet ed -L -d "//triggered_effect[@help='SPAWNPOINT_RANDOM_AUTOMATIC']" "${strFlGenBuf}"
#CFGFUNCtrash "${strFlGenBuf}${strGenTmpSuffix}"
#echo '        <triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="iGSKTeleportedToSpawnPointIndex" operation="set" value="randomInt('"${iTeleportIndexFirst},${iTeleportMaxIndex}"')"/>' >>"${strFlGenBuf}${strGenTmpSuffix}"
#./gencodeApply.sh --subTokenId "TeleportCfgs" "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
./gencodeApply.sh --xmlcfg iGSKTeleportedToSpawnPointIndex 'randomInt('"${iTeleportIndexFirst},${iTeleportMaxIndex}"')'

./gencodeApply.sh --cleanChkDupTokenFiles
