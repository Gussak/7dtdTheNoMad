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

source ./libSrcCfgGenericToImport.sh

#function FUNCsafeGrepChk() {
  #local lstrRegex="$1";shift
  #local lastrFlListEtc="$@"
  #egrep --color=always "$lstrRegex" -iRn "${lastrFlListEtc[@]}"
  #local lstrOutput="`egrep --color=always "$lstrRegex" -iRn "${lastrFlListEtc[@]}"`"&&:;local lnRet=$?;declare -p lnRet
  #declare -p lstrOutput >&2
  #echo "$lstrOutput" >&2
  #echo "$lstrOutput" |wc -l
  #pwd
  #if((`echo "$lstrOutput" |wc -l`>0));then
    #return 0
  #fi
  #return 1
#}
##egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" -iRn * --include="blocks.xml"
#if FUNCsafeGrepChk "Collide.*melee.*NoCollideMeleeCheckGrepHint" * --include="blocks.xml";then
  #CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are blocks with melee collision that should not have it set"
  #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it..."
#fi
#exit
#if CFGFUNCexec --noErrorExit egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" * --include="blocks.xml";then
#if egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" * --include="blocks.xml" -iRn |egrep melee;then
#if egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" _Rel* -iRn --include="blocks.xml" ;then
  #CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are blocks with melee collision that should not have it set"
  #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it..."
#fi
#exit

strMainPath="`pwd`"

CFGFUNCinfo "This is a generic cleanup script to prepare good quality files for developers and end users because I add too many unnecessary comments, and leave a huge lot of failed tests and deprecated code on original files."

#export strVersionFull="`egrep "GameVersion" "$WINEPREFIX/drive_c/users/$USER/Application Data/7DaysToDie/GeneratedWorlds/East Nikazohi Territory/map_info.xml" |cut -d. -f2-3`"
#export strMainVersion="`echo "$strVersionFull" |cut -d. -f1`"
export strVersionFull="$(strings _NewestSavegamePath.IgnoreOnBackup/main.ttw |head -n 1 |cut -d' ' -f2-3 |tr -d '() ')"
export strMainVersion="$(strings _NewestSavegamePath.IgnoreOnBackup/main.ttw |head -n 1 |cut -d' ' -f2)"
export strVersionRegex="`echo "$strMainVersion" |sed -r 's@[.]@[.]@g'`"
declare -p strVersionFull strMainVersion strVersionRegex

############################ VALIDATIONS 

IFS=$'\n' read -d '' -r -a astrCalledScriptsList < <(egrep "[ (\`;][a-zA-Z0-9_]*[.]sh" -iRIho --include="*.sh" |awk '{print $1}' |sort -u |egrep -v '^[.]sh$')&&:
declare -p astrCalledScriptsList |tr '[' '\n'
#IFS=$'\n' read -d '' -r -a astrScriptsList < <(find -iname "*.sh")&&:
#strScriptsCalled="`egrep "[a-zA-Z0-_]*[.]sh" -iRIh --include="*.sh"`"
iScriptNotFoundCount=0
for strCalledScript in "${astrCalledScriptsList[@]}";do
  declare -p strCalledScript
  if [[ ! -f "$strCalledScript" ]];then
    echo "!!!!!!!!!!!!!!!!!!! ERROR: this called script '$strCalledScript' was not found !!!!!!!!!!!!!!!!!"
    strCalledScriptRegex="`echo "$strCalledScript" |sed -r 's@(.)@[\1]@g'`"
    declare -p strCalledScriptRegex
    egrep "$strCalledScriptRegex" * -iRnI --include="*.sh"&&:
    echo "#sed -i.bkp -r 's@${strCalledScript}@EDITHERE@' *.sh"
    ((iScriptNotFoundCount++))&&:
  fi
done
if((iScriptNotFoundCount>0));then echo "ERROR: see valid scripts below";ls *.sh;echo "ERROR:see above";exit 1;fi

# sanity checks and quality control
if CFGFUNCprompt -q "Inc buff IDs?";then ./incBuffsIDs.sh;fi #help important to grant no old buff will remain running while there is an updated one after the user updates the mod
if CFGFUNCprompt -q "Check case sensitive xml?";then
  if ! xterm -maximize -e ./fixCaseSensitiveXml.sh;then exit 1;fi #keep here because better be sure all is ok... must be before source libSrcCfgGenericToImport.sh
