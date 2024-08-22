#!/bin/bash

function FUNCdropcaches() {
	set -x;
	sudo dd if=/proc/3/stat of=/proc/sys/vm/drop_caches bs=1 count=1; #OBS.: this seems to suffice, no need for this whole script
	set +x 
}

strGameLog="$WINEPREFIX/drive_c/Program Files (x86)/7 Days To Die/_Logs_.AppData.LocalLow.The Fun Pimps/Player.log"
strRun="C:/Games/7 Days To Die/7DaysToDie.exe"

FUNCdropcaches
while true;do
	nTmBefore="$(date +"%s")"
	
	export WINEwrapperRunNowAlways=true
	(xterm -e wine64 "$strRun" & disown)
	
	while ! pgrep -fa "^${strRun}";do echo "waiting the app start nTmBefore=$nTmBefore";date;sleep 1;done
	
	nTmLog=$nTmBefore;
	while((nTmLog<=nTmBefore));do
		nTmLog="$(stat -c "%Y" "$strGameLog")";
		echo "waiting it really start now, and create a new log file";
		sleep 1;
	done
	
	tail -F "$strGameLog" |while read strLine;do
		if [[ "$strLine" =~ "at MainMenuMono.Update" ]];then
			echo "init error, Restarting";
			pkill -fe "$strRun"
			break
		else
			echo -n .
		fi;
	done
	
	date;
	FUNCdropcaches
	echo "waiting a bit before restarting to let it work by chance (10s) press Enter to run now"
	read -t 10
done
