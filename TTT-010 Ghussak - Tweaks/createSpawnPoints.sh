#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

egrep "[#]help" $0

: ${bParachuteMode:=true} #help bParachuteMode=false to spawn on the ground. bParachuteMode does not work, player is always placed on ground (never on sky), but this is good to try to place player above buildings at least

#help after death, player seems to respawn always on the nearest spawnpoints.xml if having no bed placed

source ./gencodeInitSrcCONFIG.sh

strPathWork="GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory"
strFlGenSpa="${strPathWork}/spawnpoints.xml"
trash "${strFlGenSpa}${strGenTmpSuffix}"

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
for str in "${astrPrefabsList[@]}";do
#for((i=0;i<"${#astrPrefabsList[@]}";i+=2));do
  #iX=${astrPrefabsList[i]}
  #iZ=${astrPrefabsList[i+1]}
  #declare -p str
  eval "$str" #the rotation is of the prefab not the lookat
  #if echo "$strNm" |egrep "^(${strDeny})";then continue;fi
  if ! echo "$strNm" |egrep "${strAllow}";then continue;fi
  
  #NORMAL DIFFICULTY SPAWNS from -5000 5000 to -2300 -2000
  if $bParachuteMode;then iY=2000;fi 
  : ${bUseAll:=false} #help
  if $bUseAll;then
    astrRect=("${astrRectAll[@]}")
  else
    astrRect=("${astrRectNormal[@]}")
  fi
  #declare -p iX iZ astrRect
  #set -x
  iDisplacementXZ=20 #minimum =3 to avoid the corners of POIs that may bug the auto player placent. 20 will try to place player above buildings
  if((iX > ${astrRect[0]} && iX < ${astrRect[2]}));then
    if((iZ < ${astrRect[1]} && iZ > ${astrRect[3]}));then
      strPos="$((iX+iDisplacementXZ)),$((iY+2)),$((iZ+iDisplacementXZ))"
      strTeleport="teleport $iX $iY $iZ"
      echo '    <spawnpoint helpSort="'"${strNm},Z=${iZ}"'" position="'"${strPos}"'" rotation="0,0,0" help="'"${strNm} iRot=$iRot ${strTeleport}"'"/>' >>"${strFlGenSpa}${strGenTmpSuffix}"
    fi
  fi
done
strSorted="`cat "${strFlGenSpa}${strGenTmpSuffix}" |sort`"
echo "$strSorted" >"${strFlGenSpa}${strGenTmpSuffix}"
cat "${strFlGenSpa}${strGenTmpSuffix}"

./gencodeApply.sh "${strFlGenSpa}${strGenTmpSuffix}" "${strFlGenSpa}"
