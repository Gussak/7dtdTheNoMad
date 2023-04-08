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

source ./libSrcCfgGenericToImport.sh

strFileFilter="${1-}" #help use this to uninstall specific files only (between quotes) like ex.: "trader_*"

function FUNCunin() {
  local lstrFlOrigBkp="$1"
  CFGFUNCinfo " ====================== Working with: ${lstrFlOrigBkp} ======================"
  local lstrFlDest="${lstrFlOrigBkp%${strCFGOriginalBkpSuffix}}"
  if [[ -f "${lstrFlDest}" ]];then
    CFGFUNCinfo "Uninstalling modded file: ${lstrFlDest}"
    local lstrFlDestTmp="${lstrFlDest}.ThisModFileWillBeSentToTrashBy_${strModNameForIDs}.tmp"
    CFGFUNCexec cp -v "${lstrFlDest}" "$lstrFlDestTmp"
    #CFGFUNCexec rm -v "${lstrFlDest}"
  else
    CFGFUNCinfo "This file should exist: ${lstrFlDest}. No problem tho, restoring the original backup now."
  fi
  CFGFUNCexec cp -vf "${lstrFlOrigBkp}" "${lstrFlDest}"
  #CFGFUNCexec mv -v "${lstrFlOrigBkp}" "${lstrFlDest}"
  CFGFUNCtrash "${lstrFlOrigBkp}" "$lstrFlDestTmp"
};export -f FUNCunin

CFGFUNCinfo "If nothing shows below, it means nothing was found to be uninstalled (reverted to original/pre-existing)."

IFS=$'\n' read -d '' -r -a astrFlList < <(find "${strCFGGameFolder}/"            -iname "${strFileFilter}*${strCFGOriginalBkpSuffix}")&&:
for strFl in "${astrFlList[@]}";do FUNCunin "$strFl";done

IFS=$'\n' read -d '' -r -a astrFlList < <(find "${strCFGGeneratedWorldsFolder}/" -iname "${strFileFilter}*${strCFGOriginalBkpSuffix}")&&:
for strFl in "${astrFlList[@]}";do FUNCunin "$strFl";done

#find "${strCFGGameFolder}/" \
  #-iname "${strFileFilter}*${strCFGOriginalBkpSuffix}" -e xec bash -c 'FUNCunin "{}"' \;
#find "${strCFGGeneratedWorldsFolder}/" \
  #-iname "${strFileFilter}*${strCFGOriginalBkpSuffix}" -e xec bash -c 'FUNCunin "{}"' \;










