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

egrep "[#]help" $0

: ${strFlCfg:="$HOME/.config/$(basename "$0").cfg"} #help the config file stored as bash code and used here as source file, be careful editing it!

: ${iInvSlotWidth:=39} #help CFG THIS FOR YOUR RESOLUTION! here is 1366x768 btw

: ${posXYnpcInvSortIcon:="331 122"} #help CFG THIS TO THE NPC sort inv icon POSITION ON YOUR RESOLUTION!
#: ${posXYnpcFirstInvSlot:="127 142"} #he lp CFG THIS TO THE NPC. first inv slot POSITION ON YOUR RESOLUTION! this position never changes.
: ${posXYnpcLastInvSlot:="439 632"} #help CFG THIS TO THE NPC last inv slot POSITION ON YOUR RESOLUTION!

: ${strFlMonitorRequest_MoveOne:="/tmp/$(basename "$0").MonitorUserRequest_MoveOne.tmp"} #help create this file to let: Tip:Ubuntu:Settings/keyboard/keyboardShortcuts/...customize.../...custom.../+:command: bash -c "echo >/tmp/macroMoveItemsToNPCInventory.sh.MonitorUserRequest_MoveOne.tmp" #name: 7DTD move one item to NPC inventory
: ${strFlMonitorRequest_UpdateLastPos:="/tmp/$(basename "$0").MonitorUserRequest_UpdateLastPos.tmp"} #help create this file to let: Tip:Ubuntu:Settings/keyboard/keyboardShortcuts/...customize.../...custom.../+:command: bash -c "echo >/tmp/macroMoveItemsToNPCInventory.sh.MonitorUserRequest_UpdateLastPos.tmp" #name: 7DTD update NPC last inventory position
: ${strFlMonitorRequest_UpdateSortIconPos:="/tmp/$(basename "$0").MonitorUserRequest_UpdateSortIconPos.tmp"} #help create this file to let: Tip:Ubuntu:Settings/keyboard/keyboardShortcuts/...customize.../...custom.../+:command: bash -c "echo >/tmp/macroMoveItemsToNPCInventory.sh.MonitorUserRequest_UpdateSortIconPos.tmp" #name: 7DTD update NPC sort icon position
: ${strFlMonitorRequest_MoveWholeLine:="/tmp/$(basename "$0").MonitorUserRequest_MoveWholeLine.tmp"} #help create this file to let: Tip:Ubuntu:Settings/keyboard/keyboardShortcuts/...customize.../...custom.../+:command: bash -c "echo >/tmp/macroMoveItemsToNPCInventory.sh.MonitorUserRequest_MoveWholeLine.tmp" #name: 7DTD move a whole line to NPC inventory (or stop doing it)

: ${nTotSlotsInThePlayerInvForASingleLine:=20} #help

: ${strGameWindowName:="Default - Wine desktop"} #help

: ${fWaitBeforeInitMoving:=3} #help
: ${fWaitCheckDelay:=0.33} #help in seconds, this is how fast checks will happen, the lower the less you have to wait for commands to happen

: ${strEvalCmdSpeakRequest:="echoc --say "} # from ScriptEchoColor project

#: ${strChkSelfRunRegex:="$(which bash) .*/$(basename "$0") --RunSingleInstance"} #help single instance check


### MAIN

#: ${bRunSingleInstance:=false} # do not set by hand
#if ! $bRunSingleInstance;then
	#if(( $(pgrep -fa "$strChkSelfRunRegex" |tee -a /dev/stderr |wc -l) == 0 ));then
		#echo "RUNNING SINGLE INSTANCE:"
		#bRunSingleInstance=true "$0" --RunSingleInstance
	#else
		#read -t 60 -n 1 -p "INFO: already running, exiting soon..."
	#fi
	#exit 0
