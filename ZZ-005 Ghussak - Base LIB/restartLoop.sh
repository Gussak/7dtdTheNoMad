#!/bin/bash

export strRLGameLog="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"
export strRLRun="C:/Games/7 Days To Die/7DaysToDie.exe"

function FUNCRLDropcaches() {
	: ${bUseDropCaches:=false} #help
	set -x;
	if $bUseDropCaches;then sudo dd if=/proc/3/stat of=/proc/sys/vm/drop_caches bs=1 count=1;fi
	set +x 
};export -f FUNCRLDropcaches

function FUNCRLRun() {
	WINEwrapperRunNowAlways=true wine64 "$strRLRun";
	echo "Exited, hit Enter (600s)";
	read -t 600 #to have some time to read/copy the log
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
			if [[ "$strLine" =~ "at MainMenuMono.Update" ]];then
				echo "iRestartCount=$iRestartCount, init error, Restarting";
				pkill -fe "$strRLRun"
				break
			else
				echo -n .
			fi;
			
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
