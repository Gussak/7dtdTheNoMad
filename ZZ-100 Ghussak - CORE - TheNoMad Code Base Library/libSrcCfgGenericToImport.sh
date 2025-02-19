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

#if [[ "$1" == --aliases ]];then
  #echo "
    #alias CFGFUNCinfoA='CFGFUNCinfo -l \$LINENO'
  #"
  #exit
#fi

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
  local lstr="`CFGFUNCcleanMsgPRIVATE " (CFG:${SECONDS}/${astrCFGTotalRunTimeList[${strCFGScriptNameAsID}]-}s) $*"`"
  CFGFUNCechoLogPRIVATE "${lstr}"
  #echo "$lstr" >&2
  #echo "$lstr" >>"$strCFGScriptLog"
};export -f CFGFUNCcleanEchoPRIVATE

function CFGFUNCbiomeData() { #helpf <lstrXYZ>
  local lstrXYZ="$1"
  if [[ -n "${astrPosVsBiomeColor[${lstrXYZ}]-}" ]];then      # faster
    eval "`${strCFGBaseLIBFolder}/getBiomeData.sh -t ${astrPosVsBiomeColor["${lstrXYZ}"]}`" # iBiome strBiome strColorAtBiomeFile
  else      # much slower
    eval "`${strCFGBaseLIBFolder}/getBiomeData.sh "${lstrXYZ}"`" # strColorAtBiomeFile strBiome iBiome
  fi
  #declare -p iBiome strBiome strColorAtBiomeFile
  echo "iBiome=$iBiome;strBiome='$strBiome';strColorAtBiomeFile='$strColorAtBiomeFile'" #OUTPUT
};export -f CFGFUNCbiomeData

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
  #else
    #astrCFGTotalRunTimeList["${strCFGScriptNameAsID}"]=$SECONDS
    #declare -p astrCFGTotalRunTimeList >"${strCFGFlTotalRunTimeSrc}"
  fi
};export -f CFGFUNCerrorChk

function CFGFUNCgencodeApply() {
  local lSECONDS=$SECONDS
  CFGFUNCexec "${strCFGBaseLIBFolder}/gencodeApply.sh" "$@"
  SECONDS=$lSECONDS
};export -f CFGFUNCgencodeApply

function CFGFUNCwriteTotalScriptTimeOnSuccess() { #helpf use this before calling ./gencodeApply.sh as it opens merger app and you may delay there, or use CFGFUNCgencodeApply and place this function at the very end
  astrCFGTotalRunTimeList["${strCFGScriptNameAsID}"]=$SECONDS
  declare -p astrCFGTotalRunTimeList >"${strCFGFlTotalRunTimeSrc}"
};export -f CFGFUNCwriteTotalScriptTimeOnSuccess

function CFGFUNCchkDenySubshellForGlobalVarsWork() {
  if((BASH_SUBSHELL>0));then CFGFUNCDevMeErrorExit "functions that output global vars will also modify other global vars and shall NOT be called in a subshell.";fi
};export -f CFGFUNCchkDenySubshellForGlobalVarsWork