#fi
strFlSingleInstance="/tmp/$(basename "$0").SingleInstance.PID.tmp"
nSingleInstancePID="$(cat "$strFlSingleInstance")"&&:
if ps -p "$nSingleInstancePID";then
	read -t 60 -n 1 -p "INFO: already running, exiting soon..."
	exit 0
fi
echo $$ >"$strFlSingleInstance"
ls -l "$strFlSingleInstance"

if [[ -f "$strFlCfg" ]];then
	echo "loading config file: $strFlCfg"
	cat "$strFlCfg"
	source "$strFlCfg";
fi

function FUNCmvItemToNPC() { #help xdotool to move item at cursor to npc inventory. 
  : ${fSleep1:="0.5"} #help initial click and mouse left button down hold
  : ${fSleep3:="0.25"} #help 
  
  echo -e "${FUNCNAME[@]}:$((iFUNCmvItemToNPC_count++))\r"&&:
  
  eval "`xdotool getmouselocation --shell`" # X Y
  
  #set -x
  xdotool click --window $nWId 1;sleep $fSleep1
  xdotool mousedown --window $nWId 1;sleep $fSleep1
  xdotool mousemove_relative -- -5 0;sleep 0.1
  xdotool mousemove_relative -- -5 0;sleep 0.1
  xdotool mousemove_relative -- -5 0;sleep 0.1
  
  xdotool mousemove ${posXYnpcLastInvSlot};sleep $fSleep3
  xdotool mouseup --window $nWId 1;sleep $fSleep3
  xdotool click --window $nWId 1;sleep $fSleep3
  
  xdotool mousemove ${posXYnpcInvSortIcon};sleep $fSleep3
  xdotool click --window $nWId 1;sleep $fSleep3
  
  xdotool mousemove $((X + iInvSlotWidth)) $Y #restore initial pos where player placed the mouse + next slot to the right
  #set +x
};export -f FUNCmvItemToNPC

echo
echo "TIP for quickly and easily moving items from one npc to another:"
echo " Remove from your inventory all items that are disorganized into some EMPTY chest using shift+click (a mouse with turbo left button will help a lot)."
echo " Make it sure there is no empty slots in the top organized lines of your inventory."
echo " Put both NPCs in stayWhereIAmStanding mode."
echo " Get from 1st npc all items you want to to move to the 2nd npc into your inventory."
echo " (continue below on the macro.)"
echo
echo "IMPORTANT:"
echo " Please place the mouse on the first column of the line of items in YOUR inventory that you want to fully transfer to the NPC, and then hit ENTER here and focus the game window in less than ${fWaitBeforeInitMoving}s."
echo " OR: bind a system key combination to create the request file as suggested, then place the mouse over every item you want to move and hit that key (suggestion Super + F5 F6 F7 F8)"
echo

function FUNCwriteCfg() {
	echo "$1" |tee -a "$strFlCfg"
	cp -vf "$strFlCfg" "${strFlCfg}.bkp"
	strCfgData="$(cat "$strFlCfg")"
	echo "$strCfgData" >"$strFlCfg"
}

function FUNCchkRequest() { #helpf <request>
	local lstrReq="$1";shift
	
	eval "strFlReq=\${strFlMonitorRequest_${lstrReq}}"
	#declare -p strFlReq
	if [[ -f "$strFlReq" ]];then
		echo
		echo "`date`: processing request: ${lstrReq}"
		eval "${strEvalCmdSpeakRequest} \"$( echo "${lstrReq}" |sed 's@[A-Z][a-z]*@& @g' )\""&&:
		ls -l "$strFlReq"
		rm -v "$strFlReq" #removing before it start is good to let make it easier to issue more commands faster
		eval "FUNCprocessRequest_${lstrReq}"
		#rm -v "$strFlReq"
		echo
	fi
}
function FUNCprocessRequest_MoveWholeLine() {
	if [[ "$strResp" != y ]];then
		strResp="y"
		echo "Init: move line"
	else
		strResp=""
		echo "STOP: move line"
	fi
}
function FUNCprocessRequest_MoveOne() {
	FUNCmvItemToNPC
}
function FUNCprocessRequest_UpdateLastPos() {
	eval "`xdotool getmouselocation --shell`" # X Y
	posXYnpcLastInvSlot="$X $Y"
	declare -p posXYnpcLastInvSlot |tee -a "$strFlCfg"
}
function FUNCprocessRequest_UpdateSortIconPos() {
	eval "`xdotool getmouselocation --shell`" # X Y
	posXYnpcInvSortIcon="$X $Y"
	declare -p posXYnpcInvSortIcon |tee -a "$strFlCfg"
}

