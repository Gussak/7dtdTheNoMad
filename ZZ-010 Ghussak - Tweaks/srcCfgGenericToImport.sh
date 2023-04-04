
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

strScriptName="`basename "$0"`";declare -p strScriptName >&2 #do not export this var in case one script calls another

bNoChkErrOnExitPls=false
function FUNCshowHelp() { 
  echo "HELP for ${strScriptName}:" >&2
  egrep "[#]help" $0 -wn >&2 &&:
};export -f FUNCshowHelp
function FUNCerrorChk() {
  if $bNoChkErrOnExitPls;then return;fi
  if(($?!=0));then
    echo "ERROR: the above message may contain the line where the error happened, read below on the help if it is there."
    read -p 'WARN: Hit a key to show the help.' -n 1&&:
    FUNCshowHelp
  fi
};export -f FUNCerrorChk
function FUNCtrash() {
  if [[ -f "${1-}" ]];then trash "$1";fi
};export -f FUNCtrash
echo "Use --help alone to show this script help." >&2
if [[ "${1-}" == --help ]];then FUNCshowHelp;exit 0;fi

if [[ -z "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
  set -Eeu
  
  trap 'read -p "ERROR=$?: Hit a key to continue" -n 1&&:;bNoChkErrOnExitPls=true;exit' ERR
  trap 'echo "Ctrl+c pressed...";exit' INT
  trap 'FUNCerrorChk' EXIT
  
  export strModName="[NoMad]" #as short as possible
  export strModNameForIDs="TheNoMadOverhaul"

  export strFlGenLoc="Config/Localization.txt"
  export strFlGenLoa="Config/loadingscreen.xml"
  export strFlGenEve="Config/gameevents.xml"
  export strFlGenRec="Config/recipes.xml"
  export strFlGenXml="Config/items.xml";strFlGenIte="$strFlGenXml"
  export strFlGenBuf="Config/buffs.xml"

  export strGenTmpSuffix=".GenCode.UpdateSection.TMP"

  FUNCtrash "${strFlGenLoc}${strGenTmpSuffix}"&&:
  FUNCtrash "${strFlGenLoa}${strGenTmpSuffix}"&&:
  FUNCtrash "${strFlGenEve}${strGenTmpSuffix}"&&:
  FUNCtrash "${strFlGenRec}${strGenTmpSuffix}"&&:
  FUNCtrash "${strFlGenXml}${strGenTmpSuffix}"&&:
  FUNCtrash "${strFlGenBuf}${strGenTmpSuffix}"&&:

  export bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes=true
fi

# keep at the end
echo -n "" #this is to prevent error value returned from missing files to be trashed above or anything else irrelevant