fi
if CFGFUNCprompt -q "Check and update possible dependencies info?";then
  ./findUsedCmdsInScriptsLookForLinuxAppDependencies.sh
fi
if ! ./checkLootIDs.sh;then exit 1;fi

#egrep "[#]help" $0

#set -Eeu
#trap 'echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ERROR <<<<<<<<<<<<<<<<<<<<<<<<<<<<"' ERR
#trap 'read -p "!!!ERROR!!!" -n 1' ERR

################################### MAIN

function FUNCexecEcho() {
  "$@"&&:;local lnRet=$?
  if((lnRet!=0));then
    echo "ERROR-EXEC: $@; lnRet=$lnRet (hit ctrl+c)" 
    #trap 'echo "ctrl+c, continuing..."' INT
    sleep 6000 #cant use `read` as it is non iteractive (will ignore keypresses)
    #trap -- INT
  fi
  return 0
};export -f FUNCexecEcho

if egrep 'ModifyCVar.*bGSKDebug.*set.*1' * --include="*.xml" -irnI;then
  CFGFUNCerrorExit "debug must be disabled!"
fi

export strPathTmp="_ReleasePackageFiles_.IgnoreOnBackup"
export strDestPath="${strPathTmp}/Mods"
trash "${strPathTmp}"&&:
mkdir -vp "${strDestPath}"

function FUNCFilesFromModsList() {
	IFS=$'\n' read -d '' -r -a astrFlFModsList < <(find ./ -maxdepth 1 -type d |egrep -v "./(ZZ-.*Ghussak - .*|.*DISABLED)|^[.]$" |sort -u)&&:
	return 0
}
function FUNCmodList() {
	IFS=$'\n' read -d '' -r -a astrModList < <(find ./ -maxdepth 1 -type d -iname "ZZ-*Ghussak - *" |sort -u |egrep -v "SkipOnRelease")&&:
	return 0
}

# prepare dependencies info
strFlDeps="`pwd`/Dependencies.AddedToRelease.txt"
strFlDepsNew="${strFlDeps}.NEW"
#strFlDepsOld="${strFlDeps}.`date +"${strCFGDtFmt}"`.OLD"
#if [[ -f "$strFlDeps" ]];then
  #CFGFUNCexec mv -v "$strFlDeps" "$strFlDepsOld"
#fi
#CFGFUNCtrash "$strFlDeps"
echo "DEPENDENCIES(suggested):" |tee "$strFlDepsNew"
(
  cd .. #this grants `find` will work on the current symlinked path tree at the terminal (or something like that...)
  echo "SELFNOTE: auto generated file, do not edit!" |tee -a "$strFlDepsNew"
  echo "Below is the sha1sum of the dependencies I used." |tee -a "$strFlDepsNew"
  echo "Before each file is the pathname I used that also grants it's load order, so better you use the same if possible." |tee -a "$strFlDepsNew"
  echo "Missing packages will still show their folder names what helps on searching for them for now sorry." |tee -a "$strFlDepsNew"
  echo "Dependencies are not exactly 'necessary'. If you do not install them, the game may still work..." |tee -a "$strFlDepsNew"
  echo "___________________________" |tee -a "$strFlDepsNew"
  IFS=$'\n' read -d '' -r -a astrFlList < <(find -maxdepth 1 -type d |egrep -v "./(ZZ-.*Ghussak - .*|.*DISABLED)|^[.]$" |sort -u)&&:
  iMissingPkgs=0
  for strFl in "${astrFlList[@]}";do
    strFound="`find "${strFl}/" -maxdepth 1 \( -iname "*.zip" -or -iname "*.rar" -or -iname "*.7z" \) -exec sha1sum '{}' \;`"&&:
    if [[ -n "$strFound" ]];then
      echo " $strFound" |tee -a "$strFlDepsNew"
    else
      echo " [WARN] PackageFileNotFoundFor: $strFl" |tee -a "$strFlDepsNew"
      ((iMissingPkgs++))&&:
    fi
  done
  ls -l "$strFlDepsNew"
  realpath "$strFlDepsNew"
  
  if ! cmp "$strFlDepsNew" "$strFlDeps";then
    colordiff "$strFlDeps" "$strFlDepsNew"&&:
    if CFGFUNCprompt -q "'$strFlDeps' got updated, is the above correct?";then
      CFGFUNCtrash "$strFlDeps"
      CFGFUNCexec mv -v "$strFlDepsNew" "$strFlDeps"
      chmod -v u-w "$strFlDeps"
    else
      if ! CFGFUNCprompt -q "ignore changes and continue anyway? at '$strFlDeps'?";then
        CFGFUNCinfo "reverting changes and exiting"
        CFGFUNCtrash "$strFlDepsNew"
        #CFGFUNCexec mv -v "$strFlDepsOld" "$strFlDeps"
        CFGFUNCerrorExit
      fi
    fi
  else
    CFGFUNCtrash "$strFlDepsNew"
  fi
  
  if((iMissingPkgs>0));then
    CFGFUNCinfo "WARNING: iMissingPkgs=$iMissingPkgs"
    read -n 1 -t 3 -p "continuing in 3s..."&&:
    #if ! CFGFUNCprompt -q "continue anyway?";then
      #exit 1  # is subshell
    #fi
  fi
  
  exit 0 # is subshell
)

