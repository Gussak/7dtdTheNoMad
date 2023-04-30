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

#this is a config file and a import library

#PREPARE_RELEASE:REVIEWED:OK


function CFGFUNCcalc() { #help [-s <scale(default=2)>] <lstrCalcExpression>
  local liScale=2
  if [[ "${1}" == -s ]];then shift;liScale=$1;shift;fi
  local lstrCalcExpression="$1"
  printf "%.${liScale}f" "`bc <<< "scale=10;${lstrCalcExpression}"`"
}
function CFGFUNCcleanMsgPRIVATE() {
  if $bCFGDbg;then set -x;fi #place anywhere useful
  echo "$*" |sed -r                                              \
    -e "s@${strCFGGameFolderRegex}@(GameDir)@g"                  \
    -e "s@${strCFGGeneratedWorldsFolderRegex}@(RwgDir)@g"        \
    -e "s@${strCFGGeneratedWorldTNMFolderRegex}@(RwgTNMDir)@g"
};export -f CFGFUNCcleanMsgPRIVATE
function CFGFUNCcleanEchoPRIVATE() {
  local lstr="`CFGFUNCcleanMsgPRIVATE " (CFG) $*"`"
  CFGFUNCechoLogPRIVATE "${lstr}"
  #echo "$lstr" >&2
  #echo "$lstr" >>"$strCFGScriptLog"
};export -f CFGFUNCcleanEchoPRIVATE

function CFGFUNCshowHelp() { 
  local lstrMatch="help";if [[ "${1-}" == --func ]];then shift;lstrMatch="helpf";fi
  echo " (CFG)HELP for ${strScriptName}:" >&2
  egrep "[#]${lstrMatch}" $0 -wn >&2 &&:
  bCFGHelpMode=true
  exit 1 #And this exits with error to prevent scripts using this lib to continue running!
};export -f CFGFUNCshowHelp

function CFGFUNCprepareRegex() {
  echo "$1" |sed -r 's@(.)@[\1]@g'
};export -f CFGFUNCcleanMsgPRIVATE

bNoChkErrOnExitPls=false
function CFGFUNCerrorChk() {
  if $bNoChkErrOnExitPls;then return;fi
  if(($?!=0));then
    CFGFUNCechoLogPRIVATE " (CFG)ERROR: the above message may contain the line where the error happened, read below on the help if it is there."
    read -p '(CFG)WARN: Hit a key to show the help.' -n 1&&:
    CFGFUNCshowHelp
  fi
};export -f CFGFUNCerrorChk

function CFGFUNCchkAvailHDAndGetFlSz() { #helpf <lstrRequiredBinaryFile> <liMultiplyFileSize> the liMultiplyFileSize param means that if you want to create a temporary and a backup you will need 2x the lstrRequiredBinaryFile file size in available HD space
  local lstrRequiredBinaryFile="$1";shift
  local liMultiplyFileSize="$1";shift
  
  local lnSzBytes=$(stat -c "%s" "$lstrRequiredBinaryFile")
  
  local lnAvailableHDSzBytes="`df --block-size=1 --output=avail . |tail -n 1 |awk '{print $1}'`"
  
  local lnReqAvail=$(( (lnSzBytes*liMultiplyFileSize)+(10*1024*1024) ))&&: # asks enough space for all tmp files for safe patching, and for extra 10MB 
  if((lnReqAvail>lnAvailableHDSzBytes));then 
    ls -l "$strRequiredBinaryFile" >&2
    df -h . >&2
    CFGFUNCerrorExit "The ${liMultiplyFileSize} extra files that will be a copy of '$strRequiredBinaryFile' require more free space in your HD: $((lnReqAvail/(1024*1024)))MB"
  fi
  
  echo "$lnSzBytes"
};export -f CFGFUNCchkAvailHDAndGetFlSz

