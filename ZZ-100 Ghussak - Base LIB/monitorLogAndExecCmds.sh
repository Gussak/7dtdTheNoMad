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

source ./libSrcCfgGenericToImport.sh

export strFlLog="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"
declare -p strFlLog

: ${strExecFlNm:="7DaysToDie.exe"} #help
strExecFlNm="`echo "$strExecFlNm" |sed 's@.@[&]@g'`" # this prevent other pgrep elseware matching like the pgrep here was the running game..
: ${strExecRegex:="C:/.*/${strExecFlNm}"} #help
declare -p strExecRegex
export strExecRegex

function FUNCpromptGfx() {
	if which yad;then
		while ! CFGFUNCexec --noErrorExit yad --title "7DTD Log Monitor" --on-top --center --text "$@.\n\nYou need to click OK to continue checking the log.";do :;done
	else
		CFGFUNCprompt "$@"
	fi
};export -f FUNCpromptGfx
function FUNCrawMatchRegex() { echo "$1" |sed -r 's@.@[&]@g'; };export -f FUNCrawMatchRegex

function FUNCsuspendPopup() {
	CFGFUNCexec pkill -SIGSTOP -fe "${strExecRegex}"
	strInfo="$1"
	#if which yad;then
		#while ! CFGFUNCexec --noErrorExit yad --on-top --center --text "${strInfo}. Close to SIGCONT the game.";do :;done
	#else
		#CFGFUNCprompt "$strInfo"
	#fi
	FUNCpromptGfx "${strInfo}. Close this popup to SIGCONT the game."
	CFGFUNCexec pkill -SIGCONT -fe "$strExecRegex"
}

export strChkAutoStopOnLoadA="`FUNCrawMatchRegex " INF Created player with id="`"
#export strChkAutoStopOnLoadB="`FUNCrawMatchRegex " INF PlayerSpawnedInWorld (reason: LoadedGame, position:"`.*: localplayer" # this grants extra 10s w/o waiting!
export strChkAutoStopOnLoadB=" INF PlayerSpawnedInWorld [(]reason: (LoadedGame|NewGame), position:.*: localplayer" # this grants extra 10s w/o waiting!
export bAllowPauseOnB=false

export strChkButtonSpawn="INF Loading players.xml"
export strChkShapesIni="`FUNCrawMatchRegex " INF Loaded (local): shapes"`"
export strChkErrors="^....-..-.*:..:.. [0-9]*[.][0-9]* ERR " #todo ignore some errors like "Object reference not set to an instance of an object"
export strChkErrors="^....-..-.*:..:.. [0-9]*[.][0-9]* ERR XML loader" #todo popup and SIGSTOP
export strChkExceptions="^....-..-.*:..:.. [0-9]*[.][0-9]* EXC |at vp_FPCamera.DoCameraCollision" #fpcamera not so rarely happens just before trying to join the server
#export strChkStartServer="`FUNCrawMatchRegex " INF NET: Starting server protocols"`" #" INF [MODS] Start loading" " INF StartAsServer"
export strChkStartServer="`FUNCrawMatchRegex " INF NET: Starting offline server"`" #" INF [MODS] Start loading" " INF StartAsServer"
export strChkNullptrReqRestart="^ *at (Block.OnEntityWalking)" #help if this happens, the game becomes unplayable because NPCs and foes will start lagging a lot. This solves with 1 or more engine full restart, exit the engine and restart the app. #EntityHuman.OnUpdateLive|EntityAnimal.OnUpdateLive
export strChkNullRefExc="^NullReferenceException: Object reference not set to an instance of an object"

