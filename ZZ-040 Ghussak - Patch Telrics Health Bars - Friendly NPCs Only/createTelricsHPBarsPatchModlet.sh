#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

egrep "[#]help" $0

: ${strTelricsModFolder:="Telrics Health Bars 2.0A19"} #help config this to the correct folder name or it wont work..

if [[ ! -f "./Resources/100HealthBarParticle.unity3d" ]];then
  echo "ERROR: you need to symlink or copy the Resources folder from 'Telrics Health Bars' to this mod's folder (I dont know how to point to the files on that folder w/o causing errors and failing, sorry...)"
  exit 1
fi

astrEffectGroupNameList=(
  "100 - 88"
  "87 - 76"
  "75 - 63"
  "62 - 51"
  "50 - 38"
  "37 - 26"
  "25 - 13"
  "12 - 0"
)

strFlOut="copyPatchFromHere.TMP.txt"
trash "$strFlOut"

for strEGN in "${astrEffectGroupNameList[@]}";do
  #nPerc="${strEGN:0:2}"
  nPerc="`echo "$strEGN" |egrep -o "^[0-9]*"`"
  # to edit the xml with +- good syntax highlight on geany, temporarily change the '<<EOF' to '< <EOF'
	cat >>"${strFlOut}" <<EOF
    <append xpath="/buffs/buff[@name='TelricsHealthBarTarget']/effect_group[@name='${strEGN}']">
      <triggered_effect trigger="onSelfBuffUpdate" action="AttachPrefabToEntity" 
        prefab="#@modfolder(${strTelricsModFolder}):Resources/${nPerc}HealthBarParticle.unity3d?${nPerc}HealthBarParticlePrefab" 
        parent_transform="Origin"  local_offset="0,3.00,0" local_rotation="0,0,0" >
        <requirement name="!EntityTagCompare" tags="bandit" />
        <requirement name="EntityTagCompare" tags="npc" />
      </triggered_effect>
    </append>
    
EOF
  #doesnt work        <requirement name="EntityTagCompare" tags="hirable" />
done

cat "$strFlOut"
trash "$strFlOut"
