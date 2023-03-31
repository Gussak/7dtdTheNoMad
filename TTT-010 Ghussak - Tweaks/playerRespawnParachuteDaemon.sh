#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

egrep "[#]help" $0

set -Eeu

if [[ "${1-}" == -x ]];then #help run on xterm
  (xterm -e "$0"&disown)
  exit
fi

#help WHEN FIRST ENTERING THE GAME OR AFTER YOU DIE, BE PATIENT IF YOU ARE NOT SPAWNING IN/NEAR YOUR BED (if you have NO bed placed)!

function FUNCtele() {
  sleep "$nWaitBeforeTeleport"
  nWId="`xdotool search "$strWindowName" 2>/dev/null`" #this requires to run the game in Wine Desktop mode
  xdotool windowactivate $nWId
  sleep 0.5
  echo -ne "$strTeleportCmd" |xclip -selection clipboard
  #xdotool type --window $nWId --delay 50 "$strTeleportCmd" # 20s too slow!
  xdotool key F1
  xdotool key --delay 500 ctrl+v Return F1
}

: ${strFlLog:="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"} #help
: ${strWindowName:="Default - Wine desktop"} #help change this if using WM integration window mode
: ${strTeleportCmd:="teleport offset 0 2000 0"} #help
: ${nWaitBeforeTeleport:=5} #help increase this if your machine is slow and please WAIT the teleport happens!
bIgnoreOnce=false
strFlMatchPrev=".$0.strMatchPrev.tmp"
strMatchPrev="`cat "$strFlMatchPrev"`"&&:
declare -p strMatchPrev
while true;do
  read -p "`date`: Press 'y' to force teleport now`echo -e "\r"`" -t 1 -n 1 strResp&&:;if [[ "$strResp" == y ]];then FUNCtele;continue;fi
  strMatch="`egrep "sleeping bag SpawnPoint|PlayerSpawnedInWorld.*localplayer" "$strFlLog" |tail -n 1`" #OpenSpawnWindow
  #declare -p strMatch
  if [[ "${strMatch}" == "${strMatchPrev}" ]];then continue;fi
  strMatchPrev="${strMatch}"
  echo -n "$strMatchPrev" >"$strFlMatchPrev"
  
  if [[ "$strMatch" =~ sleeping\ bag\ SpawnPoint ]];then echo "Respawing in bed.";bIgnoreOnce=true;continue;fi # will ignore one respawn
  
  if [[ "$strMatch" =~ PlayerSpawnedInWorld ]];then
    if $bIgnoreOnce;then bIgnoreOnce=false;continue;fi
    if [[ "$strMatch" =~ reason:\ (NewGame|Died) ]];then #not on reason: LoadedGame
      FUNCtele
    fi
  fi
done