function CFGFUNCtrash() { #helpf <file>
  while [[ -f "${1-}" ]];do
    CFGFUNCcleanEchoPRIVATE " (CFG)TRASHING`CFGFUNCDryRunMsg`: $1"
    if ! $bCFGDryRun;then
      #trash -v "$1"&&:
      #trash -v "$1" 2>&1 |egrep "^trash: '" &&:
      trash -v "$1" 2>&1 |egrep "`basename "$1"`" &&:
    fi
    shift&&:
  done
};export -f CFGFUNCtrash
function CFGFUNCechoLogPRIVATE() {
  CFGFUNCerrorForceEndPRIVATE #this is here just because this function is the one called most often
  if [[ "$1" == "--error" ]];then
    shift
    echo "$* (Stack: ${FUNCNAME[@]})" >>"$strCFGErrorLog"
  fi
  echo "$*" >&2
  echo "$* (Stack: ${FUNCNAME[@]})" >>"$strCFGScriptLog"
};export -f CFGFUNCechoLogPRIVATE
function CFGFUNCmeld() { #helpf <meldParams> or for colordiff or custom better just pass only 2 files...
  local lbSIGINTonMeld=false
  trap 'lbSIGINTonMeld=true' INT
  : ${strCFGCompareApp:="meld"} #help here you can configure another app to show differences
  if ! which "${strCFGCompareApp}";then # a helper for windows users on cygwin
    if which winmerge;then
      strCFGCompareApp="winmerge"
    fi
  fi
  if which "${strCFGCompareApp}";then
    CFGFUNCcleanEchoPRIVATE "WARN: hit ctrl+c to abort, closing '${strCFGCompareApp}' will accept the patch!!!"
    colordiff "$@"&&:
    "${strCFGCompareApp}" "$@"&&:;local lnRet=$? # it is expected that the merger app will not be a detached child process otherwise this wont work!
    if((lnRet!=0));then # (USELESS) meld gives the same exit value 0 if you hit ctrl+c, this wont help
      CFGFUNCechoLogPRIVATE "ERROR=$lnRet: '${strCFGCompareApp}' $@"
      return 1;
    fi
  else
    colordiff "$@"&&:
    CFGFUNCprompt -q "WARN: hit ctrl+c to abort, or continue to accept the patch!!! Obs.: you can configure a merger app like meld or winmerge for better viewing."
  fi
  if $lbSIGINTonMeld;then
    CFGFUNCcleanEchoPRIVATE "WARN: Ctrl+c pressed while running: '${strCFGCompareApp}' $@"
    return 1;
  fi
  CFGFUNCcleanEchoPRIVATE "AcceptingChanges: '${strCFGCompareApp}' $@"
  return 0
};export -f CFGFUNCmeld

#export iCFGFUNCerrorExit_Count=0
function CFGFUNCerrorForceEndPRIVATE() { #help this function is important to grant errors happening in subshells will be detected and help stop the script
  #if((iCFGFUNCerrorExit_Count>0));then
  if [[ -f "${strCFGErrorLog}" ]];then
    cat "${strCFGErrorLog}"
    echo "ERROR: There are the above errors in the error log file, probably because it happened in a subshell: ${strCFGErrorLog} " >&2
    read -n 1 -p "ERROR: Hit a key to trash the error log file (in case you already fixed the problem of a previous run) to prepare for a clean next run of this script. Or hit ctrl+c to keep it there."
    trash "${strCFGErrorLog}"
    exit 1
  fi
};export -f CFGFUNCerrorForceEndPRIVATE
function CFGFUNCerrorExit() { #helpf <msg>
  #((iCFGFUNCerrorExit_Count++))&&:
  if [[ -z "${1-}" ]];then CFGFUNCDevMeErrorExit "now $FUNCNAME needs to have some message, is better to have anything than nothing to help tracking problems";fi
  CFGFUNCechoLogPRIVATE --error " [ERROR] ${1} (Caller ${FUNCNAME[1]}) (Stack: ${FUNCNAME[@]})" 
  exit 1
};export -f CFGFUNCerrorExit
function CFGFUNCDevMeErrorExit() { #helpf <msg>
  #((iCFGFUNCerrorExit_Count++))&&:
  CFGFUNCechoLogPRIVATE --error "   !!!!!! [ERROR:DEVELOPER:SELFNOTE] $1 !!!!!! (Caller ${FUNCNAME[1]}) (Stack: ${FUNCNAME[@]})"
  exit 1
};export -f CFGFUNCDevMeErrorExit

