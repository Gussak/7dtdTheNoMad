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

#help Run this script to automatically install some files outside this mod folder. There are a lot of prompts explaining each step so you can abort this at any time.

#if ! egrep "[#]help .*[.]/[a-zA-Z0-9_]*[.]sh" $0 |egrep -v "${strScriptName}";then CFGFUNCDevMeErrorExit "help info is outdated.";fi

#he lp Use this option to uninstall. It will uninstall only the files that were installed, and replace them with the backup made by this installer. Use it like: ./installSpecificFilesIntoGameFolder.sh --uninstall
#bUninstall=false;
#if [[ "${1-}" == --uninstall ]];then #h elp 
  #shift;bUninstall=true;
#fi 

function FUNCinstall() {
  local lstrFl="$1";shift
  local lstrDestFolder="$1";shift
  
  local lstrFlBN="`basename "$lstrFl"`"
  local lstrFlDest="${lstrDestFolder}/${lstrFlBN}"
  #local lstrFlOrigBkp="${lstrFlDest}${strCFGOriginalBkpSuffix}"
  
  echo >&2
  CFGFUNCinfo " ===================== WORKING WITH: $lstrFl =================="
  
  if ! egrep --silent "$strCFGInstallToken" "$lstrFl";then CFGFUNCDevMeErrorExit "token $strCFGInstallToken missing at $lstrFl";fi
  
  if cmp "$lstrFl" "$lstrFlDest" 2>/dev/null;then
    CFGFUNCinfo "Skipping identical file '$lstrFl' that is already installed!"
    return 0
  fi
  
  CFGFUNCcreateBackup "${lstrFlDest}"
  #if [[ -f "${lstrFlDest}" ]];then
    #if egrep --silent "$strCFGInstallToken" "$lstrFlDest";then
      #CFGFUNCinfo "The destination file ${lstrFlDest} was already replaced by this mod's installer before."
      #if [[ ! -f "$lstrFlOrigBkp" ]];then
        #CFGFUNCprompt -q "But there is no original file backup there!"
      #fi
    #else
      #CFGFUNCinfo "Backuping file: ${lstrFlDest}"
      #CFGFUNCexec cp -v "${lstrFlDest}" "${lstrFlOrigBkp}"
    #fi
  #else
    #if ! $bIgnMissing;then
      #CFGFUNCprompt "WARNING: The destination file that would be backuped and replaced is missing '${lstrFlDest}'. Such file is important if you decide to uninstall this mod. ${strHitAKey}"
    #fi
  #fi
  CFGFUNCinfo "Installing (replacing) '$lstrFl' at '$lstrDestFolder'"
  CFGFUNCexec cp -vf "$lstrFl" "$lstrFlDest"
};export -f FUNCinstall
#function FUNCdoIt() {
  #if $bUninstall;then
    #FUNCuninstall "$@"
  #else
    #FUNCinstall "$@"
  #fi
#};export -f FUNCdoIt

CFGFUNCprompt "It is always safer to create a backup before changing things. If you havent done that yet... do it now please!"

if CFGFUNCprompt -q "This is an automatic installer for all files and folders that have 'ManualInstallRequired' in their names. Read more details about this installer?";then
  echo "
 ManualInstallRequired?
  Instead of running this script you can install the ManualInstallRequired files manually too, just follow the instructions in the ...ManualInstallRequired.txt files:"
  find -iname "*ManualInstallRequired*.txt"
  echo
  echo "
 Backups:
  This installer creates original files' backups.
  Then it copies this mod(ified) files over the original files (see Patchers below too).
  That backup is necessary if you are going to run the uninstall script, so DO NOT DELETE THEM!
  To uninstall using the these backups just run: ./uninstallByRestoringOriginalFilesBackups.sh
  
 Patchers:
  The patchers modify files instead of copying mod files over them.
  There are text and binary patchers.
  The patcher scripts at the end can be skipped and applied later by running each of them individually.
  You can also run this install script again as all previous steps that are already completed will be skipped.
  The files the patchers modify can be patched manually too if you prefer and know what you are doing.
  
 Developers:
  If you are a developer read too: ./libSrcCfgGenericToImport.sh --help
"
  if CFGFUNCprompt -q "Read this installer help now? (you can read it later passing --help param to it)";then
    $0 --help&&:
  fi
  
  CFGFUNCprompt "Waiting you finish reading above."
fi

CFGFUNCprompt "Close the game now if it is running!"
while pgrep -fa "C:.*7DaysToDie[.]exe";do
  CFGFUNCprompt "Close the game now!"
  if CFGFUNCprompt -q "Tho.. if you know what you are doing, you can continue this script anyway. Continue now?";then
    break
  fi
done

#if $bUninstall;then
  #./uninstallByRestoringOriginalFilesBackups.sh
  #exit
#fi

################## INSTALL

function FUNCmanualInstallInstructions() {
  local lstrInfoFl="$1"
  if CFGFUNCprompt -q "The above installed file requires manual preparations ($lstrInfoFl), read them now?";then
    cat "$lstrInfoFl" |egrep -v "^#"
    CFGFUNCprompt "Waiting you finish preparing the requirements above."
  fi
}

FUNCinstall "Data.ManualInstallRequired/Config/rwgmixer.xml" \
  "${strCFGGameFolder}/Data/Config/" 
FUNCmanualInstallInstructions "./Data.ManualInstallRequired/Config/readme.ManualInstallRequired.txt"
  
FUNCinstall "GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/prefabs.xml" \
  "$strCFGGeneratedWorldTNMFolder"
FUNCinstall "GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/spawnpoints.xml" \
  "$strCFGGeneratedWorldTNMFolder"
#FUNCmanualInstallInstructions "./GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/readme.ManualInstallRequired.txt"

echo >&2
CFGFUNCinfo "=========================== RUNNING PATCHERS ============================="
if ! CFGFUNCprompt -q "The next steps will run scripts to patch files. Do you want to continue?";then
  bCFGDryRun=true
  bCFGInteractive=false
fi

if CFGFUNCprompt -q "Would you like to be able to destroy trader area's blocks?";then
  CFGFUNCexec ./disableTraderAreaProtect.sh
fi

if CFGFUNCprompt -q "Would you like to prepare loading screens from screenshots?";then
  CFGFUNCexec ./createLoadingScreensFromScreenshots.sh
  CFGFUNCprompt "You can run './createLoadingScreensFromScreenshots.sh' alone again later to update the loading screens."
fi

if CFGFUNCprompt -q "Would you like to be able to crouch and move inside one block empty spaces?";then
  CFGFUNCinfo "Can be re-run like this: bHCTCrouchHeight=true ./HardcodedTips.sh"
  export bHCTCrouchHeight=true; CFGFUNCexec ./HardcodedTips.sh
fi

#CFGFUNCprompt "while playing the game, if you need to transfer items from your inventory into a NPC follower, you may like this: ./macroMoveItemsToNPCInventory.sh (it will transfer a whole row of items, but will certainly requiring adjustments for time and positioning)"




















