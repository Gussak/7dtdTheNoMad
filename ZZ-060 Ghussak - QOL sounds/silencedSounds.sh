#!/bin/bash
#PREPARE_RELEASE:REVIEWED:OK
set -eu
strFlSoundsXml="$1" #help use the xml file from the game being played from the savegame folder. it is better than from the vanilla data folder that was not modded!
IFS=$'\n' read -d '' -r -a astrList < <(egrep 'Sounds[^"]*_s_fire[^"]*' "$strFlSoundsXml" -irhIo |sort -u)&&:
for strSilenced in "${astrList[@]}";do
  strLoud="`echo "${strSilenced}"|sed 's"_s_fire"_fire"'`"
  echo '  <set xpath="//AudioClip[@ClipName='"'${strLoud}'"']/@ClipName">'"${strSilenced}"'</set>'
done
