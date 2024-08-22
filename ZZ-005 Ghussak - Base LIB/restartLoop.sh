#!/bin/bash

export strRLGameLog="$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/The Fun Pimps/7 Days To Die/Player.log"
export strRLRun="C:/Games/7 Days To Die/7DaysToDie.exe"

function FUNCRLDropcaches() {
	set -x;
	sudo dd if=/proc/3/stat of=/proc/sys/vm/drop_caches bs=1 count=1;
	set +x 
};export -f FUNCRLDropcaches

function FUNCRLRun() {
	WINEwrapperRunNowAlways=true wine64 "$strRLRun";
	echo "Exited, hit Enter (60s)";
	read #read -t 60
};export -f FUNCRLRun

function FUNCRLRunLoop() {
	FUNCRLDropcaches
	while true;do
		nTmBefore="$(date +"%s")"
		
		(xterm -e bash -c "FUNCRLRun" & disown)
		
		while ! pgrep -fa "^${strRLRun}";do echo "waiting the app start nTmBefore=$nTmBefore";date;sleep 1;done
		
		nTmLog=$nTmBefore;
		while((nTmLog<=nTmBefore));do
			nTmLog="$(stat -c "%Y" "$strRLGameLog")";
			echo "waiting it really start now, and create a new log file";
			sleep 1;
		done
		
		tail -F "$strRLGameLog" |while read strLine;do
			if [[ "$strLine" =~ "at MainMenuMono.Update" ]];then
				echo "init error, Restarting";
				pkill -fe "$strRLRun"
				break
			else
				echo -n .
			fi;
			
			if ! pgrep -fa "^${strRLRun}" >/dev/null;then
				echo "stopped running, user exit? hit Enter to run again"
				read
			fi
		done
		
		date;
		FUNCRLDropcaches
		echo "waiting a bit before restarting to let it work by chance (10s) press Enter to run now"
		read -t 10
	done
};export -f FUNCRLRunLoop

: ${bRLrunNow:=true}
if $bRLrunNow;then
	FUNCRLRunLoop
fi
