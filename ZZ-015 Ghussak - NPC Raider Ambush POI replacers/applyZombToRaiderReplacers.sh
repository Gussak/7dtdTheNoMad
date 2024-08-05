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

trash -v Prefabs

mkdir -v ./Prefabs.SkipOnRelease
cp -vr ../../Data/Prefabs/* ./Prefabs.SkipOnRelease
ln -vsf ./Prefabs.SkipOnRelease ./Prefabs

echo "total files: $(egrep "S_-Group_Generic_Zombie" -iRnIa --include="*.xml" -c |wc -l)"

echo "total files without zombie matches: $(egrep "S_-Group_Generic_Zombie" -iRnIa --include="*.xml" -c |grep :0 |wc -l)"
echo "total files with zombie matches: $(egrep "S_-Group_Generic_Zombie" -iRnIa --include="*.xml" -c |grep -v :0 |wc -l)"

find ./Prefabs/ -iname "*.xml" |\
	while read strFl;do
		sed -i.bkp 's@S_-Group_Generic_Zombie@S_-Group_NPC_Bandits_AmbushRanged@g' "$strFl";
		echo -n .;
	done

echo "total files without raider matches: $(egrep "S_-Group_NPC_Bandits_AmbushRanged" -iRnIa --include="*.xml" -c |grep :0 |wc -l)"
echo "total files with raider matches: $(egrep "S_-Group_NPC_Bandits_AmbushRanged" -iRnIa --include="*.xml" -c |grep -v :0 |wc -l)"

