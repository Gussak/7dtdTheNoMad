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

set -Eeu

#egrep "[#]help" $0

source ./libSrcCfgGenericToImport.sh

function FUNCDevMeErrorExit() {
  echo "   !!!!!! [ERROR:DEVELOPER:SELFNOTE] $1 !!!!!!"
  exit 1
};export -f FUNCDevMeErrorExit
if ! egrep "#help .*[.]/[a-zA-Z0-_]*[.]sh" $0 |egrep -v "${strScriptName}";then FUNCDevMeErrorExit "help info is outdated.";fi

#help Use this option to uninstall. It will uninstall only the files that were installed, and replace them with the backup made by this installer. Use it like: ./installSpecificFilesIntoGameFolder.sh --uninstall
bUninstall=false;
if [[ "${1-}" == --uninstall ]];then 
  shift;bUninstall=true;
fi 

: ${bInteractive:=true} #help run like this to not have to press any keys: bInteractive=false ./installSpecificFilesIntoGameFolder.sh
: ${bIgnMissing:=false} #help AlwaysIgnoreMissingFilesThatWouldBeReplaced, otherwise you will be prompted for each missing file
: ${bDryRun:=false} #help just show what would be done
: ${bVerbose:=false} #help enable this to show detailed messages. Anyway everything will be in the install log.

strLog="${0}.`date +'%Y_%m_%d-%H_%M_%S_%N'`.log"

fWait=3600;if $bInteractive;then fWait=0.01;fi

strHitAKey="[Hit Ctrl+C to abort or any other key to continue]"

strBkpSuffix=".OriginalOrExistingFile.BakupMadeBy_${strModNameForIDs}.bkp"
strInstallToken="ThisFileWasReplacedBy_${strModNameForIDs}" #TODO may be it is possible to create a xmlstarlet merger that provide consistent/reliable results for each xml file that cant be patched as modlet?

function FUNCexec() {
  echo "EXEC: $@" |tee -a "$strLog"
  if ! $bDryRun;then
    if ! "$@";then
      FUNCerrorExit "Failed to execute the command above."
    fi
  fi
};export -f FUNCexec
function FUNCerrorExit() {
  echo "[ERROR] $1" |tee -a "$strLog"
  exit 1
};export -f FUNCerrorExit
function FUNCprompt() {
  local lbQ=false;if [[ "$1" == -q ]];then shift;lbQ=true;fi
  local lstrMsg="$1";shift
  echo "${lstrMsg} ${strHitAKey}" |tee -a "$strLog"
  read -t $fWait -n 1 strResp&&:
  if $lbQ;then
    if [[ "$strResp" =~ [yY] ]];then
      return 0
    else
      return 1
    fi
  fi
  return 0
};export -f FUNCprompt
function FUNCinfo() {
  local lstrShortMsg="$1";shift
  local lstrVerboseMsg="$1";shift
  if ! $bVerbose;then
    echo "[INFO] $lstrShortMsg"
  else
    echo "[INFO] $lstrVerboseMsg"
  fi
  echo "[INFO] $lstrVerboseMsg" >>"$strLog"
};export -f FUNCinfo
function FUNCinstall() {
  local lstrFl="$1";shift
  local lstrDestRelativeFolder="$1";shift
  
  local lstrFlBN="`basename "$lstrFl"`"
  local lstrFlDest="${strCFGGameFolder/}${lstrDestRelativeFolder}/${lstrFlBN}"
  
  if egrep "$strInstallToken" "$lstrFl";then FUNCDevMeErrorExit "token $strInstallToken missing at $lstrFl";fi
  
  if cmp "$lstrFl" "$lstrFlDest";then
    FUNCinfo "Skipping identical file '$lstrFl' that is already installed!"
    return 0
  fi
  
  if [[ -f "${lstrFlDest}" ]];then
    if egrep "$strInstallToken" "$lstrFlDest";then
      FUNCinfo "The destination file ${lstrFlDest} was already replaced by this mod's installer. Just trashing it now before udating."
    else
      FUNCinfo "Backuping file: ${lstrFlDest}"
      FUNCexec cp -v "${lstrFlDest}" "${lstrFlDest}${strBkpSuffix}"
    fi
  else
    if ! $bIgnMissing;then
      FUNCprompt "WARNING: The destination file that would be backuped and replaced is missing '${lstrFlDest}'. Such file is important if you decide to uninstall this mod. ${strHitAKey}"
    fi
  fi
  FUNCinfo "Installing (replacing) '$lstrFl' at '$lstrDestRelativeFolder'"
  FUNCexec cp -vf "$lstrFl" "$lstrFlDest"
};export -f FUNCinstall
function FUNCuninstall() {
  echo "ERROR:TODO";exit 1
};export -f FUNCuninstall
function FUNCdoIt() {
  if $bUninstall;then
    FUNCuninstall "$@"
  else
    FUNCinstall "$@"
  fi
};export -f FUNCdoIt

FUNCprompt "Close the game now if it is running!"
while pgrep -fa "C:.*7DaysToDie[.]exe";do
  FUNCprompt "Close the game now!"
  if FUNCprompt -q "if you know what you are doing, yo ucan continue this script anyway. Do it?";then
    break
  fi
done

FUNCdoIt "Data.ManualInstallRequired/Config/rwgmixer.xml" "7 Days To Die/Data/Config/" 
FUNCdoIt "GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/prefabs.xml" "$strCFGGeneratedWorldTNMFolder"
FUNCdoIt "GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/spawnpoints.xml" "$strCFGGeneratedWorldTNMFolder"

if FUNCprompt -q "The next steps will run script to patch files, do you want to continue?";then
  :
fi


