function FUNCcleanup() { #helpf cleanup xml files from comments until I can manually review all that mess...
  astrFlDisableList=(
    #"loadingscreen.xml" #he lp Added 1 ok pic, so can be enabled! #old info: DISABLED: because user must prepare the custom screenshots before enabling the file
    #"spawnpoints.xml" #h elp
  )
  
  set -Eeu
  trap 'echo "ERROR:FUNCcleanup:!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"' ERR
  
  local lstrFlOrig="$1"
  
  local lstrFl="${lstrFlOrig#../}"
  local lstrDir="`dirname "$lstrFl"`"
  local lstrFlBN="`basename "$lstrFlOrig"`"
  
  #echo "FILE: $lstrFl "
  
  mkdir -vp "${strDestPath}/$lstrDir"
  FUNCexecEcho cp -f "$lstrFlOrig" "${strDestPath}/$lstrDir/"
  if [[ "$lstrFlBN" =~ .*[.]xml ]];then
    #if [[ "$lstrFlBN" == "createEnergyBlinks.xml" ]];then :; # ignore files like this.
    #else
      #if [[ "`head -n 1 "$lstrFlOrig"`" == '<!-- REVIEWED:OK -->' ]];then
      if egrep "<!-- PREPARE_RELEASE:REVIEWED:OK -->" "$lstrFlOrig" -q;then #help place this xml on the top of the file to KEEP its comments
        echo "( KEEP COMMENTS ): $lstrDir/$lstrFlBN"
      else
        echo "CleaningMessyComments: $lstrDir/$lstrFlBN"
        #xmlstarlet ed -L -d '//comment()' "${strDestPath}/$lstrDir/$lstrFlBN"
        #perl -i -w -0777pe 's/<!--(.(?<!(HELP)))*?-->//sg' "${strDestPath}/$lstrDir/$lstrFlBN" #keep only commens with the HELP word on them
        #PROBLEM: THIS -P DOES NOT KEEP THE FORMATTING INSIDE STRINGS LIKE ALL NEWLINES ARE REMOVED!!!: FUNCexecEcho xmlstarlet ed -P -L -d '//comment()[not(contains(.,"HELPGOOD"))]' "${strDestPath}/$lstrDir/$lstrFlBN" #keep only commens with the HELPGOOD word on them
        FUNCexecEcho xmlstarlet ed -L -d '//comment()[not(contains(.,"HELPGOOD"))]' "${strDestPath}/$lstrDir/$lstrFlBN" #keep only commens with the HELPGOOD word on them
        FUNCexecEcho xmlstarlet ed -L -d '//comment()[contains(.,"- - HELPGOOD")]' "${strDestPath}/$lstrDir/$lstrFlBN" #remove commented trash code with commented good help
      fi
    #fi
  else
    echo "Copied: $lstrDir/$lstrFlBN"
  fi
  
  # clean/simplify version
  if [[ "$lstrFlBN" == "loadingscreen.xml" ]];then
    FUNCexecEcho xmlstarlet ed -L -d "//tex[contains(@file,'LoadingScreens')]" "${strDestPath}/$lstrDir/$lstrFlBN" #remove screenshot filenames with version name
    #xmlstarlet ed -L -d "//tex[contains(@file,'LoadingScreens') and not(contains(@file,'ScreenShotTest'))]" "${strDestPath}/$lstrDir/$lstrFlBN" #remove screenshot filenames with version name
    #<tex file="@modfolder:LoadingScreens/A20.jpg" />
    #xmlstarlet sel -t -v  "$strFl"
    #sed -i -r "s@${strVersionRegex}@${strMainVersion}@g" "${strDestPath}/$lstrDir/$lstrFlBN"
    #ScreenShotTest001
  fi
  
  # disable some files that need user special attention
  for strFlDisable in "${astrFlDisableList[@]}";do
    #declare -p strFlDisable lstrFlBN
    if [[ "$lstrFlBN" == "$strFlDisable" ]];then
      FUNCexecEcho mv -v "${strDestPath}/$lstrDir/$lstrFlBN" "${strDestPath}/$lstrDir/${lstrFlBN}.DISABLED"
    fi
  done
  
  : ${bDefaultNormalSpawnPoints:=false} #help
  if $bDefaultNormalSpawnPoints;then
    if [[ "$lstrFlBN" == "spawnpoints.xml" ]];then
      local lstrSPD="${strDestPath}/$lstrDir/spawnpoints.Z_DEFAULT_NORMAL_SPAWNS_ONLY.xml"
      #declare -p lstrFlBN lstrSPD;ls -l "${strDestPath}/$lstrDir/$lstrFlBN" "$lstrSPD"
      if ! cmp "${strDestPath}/$lstrDir/$lstrFlBN" "$lstrSPD";then
        FUNCexecEcho trash "${strDestPath}/$lstrDir/$lstrFlBN"
        FUNCexecEcho cp -v "$lstrSPD" "${strDestPath}/$lstrDir/$lstrFlBN"
      fi
    fi
    #if [[ "$lstrFlBN" == "spawnpoints.Z_DEFAULT_NORMAL_SPAWNS_ONLY.xml" ]];then
      #FUNCexecEcho cp -v "${strDestPath}/$lstrDir/$lstrFlBN" "${strDestPath}/$lstrDir/spawnpoints.xml"
    #fi
  fi
};export -f FUNCcleanup

