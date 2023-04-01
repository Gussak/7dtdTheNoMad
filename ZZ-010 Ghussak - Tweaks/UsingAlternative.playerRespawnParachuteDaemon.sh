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

#help UsingAlternative: using gameevents to teleport the player on join and respawn events

egrep "[#]help" $0

set -Eeu

if [[ "${1-}" == -x ]];then #help run on xterm
  (xterm -e "$0"&disown)
  exit
fi

#help this is meant to run with: buffGSKRespawnNoFallDmg

#help When first entering the game or after you die, and if you are not spawning in your bed or near it (if you have no bed placed), be patient, this script will shortly kick in and teleport you to the sky!

: ${strNewGameSpawnsFile:="./GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/spawnpoints.Z_DEFAULT_NORMAL_SPAWNS_ONLY.xml"} #help set the file to collect the spawn point to teleport the player to it when starting a new game (your first spawn in the world)
function FUNCtele() {
  local lstrFlSpawn="${1-}"
  sleep "$nWaitBeforeTeleport"
  local lnWId="`xdotool search "$strWindowName" 2>/dev/null`"&&: #this requires to run the game in Wine Desktop mode
  xdotool windowactivate $lnWId&&: # this line can fail to be compatible with xdotool-for-windows
  sleep 0.5
  local lstrTeleCmd="$strTeleUpToSkyCmd"
  if [[ -n "$lstrFlSpawn" ]];then
    local lastrPosList=(`xmlstarlet sel -t -v "spawnpoints/spawnpoint/@position" "$strNewGameSpawnsFile"`)
    local iRnd=$(($RANDOM%${#lastrPosList[*]}))&&:
    lstrTeleCmd="teleport `echo ${lastrPosList[iRnd]} |tr , ' '`"
    #declare -p astrPosList |tr '[' '\n'
    #declare -p lstrTeleCmd
  fi
  declare -p lstrTeleCmd
  echo -ne "$lstrTeleCmd" |xclip -selection clipboard
  #xdotool type --window $lnWId --delay 50 "$strTeleUpToSkyCmd"&&: # 20s too slow!
  xdotool key F1 #this may work with xdotool-for-windows project on cygwin
  xdotool key --delay 500 ctrl+v Return F1
}

: ${strFlLog:="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"} #help this file is essential to let this script work
while [[ ! -f "$strFlLog" ]];do
  echo -e "`date`:PROBLEM: the Player.log file was not created yet or strFlLog variable is not properly configured!\r"
  sleep 3
done

: ${strWindowName:="Default - Wine desktop"} #help change this if using WM integration window mode
: ${strTeleUpToSkyCmd:="teleport offset 0 2000 0"} #help
: ${nWaitBeforeTeleport:=5} #help increase this if your machine is slow and please WAIT the teleport happens!
bIgnoreOnce=false
strFlMatchPrev=".$0.strMatchPrev.tmp"
strMatchPrev="`cat "$strFlMatchPrev"`"&&:
declare -p strMatchPrev
while true;do
  read -p "`date`: Press 't' to force normal teleport now ('n' to test NewGame teleport)`echo -e "\r"`" -t 1 -n 1 strResp&&:;
  if [[ "$strResp" == y ]];then FUNCtele;continue;fi
  if [[ "$strResp" == n ]];then FUNCtele "$strNewGameSpawnsFile";continue;fi
  
  strMatch="`egrep "sleeping bag SpawnPoint|PlayerSpawnedInWorld.*localplayer" "$strFlLog" |tail -n 1`" #OpenSpawnWindow
  if [[ "${strMatch}" == "${strMatchPrev}" ]];then continue;fi
  strMatchPrev="${strMatch}"
  echo -n "$strMatchPrev" >"$strFlMatchPrev"
  
  if [[ "$strMatch" =~ sleeping\ bag\ SpawnPoint ]];then echo "Respawing in bed.";bIgnoreOnce=true;continue;fi # will ignore one respawn
  
  if [[ "$strMatch" =~ PlayerSpawnedInWorld ]];then
    if $bIgnoreOnce;then bIgnoreOnce=false;continue;fi
    #ignores at least =~ reason: LoadedGame
    if [[ "$strMatch" =~ reason:\ Died ]];then 
      declare -p strMatch
      FUNCtele
    fi
    if [[ "$strMatch" =~ reason:\ NewGame ]];then
      declare -p strMatch
      FUNCtele "$strNewGameSpawnsFile"
    fi
  fi
done
