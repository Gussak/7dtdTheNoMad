#!/bin/bash

cd "`dirname "$0"`"
(xterm -e bash -c "sleep 1;(nohup git gui & disown);sleep 1"&disown) #it is important to be this way to force gitgui open a gui to ask for password (instead of requesting the password to be input on the terminal)
set -x
read -t 60 -n 1 -p PressAKeyToExit
