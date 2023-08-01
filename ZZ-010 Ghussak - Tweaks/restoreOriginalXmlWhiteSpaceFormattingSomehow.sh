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

source ./libSrcCfgGenericToImport.sh #place exported arrays above this include

echo "WIP: Run this to restore the original whitespaces formatting to make it easier to read"

astrFlList=()

strHint="RestoredWhiteSpaces"

if CFGFUNCprompt -q "work with files from '_ReleasePackageFiles_' (Developer)?";then
  IFS=$'\n' read -d '' -r -a astrFlTmpList < <(ls -1 _ReleasePackageFiles_.IgnoreOnBackup/Mods/*/Config/*.xml |egrep -v "${strHint}")&&: #this is the files before packaging this mod
  astrFlList+=("${astrFlTmpList[@]}")
fi

if CFGFUNCprompt -q "work with files from '../ZZ-... Ghussak - ' (End-User)?";then
  #IFS=$'\n' read -d '' -r -a astrFlTmpList < <(ls -1 ../*/Config/*.xml |egrep -v "${strHint}")&&: #these are the files of the package the end user downloads
  IFS=$'\n' read -d '' -r -a astrFlTmpList < <(ls -1 ../ZZ-*\ Ghussak\ -\ */Config/*.xml |egrep -v "${strHint}")&&: #these are the files of the package the end user downloads
  astrFlList+=("${astrFlTmpList[@]}")
fi

declare -p astrFlList |tr '[' '\n'
if ! CFGFUNCprompt -q "the full list to work with is ok?";then exit;fi

strXmlOpRegex="contains|starts-with|not|@|[]()]";
for strFl in "${astrFlList[@]}";do
  echo "======== WORKING WITH: $strFl"
  : ${bPauseBeforeEachWork:=true} #help
  if $bPauseBeforeEachWork && ! CFGFUNCprompt -q "work with it?";then exit;fi
  mkdir -vp "./_${strHint}/`dirname "$strFl"`"
  sed -r -e 's@xpath="@&@' -e "s'(  +(${strXmlOpRegex}))'\n\1'g" "${strFl}" >"./_${strHint}/${strFl}"
  if cmp -s "${strFl}" "./_${strHint}/${strFl}";then
    trash "./_${strHint}/${strFl}" #keep only changed files
    echo "NOTHING CHANGED."
  else
    echo "meld '`realpath "${strFl}"`' '`realpath "./_${strHint}/${strFl}"`'"
  fi
  echo
done















