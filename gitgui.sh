#!/bin/bash

cd "$(dirname "$0")"
pwd
strGitProj="$(basename "$(realpath .)")"
declare -p strGitProj
read -t 1 -n 1 -p "[$LINENO]wait a bit..." # waiting a bit may help it kickin mainly just after starting the OS while there is some cpu load
nWid="$(xdotool search "Git Gui.*${strGitProj}")"
declare -p nWid
if [[ -n "$nWid" ]];then
	read -t 1 -n 1 -p "[$LINENO]wait a bit..."
	if which xdotool;then
		read -t 1 -n 1 -p "[$LINENO]wait a bit..."
		xdotool windowraise $nWid
	fi
else
	(xterm -e bash -c "sleep 1;(nohup git gui & disown);sleep 1"&disown) #it is important to be this way to force gitgui open a gui to ask for password (instead of requesting the password to be input on the terminal)
fi
#set -x
#read -t 60 -n 1 -p PressAKeyToExit