#(
	#cd ..
pwd
	#FUNCmodList;for strModFolder in "${astrModList[@]}";do
find ../ -maxdepth 1 -type d -iname "ZZ-*Ghussak - *" |sort -u |egrep -v "SkipOnRelease" |while read strModFolder;do
  echo "MOD: $strModFolder"
  find "${strModFolder}/" -type f         \
  \(                                      \
    -iname "*.AddedToRelease*"            \
    -or                                   \
    -iname "*.blocks.nim"                 \
    -or                                   \
    -iname "*.cfg"                        \
    -or                                   \
    -iname "*.ins"                        \
    -or                                   \
    -iname "*.jpg"                        \
    -or                                   \
    -iname "Localization.txt"             \
    -or                                   \
    -iname "*.ManualInstallRequired*"     \
    -or                                   \
    -iname "*.mesh"                       \
    -or                                   \
    -iname "*.png"                        \
    -or                                   \
    -iname "*.sh"                         \
    -or                                   \
    -iname "*.tts"                        \
    -or                                   \
    -iname "*.xml"                        \
  \) -and -not \(                         \
    -iregex ".*/${strPathTmp}/.*"         \
    -or                                   \
    -iname "DEPRECATED.*"                 \
    -or                                   \
    -iname "$(basename "$0")"             \
    -or                                   \
    -iname "(copy *)"                     \
    -or                                   \
    -iregex ".*/_.*"                      \
    -or                                   \
    -iregex ".*\.RestoredWhiteSpaces.*"   \
    -or                                   \
    -iregex ".*\.new.*"                   \
    -or                                   \
    -iregex ".*\.old.*"                   \
    -or                                   \
    -iregex ".*\.bkp.*"                   \
    -or                                   \
    -iregex ".*\.SkipOnRelease.*"         \
  \) -exec bash -c "FUNCcleanup \"{}\"" \;
done
    #-iname "ScreenShotTest*.jpg"          \
    #-or                                   
#
#)

#TODO the steam ID removal from prefabs should be generic and not based on current user... Actually, the engine itself should not store it right? Unless the user asks to be like that, as if he ever connect to a server using it then would have the right to edit the sign?
while true;do
  while ! nSteamId="`ls "./_NewestSavegamePath.IgnoreOnBackup/Player/Steam_"*".ttp" |sed -r 's@.*/Steam_(.*).ttp@\1@'`";do
    CFGFUNCprompt "run ./updateNewestSavegameSymlink.sh to access your steam ID"
  done
  if [[ -z "$nSteamId" ]];then
    if ! CFGFUNCprompt -q "invalid nSteamId='$nSteamId', continue anyway? (if not, will retry)";then
      continue
      #CFGFUNCerrorExit "invalid empty nSteamId"
    fi
  fi
  break
