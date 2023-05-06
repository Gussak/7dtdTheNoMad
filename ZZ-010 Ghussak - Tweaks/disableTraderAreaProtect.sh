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

CFGFUNCinfo "Not working well. Trading and quests are more interesting. Skipping..."

exit 0 #TODO: find a way to let trader area be both destructible and have an interactive trader. Trader's quests seem to stop working too? did I config something wrong?

#if ! CFGFUNCprompt -q "This is still not working, patch anyway?";then 
  #exit 0
#fi

IFS=$'\n' read -d '' -r -a astrFlList < <(ls "${strCFGGameFolder}/Data/Prefabs/POIs/trader_"*".xml")&&:
for strFl in "${astrFlList[@]}";do
  #strFlBkp="${strFl}.`date +"${strCFGDtFmt}"`.bkp"
  #strFlBkp="${strFl}${strCFGOriginalBkpSuffix}"
  #cp -v "$strFl" "$strFlBkp"
  CFGFUNCcreateBackup "${strFl}"
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderArea']/@value" -v "False" "$strFl" #TODO ? this would make trader non interactive... even the newly spawned ones using the dll: 
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaProtect']/@value" -v "1,1,1" "$strFl"
  xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaTeleportSize']/@value" -v "1,1,1" "$strFl"
  #xmlstarlet ed -P -L -u "/prefab/property[@name='TraderAreaTeleportCenter']/@value" -v "0,0,0" "$strFl"
  #xmlstarlet ed -P -L -u "/prefab/property[@name='PrefabSize']/@value" -v "1,1,1" "$strFl"
  CFGFUNCdiffFromBkp "$strFl"
done

CFGFUNCinfo "to undo just this patch run: ./uninstallByRestoringOriginalFilesBackups.sh trader_"

CFGFUNCwriteTotalScriptTimeOnSuccess
