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

function FUNCtranslateColor() { #<strColorAtBiomeFile>
  strColorAtBiomeFile="$1";shift
  if [[ "$strColorAtBiomeFile" == "FFFFFFFF" ]];then 
    strBiome="Snow";iBiome=1
  elif [[ "$strColorAtBiomeFile" == "004000FF" ]];then 
    strBiome="PineForest";iBiome=3
  elif [[ "$strColorAtBiomeFile" == "FFE477FF" ]];then 
    strBiome="Desert";iBiome=5
  elif [[ "$strColorAtBiomeFile" == "FFA800FF" ]];then 
    strBiome="Wasteland";iBiome=8
  elif [[ "$strColorAtBiomeFile" == "BA00FFFF" ]];then # does not exist on rgw generated worlds right?
    strBiome="BurntForest";iBiome=9
  else
    CFGFUNCerrorExit "not implemented biome for ${strColorAtBiomeFile}"
  fi
  
  declare -p iBiome strBiome strColorAtBiomeFile #help this return result is meant to be eval
  echo "declare -g iBiome strBiome strColorAtBiomeFile"
}
if [[ "${1-}" == -t ]];then #help <strColorAtBiomeFile> just translate color
  shift
  FUNCtranslateColor "$1"
  exit
fi

######################################################################################################

source ./libSrcCfgGenericToImport.sh #placed here so the code above will run as fast as possible!

strFlPosVsBiomeColorCACHE="`basename "$0"`.PosVsBiomeColor.CACHE.sh" #help if you delete the cache file it will be recreated
declare -A astrPosVsBiomeColor=()
source "${strFlPosVsBiomeColorCACHE}"&&:

bVerbose=false;if [[ "${1-}" == -v ]];then bVerbose=true;shift;fi
bJustWorldData=false;if [[ "${1-}" == "-w" ]];then bJustWorldData=true;shift;fi #help just get the world data

if ! $bJustWorldData;then
  strPosV3="$1";shift #help <strPosV3> ex.: 476,38,-1243 use no spaces as this is a key
fi

strFlBiomes="${strCFGGeneratedWorldTNMFolder}/biomes.png"

strSHA1SUMBiomesFileChk="`cat "$strFlBiomes" |sha1sum`"
bNeedsUpdate=false
if [[ -z "${strSHA1SUMBiomesFile-}" ]] || [[ "$strSHA1SUMBiomesFile" != "$strSHA1SUMBiomesFileChk" ]];then
  #strSHA1SUMBiomesFile="`cat "$strFlBiomes" |sha1sum`"
  bNeedsUpdate=true
fi

#if [[ -z "${nWorldW-}" ]] || [[ -z "${nWorldH}" ]];then
if $bNeedsUpdate;then
  strBiomeFileInfo="`identify "${strFlBiomes}" |egrep " [0-9]*x[0-9]* " -o |tr -d ' ' |tr 'x' ' '`";
  nWorldW="`echo "${strBiomeFileInfo}" |cut -d' ' -f1`";
  nWorldH="`echo "${strBiomeFileInfo}" |cut -d' ' -f2`";
fi
if $bVerbose;then declare -p nWorldW nWorldH >&2;fi
if $bJustWorldData;then #help just get the world data
  declare -p nWorldW nWorldH
  exit
fi

nNewRequested=0
strColorAtBiomeFile="${astrPosVsBiomeColor[${strPosV3}]-}"&&:
if [[ -z "${strColorAtBiomeFile}" ]];then
  iXSP="`echo "${strPosV3}" |cut -d, -f1`"
  iZSP="`echo "${strPosV3}" |cut -d, -f3`"
  strColorAtBiomeFile="`convert "${strCFGGeneratedWorldTNMFolder}/biomes.png" -format '%[hex:u.p{'"$(((nWorldW/2)+iXSP)),$(((nWorldH/2)-iZSP))"'}]' info:-`" #the center of the map is X,Z=0,0. North from center is Z positive in game, but for imagemagick convert, it is inverted because the topleft image picture is the 0,0 origin
  ((nNewRequested++))&&:
fi

FUNCtranslateColor "$strColorAtBiomeFile"

if((nNewRequested>0)) || $bNeedsUpdate;then
  astrPosVsBiomeColor["${strPosV3}"]="${strColorAtBiomeFile}"
  strSHA1SUMBiomesFile="`cat "$strFlBiomes" |sha1sum`"
  
  if $bVerbose;then echo "UPDATING CACHE" >&2;fi
  
  echo "#PREPARE_RELEASE:REVIEWED:OK" >"$strFlPosVsBiomeColorCACHE" #trunc/init
  echo "# this file is auto generated. delete it to be recreated. do not edit!" >>"$strFlPosVsBiomeColorCACHE"
  echo "# avoid unnecessary requests, the bigger this file is the slower it will get" >>"$strFlPosVsBiomeColorCACHE"
  declare -p strSHA1SUMBiomesFile nWorldW nWorldH >>"$strFlPosVsBiomeColorCACHE"
  declare -p astrPosVsBiomeColor >>"$strFlPosVsBiomeColorCACHE" #TODO sha1sum the biome file and if it changes, recreate the array
fi

# this is the returned result 
#echo "strBiomeInfo='$iBiome,$strBiome'" 

#OUTPUT
#declare -p iBiome strBiome strColorAtBiomeFile #help this return result is meant to be eval

exit 0
