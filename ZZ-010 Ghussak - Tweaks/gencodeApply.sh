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

#set -Eeu
#trap 'read -p ERROR_HitAKeyToContinue -n 1' ERR
#trap 'echo WARN_CtrlC_Pressed_ABORTING;exit 1' INT
#if [[ -z "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
source ./libSrcCfgGenericToImport.sh
#fi

#egrep "[#]help" $0

function FUNCerrorExit() {
  read -p "FUNCerrorExit:${strScriptName}: HitAKeyToExit" -n 1
  exit $1
}

strSubTokenId=""
if [[ "${1-}" == "--subTokenId" ]];then #help <strSubTokenId> will be used on the same file to match another section on it
  shift
  strSubTokenId="$1";shift
  if ! [[ "$strSubTokenId" =~ ^[A-Z0-9]*$ ]];then echo "ERROR: invalid strSubTokenId='$strSubTokenId'";fi
  strSubTokenId="_${strSubTokenId}"
fi

#strToken="$1";shift #he lp token marking begin and end lines
strFlPatch="$1";shift #help file containing only the changes section to be updated, only the contents between the begin/end tokens. will be consumed (trashed) after used.
strFlToPatch="$1";shift #help file to be patched
#strComment="$1";shift #he lp 
if ! ls -l "$strFlPatch" "$strFlToPatch";then
  echo "InputFilesMissing.";FUNCerrorExit 1
fi

strCallerScript="`ps --no-header -p $PPID -o cmd |sed -r 's@.* .*/([a-zA-Z0-9]*[.]sh).*@\1@'`"
if [[ ! -f "$strCallerScript" ]];then echo "ERROR: caller should be a script. strCallerScript='$strCallerScript'";FUNCerrorExit 1;fi
strCallerAsTokenID="`echo "${strCallerScript%.sh}" |tr '[:lower:]' '[:upper:]'`"
declare -p strCallerScript

strFileType=""
if [[ "${strFlToPatch}" =~ .*[.]txt$ ]];then
  strFileType=ftTXT
elif [[ "${strFlToPatch}" =~ .*[.]xml$ ]];then
  strFileType=ftXML
else
  echo "Unsupported filetype.";FUNCerrorExit 1
fi

#strCodeTokenBegin="${strToken}_BEGIN"
#strCodeTokenEnd="${strToken}_END"
strCodeTokenBegin="_AUTOGENCODE_${strCallerAsTokenID}${strSubTokenId}_BEGIN"
strCodeTokenEnd="_AUTOGENCODE_${strCallerAsTokenID}${strSubTokenId}_END"
declare -p strCodeTokenBegin strCodeTokenEnd
strMsgDoNotModify="===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: ${strCallerScript} ====="

strMsgErrTokenMiss="token missing, you must place it manually initially (each token must be in a single whole line)!"
strTokenHelperXml="\n<!-- $strCodeTokenBegin -->\n<!-- $strCodeTokenEnd -->"
strTokenHelperTxt="$strCodeTokenBegin,\"\"\n$strCodeTokenEnd,\"\""
#if ! egrep "$strCodeTokenBegin" "$strFlToPatch" -ni;then echo -e "ERROR: begin $strMsgErrTokenMiss${strTokenHelper}";FUNCerrorExit 1;fi
#if ! egrep "$strCodeTokenEnd"   "$strFlToPatch" -ni;then echo -e "ERROR: end   $strMsgErrTokenMiss${strTokenHelper}"  ;FUNCerrorExit 1;fi
if ! egrep "$strCodeTokenBegin" "$strFlToPatch" -ni || ! egrep "$strCodeTokenEnd" "$strFlToPatch" -ni;then
  echo "ERROR: $strMsgErrTokenMiss"
  if [[ "${strFileType}" == ftTXT ]];then
    echo -e "$strTokenHelperTxt"
  elif [[ "${strFileType}" == ftXML ]];then
    echo -e "$strTokenHelperXml"
  fi
  FUNCerrorExit 1
fi

# apply patch (recreated code)
# find begin and end of the patch
nHead="`egrep "${strCodeTokenBegin}" "${strFlToPatch}" -ni |cut -d: -f1`"
nTail="`egrep "${strCodeTokenEnd}"   "${strFlToPatch}" -ni |cut -d: -f1`"
declare -p nHead nTail
# create the new file to check
trash "${strFlToPatch}.GENCODENEWFILE"&&:

# copy before begin token
head -n $((nHead-1)) "${strFlToPatch}" >>"${strFlToPatch}.GENCODENEWFILE";wc -l "${strFlToPatch}.GENCODENEWFILE"
if [[ "${strFileType}" == ftTXT ]];then
  echo "${strCodeTokenBegin},\"BELOW:${strMsgDoNotModify}\"" >>"${strFlToPatch}.GENCODENEWFILE"
elif [[ "${strFileType}" == ftXML ]];then
  echo "<!-- HELPGOOD:${strCodeTokenBegin} BELOW:${strMsgDoNotModify} -->" >>"${strFlToPatch}.GENCODENEWFILE"
else
  echo "Unsupported filetype.";FUNCerrorExit 1
fi
# copy updated sector
wc -l "$strFlPatch"
cat "$strFlPatch" >>"${strFlToPatch}.GENCODENEWFILE";wc -l "${strFlToPatch}.GENCODENEWFILE"
trash "$strFlPatch"
# copy after end token
if [[ "${strFileType}" == ftTXT ]];then
  echo "${strCodeTokenEnd},\"ABOVE:${strMsgDoNotModify}\"" >>"${strFlToPatch}.GENCODENEWFILE"
elif [[ "${strFileType}" == ftXML ]];then
  echo "<!-- HELPGOOD:${strCodeTokenEnd} ABOVE:${strMsgDoNotModify} -->" >>"${strFlToPatch}.GENCODENEWFILE"
else
  echo "Unsupported filetype.";FUNCerrorExit 1
fi

tail -n +$((nTail+1)) "${strFlToPatch}" >>"${strFlToPatch}.GENCODENEWFILE";wc -l "${strFlToPatch}.GENCODENEWFILE"

#declare -p LINENO
if ! cmp "${strFlToPatch}" "${strFlToPatch}.GENCODENEWFILE";then
  : ${bSkipMeld:=false} #help
  if ! $bSkipMeld;then 
    #echo "WARN: hit ctrl+c to abort, closing meld will accept the patch!!! "
    if ! CFGFUNCmeld "${strFlToPatch}" "${strFlToPatch}.GENCODENEWFILE";then
      echo "ERROR: aborted."
      FUNCerrorExit 1
    fi
  fi
  # "overwrite" the old with new file
  #trash "${strFlToPatch}.OLD"&&:
  mv -v "${strFlToPatch}" "${strFlToPatch}.`date +"${strCFGDtFmt}"`.OLD"
  mv -v "${strFlToPatch}.GENCODENEWFILE" "${strFlToPatch}"
  echo "PATCHING expectedly WORKED! now test it!"
else
  echo "WARN: nothing changed"
fi

#trash "$strFlPatch"&&:
