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

set -Eeu

set -x
read -p "press a key to: trash old patch"
trash Prefabs ./Prefabs.SkipOnRelease&&:
mkdir -v ./Prefabs.SkipOnRelease

read -p "press a key to: copy all perfabs here"
cp -vr ../../Data/Prefabs/* ./Prefabs.SkipOnRelease
ln -vsf ./Prefabs.SkipOnRelease ./Prefabs

set +x

#########

cd Prefabs

: ${strGroupOldID:="(S_-Group_Generic_Zombie|GroupGenericZombie)"} #help what kind of zombies to replace (this is a regex)

echo "total files: $(egrep "${strGroupOldID}" -iRnIa --include="*.xml" -c |wc -l)"

echo "total files without zombie matches: $(egrep "${strGroupOldID}" -iRnIa --include="*.xml" -c |grep :0 |wc -l)"

read -p "press a key to: remove from patch files prefabs that wont be patched"
IFS=$'#\n' read -d '' -r -a astrList < <(egrep "${strGroupOldID}" -iRnIa --include="*.xml" -c |grep :0)&&:
nCountNotMatched=0
nCountNotMatchedFound=0
nCountNotMatchedNotFound=0
for strFl in "${astrList[@]}";do
	if trash "${strFl%.xml:0}"*;then
		((nCountNotMatchedFound++))&&:
		echo -ne "${nCountNotMatchedFound}:trashed ok: ${strFl}                   \r"
	else
		ls -l "${strFl%.xml:0}"*&&:
		((nCountNotMatchedNotFound++))&&:
		echo "${nCountNotMatchedNotFound}:TODO: failed to trash, why?: ${strFl}               "
	fi
	((nCountNotMatched++))&&:
done
declare -p nCountNotMatchedNotFound nCountNotMatchedFound nCountNotMatched

nCount=$(egrep "$strGroupOldID" -iRnIa --include="*.xml" -c |grep -v :0 |wc -l)
echo "total files with zombie matches: $nCount"

read -p "press a key to: apply the patch on remaining files"
IFS=$'#\n' read -d '' -r -a astrList < <(find ./ -iname "*.xml")&&:
nCountPatched=0
: ${strGroupNewID:="S_-Group_NPC_Bandits_All"} #help all bandits "S_-Group_NPC_Bandits_All" is better than "S_-Group_NPC_Bandits_AmbushRanged", as it spawns NPCs that drop things, but also can be melee or even rocket laucher one, and most importantly, each will call a delayed spawn of an ambush raiders team, increasing the challenge
for strFl in "${astrList[@]}";do
	sed -i.bkp -r -e "s@${strGroupOldID}@${strGroupNewID}@g" "$strFl";
	echo -n .;
	((nCountPatched++))&&:
done
echo

#echo "total files without raider matches: $(egrep "${strGroupNewID}" -iRnIa --include="*.xml" -c |grep :0 |wc -l)"
nCountNew=$(egrep "${strGroupNewID}" -iRnIa --include="*.xml" -c |grep -v :0 |wc -l)
echo "total files with raider matches: $nCountNew"

declare -p nCount nCountNew nCountPatched
if((nCount != nCountNew));then echo "WARNING: something went wrong... ln:$LINENO";fi
if((nCount != nCountPatched));then echo "WARNING: something went wrong... ln:$LINENO";fi

