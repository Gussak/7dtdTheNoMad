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

source ./srcCfgGenericToImport.sh

#TODO read all correct case sensitive things from vanilla xml cfg files and use them here in a loop!

egrep '" *[!]hasbuff *"' * -iRnIw --include="*.xml"
IFS=$'\n' read -d '' -r -a astrFlList < <(egrep '" *[!]hasbuff *"' * -iRnIw --include="*.xml" -c |egrep -v :0 |cut -f1 -d:)&&:
for strFl in "${astrFlList[@]}";do
  trash "${strFl}.${strScriptName}.NEW"
  sed -r -e 's@" *[!]hasbuff *"@"NotHasBuff"@gi' "$strFl" >>"${strFl}.${strScriptName}.NEW"
  echo "WARN: Hit ctrl+c to end meld and stop this script if you do not like the results."
  meld "${strFl}" "${strFl}.${strScriptName}.NEW"
done
exit

if SECFUNCexecA -ce egrep '[!]hasbuff' * -iRnIw --include="*.xml";then
  echoc -p "FilesAbove:wrongly coded NotHasBuff. coding like '!HasBuff' may fail sometimes (like at items.xml GSKTeslaTeleport)"
  bNeedsFixing=true
fi
if SECFUNCexecA -ce egrep 'addbuff' * -iRnIw --include="*.xml" |egrep -wv "AddBuff";then
