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
    while ! CFGFUNCexec --noErrorExit yad --on-top --center --text "$@. You need to click OK to continue.";do :;done
  else
    CFGFUNCprompt "$@"
  fi
};export -f FUNCpromptGfx
function FUNCrawMatchRegex() { echo "$1" |sed -r 's@.@[&]@g'; };export -f FUNCrawMatchRegex

export strChkAutoStopOnLoad="`FUNCrawMatchRegex " INF Created player with id="`"
export strChkShapesIni="`FUNCrawMatchRegex " INF Loaded (local): shapes"`"
#echo "PID=$$"
#tail -n +1 -F "$strFlLog" |while read strLine;do
tail -F "$strFlLog" |while read strLine;do
  #echo "while.PID=$$"
  bExecCmd=false
  
  #if ! pgrep -fa "${strExecRegex}";then
    #echo "-[WAIT:GameNotRunning:SKIP] ${strLine}"
  if [[ "$strLine" =~ .*${strChkAutoStopOnLoad}.* ]];then
    if ! pgrep -fa "${strExecRegex}";then
      echo "-[WAIT:GameNotRunning:SKIP] ${strLine}"
    else
      CFGFUNCinfo "+[EXEC:AutoStopOnLoadGame] $strLine"
      CFGFUNCexec pkill -SIGSTOP -fe "${strExecRegex}"
      strInfo="the game finished loading and is ready to play"
      #if which yad;then
        #while ! CFGFUNCexec --noErrorExit yad --on-top --center --text "${strInfo}. Close to SIGCONT the game.";do :;done
      #else
        #CFGFUNCprompt "$strInfo"
      #fi
      FUNCpromptGfx "${strInfo}. Close this popup to SIGCONT the game."
      CFGFUNCexec pkill -SIGCONT -fe "$strExecRegex"
      bExecCmd=true
    fi
  elif [[ "$strLine" =~ .*${strChkShapesIni}.* ]];then
    CFGFUNCinfo "+[EXEC:ChkIfGameFrozeLoadingShapes] $strLine"
    #@RM noneed: start child process, get it's pid, if "block ids" comes, kill child pid, otherwise hint SIGKILL game to user thru yad
    #function FUNCchkShapesIni() {
      : ${nIniShapesDelay:=25} #help shapes shall take only a few seconds to complete (here)
      lstrKeyShapesIni="`ls -l "$strFlLog"`"
      li=0
      #bBreakChkShapesLoop=false
      #trap 'bBreakChkShapesLoop=true' INT
      while true;do
        #echo "while2.PID=$$"
        ((li++))&&:
        if [[ "$lstrKeyShapesIni" != "`ls -l "$strFlLog"`" ]];then CFGFUNCinfo "Shapes success!";break;fi
        echo -en "${li}/${nIniShapesDelay}s waiting shapes complete init\r" # (hit 'y' to skip this check).\r"
        #if CFGFUNCprompt -q "ignore/skip this check?";then break;fi
        if((li>nIniShapesDelay));then CFGFUNCinfo "[WARN] ${li}/${nIniShapesDelay}s log file have not changed yet, froze on ini Shapes? if so you should SIGKILL the game.";fi
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
    echo "-[SKIP] $strLine"
  fi
  #if ! $bExecCmd;then  echo "[IGNOREDLINE] $strLine";fi
done

echo "below error chk not ready";exit 0 #todo rm
while true;do
  read -p "." -t 3&&:
  strRegex="^....-..-.*:..:.. [0-9]*[.][0-9]* EXC " #todo ignore some errors like "Object reference not set to an instance of an object"
  if egrep -q "$strRegex" "$strFlLog";then
    egrep "$strRegex" "$strFlLog" -A 20 #todo show range til each log sector end
    #todo yad tiny alert
  fi
  #todo ignore old lines
done

#2023-04-12T18:22:27 316.119 EXC Object reference not set to an instance of an object
#UnityEngine.StackTraceUtility:ExtractStringFromException(Object)
#...
#Log:Exception(Exception)