done

CFGFUNCinfo "Validating:"
bCheckLoop=true
while $bCheckLoop;do
  bNeedsFixing=false
  #pwd
  #function FUNCsafeGrepChk() {
    #local lstrRegex="$1";shift
    #local lastrFlListEtc="$@"
    #local lstrOutput="`egrep --color=always "$lstrRegex" -iRn "${lastrFlListEtc[@]}"`"&&:;local lnRet=$?;declare -p lnRet
    #declare -p lstrOutput >&2
    #echo "$lstrOutput" >&2
    #echo "$lstrOutput" |wc -l
    #pwd
    #if((`echo "$lstrOutput" |wc -l`>0));then
      #return 0
    #fi
    #return 1
  #}
  #egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" -iRn * --include="blocks.xml"
  #if FUNCsafeGrepChk "Collide.*melee.*NoCollideMeleeCheckGrepHint" * --include="blocks.xml";then
  #if CFGFUNCexec --noErrorExit egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" * --include="blocks.xml";then
    #CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are blocks with melee collision that should not have it set"
    #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  #fi
  # USING double egrep because if using * instead of "${strDestPath}/" it may return "File name too long" error and being an error will work like NOTFOUND what would mean OK here, and tha is not good...
  while egrep --color=always "$nSteamId" "${strDestPath}/" -iRnao |egrep "$nSteamId" -i;do
    CFGFUNCinfo "WARN:FilesAbove:Your steam ID should not be on project files. You won't connect on all servers that could run it. You should not be able to edit prefabs' signs. Clean it with ex.: sed -i.bkp -r 's@${nSteamId}@$(printf %0${#nSteamId}d 0)@g' Prefabs/Parts/part_TNM_Explosion1.tts"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  while egrep --color=always "replaced by:" "${strDestPath}/" -iRn --include="*.xml" |egrep melee -i;do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are 'replaced by' comments..."
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  while egrep --color=always "Collide.*melee.*NoCollideMeleeCheckGrepHint" "${strDestPath}/" -iRn --include="blocks.xml" |egrep melee -i;do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are blocks with melee collision that should not have it set, fix with ex.: sed -i.bkp -r 's@(,melee)(.*NoCollideMeleeCheckGrepHint)@\2@' Config/blocks.xml"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  while egrep --color=always  "$USER" "${strDestPath}/" -iRn |egrep "$USER" -i;do #check on binary files too!!!
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: found private data username USER='$USER' in some files"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  while egrep --color=always  "$strVersionRegex" "${strDestPath}/" -iRnI |egrep "$strVersionRegex" -i;do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: game version is present" #unnecessary?
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  #while CFGFUNCexec --noErrorExit egrep --color=always  "$USER" "${strDestPath}/" -iRnI;do
    #CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: user name is present"
    #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  #done
  while egrep --color=always  "^#PREPARE_RELEASE:REVIEWED:OK$" "${strDestPath}/" -iRnI -c --include="*.sh" |egrep ":0$";do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are .sh file(s) w/o the reviewed token"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  #bSetShRWOn=false
  #while CFGFUNCexec --noErrorExit find "${strDestPath}/" -iname "*.sh" -perm "-u=w" |egrep ".*";do
    #CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are .sh file(s) writable, make it sure to mark them read only AFTER activating the review token on them, and deactivate it if you want to edit them again."
    #echo "chmod u-w *.sh #chmod u+w *.sh # helper code"
    #if CFGFUNCprompt -q "change all .sh to readonly now?";then
      #CFGFUNCexec chmod -v u-w *.sh
      #bSetShRWOn=true
    #else
      #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
    #fi
  #done
  while find "${strDestPath}/" -iname ".*" |egrep ".*";do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are hidden files"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  #while CFGFUNCexec --noErrorExit find "${strDestPath}/" -iregex ".*\(copy\|bkp\|backup\).*" |egrep ".*";do
  while find "${strDestPath}/" -iregex ".*copy.*" |egrep ".*";do
    CFGFUNCinfo "WARN:FilesAbove:Still needs fixing: there are backup files, suffix them with something that will be ignored like .SKIP"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  while egrep --color=always  'randomInt\([^)]*[.]' * -iRnI --include="*.xml" |egrep randomInt -i;do
    CFGFUNCinfo "WARN:FilesAbove:wrongly coded randomInt using floats as param, should be randomFloat!"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  #while CFGFUNCexec --noErrorExit egrep --color=always  '(cvar="|requirement).*value="[.$a-zA-Z_]"' * -iRnI --include="*.xml";do
    #CFGFUNCinfo "WARN:FilesAbove:wrongly coded cvar value assignment, missing @@"
    #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it..."
  #done
  while egrep --color=always  '[-]exec' * -iRnIw --include="*.sh" --exclude="`basename "$0"`" |egrep exec -i;do
    CFGFUNCinfo "WARN:FilesAbove:do not use 'find -exec' because called scripts and functions from it will be non interactive!"
    bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  done
  #while CFGFUNCexec --noErrorExit egrep --color=always  '[!]hasbuff' * -iRnIw --include="*.xml";do
    #CFGFUNCinfo "WARN:FilesAbove:wrongly coded NotHasBuff. coding like '!HasBuff' may fail sometimes (like at items.xml GSKElctrnTeleport)"
    #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  #done
  #while CFGFUNCexec --noErrorExit egrep --color=always  'addbuff' * -iRnIw --include="*.xml" |egrep -wv "AddBuff";do
    #CFGFUNCinfo "WARN:FilesAbove:wrongly coded AddBuff. coding w/o respecting case may fail sometimes (like at buffs.xml buffGSKElctrnTeleport)"
    #bNeedsFixing=true;CFGFUNCprompt "waiting you fix it...";break
  #done
  if ! $bNeedsFixing;then
    bCheckLoop=false
  fi