function CFGFUNCsetGlobals() { #helpf <global=value> [<global=value> ...] the same params used with `declare -g` ex.: CFGFUNCsetGlobals -a astrTmpList #will work as expected but for arrays, the values must be set on another line, only declare arrays this way!
  CFGFUNCchkDenySubshellForGlobalVarsWork
  eval declare -g "$@"
  #eval "declare -g $*"
};export -f CFGFUNCsetGlobals

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
function CFGFUNCechoPRIVATE() {
  CFGFUNCerrorForceEndPRIVATE #this is here just because this function is the one called most often
  echo "$*" >&2
};export -f CFGFUNCechoPRIVATE
function CFGFUNCechoLogPRIVATE() {
  CFGFUNCerrorForceEndPRIVATE #this is here just because this function is the one called most often
  if [[ "$1" == "--error" ]];then
    shift
    echo "$* (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})" >>"$strCFGErrorLog"
  fi
  if ! ${bCFGLIBONLYOptInfoDebugMode-false};then
    CFGFUNCechoPRIVATE "$*" #all terminal output should be thru here
  else
    bCFGLIBONLYOptInfoDebugMode=false #unnecessary? the only terminal output should be on the above but...
  fi
  echo "$* (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})" >>"$strCFGScriptLog"
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

function CFGFUNCapplyChanges() { #helpf <lstrFlOld> <lstrFlNew>
  local lstrFlOld="$1";shift
  local lstrFlNew="$1";shift
  cp -v "${lstrFlOld}" "${lstrFlOld}.`date +"${strCFGDtFmt}"`.OLD" #backup
  mv -vf "${lstrFlNew}" "${lstrFlOld}" #overwrite
  echo "PATCHING expectedly WORKED! now test it!"
};export -f CFGFUNCapplyChanges

function CFGFUNCdbg() { echo "$@" >&2; };export -f CFGFUNCdbg; #export CFGdbg='echo "(stack: ${FUNCNAME[@]-})Ln:${LINENO},Ret=$?" >&2;CFGFUNCdbg '

function CFGFUNCxmlGetLinePropertyValue(){ #help <lstrLine> <lstrXmlPathAndPropID>
  local lstrLine="$1";shift
  local lstrXmlPathAndPropID="$1";shift
  #$CFGdbg "$lstrXmlPathAndPropID:$lstrLine"
  local lstrVal="`echo "$lstrLine" |xmlstarlet sel -t -v "${lstrXmlPathAndPropID}"`"&&:;local lnRet=$?
  #echo "(stack: ${FUNCNAME[@]-})Ln:${LINENO},Ret=$?,$lstrXmlPathAndPropID:$lstrVal:$lstrLine" >&2
  if [[ -z "$lstrVal" ]];then
    CFGFUNCinfo "WARNING: xmlstarlet returned empty value for lstrXmlPathAndPropID='$lstrXmlPathAndPropID', lstrLine='$lstrLine'"
  fi
  if((lnRet>0));then
    CFGFUNCerrorExit "xmlstarlet errored. lstrXmlPathAndPropID='$lstrXmlPathAndPropID', lstrLine='$lstrLine'"
    #CFGFUNCinfo "WARNING: xmlstarlet returned empty value for lstrXmlPathAndPropID='$lstrXmlPathAndPropID', lstrLine='$lstrLine'"
    #if [[ -z "$lstrVal" ]];then
      #CFGFUNCinfo "WARNING: xmlstarlet returned empty value for lstrXmlPathAndPropID='$lstrXmlPathAndPropID', lstrLine='$lstrLine'"
      #return 0
    #else
      #CFGFUNCerrorExit "xmlstarlet errored while returning a not empty value. lstrXmlPathAndPropID='$lstrXmlPathAndPropID', lstrLine='$lstrLine'"
    #fi
  fi
  #$CFGdbg "$lstrXmlPathAndPropID:$lstrLine"
  #echo "(stack: ${FUNCNAME[@]-})Ln:${LINENO},Ret=$?,$lstrXmlPathAndPropID:$lstrLine" >&2
  #echo "$lstrLine" |sed -r "s@.* ${lstrPropID}=\"([^\"]*)\".*@\1@"
  #echo "$lstrLine" |sed -r 's@.* '"${lstrPropID}"'="([^"]*)".*@\1@'
  echo "$lstrVal" # OUTPUT
};export -f CFGFUNCxmlGetLinePropertyValue
function CFGFUNCxmlSetLinePropertyValue(){ #help <lstrLine> <lstrXmlPathAndPropID> <lstrValue>
  local lstrLine="$1";shift
  local lstrXmlPathAndPropID="$1";shift
  local lstrValue="$1";shift
  echo "$lstrLine" |xmlstarlet ed -P -L -u "${lstrXmlPathAndPropID}" -v "${lstrValue}" |tail -n 1
  #echo "$lstrLine" |sed -r "s@(.* ${lstrPropID}=\")[^\"]*(\".*)@\1${lstrValue}\2@"
  #echo "$lstrLine" |sed -r 's@(.* '"${lstrPropID}"'=")[^"]*(".*)@\1'"${lstrValue}"'\2@'
};export -f CFGFUNCxmlSetLinePropertyValue
function CFGFUNCxmlAppendLinePropertyValue(){ #help <lstrLine> <lstrXmlPathAndPropID> <lstrValue> only for text
  local lstrLine="$1";shift
  local lstrXmlPathAndPropID="$1";shift
  local lstrValue="$1";shift
  #echo "$LINENO:RET=$?" >&2
  local lstrValueOld="`CFGFUNCxmlGetLinePropertyValue "$lstrLine" "$lstrXmlPathAndPropID"`"
  #echo "$LINENO:RET=$?" >&2
  CFGFUNCxmlSetLinePropertyValue "$lstrLine" "$lstrXmlPathAndPropID" "${lstrValueOld};${lstrValue}"
  #echo "$LINENO:RET=$?" >&2
};export -f CFGFUNCxmlAppendLinePropertyValue

#export iCFGFUNCerrorExit_Count=0
function CFGFUNCerrorForceEndPRIVATE() { #help this function is important to grant errors happening in subshells will be detected and help stop the script
  #if((iCFGFUNCerrorExit_Count>0));then
  if [[ -f "${strCFGErrorLog}" ]];then
    echo "====================== ERROR LOG ======================"
    cat "${strCFGErrorLog}"
    echo "====================== ERROR LOG ======================"
    echo "ERROR: There are the above errors in the error log file, probably because it happened in a subshell maybe: '${strCFGErrorLog}' (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})" >&2
    echo "QUESTION: did you fix the above errors already? if yes, hit 'y'. The error file will be trashed and the script will continue running. Any other key will exit the script. (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})"
    read -n 1 strResp&&:;if [[ "$strResp" =~ [yY] ]];then trash "${strCFGErrorLog}";return 0;fi
    #read -n 1 -p "ERROR: Hit a key to trash the error log file (in case you already fixed the problem of a previous run) to prepare for a clean next run of this script. Or hit ctrl+c to keep it there."
    #trash "${strCFGErrorLog}"
    exit 1
  fi
};export -f CFGFUNCerrorForceEndPRIVATE
#CFGFUNCerrorForceEndPRIVATE #here is good to quickly show there is some problem if any

function CFGFUNCerrorExit() { #helpf <msg>
  #((iCFGFUNCerrorExit_Count++))&&:
  if [[ -z "${1-}" ]];then CFGFUNCDevMeErrorExit "$FUNCNAME needs to have some message, is better to have anything than nothing to help tracking problems";fi
  CFGFUNCechoLogPRIVATE --error " [ERROR] ${1} (${strCFGScriptName}:Caller ${FUNCNAME[1]}) (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})" 
  echo "$FUNCNAME: The above error happened." >&2;read -n 1&&: #this is here in case the error happens in a subshell and such call has a protection against errors when the script returns from the subshell
  exit 1
};export -f CFGFUNCerrorExit
function CFGFUNCDevMeErrorExit() { #helpf <msg>
  #((iCFGFUNCerrorExit_Count++))&&:
  while true;do #requires ctrl+c now
    CFGFUNCechoLogPRIVATE --error "   !!!!!! [ERROR:DEVELOPER:SELFNOTE] $1 !!!!!! (${strCFGScriptName}:Caller ${FUNCNAME[1]}) (${strCFGScriptName}:Stack: ${FUNCNAME[@]-}) (YOU NEED TO HIT ctrl+c now)"
  done
  exit 1
};export -f CFGFUNCDevMeErrorExit

function CFGFUNCDryRunMsg() { 
  if $bCFGDryRun;then echo "<DryRun>";fi
};export -f CFGFUNCDryRunMsg
function CFGFUNCexec() { #helpf [--noErrorExit] [-m <lstrComment>] <<acmd>>
  local lbAllowErrorExit=true;if [[ "$1" == --noErrorExit ]];then shift;lbAllowErrorExit=false;fi
  local lstrComment="";if [[ "$1" == -m ]];then shift;lstrComment="#COMMENT: $1";shift;fi
  CFGFUNCcleanEchoPRIVATE " (((EXEC`CFGFUNCDryRunMsg`))) $* ${lstrComment} (${strCFGScriptName}:Stack: ${FUNCNAME[@]-})"
  if ! $bCFGDryRun;then
    "$@"&&:;local lnRet=$?
    if((lnRet>0));then
      if $lbAllowErrorExit;then
        CFGFUNCerrorExit "Failed to execute the command: $*"
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
    while read -n 1 -t 0.1 str;do echo -n .;done;echo #cleans any buffered key to avoid messing up the interaction
    local lSECONDSbkp=$SECONDS
    read -p '.' -t $fCFGPromptWait -n 1 strResp >&2 &&:
    SECONDS=$lSECONDSbkp
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
#function CFGFUNCinfo() { #helpf [-l <lnLine>] [-v] <lstrFullMsg>; if the -v option is used, the message will only be shown on the terminal if --verbose mode is enabled, but it will always be on the log
function CFGFUNCinfo() { #helpf [-l <lnLine>] [--dgb] <lstrFullMsg> ; if --dbg option is used, the message will only only be only on the log file
  local lstrLine="";if [[ "$1" == -l ]];then shift;lstrLine=":Ln${1}";shift;fi
  #local lstrOptLogOnly="";if [[ "$1" == -v ]] && ! $bCFGVerboseOutput;then lstrOptLogOnly="-l";fi
  #local lstrDbgMode="";if [[ "$1" == --dbg ]];then lstrDbgMode="$1";fi
  bCFGLIBONLYOptInfoDebugMode=false;if [[ "$1" == --dbg ]];then bCFGLIBONLYOptInfoDebugMode=true;fi #only sub calls after this shall use bCFGLIBONLYOptInfoDebugMode
  #[shortMsg]
  local lstrFullMsg=" [INFO] $* (Caller ${FUNCNAME[1]}${lstrLine})";shift
  #local lstrShortMsg="${1-}";shift&&:
  
  #local lstrMsg=" [INFO] $lstrShortMsg"
  #if $bCFGVerbose || [[ -z "${lstrShortMsg-}" ]];then
    #lstrMsg="$lstrFullMsg"
  #fi
  #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrMsg"
  
  #if ! $bCFGVerbose && [[ -n "${lstrShortMsg-}" ]];then
    #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrShortMsg"
  #else
    #CFGFUNCcleanEchoPRIVATE " [INFO] $lstrFullMsg (Caller ${FUNCNAME[1]})"
  #fi
  
  #!!! no CFGFUNCcleanEchoPRIVATE for the log !!!
  #CFGFUNCechoLogPRIVATE " [INFO] $lstrFullMsg (Caller ${FUNCNAME[1]})"
  #CFGFUNCechoLogPRIVATE --logOnly "$lstrFullMsg"
  #CFGFUNCechoLogPRIVATE "$lstrFullMsg"
  
#  CFGFUNCcleanEchoPRIVATE ${lstrDbgMode} "$lstrFullMsg" #lstrDbgMode is w/o quotes to not create an empty param
  CFGFUNCcleanEchoPRIVATE "$lstrFullMsg"
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

function CFGFUNCfixId() {
  echo "$1" |sed -r 's@[^a-zA-Z0-9_]@_@g'
}

: ${nCFGSeedPredictiveRandom:=1337} #help this seed will give the same result anywhere anytime if the equivalent conditions (all the input data, files etc) is the same
export nCFGSeedPredictiveRandom
#: ${iCFGPredictiveRandomCacheMax:=2500} #he lp max generated predictive random values
#export iCFGPredictiveRandomCacheMax
: ${iCFGPredictiveRandomIncStep:=100} #help
export iCFGPredictiveRandomIncStep
function CFGFUNCpredictiveRandomUpdateArray_PRIVATE() { #requires: liCurrentSize lstrID liCurrentIndex
  local lstrRndMany="`RANDOM=${nCFGSeedPredictiveRandom};for((i=0;i<(liCurrentSize+iCFGPredictiveRandomIncStep);i++));do echo -n "$RANDOM ";done`"
  declare -p lstrID liCurrentIndex liCurrentSize |tee -a "${strCFGScriptLog}" >&2
  #echo 'CFGFUNCsetGlobals -a aiPredictiveRandom'"${lstrID}=(${lstrRndMany})" |tee -a "${strCFGScriptLog}" >&2
  #eval 'CFGFUNCsetGlobals -a aiPredictiveRandom'"${lstrID}=(${lstrRndMany})"
  eval 'CFGFUNCsetGlobals -a aiPredictiveRandom'"${lstrID}"
  eval 'aiPredictiveRandom'"${lstrID}=(${lstrRndMany})"
  #eval 'declare -p aiPredictiveRandom'"${lstrID}" |tee -a "${strCFGScriptLog}" >&2 #too much annoying useless log
}
CFGFUNCsetGlobals -A astrCFGIdForRandomVsCurrentIndex
function CFGFUNCpredictiveRandom() { #helpf <lstrID> this ID will be used to provide the same random result for the same request time. Be sure to use the same ID in the same context.
  local lstrID="$1"
  
  local liCurrentSize=0
  local liCurrentIndex=0
  #declare -p astrCFGIdForRandomVsCurrentIndex
  #if ! echo "${!astrCFGIdForRandomVsCurrentIndex[@]}" |egrep -qw "$lstrID";then
  if ! CFGFUNCarrayContains "$lstrID" "${!astrCFGIdForRandomVsCurrentIndex[@]}";then #init
    if ! [[ "$lstrID" =~ ^[a-zA-Z0-9_]*$ ]];then CFGFUNCDevMeErrorExit "invalid lstrID='$lstrID' to create an array";fi
    #liCurrentSize=0
    astrCFGIdForRandomVsCurrentIndex["$lstrID"]=0
    #local lstrRndMany="`RANDOM=${nCFGSeedPredictiveRandom};for((i=0;i<(liCurrentSize+iCFGPredictiveRandomIncStep);i++));do echo -n "$RANDOM ";done`"
    #eval 'CFGFUNCsetGlobals -a aiPredictiveRandom'"${lstrID}=($lstrRndMany)"
    #eval 'declare -p aiPredictiveRandom'"${lstrID}" |tee -a "${strCFGScriptLog}" >&2
    CFGFUNCpredictiveRandomUpdateArray_PRIVATE
  fi
  
  liCurrentIndex=${astrCFGIdForRandomVsCurrentIndex[${lstrID}]}
  #if((liCurrentIndex>=iCFGPredictiveRandomCacheMax));then CFGFUNCerrorExit "liCurrentIndex > iCFGPredictiveRandomCacheMax. You need to increase iCFGPredictiveRandomCacheMax value";fi
  
  eval 'liCurrentSize=${#aiPredictiveRandom'"${lstrID}"'[@]}'
  if(( liCurrentIndex >= (liCurrentSize-1) ));then #increases
    CFGFUNCpredictiveRandomUpdateArray_PRIVATE
  fi
  
  eval 'CFGFUNCsetGlobals iPRandom="${aiPredictiveRandom'"${lstrID}"'['"${liCurrentIndex}"']}"' #OUTPUT
  astrCFGIdForRandomVsCurrentIndex[${lstrID}]=$((liCurrentIndex+1))
}

function CFGFUNCcourier() { #helpf <liDeliveryPrice> <liMinVal> <liMaxVal> chooses an adequate courier depending on the delivery value
  local liDeliveryPrice="$1";shift&&:
  local liMinVal="$1";shift&&:
  local liMaxVal="$1";shift&&:
  local lstrCourier="eventGSKSpwCourier" # most good mods
  if((liDeliveryPrice<=liMinVal));then lstrCourier="eventGSKSpwCourierWeak";fi # cheap stuff
  if((liDeliveryPrice>=liMaxVal));then lstrCourier="eventGSKSpwCourierStrong";fi # top tier
  echo "$lstrCourier"
};export -f CFGFUNCcourier

function CFGFUNCarrayContains() { # <lstrValueToChk> <array values...>
  local lstrValueToChk="$1";shift
  local lstr
  for lstr in "${@}";do
    if [[ "$lstrValueToChk" == "$lstr" ]];then return 0;fi
  done
  return 1
};export -f CFGFUNCarrayContains

function CFGFUNCgetNewestSavegamePath() {
  local lstrPath="`ls -1tr "${strCFGSavesPathIgnorable}/"*"/Player/Steam_"*".ttp" |tail -n 1`"
  lstrPath="${lstrPath#${strCFGSavesPathIgnorable}/}"
  lstrPath="`echo "$lstrPath" |cut -d/ -f1`"
  echo "${strCFGSavesPathIgnorable}/$lstrPath"
};export -f CFGFUNCgetNewestSavegamePath

function CFGFUNCxmlstarletSel() {
  local lbChkExistsOnly=false;if [[ "$1" == --chk ]];then shift;lbChkExistsOnly=true;fi
  local lstrPath="$1";shift
  local lstrFlXml="$1";shift
  
  local lastrCmd=(xmlstarlet)
  if $lbChkExistsOnly;then lastrCmd+=(-q);fi
  lastrCmd+=(sel -t)
  if $lbChkExistsOnly;then
    lastrCmd+=(-c)
  else
    lastrCmd+=(-v)
  fi
  lastrCmd+=("${lstrPath}" "${lstrFlXml}")
  
  if $lbChkExistsOnly;then
    if CFGFUNCexec --noErrorExit "${lastrCmd[@]}";then return 0;fi
  else
    #CFGFUNCinfo "EXEC: ${lastrCmd[@]}"
    local lstrResult="`CFGFUNCexec --noErrorExit "${lastrCmd[@]}"`"&&:
    if((`echo "${lstrResult}" |wc -l`!=1));then 
      CFGFUNCinfo "WARNING: invalid result, more than one match found lstrResult='${lstrResult}', ${lstrPath} ${lstrFlXml}. The last one will be used as it overrides previous ones.";
      lstrResult="`echo "$lstrResult" |tail -n 1`"
    fi
    
    if [[ -n "$lstrResult" ]];then
      echo "$lstrResult"
      return 0
    #else
      #CFGFUNCinfo "WARNING: empty lstrResult='$lstrResult' ${lstrPath} ${lstrFlXml}"
    fi
  fi
  
  return 1
};export -f CFGFUNCxmlstarletSel

function CFGFUNCidWithoutVariant() {
  echo "${1}" |cut -d: -f1 #TODO check for the "VariantHelper" string if it is valid like in "cobblestoneShapes:VariantHelper"
};export -f CFGFUNCidWithoutVariant

function CFGFUNCgetCustomEconomicValue() { #<lstrItemID> returning -1 means the item shall be ignored
  #local lstrMsg="$1";shift
  local lstrItemID="$1";shift
  while true;do
    #CFGFUNCinfo "$lstrMsg"
    #local liItemValueResp;read -p "INPUT: run the game and collect the item '${lstrItemID}' trader value (and paste here) for player lvl 1 w/o trading skills (I think price is like EcoVal/5=playerSellVal*15=traderSellVal or EcoVal=traderSellVal/3 right?):" liItemValueResp&&:
    # auto price 'EconomicValue'=0 failed, configure a custom price (at input data file) by collecting it from ingame sell price at inventory (just after entering the game for the first time and having sold/bought nothing before)
    local liItemValueResp;read -p "INPUT: (a value of -1 will set the item to be ignored) Start a new game. Add to your inventory item '${lstrItemID}'. If the item has tiers, collect the sell price for tier4. If the item has no tiers (like gun mods), collect the trader sell price for it. So, the player must be  lvl 1 w/o any trading bonuses (just after you enter the game the 1st time, having sold/bought nothing before (what lowers the price after some tradings) and w/o any skills or other bonuses from consumables or equipment) (I think price is like +- sellValue=itemTier4SellValue=EconomicValue. sellValue*15=traderSellValue (right?):" liItemValueResp&&:
    #if [[ "$liItemValueResp" =~ ^[0-9]*$ ]] && ((liItemValueResp>0));then
    if CFGFUNCchkNum "${liItemValueResp}";then
      local liEconomicValue="$liItemValueResp" #this is a player override
      #liEconomicValue="$((liItemValueResp/15))"
      #liEconomicValue=$((liEconomicValue*5/15))&&:
      if CFGFUNCprompt -q "economic value for '${lstrItemID}' will be ${liEconomicValue}, is that ok?";then
        break
      fi
    else
      CFGFUNCinfo "WARN: invalid value '$liItemValueResp' integer"
    fi
  done  
  echo "$liEconomicValue"
}

function CFGFUNCrecursiveSearchPropertyValue() { #tip: CFGFUNCrecursiveSearchPropertyValue --boolAllowProp "SellableToTrader" "EconomicValue"
  local lbRecursive=true;if [[ "$1" == "--no-recursive" ]];then shift;lbRecursive=false;fi
  local lstrBoolAllowProp="";if [[ "$1" == "--boolAllowProp" ]];then shift;lstrBoolAllowProp="$1";shift;fi
  local lstrProp="$1";shift #what property value to output
  local lstrXmlToken="$1";shift #this matches the filename (least many suffix 's') and the main sections inside it, both are the same id
  local lstrItemID="$1";shift
  local lstrFlCfgChkFullPath="$1";shift
  
  #OUTPUTS:
  declare -g bFRSPV_CanSell_OUT #TODOA rename everywhere to bFRSPV_PropAllow_OUT
  declare -g iFRSPV_PropVal_OUT #returning empty means it was not found TODOA rename everywhere to strFRSPV_PropVal_OUT
  declare -g strFRSPV_XmlTokenFound_OUT #to help determine what kind of id is this, in what xml file it is
  
  declare -g strFRSPV_PreviousItemID
  
  local lstrChkItem="`CFGFUNCidWithoutVariant "$lstrItemID"`"
  local lastrItemInheritPath=("$lstrChkItem")
  local lstrParent=""
  while [[ -n "$lstrChkItem" ]];do # recursively look for lstrProp at extended parents
    #if xmlstarlet -q sel -t -c "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
    if CFGFUNCxmlstarletSel --chk "//${lstrXmlToken}[@name='${lstrChkItem}']" "${lstrFlCfgChkFullPath}";then
      strFRSPV_XmlTokenFound_OUT="${lstrXmlToken}"
    else
      return 1
    fi
    
    if [[ "${strFRSPV_PreviousItemID-}" != "$lstrItemID" ]];then
      CFGFUNCinfo "initialize new item: $lstrItemID"
      #strFRSPV_XmlTokenFound_OUT=""
      strFRSPV_PreviousItemID="$lstrItemID"
      bFRSPV_CanSell_OUT=true #engine default hardcoded is this
      iFRSPV_PropVal_OUT="" #empty means it was not found
    fi
    
    CFGFUNCinfo "CHECKING: ${lstrChkItem} ${lstrFlCfgChkFullPath}"
    
    # check allowed
    #echo CFGFUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"
    if [[ -n "$lstrBoolAllowProp" ]];then
      local lstrAllowVal="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrBoolAllowProp}']/@value" "${lstrFlCfgChkFullPath}"`" #like SellableToTrader
      #if((`echo "$lstrAllowVal" |wc -l`!=1));then CFGFUNCerrorExit "invalid result, more than one match found lstrAllowVal='${lstrAllowVal}'";fi
      if [[ "`echo ${lstrAllowVal} |tr '[:upper:]' '[:lower:]'`" == "false" ]];then
        bFRSPV_CanSell_OUT=false #even if it cant be sold, it may still have a EconomicValue set, that is good for the calc here
        declare -p bFRSPV_CanSell_OUT
        #break
      fi
    fi
    
    # get value
    #if iFRSPV_PropVal_OUT="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrProp}']/@value" "${lstrFlCfgChkFullPath}"`";then
    iFRSPV_PropVal_OUT="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='${lstrProp}']/@value" "${lstrFlCfgChkFullPath}"`"&&:
    CFGFUNCinfo "iFRSPV_PropVal_OUT='$iFRSPV_PropVal_OUT'"
    if [[ -n "$iFRSPV_PropVal_OUT" ]];then
      #CFGFUNCinfo "iFRSPV_PropVal_OUT='iFRSPV_PropVal_OUT'"
      break
    fi
    
    # get parent to check
    #echo CFGFUNCxmlstarletSel "${lstrXmlToken}s/${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"
    if $lbRecursive && lstrParent="`CFGFUNCxmlstarletSel "//${lstrXmlToken}[@name='${lstrChkItem}']/property[@name='Extends']/@value" "${lstrFlCfgChkFullPath}"`";then
      if [[ -z "$lstrParent" ]];then CFGFUNCinfo "WARN: should not be empty lstrParent='$lstrParent'";break;fi
      CFGFUNCinfo "lstrChkItem='$lstrChkItem' extends lstrParent='$lstrParent'"
      lstrChkItem="$lstrParent"
      lastrItemInheritPath+=("$lstrChkItem")
    else
      break
    fi
  done
  
  if [[ -n "$lstrBoolAllowProp" ]];then
    if ! $bFRSPV_CanSell_OUT;then
      CFGFUNCinfo "DeniedByProp:'${lstrBoolAllowProp}'=false: ${lstrItemID}";
      return 1
    fi
  fi
  
  if $bFRSPV_CanSell_OUT;then
    #if((iFRSPV_PropVal_OUT>0));then 
    #if [[ "$iFRSPV_PropVal_OUT" != "0" ]];then  #can be a string like true/false
    if [[ -n "$iFRSPV_PropVal_OUT" ]];then
      strItemInheritPathDBG="`echo "${lastrItemInheritPath[@]}"|tr ' ' '>'`"
      CFGFUNCinfo "${lstrProp}: ${strItemInheritPathDBG} iFRSPV_PropVal_OUT='${iFRSPV_PropVal_OUT}' ${lstrFlCfgChkFullPath}";
      return 0
    fi
  fi
  
  return 1
};export -f CFGFUNCrecursiveSearchPropertyValue
function CFGFUNCrecursiveSearchPropertyValueAllFiles() {
  local strOptRecursive="";if [[ "$1" == "--no-recursive" ]];then strOptRecursive="$1";shift;fi
  local lstrBoolAllowProp="";if [[ "$1" == "--boolAllowProp" ]];then shift;lstrBoolAllowProp="$1";shift;fi
  local lstrProp="$1";shift #what property value to output
  local lstrItemID="$1";shift
  
  local bFoundSomething=false
  for((j=0;j<${#CFGastrXmlToken1VsFile2List[@]};j+=2));do 
    local lstrXmlToken="${CFGastrXmlToken1VsFile2List[j]}"
    local lstrFlCfgChkFullPath="${CFGastrXmlToken1VsFile2List[j+1]}"
    if CFGFUNCrecursiveSearchPropertyValue ${strOptRecursive} --boolAllowProp "$lstrBoolAllowProp" "$lstrProp" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then # FRSPV
    #if CFGFUNCrecursiveSearchPropertyValue "EconomicValue" "$lstrXmlToken" "$lstrItemID" "$lstrFlCfgChkFullPath";then
      bFoundSomething=true
      break
    fi
  done
  if ! $bFoundSomething;then 
    CFGFUNCinfo "WARN: nothing found for lstrItemID='$lstrItemID' lstrProp='$lstrProp' lstrBoolAllowProp='$lstrBoolAllowProp'";
    #bFRSPV_CanSell_OUT=true
    return 1
  fi
  return 0
};export -f CFGFUNCrecursiveSearchPropertyValueAllFiles

function CFGFUNCchkNumGT0() {
#  if [[ -n "${1-}" ]] && [[ "${1}" =~ ^[0-9]*$ ]] && ((${1}>0));then return 0;fi
  if [[ -n "${1-}" ]] && [[ "${1}" =~ ^[0-9]*$ ]] && ((${1}>0));then return 0;fi
  echo "WARN: invalid positive integer > 0: $1" >&2
  return 1
};export -f CFGFUNCchkNumGT0
function CFGFUNCchkNum() {
#  if [[ -n "${1-}" ]] && [[ "${1}" =~ ^[0-9]*$ ]] && ((${1}>0));then return 0;fi
  if [[ -n "${1-}" ]] && [[ "${1}" =~ ^-{0,1}[0-9]*$ ]];then return 0;fi
  echo "WARN: invalid integer: $1" >&2
  return 1
};export -f CFGFUNCchkNum

function CFGFUNCarrayDataSorted() { # [--noindent]
  local lstrIndent="  ";if [[ "$1" == "--noindent" ]];then lstrIndent="";shift;fi
  local lastrArray="$1"
  
  #local lstrSedRmArrayClose='s@(.*)[)]$@\1\n)@'
  #local lstrSedNewLineForFirstEntry="s@${lastrArray}=[(][[]@${lastrArray}=(\n  [@"
  #local lstrSedNewLineForEachEntry='s@" [[]@"\n  [@g'
  ## tail ignores first line with declare statement
  ## head ignores last line
  #declare -p "${lastrArray}" \
    #|sed -r \
      #-e "$lstrSedRmArrayClose" \
      #-e "$lstrSedNewLineForFirstEntry" \
      #-e "$lstrSedNewLineForEachEntry" \
    #|tail -n +2 \
    #|head -n -1 \
    #|sort
    
  #lstrOutput="$(declare -p "${lastrArray}" |sed -r -e 's@(.*)[)]$@\1@' -e "s@^declare .* ${lastrArray}=[(]@@" -e 's@" [[]@"\n  [@g')";echo "${lstrOutput}"|wc -l
  #local lstrSedRmArrayClose='s@(.*) *[)] *$@\1@' #and spaces just before and just after it
  local lstrSedRmArrayClose='s@(.*) +[)] *$@\1@' #`declare -p` !always! add a space before the array closing ')'
  local lstrSedRmDeclareStatement="s@^declare .* ${lastrArray}=[(] *@${lstrIndent}@" #first entry gets the indent too
  local lstrSedNewLineForEachEntry="s@\" *[[]@\"\n${lstrIndent}[@g" #works between each entry. this is guess work, values must not contain '[' but that consistency is expected
  declare -p "${lastrArray}" \
    |sed -r \
      -e "$lstrSedRmArrayClose" \
      -e "$lstrSedRmDeclareStatement" \
      -e "$lstrSedNewLineForEachEntry" \
    |sort
}

function CFGFUNChashArray() { #helpf hash the array data (excludes the array name)
  #declare -p "$1" |sed -e 's@[^=]*=@@' |tr '[' '\n' |sort |sha1sum
  #echo "${1}" >>/tmp/debugHashArray237453847.txt;CFGFUNCarrayDataSorted --noindent "${1}" |tr -d '\n' >>/tmp/debugHashArray237453847.txt;echo >>/tmp/debugHashArray237453847.txt #TODOA comment
  #declare -p "$1" >>/tmp/debugHashArray237453847.txt
  CFGFUNCarrayDataSorted --noindent "${1}" |tr -d '\n' |sha1sum
};export -f CFGFUNChashArray
function CFGFUNCloadCaches() { #helpf use like: eval "`CFGFUNCloadCaches`"
  local lstrFlID
  
  # ItemEconomicValue
  lstrFlID="ItemEconomicValue"
  declare -A CFGastrItem1Value2List
  declare -gx CFGstrFlItemEconomicValueCACHE="Cache.DeleteToRecreate/cache.${lstrFlID}.sh" #help if you delete the cache file it will be recreated
  if [[ -f "${CFGstrFlItemEconomicValueCACHE}" ]];then source "${CFGstrFlItemEconomicValueCACHE}";fi
  # checks
  #strIVChk="`declare -p CFGastrItem1Value2List |tr '[' '\n' |egrep -v "^ *$" |egrep -v "${strCraftBundlePrefixID}" |sort -u`"
  #echo "$strIVChk" |egrep '="1"' >&2 &&: # just to check if they should really be value 1
  #if((`echo "$strIVChk" |egrep '="0*"' |wc -l`>0));then # matches "" or "0"
    #echo "$strIVChk" >&2
    #CFGFUNCprompt "there are the above entries that could be improved (at least EconomicValue 1)" #let/wait user know about it
  #fi
  declare -gx CFGstrItemEcoValHASH="`CFGFUNChashArray CFGastrItem1Value2List`"
  echo "`declare -p CFGstrItemEcoValHASH CFGastrItem1Value2List CFGstrFlItemEconomicValueCACHE`" #OUTPUT
  
  # ItemHasTiers
  lstrFlID="ItemHasTiers"
  declare -A CFGastrItem1HasTiers2List
  declare -gx CFGstrFlItemHasTierCACHE="Cache.DeleteToRecreate/cache.${lstrFlID}.sh"
  if [[ -f "${CFGstrFlItemHasTierCACHE}" ]];then source "${CFGstrFlItemHasTierCACHE}";fi
  declare -gx CFGstrItemHasTierHASH="`CFGFUNChashArray CFGastrItem1HasTiers2List`"
  echo "`declare -p CFGstrItemHasTierHASH CFGastrItem1HasTiers2List CFGstrFlItemHasTierCACHE`" #OUTPUT
  
  # CustomIcons
  lstrFlID="CustomIcons"
  declare -A CFGastrCacheItem1CustomIcon2List
  declare -gx CFGstrFlCustomIconCACHE="Cache.DeleteToRecreate/cache.${lstrFlID}.sh"
  if [[ -f "${CFGstrFlCustomIconCACHE}" ]];then source "${CFGstrFlCustomIconCACHE}";fi
  declare -gx CFGastrCustomIconHASH="`CFGFUNChashArray CFGastrCacheItem1CustomIcon2List`"
  echo "`declare -p CFGastrCustomIconHASH CFGastrCacheItem1CustomIcon2List CFGstrFlCustomIconCACHE`" #OUTPUT
  
  # CreativeModes
  lstrFlID="CreativeMode"
  declare -A CFGastrCacheItem1CreativeMode2List
  declare -gx CFGstrFlCreativeModeCACHE="Cache.DeleteToRecreate/cache.${lstrFlID}.sh"
  if [[ -f "${CFGstrFlCreativeModeCACHE}" ]];then source "${CFGstrFlCreativeModeCACHE}";fi
  declare -gx CFGastrCreativeModeHASH="`CFGFUNChashArray CFGastrCacheItem1CreativeMode2List`"
  echo "`declare -p CFGastrCreativeModeHASH CFGastrCacheItem1CreativeMode2List CFGstrFlCreativeModeCACHE`" #OUTPUT
  
  # CanPickups
  lstrFlID="CanPickup"
  declare -A CFGastrCacheItem1CanPickup2List
  declare -gx CFGstrFlCanPickupCACHE="Cache.DeleteToRecreate/cache.${lstrFlID}.sh"
  if [[ -f "${CFGstrFlCanPickupCACHE}" ]];then source "${CFGstrFlCanPickupCACHE}";fi
  declare -gx CFGastrCanPickupHASH="`CFGFUNChashArray CFGastrCacheItem1CanPickup2List`"
  echo "`declare -p CFGastrCanPickupHASH CFGastrCacheItem1CanPickup2List CFGstrFlCanPickupCACHE`" #OUTPUT
  
};export -f CFGFUNCloadCaches
function CFGFUNCwriteCaches() {
  local lstrHeader='#PREPARE_RELEASE:REVIEWED:OK
# this file is auto generated. delete it to be recreated. do not edit (unless you know what you are doing, what will be much faster than recreating it)!'
  local lastrCacheList=(
    CFGstrItemEcoValHASH    CFGastrItem1Value2List             CFGstrFlItemEconomicValueCACHE 
    CFGstrItemHasTierHASH   CFGastrItem1HasTiers2List          CFGstrFlItemHasTierCACHE
    CFGastrCustomIconHASH   CFGastrCacheItem1CustomIcon2List   CFGstrFlCustomIconCACHE
    CFGastrCreativeModeHASH CFGastrCacheItem1CreativeMode2List CFGstrFlCreativeModeCACHE
    CFGastrCanPickupHASH    CFGastrCacheItem1CanPickup2List    CFGstrFlCanPickupCACHE
  )
  local liLoopCachesDataLnIniIndex
  for((liLoopCachesDataLnIniIndex=0;liLoopCachesDataLnIniIndex<${#lastrCacheList[@]};liLoopCachesDataLnIniIndex+=3));do
    local lstrHash="${!lastrCacheList[liLoopCachesDataLnIniIndex]}"
    local lastrArray="${lastrCacheList[liLoopCachesDataLnIniIndex+1]}"
    local lstrFlCache="${!lastrCacheList[liLoopCachesDataLnIniIndex+2]}"
    
    #echo "declare -p ${lastrArray}" # |sha1sum
    #declare -p ${lastrArray}
    #local lstrNewHash="`declare -p ${lastrArray} |sed 's@[^=]*=@@' |sha1sum`"
    local lstrNewHash="`CFGFUNChashArray ${lastrArray}`"
    if [[ "$lstrHash" != "$lstrNewHash" ]];then
      declare -p lstrHash lastrArray lstrFlCache lstrNewHash
      ls -l "$lstrFlCache" >&2 &&:
      CFGFUNCtrash "$lstrFlCache"
      echo "${lstrHeader}" >"$lstrFlCache"
      
      #declare -p "${lastrArray}" >>"$lstrFlCache" #simple granted to work
      #### MoreReadableCache: ###
      #  This may work if there is no need to escape chars: for lstrIdIndex in $(eval "echo \${!${lastrArray}[@]}"|tr ' ' '\n'|sort);do echo "${lastrArray}[${lstrIdIndex}]='$(eval "echo \${${lastrArray}[${lstrIdIndex}]}")'";done
      #local lstrOutput="$(declare -p "${lastrArray}" |sed -r -e 's@(.*)[)]$@\1\n)@' -e "s@${lastrArray}=[(][[]@${lastrArray}=(\n  [@" -e 's@" [[]@"\n  [@g')"
      #echo "${lstrOutput}" |head -n 1 >>"$lstrFlCache" #declare statement
      declare -p "${lastrArray}" |sed -r -e "s@^(declare .* ${lastrArray}=[(]).*@\1@" >>"$lstrFlCache" #declare statement and array opening '=('
      #echo "${lstrOutput}" |tail -n +2 |head -n -1 |sort >>"$lstrFlCache" #array data
      CFGFUNCarrayDataSorted "${lastrArray}" >>"$lstrFlCache"
      echo ')' >>"$lstrFlCache" #close array
      
      ls -l "$lstrFlCache" >&2
    fi
  done
  #if [[ "$CFGstrItemEcoValHASH" != "`declare -p CFGastrItem1Value2List |sha1sum`" ]];then
    #ls -l "$CFGstrFlItemEconomicValueCACHE" >&2
    #CFGFUNCtrash "$CFGstrFlItemEconomicValueCACHE"
    #echo "${lstrHeader}" >"$CFGstrFlItemEconomicValueCACHE"
    #declare -p CFGastrItem1Value2List >>"$CFGstrFlItemEconomicValueCACHE"
    #ls -l "$CFGstrFlItemEconomicValueCACHE" >&2
  #fi
  #if [[ "$CFGstrItemHasTierHASH" != "`declare -p CFGastrItem1HasTiers2List |sha1sum`" ]];then
    #ls -l "$CFGstrFlItemHasTierCACHE" >&2
    #CFGFUNCtrash "$CFGstrFlItemHasTierCACHE"
    #echo "${lstrHeader}" >"$CFGstrFlItemHasTierCACHE"
    #declare -p CFGastrItem1HasTiers2List >>"$CFGstrFlItemHasTierCACHE"
    #ls -l "$CFGstrFlItemHasTierCACHE" >&2
  #fi
};export -f CFGFUNCwriteCaches

#: ${strScriptNameList:=""};if [[ -n "${strScriptName-}" ]];then strScriptNameList+="$strScriptName";fi
export strScriptParentList;if [[ -n "${strScriptName-}" ]];then strScriptParentList+=", ($$)$strScriptName";fi
export strScriptName="`basename "$0"`" #MUST OVERWRITE (HERE) FOR EVERY SCRIPT CALLED FROM ANOTHER. but must also be exported to work on each script functions called from `find -e xec bash`
export strCFGScriptName="$strScriptName" #TODO update all scripts with this new var name
export strCFGScriptNameAsID="`CFGFUNCfixId "${strScriptName}"`"
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
  
  if [[ -z "${WINEPREFIX-}" ]];then
		echo "WARNING: WINEPREFIX is not set (this could be ok if on cygwin, not tested there tho..)" >&2
		read -p "Hit Enter"
		export WINEPREFIX="";
	fi #setting empty prevents errors if used w/o '-}'
  
  : ${bCFGInteractive:=true} #help running like this will accept all prompts: bInteractive=false ./installSpecificFilesIntoGameFolder.sh
  export bCFGInteractive
  fCFGPromptWait=$((60*60*24*31*3));if ! $bCFGInteractive;then fCFGPromptWait=0.01;fi
  
  SECONDS=0
  export strCFGDtFmt="%Y_%m_%d-%H_%M_%S" #%Y_%m_%d-%H_%M_%S_%N
  shopt -s expand_aliases

  : ${bCFGDryRun:=false} #help just show what would be done
  export bCFGDryRun
  
  mkdir -vp _log _tmp #this will end up being created at the folder of the script importing this lib
  
  export strCFGScriptLog="`pwd`/_log/`basename "${0}"`.`date +"${strCFGDtFmt}"`.log"
  export strCFGScriptLogLastLink="`pwd`/_log/`basename "${0}"`.Last.log"
  #set -x;
  ln -vsfT "${strCFGScriptLog}" "${strCFGScriptLogLastLink}";
  #set +x
  #declare -p strCFGScriptLog strCFGScriptLogLastLink
  
  export strCFGErrorLog="`pwd `/_log/`basename "${0}"`.`date +"${strCFGDtFmt}"`.Errors.log"
  export strCFGErrorLogLastLink="`pwd `/_log/`basename "${0}"`.Errors.Last.log"
  #set -x;
  ln -vsfT "${strCFGErrorLog}" "${strCFGErrorLogLastLink}";
  #set +x
  #declare -p strCFGErrorLog strCFGErrorLogLastLink
  #exit 1
  
  export strCFGFlTotalRunTimeSrc="`pwd `/_tmp/CFGTotalScriptsRunTimes.sh"
  #declare -p strCFGScriptLog
  declare -A astrCFGTotalRunTimeList=()
  if [[ -f "$strCFGFlTotalRunTimeSrc" ]];then
    source "${strCFGFlTotalRunTimeSrc}"
  fi
  
  : ${bCFGDbg:=false} #help to debug these scripts
  export bCFGDbg
  
  : ${strCFGGameFolder:="`cd ../..;pwd`"} #help configure the game folder
  export strCFGGameFolder
  export strCFGGameFolderRegex="`CFGFUNCprepareRegex "$strCFGGameFolder"`" #help GameDir
  
  : ${strCFGBaseLIBFolder:="$(find ../ -maxdepth 1 -type d -iname "*Ghussak*TheNoMad*Code Base Library*"&&:)"} #help
  
  : ${strCFGAppDataFolder:="${WINEPREFIX-}/drive_c/users/$USER/Application Data/"}&&: #help
  : ${strCFG7dtdAppDataFolder:="${strCFGAppDataFolder}/7DaysToDie/"}&&: #help
  : ${strCFGScreenshotsFolder:="${strCFG7dtdAppDataFolder}/Screenshots"}&&: #help
  
  #help setting WINEPREFIX manually may help if you are using cygwin
  : ${strCFGGeneratedWorldsFolder:="${strCFG7dtdAppDataFolder}/GeneratedWorlds/"}&&: #help you will need to set this if on windows cygwin
  export strCFGGeneratedWorldsFolder
  export strCFGGeneratedWorldsFolderRegex="`CFGFUNCprepareRegex "$strCFGGeneratedWorldsFolder"`" #help RwgDir
  
  : ${strCFGGeneratedWorldTNM:="West Bogacuyu Valley"} #help
  export strCFGGeneratedWorldTNM
  export strCFGGeneratedWorldTNMFixedAsID="`CFGFUNCfixId "$strCFGGeneratedWorldTNM"`"
  : ${strCFGGeneratedWorldSpecificDataAsID:="SeedHolyAir2_Size10240_TownsFew_WildPOIsMany_RiversMany_CratersMany_CracksMany_LakesMany_Plains0_Hills10_Mountains10_Random3"} #help these are all the values used in RWG config screen
  export strCFGGeneratedWorldSpecificDataAsID
  
  export strCFGGeneratedWorldTNMFolder="$strCFGGeneratedWorldsFolder/$strCFGGeneratedWorldTNM/"
  export strCFGGeneratedWorldTNMFolderRegex="`CFGFUNCprepareRegex "$strCFGGeneratedWorldTNMFolder"`" #help RwgTNMDir
  
  export bCFGHelpMode=false
  trap 'nErrVal=$?;if ! $bCFGHelpMode;then ps -o ppid,pid,cmd >&2;echo " (CFG)TRAP:ERROR=${nErrVal}:Ln=$LINENO: (${FUNCNAME[@]-}) Hit ctrl+c to stop now (if you just hit a key it will continue but is not advised)" >&2;read -n 1&&:;fi;bNoChkErrOnExitPls=true;exit' ERR
  #trap 'nErrVal=$?;ps -o ppid,pid,cmd >&2;echo " (CFG)TRAP:ERROR=${nErrVal}:Ln=$LINENO: (${FUNCNAME[@]-}) Hit a key to continue" >&2;read -n 1&&:;bNoChkErrOnExitPls=true;exit' ERR
  trap 'echo " (CFG)TRAP: Ctrl+c pressed..." >&2;exit' INT
  trap 'CFGFUNCerrorChk' EXIT
  
  : ${strCFGSavesPath:="${strCFG7dtdAppDataFolder}/Saves"} #help
  : ${strCFGSavesPathIgnorable:="${strCFGSavesPath}/${strCFGGeneratedWorldTNM}/"}&&: #help you will need to set this if on windows cygwin
  #: ${strCFGNewestSavePathIgnorable:="${strCFGSavesPathIgnorable}/`ls -1tr "$strCFGSavesPathIgnorable" |tail -n 1`/"}&&: #he lp
  : ${strCFGNewestSavePathIgnorable:="`CFGFUNCgetNewestSavegamePath`"}&&: #help
  : ${strCFGNewestSavePathConfigsDumpIgnorable:="${strCFGNewestSavePathIgnorable}/ConfigsDump/"}&&: #help
  export strCFGSavesPathIgnorable
  export strCFGNewestSavePathIgnorable
  export strCFGNewestSavePathConfigsDumpIgnorable
  while [[ ! -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];do
    if CFGFUNCprompt -q "last savegame path '${strCFGNewestSavePathConfigsDumpIgnorable-}' not found, this may create undesired (limited, invalid, incomplete, non updated) results, continue anyway? (if not, will retry check for that path)";then break;fi
  done
  
  : ${strModName:="[NoMad]"} #as short as possible
  export strModName
  
  : ${strModNameForIDs:="TheNoMadOverhaul"} #and for backup filenames
  export strModNameForIDs
  if ! [[ "$strModNameForIDs" =~ ^[a-zA-Z0-9_]*$ ]];then CFGFUNCerrorExit " (CFG)ERROR: invalid chars at strModNameForIDs='$strModNameForIDs'";fi
  : ${strModNameShortForIDs:="TNM"}
  export strModNameShortForIDs
  
  #help Linux help: all variables shown on this help beginning like `: ${strSomeVar:="SomeValue"} #help` can be "safely" set (if you know what you are doing) before running the scripts like: strSomeVar="AnotherValue" ./incBuffsIDs.sh (TODO: that script deprecated, update info here)
  
  : ${bCFGVerbose:=false} #help enable this to show detailed messages. Anyway everything will be in the install log.
  export bCFGVerbose
  
  : ${bCFGIgnMissingDestFl:=false} #help Always Ignore Missing Files That Would Be Replaced, otherwise you will be prompted for each missing file
  export bCFGIgnMissingDestFl
  
  export strCFGInstallToken="ThisFileIsAReplacementOrPatchOfTheMod_${strModNameForIDs}" #TODO may be it is possible to create a xmlstarlet merger that provide consistent/reliable results for each xml file that cant be patched as modlet?
  
  export strCFGOriginalBkpSuffix=".OriginalOrExistingFile.BakupMadeBy_${strModNameForIDs}.bkp"
  
  export strGenTmpSuffix=".GenCode.UpdateSection.TMP"
  
  strFlScriptDepsCmds="${strCFGBaseLIBFolder}/ScriptsDependencies.AddedToRelease.Commands.txt"
  strFlScriptDepsPkgs="${strCFGBaseLIBFolder}/ScriptsDependencies.AddedToRelease.Packages.txt"
  if [[ -f "$strFlScriptDepsCmds" ]];then
		iMissingCmdCount=0;IFS=$'\n' read -d '' -r -a astrFlList < <(cat "$strFlScriptDepsCmds")&&:;for strFl in "${astrFlList[@]}";do if ! which "$strFl" >/dev/null;then CFGFUNCinfo "WARNING: this linux command is missing: '$strFl'";((iMissingCmdCount++))&&:;fi;done
		if((iMissingCmdCount>0));then
			if which dpkg >/dev/null;then
			
				if [[ -f "$strFlScriptDepsPkgs" ]];then
					iMissingPkgsCount=0;IFS=$'\n' read -d '' -r -a astrFlList < <(cat "${strFlScriptDepsPkgs}")&&:;for strFl in "${astrFlList[@]}";do if ! dpkg -s "$strFl" >/dev/null;then CFGFUNCinfo "WARNING: this linux PACKAGE is missing: '$strFl'";((iMissingPkgsCount++))&&:;fi;done
					if((iMissingPkgsCount>0));then
						if ! CFGFUNCprompt -q "WARNING: PROBLEM! There are missing command(s) and package(s) above, continue anyway? But you should install them first if possible. Removing the package from the file '${strFlScriptDepsPkgs}' will prevent this message prompt on next run.";then
							CFGFUNCerrorExit "MissingCmdsPgks"
						fi
					fi
				else
					if ! CFGFUNCprompt -q "WARNING: The file '$strFlScriptDepsPkgs' is missing, so packages dependencies can't be checked, continue anyway?";then
						CFGFUNCerrorExit "MissingDepsFile"
					fi
				fi
				
			fi #if which dpkg >/dev/null;then
		fi #if((iMissingCmdCount>0));then
	else
		if ! CFGFUNCprompt -q "WARNING: The file '$strFlScriptDepsCmds' is missing, so commands dependencies can't be checked, continue anyway?";then
			CFGFUNCerrorExit "MissingDepsFile"
		fi
	fi
  
  if [[ ! -f "${strCfgFlDBToImportOnChildShellFunctions-}" ]];then
    export strCfgFlDBToImportOnChildShellFunctions="`mktemp`" # this contains all arrays marked to export. PUT ALL SUCH ARRAYS BEFORE including/loading this cfg file!
  fi
  strTmp345987623="`export |egrep "[-][aA]x"`"&&:
  if [[ -n "$strTmp345987623" ]];then
    echo "$strTmp345987623" >>"$strCfgFlDBToImportOnChildShellFunctions"
  fi
  
  CFGFUNCtrash "${strCFGErrorLog}"
  
  # these files at astrFlCfgChkFullPathList are to be queried for useful data
  export CFGastrFlCfgChkList=(block item item_modifier)
  export CFGstrFlCfgChkRegex="`echo "${CFGastrFlCfgChkList[@]}" |tr ' ' '|'`"
  export CFGastrFlCfgChkFullPathList=()
  export CFGastrXmlToken1VsFile2List=() # key value
  for _strFlCfgChk in "${CFGastrFlCfgChkList[@]}";do
    _strFlRelatModCfgXml="Config/${_strFlCfgChk}s.xml"
    CFGastrFlCfgChkFullPathList+=("${_strFlRelatModCfgXml}") # this is the xml modlet file on this mod's folder
    CFGastrXmlToken1VsFile2List+=("$_strFlCfgChk" "${_strFlRelatModCfgXml}")
    if [[ -d "$strCFGNewestSavePathConfigsDumpIgnorable" ]];then
      _strFlXmlFinalChk="${strCFGNewestSavePathConfigsDumpIgnorable}/${_strFlCfgChk}s.xml"
      CFGastrFlCfgChkFullPathList+=("$_strFlXmlFinalChk") # this is the xml final dump of the last save
      CFGastrXmlToken1VsFile2List+=("$_strFlCfgChk" "$_strFlXmlFinalChk")
    fi
  done #for strFlCfgChkFullPath in "${astrFlCfgChkFullPathList[@]}";do
  
  
  #export bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes=true
#fi

#!!! no CFGFUNCcleanEchoPRIVATE for params !!!
CFGFUNCechoLogPRIVATE "(LIB)PARAMS: $@"

#if [[ "${1-}" == --help ]];then shift;CFGFUNCshowHelp;fi #help show help info.
#if [[ "${1-}" == --helpfunc ]];then shift;CFGFUNCshowHelp --func;fi #help show function's help info for developers.
#echo " (CFG)Use --help alone to show this script help." >&2

#( #subshell to not create these vars
  bCFGLIBONLYOptgencodeTrashLast=false
  #ps --no-headers -o cmd `ps --no-headers -o ppid $$` $$
  #if ps --no-headers -o cmd `ps --no-headers -o ppid $$` |egrep "\--help";then CFGFUNCshowHelp;fi
  strCFGLIBONLYSelfCmdLine="`ps --no-headers -o cmd $$`" #help this happens if the caller script is sourcing this lib, so is the same pid for both codes
  
  #export bCFGVerboseOutput=false
  # IMPORTANT: these are common params to all scripts sourcing this lib. They can be run with these options below ex.: createBundles\.sh --help
  if echo "$strCFGLIBONLYSelfCmdLine" |egrep -w "\--help";then CFGFUNCshowHelp;fi #help this happens if the caller script is sourcing this lib, so is the same pid for both codes
  if echo "$strCFGLIBONLYSelfCmdLine" |egrep -w "\--helpfunc";then CFGFUNCshowHelp --func;fi #help show function's help info for developers.    
  #if echo "$strCFGLIBONLYSelfCmdLine" |egrep -w "\--verbose";then bCFGVerboseOutput=true;fi #help some times this extra log will be useful
  
  #if echo "$strCFGLIBONLYSelfCmdLine" |egrep -w "\--LIBgencodeTrashLast";then bCFGLIBONLYOptgencodeTrashLast=true;fi #help trash tmp files for code generator
  
  # IMPORTANT: these options will be dected only if passed on the source cmd line inside the script ex.: source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast; if that line contains no parameters, the parameters passed to the script where it was coded will come directly to here, therefore these options must not clash with options there, so prefix them with --LIB !
  while ! ${1+false} && [[ "${1:0:5}" == "--LIB" ]];do
    if [[ "$1" == --LIBgencodeTrashLast ]];then #help trash tmp files for code generator
      bCFGLIBONLYOptgencodeTrashLast=true
      shift #ONLY CONSUME IF IT MATCHES!!!!!!! or it will mess the caller script params collection!
    else
      break #MUST BREAK TO AVOID ENDLESS LOOP!!!!!!
    fi
  done

  export strFlGenLoc="Config/Localization.txt"
  export strFlGenLoa="Config/loadingscreen.xml"
  export strFlGenEnt="Config/entityclasses.xml"
  export strFlGenEve="Config/gameevents.xml"
  export strFlGenRec="Config/recipes.xml"
  export strFlGenXml="Config/items.xml";strFlGenIte="$strFlGenXml" #TODO change everywhere to strFlGenIte
  export strFlGenBuf="Config/buffs.xml"
  export strFlGenBlo="Config/blocks.xml"
  #ps --no-headers -o cmd $$ $PPID;declare -p bCFGLIBONLYOptgencodeTrashLast;read -p oi
  if $bCFGLIBONLYOptgencodeTrashLast;then
    CFGFUNCtrash "${strFlGenLoc}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenLoa}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenEve}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenRec}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenXml}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenBuf}${strGenTmpSuffix}"&&:
    CFGFUNCtrash "${strFlGenBlo}${strGenTmpSuffix}"&&:
  fi
#)

###########################################################################
############################ LAST #########################################
###########################################################################
# keep at the end
###########################################################################
echo -n "" >&2 #this is to prevent error value returned from missing files to be trashed above or anything else irrelevant
