#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2024, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
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

export strRLGameLog="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"
export strRLRun="C:/Games/7 Days To Die/7DaysToDie.exe"

function FUNCRLDropcaches() {
	: ${bUseDropCaches:=true} #help seems to only work after a few restarts, if using drop caches.
	set -x;
	if $bUseDropCaches;then sudo dd if=/proc/3/stat of=/proc/sys/vm/drop_caches bs=1 count=1;fi
	set +x 
};export -f FUNCRLDropcaches

function FUNCRLRun() {
	(cd ..; WINEwrapperRunNowAlways=true wine64 "$strRLRun")
	echo "Exited, hit 'y' to wait or Enter to continue (15s)";
	read -t 15 strResp #to have some time to read/copy the log
	if [[ "$strResp" == y ]];then read -p "WaitingAgain...";fi
};export -f FUNCRLRun

function FUNCRLRunLoop() {
	FUNCRLDropcaches
	iRestartCount=0
	while true;do
		nTmBefore="$(date +"%s")"
		
		(xterm -e bash -c "FUNCRLRun" & disown)
		
		while ! pgrep -fa "^${strRLRun}";do echo "iRestartCount=$iRestartCount, waiting the app start nTmBefore=$nTmBefore";date;sleep 1;done
		
		nTmLog=$nTmBefore;
		while((nTmLog<=nTmBefore));do
			nTmLog="$(stat -c "%Y" "$strRLGameLog")";
			echo "iRestartCount=$iRestartCount, waiting it really start now, and create a new log file";
			sleep 1;
		done
		
		tail -F "$strRLGameLog" |while read strLine;do
			astrCriticalErrorMessages=( #chances are guessed. these mods use dll files
				"at MainMenuMono.Update" #this happens 85% chance with: WMMGameOptions
				"at vp_FPCamera.UpdateSwaying" #this still happens 33% chance with: SCore
			)
			bBreakReadLoop=false
			for strCrit in "${astrCriticalErrorMessages[@]}";do
				if [[ "$strLine" =~ "at MainMenuMono.Update" ]];then
					echo "iRestartCount=$iRestartCount, init error, Restarting";
					pkill -fe "$strRLRun"
					bBreakReadLoop=true
					break
				fi
			done
			if $bBreakReadLoop;then break;fi
			echo -n .
			
			if ! pgrep -fa "^${strRLRun}" >/dev/null;then
				echo "iRestartCount=$iRestartCount, stopped running, user exit? hit Enter to run again"
				read
				break
			fi
		done
		
		date;
		FUNCRLDropcaches
		echo "iRestartCount=$iRestartCount, waiting a bit before restarting to let it work by chance (10s) press Enter to run now"
		read -t 10

		((iRestartCount++))&&:
	done
};export -f FUNCRLRunLoop

: ${bRLrunNow:=true}
if $bRLrunNow;then
	FUNCRLRunLoop
fi