#cleanuping
rm -v "$strFlMonitorRequest_MoveOne"&&:
rm -v "$strFlMonitorRequest_UpdateLastPos"&&:
rm -v "$strFlMonitorRequest_MoveWholeLine"&&:
rm -v "$strFlMonitorRequest_UpdateSortIconPos"&&:
while true;do
	if [[ -z "${nWId-}" ]] || ! xdotool getwindowpid $nWId 2>&1 >/dev/null;then
		if ! nWId="$(xdotool search "$strGameWindowName")";then
			declare -p strGameWindowName
			read -t ${fWaitBeforeInitMoving} -n 1 -p "game seems to not be running..." >/dev/stderr
			continue
		fi
	fi
	
	echo -ne "`date`: move a whole line with ${nTotSlotsInThePlayerInvForASingleLine} items (y/...)? (or press bound key for 1 item) \r"
	read -t ${fWaitCheckDelay} -n 1 strResp
	FUNCchkRequest MoveWholeLine
	#if [[ -f "$strFlMonitorRequest_MoveWholeLine" ]];then
		#echo
		#echo "`date`: processing request"
		#ls -l "$strFlMonitorRequest_MoveWholeLine"
		#strResp=y
		#rm -v "$strFlMonitorRequest_MoveWholeLine"
		#echo
	#fi
	if [[ "$strResp" == y ]];then
		sleep ${fWaitBeforeInitMoving}
		iFUNCmvItemToNPC_count=0
		for((i=0;i<nTotSlotsInThePlayerInvForASingleLine;i++));do 
			FUNCchkRequest MoveWholeLine
			if [[ "$strResp" != y ]];then break;fi
			FUNCmvItemToNPC
		done
		eval "${strEvalCmdSpeakRequest} \"Completed moving whole line!\""&&:
	fi
	
	FUNCchkRequest MoveOne
	#if [[ -f "$strFlMonitorRequest_MoveOne" ]];then
		#echo
		#echo "`date`: processing request"
		#ls -l "$strFlMonitorRequest_MoveOne"
		#FUNCmvItemToNPC
		#rm -v "$strFlMonitorRequest_MoveOne"
		#echo
	#fi

	FUNCchkRequest UpdateLastPos
	#if [[ -f "$strFlMonitorRequest_UpdateLastPos" ]];then
		#echo
		#echo "`date`: processing request"
		#ls -l "$strFlMonitorRequest_UpdateLastPos"
		#eval "`xdotool getmouselocation --shell`" # X Y
		#posXYnpcLastInvSlot="$X $Y"
		#declare -p posXYnpcLastInvSlot |tee -a "$strFlCfg"
		#rm -v "$strFlMonitorRequest_UpdateLastPos"
		#echo
	#fi

	FUNCchkRequest UpdateSortIconPos
	#if [[ -f "$strFlMonitorRequest_UpdateSortIconPos" ]];then
		#echo
		#echo "`date`: processing request"
		#ls -l "$strFlMonitorRequest_UpdateSortIconPos"
		#eval "`xdotool getmouselocation --shell`" # X Y
		#posXYnpcInvSortIcon="$X $Y"
		#declare -p posXYnpcInvSortIcon |tee -a "$strFlCfg"
		#rm -v "$strFlMonitorRequest_UpdateSortIconPos"
		#echo
	#fi
	
done
