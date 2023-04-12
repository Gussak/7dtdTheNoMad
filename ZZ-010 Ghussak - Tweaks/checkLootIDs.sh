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

#: ${strCFGSavesPath:="$WINEPREFIX/drive_c/users/$USER/Application Data/7DaysToDie/Saves/East Nikazohi Territory/"} #help
#: ${strCFGNewestSavePath:="${strCFGSavesPath}/`ls -1tr "$strCFGSavesPath" |tail -n 1`"} #help
declare -p strCFGNewestSavePathConfigsDumpIgnorable
IFS=$'\n' read -d '' -r -a aiIdList < <(egrep 'id="[0-9]*"' "${strCFGNewestSavePathConfigsDumpIgnorable}/loot.xml" -o |egrep "[0-9]*" -o|sort -n)&&:
declare -p aiIdList

iIdMax=1023
iDupCount=0
iIdPrev=-1
astrDups=()
for iId in "${aiIdList[@]}";do
  if((iIdPrev==iId));then
    echo "DUP FOUND: $iId" >&2
    astrDups+=($iId)
    ((iDupCount++))&&:
  fi
  iIdPrev=$iId
done

for((iId=0;iId<=iIdMax;iId++));do
  bFound=false
  for iIdUsed in "${aiIdList[@]}";do
    if((iId==iIdUsed));then bFound=true;break;fi
  done
  if $bFound;then
    echo "USED ID: $iId" >&2;
  else
    echo "Free ID: $iId" >&2;
  fi
done

echo -n "Free ID ranges: "
bFoundPrev=false
for((iId=0;iId<=iIdMax;iId++));do
  bFound=false
  for iIdUsed in "${aiIdList[@]}";do
    if((iId==iIdUsed));then bFound=true;break;fi
  done
  if $bFound;then
    if ! $bFoundPrev;then
      echo -n "$((iId-1)), "
    fi
    bFoundPrev=true
  else
    if((iId==iIdMax));then
      echo -n "$iIdMax"
      break
    fi
    if $bFoundPrev;then
      echo -n "$iId to " >&2;
    fi
    bFoundPrev=false
  fi
done
echo

#iIdRangeBegin=0
#iIdRangeEnd=0
#for((iId=0;iId<=iIdMax;iId++));do
  #bFound=false
  #for iIdUsed in "${aiIdList[@]}";do
    #if((iId==iIdUsed));then bFound=true;break;fi
  #done
  #if $bFound;then
    #iIdRangeBegin=$iId
    #iIdRangeEnd=$iIdRangeBegin
    #echo "USED ID: $iId ($iIdRangeBegin..$iIdRangeEnd)" >&2;
  #else
    #iIdRangeBegin=$iId
    #((iIdRangeEnd++))&&:
    #echo "Free ID: $iId ($iIdRangeBegin..$iIdRangeEnd)" >&2;
  #fi
#done

if((iDupCount>0));then
  echo "DUPS: ${astrDups[@]}"
  echo "ERROR: duplicated loot IDs above clashed, fix it!!!" >&2
  exit 1
fi
exit 0

#iIdChk=0
#iIdMax=1023
#iDupCount=0
#iIdPrev=-1
#for iId in "${aiIdList[@]}";do
  #while((iIdChk!=iId));do
    #echo "Free ID: $iIdChk" >&2
    #((iIdChk++))&&:
  #done
  #if((iIdPrev==iId));then
    #echo "DUP FOUND: $iId" >&2
    #((iDupCount++))&&:
  #fi
  #iIdPrev=$iId
#done
#if((iDupCount>0));then
  #echo "ERROR: loot IDs above clashed, fix it!!!" >&2
  #exit 1
#fi
#exit 0
