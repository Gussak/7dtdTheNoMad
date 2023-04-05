#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

IFS=$'\n' read -d '' -r -a astrFlList < <(ls ../../Data/Prefabs/POIs/trader_*.xml)&&:
for strFl in "${astrFlList[@]}";do
  strFlBkp="${strFl}.`date +'%Y_%m_%d-%H_%M_%S'`.bkp"
  cp -v "$strFl" "$strFlBkp"
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaProtect']/@value" -v "0,0,0" "$strFl"
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaTeleportSize']/@value" -v "0,0,0" "$strFl"
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaTeleportCenter']/@value" -v "0,0,0" "$strFl"
  colordiff "$strFlBkp" "$strFl"
done
