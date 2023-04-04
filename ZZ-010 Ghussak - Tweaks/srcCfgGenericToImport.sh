
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

#this is a config file

#PREPARE_RELEASE:REVIEWED:OK

#: ${strScriptNameList:=""};if [[ -n "${strScriptName-}" ]];then strScriptNameList+="$strScriptName";fi
export strScriptParentList;if [[ -n "${strScriptName-}" ]];then strScriptParentList+=", ($$)$strScriptName";fi
export strScriptName="`basename "$0"`";declare -p strScriptName >&2 #MUST OVERWRITE (HERE) FOR EVERY SCRIPT CALLED FROM ANOTHER. but must also be exported to work on each script functions called from `find -exec bash`

bNoChkErrOnExitPls=false
function CFGFUNCshowHelp() { 
  echo "(CFG)HELP for ${strScriptName}:" >&2
  egrep "[#]help" $0 -wn >&2 &&:
};export -f CFGFUNCshowHelp
function CFGFUNCerrorChk() {
  if $bNoChkErrOnExitPls;then return;fi
  if(($?!=0));then
    echo "(CFG)ERROR: the above message may contain the line where the error happened, read below on the help if it is there."
    read -p '(CFG)WARN: Hit a key to show the help.' -n 1&&:
    CFGFUNCshowHelp
  fi
};export -f CFGFUNCerrorChk
function CFGFUNCtrash() {
  if [[ -f "${1-}" ]];then 
    echo "(CFG)TRASHING: $1" >&2
    trash "$1";
  fi
};export -f CFGFUNCtrash
function CFGFUNCmeld() { 
  local lbSIGINTonMeld=false
  trap 'lbSIGINTonMeld=true' INT
  echo "(CFG)WARN: hit ctrl+c to abort, closing meld will accept the patch!!!" >&2
  meld "$@"&&:;local lnRet=$?
  if((lnRet!=0));then #help (USELESS) meld gives the same exit value 0 if you hit ctrl+c, this wont help
    echo "(CFG)ERROR=$lnRet: meld $@" >&2
    return 1;
  fi
  if $lbSIGINTonMeld;then
    echo "(CFG)WARN: Ctrl+c pressed while running: meld $@" >&2
    return 1;
  fi
  echo "(CFG)AcceptingChanges: meld $@" >&2
  return 0
};export -f CFGFUNCmeld

echo "(CFG)PARAMS: $@"
#if [[ "${1-}" == --help ]];then shift;CFGFUNCshowHelp;fi #help
#echo "(CFG)Use --help alone to show this script help." >&2

ps -o ppid,pid,cmd
declare -p strScriptName strScriptParentList
#if [[ -n "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
  #ps -o ppid,pid,cmd
  ##pstree -p $$
  #echo "(CFG)WARNING: calling this script '${strScriptName}' (strScriptParentList='$strScriptParentList') that also uses the CFG file!!!" >&2
  ##echo "(CFG)ERROR: if calling another script that also uses the CFG file, it must be called in a subshell!" >&2
  ##exit 1
#fi

#if [[ -z "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
  set -Eeu
  
  trap 'read -p "(CFG)TRAP:ERROR=$?: Hit a key to continue" -n 1&&:;bNoChkErrOnExitPls=true;exit' ERR
  trap 'echo "(CFG)TRAP:WARN:Ctrl+c pressed...";exit' INT
  trap 'CFGFUNCerrorChk' EXIT
  
  export strModName="[NoMad]" #as short as possible
  export strModNameForIDs="TheNoMadOverhaul"

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
  
  if [[ ! -f "${strCfgFlDBToImportOnChildShellFunctions-}" ]];then
    export strCfgFlDBToImportOnChildShellFunctions="`mktemp`" #help this contains all arrays marked to export. PUT ALL SUCH ARRAYS BEFORE including/loading this cfg file!
  fi
  strTmp345987623="`export |egrep "[-][aA]x"`"&&:
  if [[ -n "$strTmp345987623" ]];then
    echo "$strTmp345987623" >>"$strCfgFlDBToImportOnChildShellFunctions"
  fi
  
  #export bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes=true
#fi

# keep at the end
echo -n "" >&2 #this is to prevent error value returned from missing files to be trashed above or anything else irrelevant
