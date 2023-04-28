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

strFlScriptDepsAll="ScriptsDependenciesAll.AddedToRelease.txt"

if [[ "${1-}" == -e ]];then #help show dependencies for each script individually
  echo -n >"$strFlScriptDepsAll" #CLEAR
  echo "# DO NOT EDIT: this file was auto generated by `basename $0` script" >"$strFlScriptDepsAll"
  echo "# Most scripts depend on libSrcCfgGenericToImport.sh, so you will probably need most of it's deps!" >>"$strFlScriptDepsAll"
  echo "#" >>"$strFlScriptDepsAll"
  find -iname "*.sh" |sort |while read strFound;do $0 "$strFound";done
  exit
fi

strScriptFile="${1-}"
strScriptFile="`basename "$strScriptFile"`"
bOneFile=false;if [[ -f "$strScriptFile" ]];then bOneFile=true;fi

strValidCharsB4Cmds=' (`;|'
strRegex="[${strValidCharsB4Cmds}][a-zA-Z0-9_]{2,} " #between [] are chars that can happen just before a valid command. {2,} means commands must have at least 2 of the previous chars

astrFileFilterList=()
if $bOneFile;then
  strFlResultPkg="./_tmp/${strScriptFile}_ScriptsDependencies_Packages.txt"
  strFlResultCmd="./_tmp/${strScriptFile}_ScriptsDependencies_Commands.txt"
  astrFileFilterList=(
    --include="$strScriptFile"
  )
else
  strFlResultPkg="ScriptsDependencies.AddedToRelease.Packages.txt"
  strFlResultCmd="ScriptsDependencies.AddedToRelease.Commands.txt"
  astrFileFilterList=(
    --include="*.sh"
    --exclude="convAllXcfToPngAndResize.sh" 
    --exclude="prepareForRelease.sh"
    --exclude="modHeadShotsAreLethal.sh"
  )
fi

echo ">>>>> search all possible commands (exclude only specific commands that will probably never be on the scripts like 'see'"
strRegexCommentedLiines="^ *#.*$"
strRegexIgnoreCmds="^(see)$"
IFS=$'\n' read -d '' -r -a astrFlList < <(
  egrep "${strRegex}" * "${astrFileFilterList[@]}" -iRIhow \
    |egrep -v "${strRegexCommentedLiines}" \
    |tr -d "${strValidCharsB4Cmds}" \
    |egrep -v "${strRegexIgnoreCmds}" \
    |sort -u \
)
declare -p astrFlList |tr '[' '\n'
    #|egrep -v "^(if|while|for|which|to|source|trap|image|fi)$" \
    #|sort -u \

echo ">>>>> make sure they are commands pointing to executables"
astrCmdList=();
for str in "${astrFlList[@]}";do 
  if which -a "$str";then 
    astrCmdList+=("`basename "$str"`");
  fi;
done
declare -p astrCmdList |tr '[' '\n'
strCmds="`echo "${astrCmdList[@]}" |tr ' ' '|'`"

echo ">>>>> show one match for each command in the scripts"
astrCmdOkList=()
for strCmd in "${astrCmdList[@]}";do 
  egrep "$strCmd" * -RnI "${astrFileFilterList[@]}" -RInw \
    |egrep -v "#.*${strCmd}" \
    |egrep -v '"[^"`]*'"${strCmd}"'[^"`]*"' \
    |egrep -v "'[^']*${strCmd}[^']*'" \
    |egrep "${strRegex}" \
    |head -n 1 \
    |egrep --color "$strCmd"&&:;nRet=$?
  if((nRet==0));then astrCmdOkList+=("${strCmd}");fi
done #|sort |egrep --color "${strCmds}" -w
#declare -p astrCmdOkList |tr '[' '\n'
echo "${astrCmdOkList[@]}" |tr ' ' '\n' |sort -u >"$strFlResultCmd"

astrPkgList=()
for strCmd in "${astrCmdOkList[@]}";do 
  IFS=$'\n' read -d '' -r -a astrWhichList < <(which -a "$strCmd")&&:
  for strWich in "${astrWhichList[@]}";do
    if strPkg="`dpkg -S "$strWich"`";then
      astrPkgList+=("`echo "$strPkg" |cut -d: -f1`")
      echo "$strPkg"
    fi
  done
done
echo "${astrPkgList[@]}" |tr ' ' '\n' |sort -u >"$strFlResultPkg"

if $bOneFile;then
  echo "#####################################################" >>"$strFlScriptDepsAll"
  echo "# SCRIPT: $strScriptFile" >>"$strFlScriptDepsAll"
  echo "############## Packages:" >>"$strFlScriptDepsAll"
  cat "$strFlResultPkg" >>"$strFlScriptDepsAll"
  echo "############## Commands:" >>"$strFlScriptDepsAll"
  cat "$strFlResultCmd" >>"$strFlScriptDepsAll"
  echo >>"$strFlScriptDepsAll"
fi