function CFGFUNCDryRunMsg() { 
  if $bCFGDryRun;then echo "<DryRun>";fi
};export -f CFGFUNCDryRunMsg
function CFGFUNCexec() { #helpf [--noErrorExit] <<acmd>>
  local lbAllowErrorExit=true;if [[ "$1" == --noErrorExit ]];then shift;lbAllowErrorExit=false;fi
  CFGFUNCcleanEchoPRIVATE " (((EXEC`CFGFUNCDryRunMsg`))) $*"
  if ! $bCFGDryRun;then
    "$@"&&:;local lnRet=$?
    if((lnRet>0));then
      if $lbAllowErrorExit;then
        CFGFUNCerrorExit "Failed to execute the command above."
      fi
      return $lnRet
    fi
  fi
  return 0
};export -f CFGFUNCexec
function CFGFUNCprompt() { #helpf [-q] <lstrMsg>
  local lbQ=false;if [[ "$1" == -q ]];then shift;lbQ=true;fi
  local lstrMsg="$1";shift
  
  local lstrHitAKey="[Hit Ctrl+C to abort]"
  local lstrMode="[WAITING]"
  local lstrQ=""
  if $lbQ;then 
    lstrMode="[QUESTION]"
    lstrQ="?";
    lstrHitAKey+="[Hit 'y' to accept]"
  else
    lstrHitAKey+="[Hit any key to continue]"
  fi
  
  CFGFUNCcleanEchoPRIVATE " ${lstrMode} ${lstrMsg} ${lstrHitAKey} ${lstrQ}"
  if $bCFGInteractive;then
    read -p '.' -t $fCFGPromptWait -n 1 strResp >&2 &&:
  else
    strResp=y
  fi
  echo >&2
  
  if $lbQ;then
    if [[ "$strResp" =~ [yY] ]];then
      return 0
    else
      return 1
    fi
  fi
  
  return 0
};export -f CFGFUNCprompt
function CFGFUNCinfo() { #helpf <verboseMsg>
  #[shortMsg]
  local lstrVerboseMsg=" [INFO] $* (Caller ${FUNCNAME[1]})";shift
  #local lstrShortMsg="${1-}";shift&&:
  
  #local lstrMsg=" [INFO] $lstrShortMsg"
  #if $bCFGVerbose || [[ -z "${lstrShortMsg-}" ]];then
    #lstrMsg="$lstrVerboseMsg"
  #fi
  #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrMsg"
  
  #if ! $bCFGVerbose && [[ -n "${lstrShortMsg-}" ]];then
    #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrShortMsg"
  #else
    #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrVerboseMsg (Caller ${FUNCNAME[1]})"
  #fi
  
  #!!! no CFGFUNCcleanEchoPRIVATE for the log !!!
  #CFGFUNCechoLogPRIVATE " [INFO] $lstrVerboseMsg (Caller ${FUNCNAME[1]})"
  #CFGFUNCechoLogPRIVATE --logOnly "$lstrVerboseMsg"
  #CFGFUNCechoLogPRIVATE "$lstrVerboseMsg"
  
  CFGFUNCcleanEchoPRIVATE "$lstrVerboseMsg"
};export -f CFGFUNCinfo
function CFGFUNCcreateBackup() { #helpf <lstrFlDest>
  #local lbOrigBkpOnly=false;if [[ "$1" == --onlyCreateOriginalBackup ]];then shift;lbOrigBkpOnly=true;fi
  #local lbBinaryPatching=false;if [[ "$1" == --binaryPatching ]];then shift;lbBinaryPatching=true;fi
  local lstrFlDest="$1"
  
  local lstrFlOrigBkp="${lstrFlDest}${strCFGOriginalBkpSuffix}"
  local lstrFlSimpleBkp="${lstrFlDest}.SimpleBkpBy_${strModNameForIDs}.`date +"${strCFGDtFmt}"`.bkp"
  if [[ -f "${lstrFlDest}" ]];then
    if egrep --silent "$strCFGInstallToken" "$lstrFlDest";then
      CFGFUNCinfo "The destination file ${lstrFlDest} was already replaced by this mod's installer before because it contains this mod's token. A simple backup will be created instead."
      CFGFUNCexec cp -v "${lstrFlDest}" "${lstrFlSimpleBkp}"
      #if [[ ! -f "$lstrFlOrigBkp" ]];then
        #if ! CFGFUNCprompt -q "There is no original file backup there! Continue anyway?";then
          #exit 1
        #fi
      #fi
    else
      local lbDoOrigBkp=true
      if [[ -f "${lstrFlOrigBkp}" ]];then
        if ! cmp "${lstrFlDest}" "${lstrFlOrigBkp}" 2>&1 >/dev/null;then
          CFGFUNCinfo "There is already a original/vanilla (or pre-existing) backup file '${lstrFlOrigBkp}' there! Creating a simple backup instead."
          CFGFUNCexec cp -v "${lstrFlDest}" "${lstrFlSimpleBkp}"
        fi
        lbDoOrigBkp=false
      fi
      if $lbDoOrigBkp;then
        CFGFUNCinfo "Backuping file: ${lstrFlDest}"
        CFGFUNCexec cp -v "${lstrFlDest}" "${lstrFlOrigBkp}"
      fi
    fi
  else
    if ! $bCFGIgnMissingDestFl;then
      CFGFUNCprompt "WARNING: The destination file that would be backuped and replaced is missing '${lstrFlDest}'. Such file is important if you decide to uninstall this mod."
    fi
  fi
};export -f CFGFUNCcreateBackup
function CFGFUNCdiffFromBkp() { #helpf <strFl>
  if colordiff --ignore-all-space "$1" "${1}${strCFGOriginalBkpSuffix}";then #less verbose ignoring white space changes
    if colordiff "$1" "${1}${strCFGOriginalBkpSuffix}";then #if just spaces changed, will show it
      if ! CFGFUNCprompt -q "No changes detected, continue anyway?";then
        exit 1
      fi
    fi
  fi
  return 0
};export -f CFGFUNCcreateBackup