export strChkCrash="^Crash[!][!][!]$"
#echo "PID=$$"
#tail -n +1 -F "$strFlLog" |while read strLine;do
export nCountExc=0
export nCountNullPtrReqRestart=0
export nCountNullRef=0
tail -F "$strFlLog" |while read strLine;do
	#echo "while.PID=$$"
	bExecCmd=false
	bRelevant=true
	#if ! pgrep -fa "${strExecRegex}";then
		#echo "-[WAIT:GameNotRunning:SKIP] ${strLine}"
	if [[ "$strLine" =~ .*${strChkStartServer}.* ]];then
		CFGFUNCinfo "+[EXEC:WritableCfgDump] $strLine (to let the game start the server)"
		CFGFUNCexec pkill -SIGSTOP -fe "${strExecRegex}" # this is important to try to grant the game wont try to write over RO files while they are becoming RW
		while ! CFGFUNCexec --noErrorExit chmod -R u+w _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/;do
			if ! CFGFUNCexec --noErrorExit ./updateNewestSavegameSymlink.sh;then
				FUNCsuspendPopup "failed to updateNewestSavegameSymlink.sh";
			fi
		done
		CFGFUNCexec pkill -SIGCONT -fe "${strExecRegex}"
	elif [[ "$strLine" =~ .*${strChkButtonSpawn}.* ]];then
		CFGFUNCinfo "skipping spawn button" # the ;\ below is just to help test on terminal, becomes one line to fix.
		nWID="$(xdotool search "Default - Wine desktop")";\
		strToEval="$(xwininfo -id $nWID|egrep -i "absolute|width|height" |tr -d ' -'|tr ':\n' '=;')";\
		eval "$strToEval";nX=$((Width/2));nY=$((Height/2));declare -p nX nY;\
		for((i=0;i<5;i++));do # so while you are using the PC it will try to continue anyway
			echo -n .
			xdotool mousemove -w $nWID $nX $nY;
			xdotool click --repeat 3 --window $nWID 1
			#xdotool click --repeat 3 --delay 200 --window $nWID 1
		done
	elif [[ "$strLine" =~ .*${strChkCrash}.* ]];then
		CFGFUNCinfo "![CRASH] !!! $strLine !!!"
		FUNCsuspendPopup "The game CRASHED!!! the engine must be restarted.\n\n${strLine}"
	elif [[ "$strLine" =~ .*${strChkExceptions}.* ]];then
		((nCountExc++))&&:
		if((nCountExc==1));then
			CFGFUNCinfo "![EXCEPTION] !!! $strLine !!!"
			FUNCsuspendPopup "Exceptions cannot be ignored, game is already broken NullReference=$nCountNullRef and must be reloaded.\n\n${strLine}"
		fi
		if((nCountExc>10));then nCountExc=0;fi # this way, it lets the player see the log a bit
	elif [[ "$strLine" =~ .*${strChkNullRefExc}.* ]];then
		((nCountNullRef++))&&:
	elif [[ "$strLine" =~ .*${strChkNullptrReqRestart}.* ]];then
		((nCountNullPtrReqRestart++))&&:
		if((nCountNullPtrReqRestart>10));then
			CFGFUNCinfo "![NULLREF] !!! $strLine !!!"
			FUNCsuspendPopup "These lines about NullReference=$nCountNullRef of this kind '$strChkNullptrReqRestart' cannot be ignored, game is already unstable, foes and NPCs wont behave properly, and the app must be restarted and a previous savegame preferably should be loaded, try also drop_caches.\n\n${strLine}"
			nCountNullPtrReqRestart=0 #so user can insist a bit too see what is happening
		fi
	elif [[ "$strLine" =~ .*${strChkAutoStopOnLoadA}.* ]];then
		bAllowPauseOnB=true
	elif $bAllowPauseOnB && [[ "$strLine" =~ .*${strChkAutoStopOnLoadB}.* ]];then
		if ! pgrep -fa "${strExecRegex}";then
			echo "-[WAIT:GameNotRunning:SKIP] ${strLine}"
		else
			CFGFUNCinfo "+[EXEC:ProtectCfgDump] $strLine (to make it easier to avoid editing them by mistake ...)"
			while ! CFGFUNCexec --noErrorExit chmod -R ugo-w _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/;do
				if ! CFGFUNCexec --noErrorExit ./updateNewestSavegameSymlink.sh;then
					FUNCsuspendPopup "failed to updateNewestSavegameSymlink.sh";
				fi
			done
			
			bAllowPauseOnB=false
			
			CFGFUNCinfo "+[EXEC:AutoStopOnLoadGame] $strLine"
			FUNCsuspendPopup "the game finished loading and is ready to play"
			bExecCmd=true
		fi
	elif [[ "$strLine" =~ .*${strChkShapesIni}.* ]];then
		########
		### IT MAY FREEZE WHILE LOADING THE BLOCKS AFTER THE SHAPES COMPLETED!!!
		### Loading blocks is slow and there is no workaround :(
		########
		CFGFUNCinfo "+[EXEC:ChkIfGameFrozeLoadingBlocks] $strLine"
		#@RM noneed: start child process, get it's pid, if "block ids" comes, kill child pid, otherwise hint SIGKILL game to user thru yad
		#function FUNCchkShapesIni() {
			: ${nIniShapesDelay:=35} #help shapes shall take not more than this seconds to complete (on my pc)
			lstrKeyShapesIni="`ls -l "$strFlLog"`"
			li=0
			#bBreakChkShapesLoop=false
			#trap 'bBreakChkShapesLoop=true' INT
			while true;do
				#echo "while2.PID=$$"
				((li++))&&:
				if [[ "$lstrKeyShapesIni" != "`ls -l "$strFlLog"`" ]];then CFGFUNCinfo "Blocks load success!";break;fi
				echo -en "${li}/${nIniShapesDelay}s waiting blocks complete init\r" # (hit 'y' to skip this check).\r"
				#if CFGFUNCprompt -q "ignore/skip this check?";then break;fi
				if((li>nIniShapesDelay));then 
					strInfo="[WARN] ${li}/${nIniShapesDelay}s log file have not changed yet, froze on ini Blocks? if so you should 'SIGKILL' the game, but 'wineserver -k' is better. Hitting OK will 'wineserver -k' !\n But you can just wait to see if it loads anyway, and AFTER that click CANCEL."
					CFGFUNCinfo "$strInfo";
					if ! pgrep "yad.*TNMMonLog:FrozenBlocks" -fa;then
						function FUNCyad_FrozenShapes() {
							if yad --title "TNMMonLog:FrozenBlocks" --text "$strInfo" --on-top --centered --no-focus;then
								xterm -title "TNMMonLog:FrozenBlocks" -e wineserver -k
							fi
						};export -f FUNCyad_FrozenShapes
						(FUNCyad_FrozenShapes&disown)
					fi
				fi
				if ! pgrep -f "$strExecRegex" >/dev/null;then CFGFUNCinfo "[WARN] game stopped running";break;fi
				sleep 1
				#if $bBreakChkShapesLoop;then echo BREAK;break;fi
				#read -n 1 -t 1 strResp&&:;if [[ "$strResp" =~ [yY] ]];then break;fi
				#read -u 0 -n 1 -t 1 strResp&&:;if [[ "$strResp" =~ [yY] ]];then break;fi
				#read -e -n 1 -t 1 strResp&&:;if [[ "$strResp" =~ [yY] ]];then break;fi
			done
		#}
		#FUNCchkShapesIni
		
		#nIniShapesSecs=$SECONDS
	#elif [[ "$strLine" == " INF Block IDs with mapping" ]]
		#nEndShapesSecs=$SECONDS
		bExecCmd=true
	else
		: ${bShowSkippedLines:=false} #help
		if $bShowSkippedLines;then echo "-[SKIP] $strLine";fi
		bRelevant=false
	fi
	
	: ${nSecondsPrevious:=$SECONDS}
	nDelayFromPrevious=$(($SECONDS - ${nSecondsPrevious}))
	if $bRelevant && ((nDelayFromPrevious>0));then echo " < DelayFromPrevious: ${nDelayFromPrevious}s > ";fi
	nSecondsPrevious=$SECONDS
	#if ! $bExecCmd;then  echo "[IGNOREDLINE] $strLine";fi
done

#echo "below error chk not ready";exit 0 #todo rm
#while true;do
	#read -p "." -t 3&&:
	#strRegex="^....-..-.*:..:.. [0-9]*[.][0-9]* EXC " #todo ignore some errors like "Object reference not set to an instance of an object"
	#if egrep -q "$strRegex" "$strFlLog";then
		#egrep "$strRegex" "$strFlLog" -A 20 #todo show range til each log sector end
		##todo yad tiny alert
	#fi
	##todo ignore old lines
#done

#2023-04-12T18:22:27 316.119 EXC Object reference not set to an instance of an object
#UnityEngine.StackTraceUtility:ExtractStringFromException(Object)
#...
#Log:Exception(Exception)