done
#xterm -e ./fixCaseSensitiveXml.sh

#TODO clean also the xml help="..." content? did I messup there too?

: ${bIgnoreErrors:=false} #help use this to generate files for github
if $bIgnoreErrors;then bNeedsFixing=false;fi

####################################################################################################
cd "${strPathTmp}"
if $bNeedsFixing;then
  CFGFUNCprompt "PROBLEMS FOUND, FIX THEM! (hit a key to clean tmp files to not bloat the other bkp script)"
  exit 1
fi

strFlNm="The NoMad unforgiving lands Overhaul and Developer Tools"
CFGFUNCtrash "${strFlNm}.7z"&&:
#tar -vcf GhussakTweaksPackage.tar "${strDestPath}/"*
CFGFUNCexec 7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -mmt15 "${strFlNm}.7z" "Mods"
CFGFUNCexec realpath "${strFlNm}.7z"
CFGFUNCexec ls -l "${strFlNm}.7z"

#trash GhussakTweaksPackage.tar
#CFGFUNCtrash "Mods"

### UPDATE REPO #################################################################################################
cd "Mods"
pwd

strRepoPath="../../_GitHub_.Home.Projects.7DTD.IgnoreOnBackup.github/"
strReqRepo="A20.7b1"

while ! grep "${strReqRepo}" "${strRepoPath}/.git/HEAD";do
	CFGFUNCprompt "Invalid branch, change it to: ${strReqRepo}"
done

CFGFUNCinfo "Cleaning mods from github folder"
#if CFGFUNCprompt -q "Clean mods from github folder? (to update just after by copying)";then
	FUNCmodList;for strMod in "${astrModList[@]}";do
		echo "============================"
		ls -ld "$strMod" "../../_GitHub_.Home.Projects.7DTD.IgnoreOnBackup.github/${strMod}" &&:
		trash -v "../../_GitHub_.Home.Projects.7DTD.IgnoreOnBackup.github/${strMod}"&&: #may be a new mod
	done
#fi

CFGFUNCinfo "Copying mods to github folder"
#if CFGFUNCprompt -q "Copy mods to github folder?";then
	FUNCmodList;for strMod in "${astrModList[@]}";do
		echo "============================"
		ls -ld "$strMod" &&:
		strDestPathMod="../../_GitHub_.Home.Projects.7DTD.IgnoreOnBackup.github/${strMod}/"
		mkdir -v "$strDestPathMod"
		CFGFUNCexec cp -vRf "${strMod}/"* "$strDestPathMod" #-vRuf
	done
#fi

####################################################################################################
CFGFUNCprompt "Fully Ready!"

#if $bSetShRWOn;then
  #cd "${strMainPath}"
  #CFGFUNCexec chmod -v u+w *.sh
#fi