#: ${strScriptNameList:=""};if [[ -n "${strScriptName-}" ]];then strScriptNameList+="$strScriptName";fi
export strScriptParentList;if [[ -n "${strScriptName-}" ]];then strScriptParentList+=", ($$)$strScriptName";fi
export strScriptName="`basename "$0"`" #MUST OVERWRITE (HERE) FOR EVERY SCRIPT CALLED FROM ANOTHER. but must also be exported to work on each script functions called from `find -e xec bash`
export strCFGScriptName="$strScriptName" #TODO update all scripts with this new var name
#declare -p strScriptName strScriptParentList >&2 

#ps -o ppid,pid,cmd
#if [[ -n "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
  #ps -o ppid,pid,cmd
  ##pstree -p $$
  #echo " (CFG)WARNING: calling this script '${strScriptName}' (strScriptParentList='$strScriptParentList') that also uses the CFG file!!!" >&2
  ##echo " (CFG)ERROR: if calling another script that also uses the CFG file, it must be called in a subshell!" >&2
  ##exit 1
#fi

#if [[ -z "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
  set -Eeu
  
  : ${bCFGDryRun:=false} #help just show what would be done
  export bCFGDryRun
  
  : ${bCFGDbg:=false} #help to debug these scripts
  export bCFGDbg
  
  : ${strCFGGameFolder:="`cd ../..;pwd`"} #help configure the game folder
  export strCFGGameFolder
  export strCFGGameFolderRegex="`CFGFUNCprepareRegex "$strCFGGameFolder"`" #help GameDir
  
  : ${strCFGGeneratedWorldsFolder:="$WINEPREFIX/drive_c/users/$USER/Application Data/7DaysToDie/GeneratedWorlds/"}&&: #help you will need to set this if on windows cygwin
  export strCFGGeneratedWorldsFolder
  export strCFGGeneratedWorldsFolderRegex="`CFGFUNCprepareRegex "$strCFGGeneratedWorldsFolder"`" #help RwgDir
  
  : ${strCFGGeneratedWorldTNM:="East Nikazohi Territory"} #help
  export strCFGGeneratedWorldTNM
  
  export strCFGGeneratedWorldTNMFolder="$strCFGGeneratedWorldsFolder/$strCFGGeneratedWorldTNM/"
  export strCFGGeneratedWorldTNMFolderRegex="`CFGFUNCprepareRegex "$strCFGGeneratedWorldTNMFolder"`" #help RwgTNMDir
  
  export bCFGHelpMode=false
  trap 'nErrVal=$?;if ! $bCFGHelpMode;then ps -o ppid,pid,cmd >&2;read -p " (CFG)TRAP:ERROR=${nErrVal}:Ln=$LINENO: (${FUNCNAME[@]}) Hit a key to continue" -n 1&&:;fi;bNoChkErrOnExitPls=true;exit' ERR
  trap 'echo " (CFG)TRAP: Ctrl+c pressed...";exit' INT
  trap 'CFGFUNCerrorChk' EXIT
  
  export strCFGDtFmt="%Y_%m_%d-%H_%M_%S" #%Y_%m_%d-%H_%M_%S_%N
  
  : ${strCFGSavesPathIgnorable:="$WINEPREFIX/drive_c/users/$USER/Application Data/7DaysToDie/Saves/${strCFGGeneratedWorldTNM}/"}&&: #help you will need to set this if on windows cygwin
  : ${strCFGNewestSavePathIgnorable:="${strCFGSavesPathIgnorable}/`ls -1tr "$strCFGSavesPathIgnorable" |tail -n 1`/"}&&: #help
  : ${strCFGNewestSavePathConfigsDumpIgnorable:="${strCFGNewestSavePathIgnorable}/ConfigsDump/"}&&: #help
  export strCFGSavesPathIgnorable
  export strCFGNewestSavePathIgnorable
  export strCFGNewestSavePathConfigsDumpIgnorable
  if [[ ! -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
    if ! CFGFUNCprompt -q "last savegame path not found, this may create undesired (limited, invalid, incomplete, non updated) results, continue anyway?";then exit 1;fi
  fi
  
  mkdir -vp _log _tmp
  export strCFGScriptLog="`dirname "${0}"`/_log/`basename "${0}"`.`date +"${strCFGDtFmt}"`.log"
  export strCFGErrorLog="`dirname "${0}"`/_tmp/`basename "${0}"`.LastRunErrors.log"
  CFGFUNCtrash "${strCFGErrorLog}"
  #declare -p strCFGScriptLog
  
  : ${strModName:="[NoMad]"} #as short as possible
  export strModName
  
  : ${strModNameForIDs:="TheNoMadOverhaul"} #and for backup filenames
  export strModNameForIDs
  if ! [[ "$strModNameForIDs" =~ ^[a-zA-Z0-9_]*$ ]];then CFGFUNCerrorExit " (CFG)ERROR: invalid chars at strModNameForIDs='$strModNameForIDs'";fi
  
  #help Linux help: all variables shown on this help beginning like `: ${strSomeVar:="SomeValue"} #help` can be "safely" set (if you know what you are doing) before running the scripts like: strSomeVar="AnotherValue" ./incBuffsIDs.sh
  
  : ${bCFGInteractive:=true} #help running like this will accept all prompts: bInteractive=false ./installSpecificFilesIntoGameFolder.sh
  export bCFGInteractive
  fCFGPromptWait=$((60*60*24*31*3));if ! $bCFGInteractive;then fCFGPromptWait=0.01;fi
  
  : ${bCFGVerbose:=false} #help enable this to show detailed messages. Anyway everything will be in the install log.
  export bCFGVerbose
  
  : ${bCFGIgnMissingDestFl:=false} #help Always Ignore Missing Files That Would Be Replaced, otherwise you will be prompted for each missing file
  export bCFGIgnMissingDestFl
  
  export strCFGInstallToken="ThisFileIsAReplacementOrPatchOfTheMod_${strModNameForIDs}" #TODO may be it is possible to create a xmlstarlet merger that provide consistent/reliable results for each xml file that cant be patched as modlet?
  
  export strCFGOriginalBkpSuffix=".OriginalOrExistingFile.BakupMadeBy_${strModNameForIDs}.bkp"
  
  export strFlGenLoc="Config/Localization.txt"
  export strFlGenLoa="Config/loadingscreen.xml"
  export strFlGenEve="Config/gameevents.xml"
  export strFlGenRec="Config/recipes.xml"
  export strFlGenXml="Config/items.xml";strFlGenIte="$strFlGenXml"
  export strFlGenBuf="Config/buffs.xml"

  export strGenTmpSuffix=".GenCode.UpdateSection.TMP"
  
  if [[ "${1-}" == --gencodeTrashLast ]];then
    CFGFUNCtrash "${strFlGenLoc}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenLoa}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenEve}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenRec}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenXml}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenBuf}${strGenTmpSuffix}"&&:
  fi
  
  iMissingCmdCount=0;IFS=$'\n' read -d '' -r -a astrFlList < <(cat "ScriptsDependencies.AddedToRelease.Commands.txt")&&:;for strFl in "${astrFlList[@]}";do if ! which "$strFl" >/dev/null;then CFGFUNCinfo "WARNING: this linux command is missing: '$strFl'";((iMissingCmdCount++))&&:;fi;done
  if((iMissingCmdCount>0));then
    strFlPkgDeps="ScriptsDependencies.AddedToRelease.Packages.txt"
    iMissingPkgsCount=0;IFS=$'\n' read -d '' -r -a astrFlList < <(cat "${strFlPkgDeps}")&&:;for strFl in "${astrFlList[@]}";do if ! dpkg -s "$strFl" >/dev/null;then CFGFUNCinfo "WARNING: this linux PACKAGE is missing: '$strFl'";((iMissingPkgsCount++))&&:;fi;done
    if((iMissingPkgsCount>0));then
      if ! CFGFUNCprompt -q "WARNING: PROBLEM! There are missing command(s) and package(s) above, continue anyway? But you should install them first if possible. Removing the package from the file '${strFlPkgDeps}' will prevent this message prompt on next run.";then
        CFGFUNCerrorExit "MissingCmdsPgks"
      fi
    fi
  fi
  
  if [[ ! -f "${strCfgFlDBToImportOnChildShellFunctions-}" ]];then
    export strCfgFlDBToImportOnChildShellFunctions="`mktemp`" # this contains all arrays marked to export. PUT ALL SUCH ARRAYS BEFORE including/loading this cfg file!
  fi
  strTmp345987623="`export |egrep "[-][aA]x"`"&&:
  if [[ -n "$strTmp345987623" ]];then
    echo "$strTmp345987623" >>"$strCfgFlDBToImportOnChildShellFunctions"
  fi
  
  #export bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes=true
#fi

#!!! no CFGFUNCcleanEchoPRIVATE for params !!!
CFGFUNCechoLogPRIVATE " (CFG)PARAMS: $@"

if [[ "${1-}" == --help ]];then shift;CFGFUNCshowHelp;fi #help show help info.
if [[ "${1-}" == --helpfunc ]];then shift;CFGFUNCshowHelp --func;fi #help show function's help info for developers.
#echo " (CFG)Use --help alone to show this script help." >&2

# keep at the end
echo -n "" >&2 #this is to prevent error value returned from missing files to be trashed above or anything else irrelevant
