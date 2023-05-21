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

#set -e # the xmlstarlet entitygroup collect line is returning 1 and I have no idea why I cant determine the problem :( so keep this commented for now :(
#set -u

source ./libSrcCfgGenericToImport.sh

egrep "[#]help" $0
echo

: ${strFlModlet:="./Config/entitygroups.xml"} #help change this to create variants
#: ${strFlModletOld:="${strFlModlet}.`date +"${strCFGDtFmt}"`.OLD"}
strFlModletOld="${strFlModlet}.`date +"${strCFGDtFmt}"`.OLD"

if [[ "${1-}" == "--help" ]];then #help but using no param will error and also show the help
  shift&&:
  exit 0
fi

bChkNotAppliedAlready=true
bConfirmIfPatchWasFullyApplied=false
if [[ "${1-}" == "--chk" ]];then #help bConfirmIfPatchWasFullyApplied
  bConfirmIfPatchWasFullyApplied=true
  bChkNotAppliedAlready=false
  shift&&:
fi

FUNCexec() { 
  echo >&2
  echo "EXEC: $@" >&2;
  if ! "$@";then
    local nRet=$?
    echo "EXEC-ERROR: $nRet; $@" >&2
    exit 1
  fi
  echo "EXEC:DONE" >&2;
  return 0
};export -f FUNCexec

strXmlCondition="starts-with(@name, 'npc') or starts-with(@name, 'Raider') or starts-with(@name, 'survivor')"

# CHECK FOR PARAMETER
strFlLastSavegameEntitygroupsXmlFile="${1-}" #help
if [[ -z "$strFlLastSavegameEntitygroupsXmlFile" ]];then
  strFlLastSavegameEntitygroupsXmlFile="${strCFGNewestSavePathConfigsDumpIgnorable}/entitygroups.xml"
fi
declare -p strFlLastSavegameEntitygroupsXmlFile
if ! CFGFUNCprompt -q "Is the above correct?";then CFGFUNCerrorExit;fi

strTokenPatchApplied="PATCH_IS_APPLYED_${strCFGScriptNameAsID}"

if [[ ! -f "$strFlLastSavegameEntitygroupsXmlFile" ]];then
  CFGFUNCerrorExit "ERROR: missing file param. requires the game to be started once w/o this patch, and '.../ConfigsDump/entitygroups.xml' passed here as a parameter, to collect the entity groups ids"
fi

if ! strModNameAtXmlFile="`xmlstarlet sel -t -v "//Name/@value" ./ModInfo.xml`";then
  if ! strModNameAtXmlFile="`xmlstarlet sel -t -v "//Name/@value" ./.DISABLED.ModInfo.xml`";then
    CFGFUNCerrorExit "unable to locate .DISABLED.ModInfo.xml nor ModInfo.xml"
  fi
fi
#while $bChkNotAppliedAlready && egrep "replaced by: \"${strModNameAtXmlFile}" "$strFlLastSavegameEntitygroupsXmlFile";do
while $bChkNotAppliedAlready && egrep "${strModNameAtXmlFile}" "$strFlLastSavegameEntitygroupsXmlFile";do
  #if egrep "${strTokenPatchApplied}" "$strFlLastSavegameEntitygroupsXmlFile";then
    #CFGFUNCerrorExit "patch already applied"
  #fi
  ls -l "$strFlLastSavegameEntitygroupsXmlFile"
  CFGFUNCinfo "ERROR: requires the game to be started w/o this patch to collect vanilla npc prob values!!! To do that, ModInfo.xml needs to be renamed to .DISABLED.ModInfo.xml temporarily!"
  ls -l ModInfo.xml .DISABLED.ModInfo.xml "$strFlModlet" "${strFlModlet}.DISABLED.xml"&&:
  if ! ps -o comm -A |egrep "^7DaysToDie[.]exe$";then
    if [[ -f ModInfo.xml ]];then
      CFGFUNCprompt "hit enter to disable this mod now before running the game"
      CFGFUNCexec mv -v ModInfo.xml .DISABLED.ModInfo.xml
    fi
  else
    if [[ -f "${strFlModlet}" ]];then
      if CFGFUNCprompt -q "disable the existing config file now as the game is still running?";then
        #strFlModletOld="${strFlModlet}.DISABLED.xml"
        CFGFUNCexec mv -v "${strFlModlet}" "$strFlModletOld"
        CFGFUNCprompt "exit the game to the main menu now"
      fi
    fi
  fi
  
  CFGFUNCprompt "Now, start (or load) the game and pause it after you spawn. Then come here and hit Enter."
done

if $bConfirmIfPatchWasFullyApplied;then
  strChkOutput="`egrep 'name="(npc|Raider|survivor).*prob' -i "$strFlLastSavegameEntitygroupsXmlFile" |grep -v "$strModNameAtXmlFile" |egrep 'npc[^"]*' -o |sort -u`"
  echo "$strChkOutput"
  if [[ -n "$strChkOutput" ]];then
    echo "$strChkOutput" |wc -l
    CFGFUNCerrorExit "PROBLEM: the above entities were not patched..."
  fi
  CFGFUNCinfo "SUCCESS!"
  exit
fi

#IFS=$'\n' read -d '' -r -a astrEntitygroupList < <(CFGFUNCexec xmlstarlet sel -t -v "//entitygroup/@name" "$strFlLastSavegameEntitygroupsXmlFile")
IFS=$'\n' read -d '' -r -a astrEntitygroupList < <(CFGFUNCexec xmlstarlet sel -t -v "/entitygroups/entitygroup/entity[${strXmlCondition}]/../@name" "$strFlLastSavegameEntitygroupsXmlFile" |sort -u)&&:
if((${#astrEntitygroupList[@]}==0));then echo "ERROR: astrEntitygroupList is empty";exit 1;fi
declare -p astrEntitygroupList |tr '[' '\n'
#exit 1 #TODO comment THIS LINE

# find mods that add friendly NPCs
IFS=$'\n' read -d '' -r -a astrFlList < <(
  CFGFUNCexec egrep "whiteriver|bandits" --include="entityclasses.xml" ../* -irnI -c \
    |egrep -v ":0" \
    |sed -r 's"entityclasses.xml.*"entityclasses.xml"' # just removes the trailing ":123" count info
)&&:
if((${#astrFlList[@]}==0));then echo "ERROR: astrFlList is empty";exit 1;fi
declare -p astrFlList |tr '[' '\n'
#exit 1 #TODO comment THIS LINE

# find npcs ids
astrNpcIdList=()
for strFl in "${astrFlList[@]}";do
  declare -p strFl
  IFS=$'\n' read -d '' -r -a astrTmp < <(xmlstarlet sel -t -v "//append[@xpath='/entity_classes']/entity_class[${strXmlCondition}]/@name" "$strFl" |sort)&&:
  astrNpcIdList+=("${astrTmp[@]}")
done
if((${#astrNpcIdList[@]}==0));then echo "ERROR: astrNpcIdList is empty";exit 1;fi
declare -p astrNpcIdList |tr '[' '\n'
#exit 1 #TODO comment THIS LINE

if egrep "^exit 1 #TODO comment THIS LINE" $0;then
  echo "CRITICAL: fix this script, comment the exit 1 lines requiring to be commented, they are just for bug track"
  exit 1
fi

# CREATE THE MODLET
mkdir -vp ./Config
#trash "${strFlModlet}"&&:
CFGFUNCexec --noErrorExit mv -v "${strFlModlet}" "$strFlModletOld"&&:
#trash -v "${strFlModlet}.TMP."* &&:
CFGFUNCtrash $(ls "${strFlModlet}.TMP."* |grep -v "[.]DONE$")&&: #trashes all incomplete files. ls creates a valid list as filenames have no spaces
echo "<GhussakTweaks>" >>"${strFlModlet}"
: ${nDiv:=50} #help change by how much default will be divided
: ${nTotCores:=$(grep "core id" /proc/cpuinfo |wc -l)} #help force 1 to prevent multithreading
nCount=0
nActiveThreads=0
SECONDS=0

if ls -l "${strFlModlet}.TMP."*".DONE";then
  if CFGFUNCprompt -q "Trash the above cached files (just hit Enter to re-use them)";then
    CFGFUNCtrash "${strFlModlet}.TMP."*".DONE"
  fi
fi

function FUNCnpcIdExists() { #<lstrNpcId>
  local lstrNpcId="$1"
  #IFS=$'\n' read -d '' -r -a astrExistingNpcIdList < <(xmlstarlet sel -t -v "/entitygroups/entitygroup[@name='${strEntityGroup}']/entity[${strXmlCondition}]/@name" "$strFlLastSavegameEntitygroupsXmlFile")&&:
  #local lbIgnoreNpcId=true
  for strExistingNpcId in "${astrExistingNpcIdList[@]}";do
    #if [[ "$strExistingNpcId" == "$lstrNpcId" ]];then lbIgnoreNpcId=false;break;fi
    if [[ "$strExistingNpcId" == "$lstrNpcId" ]];then return 0;fi
  done
  #if $lbIgnoreNpcId;then break;fi
  return 1
}
function FUNCappendError() { #<strErrorMsg>
  echo "$1" |tee -a "${strFlModlet}.TMP.ERRORED"
}
function FUNCthreadWork() {
  if [[ -f "${strFlModlet}.TMP.${strEntityGroup}.DONE" ]];then 
    echo "SKIPPING ALREADY PROCESSED: ${strFlModlet}.TMP.${strEntityGroup}.DONE";
    return 0;
  fi

  IFS=$'\n' read -d '' -r -a astrExistingNpcIdList < <(xmlstarlet sel -t -v "/entitygroups/entitygroup[@name='${strEntityGroup}']/entity[${strXmlCondition}]/@name" "$strFlLastSavegameEntitygroupsXmlFile")&&:

  for strNpcId in "${astrNpcIdList[@]}";do
    if ! FUNCnpcIdExists "$strNpcId";then continue;fi
    
    strXpath="/entitygroups/entitygroup[@name='${strEntityGroup}']/entity[@name='${strNpcId}']/@prob"
    fVal="$(xmlstarlet sel -t -v "$strXpath" "$strFlLastSavegameEntitygroupsXmlFile" |tail -n 1)"&&: #on xml, the last entry wins, so use that
    if [[ -n "$fVal" ]];then
      #if((`echo "$fVal" |wc -l`!=1));then 
        #FUNCappendError "ERROR: should return 1 result but returned '$fVal'. strXpath='$strXpath' strEntityGroup='$strEntityGroup' strNpcId='$strNpcId'"
        #exit 1;
      #fi
      #fNewVal="`bc <<< "scale=6;${fVal}/${nDiv}"`"
      fNewVal="`bc <<< "scale=6;${fVal}/${nDiv}"`";
      : ${fMinNewVal=0.0001} #help
      #declare -p fNewVal;
      strFix=""
      if((`bc <<< "${fNewVal}<${fMinNewVal}"`==1));then
        #echo FixTooSmall;
        strFix=", FixNew(${fNewVal})GotTooSmall"
        fNewVal=${fMinNewVal}
      fi;
      #declare -p fNewVal
      echo "  <set xpath=\"/entitygroups/entitygroup[@name='${strEntityGroup}']/entity[@name='${strNpcId}']/@prob\">${fNewVal}</set> <!-- was ${fVal}${strFix} -->" >>"${strFlModlet}.TMP.${strEntityGroup}"
      echo "($nCount/${#astrEntitygroupList[@]})OK: $strEntityGroup/$strNpcId $fVal $fNewVal"
    else
      echo -n . # skips if empty fVal
    fi
  done
  mv -v "${strFlModlet}.TMP.${strEntityGroup}" "${strFlModlet}.TMP.${strEntityGroup}.DONE"
}

function FUNCgetActiveThreadsCount() { cd /proc;ls -1d "${anTPidList[@]}" 2>/dev/null |wc -l; }
anTPidList=()

function FUNCchkError() {
  if [[ -f "${strFlModlet}.TMP.ERRORED" ]];then
    cat "${strFlModlet}.TMP.ERRORED"
    echo "ERROR: some error happened above."
    exit 1
  fi
}

# THIS LOOP SPAWN THE THREADS!!!
for strEntityGroup in "${astrEntitygroupList[@]}";do
  ((nCount++))&&:
  if((nTotCores>1));then
    FUNCchkError
    FUNCthreadWork& #NEW THREAD!!!
    nTPid=$!
    anTPidList+=($nTPid)
    while true;do
      if(( `FUNCgetActiveThreadsCount`<(nTotCores-1) ));then
        #wait -f "${anTPidList[@]}"
        break
      fi
      sleep 1
    done
  else
    FUNCthreadWork
  fi
done
FUNCchkError
#while((`FUNCgetActiveThreadsCount`==0));do CFGFUNCinfo "Waiting the threads start...";sleep 1;done
#FUNCchkError
while true;do #this loop is just to wait the remaining final threads to end. The above loop was already trying to keep most threads possible in use.
  nTCount=`FUNCgetActiveThreadsCount`
  if((nTCount==0));then break;fi
  CFGFUNCinfo "<> <> <> <> <> WAITING ALL THREADS ($nTCount) TO FINISH <> <> <> <> <> "
  sleep 1;
done
FUNCchkError
cat "${strFlModlet}.TMP."*".DONE" >>"${strFlModlet}"

strTokenPatchApplied="PATCH_IS_APPLYED_${strCFGScriptNameAsID}"
echo '
  <insertAfter xpath="/entitygroups/entitygroup[@name='"'"'SnowZombies'"'"']/entity[@name='"'"'zombieLumberjack'"'"']">
    <!-- HELPGOOD: '"${strTokenPatchApplied}"' -->
    <!-- HELPGOOD: there are too many friendly npcs on snow biome. may be it is because on other biomes there are about 20 other zombies probabilities? so, lets try this, if it is a list (not a specific entity cfg) this may help. Result: Worked!!! -->
    <entity name="zombieLumberjack" prob="0.99" />
    <entity name="zombieLumberjack" prob="0.98" />
    <entity name="zombieLumberjack" prob="0.97" />
    <entity name="zombieLumberjack" prob="0.96" />
    <entity name="zombieLumberjack" prob="0.95" />
    <entity name="zombieLumberjack" prob="0.94" />
    <entity name="zombieLumberjack" prob="0.93" />
    <entity name="zombieLumberjack" prob="0.92" />
    <entity name="zombieLumberjack" prob="0.91" />
    <entity name="zombieLumberjack" prob="0.90" />
    <entity name="zombieLumberjack" prob="0.89" />
    <entity name="zombieLumberjack" prob="0.88" />
    <entity name="zombieLumberjack" prob="0.87" />
    <entity name="zombieLumberjack" prob="0.86" />
    <entity name="zombieLumberjack" prob="0.85" />
    <entity name="zombieLumberjack" prob="0.84" />
    <entity name="zombieLumberjack" prob="0.83" />
    <entity name="zombieLumberjack" prob="0.82" />
    <entity name="zombieLumberjack" prob="0.81" />
    <entity name="zombieLumberjack" prob="0.80" />
    <entity name="zombieLumberjack" prob="0.79" />
    <entity name="zombieLumberjack" prob="0.78" />
    <entity name="zombieLumberjack" prob="0.77" />
    <entity name="zombieLumberjack" prob="0.76" />
    <entity name="zombieLumberjack" prob="0.75" />
    <entity name="zombieLumberjack" prob="0.74" />
    <entity name="zombieLumberjack" prob="0.73" />
    <entity name="zombieLumberjack" prob="0.72" />
    <entity name="zombieLumberjack" prob="0.71" />
  </insertAfter>
' >>"${strFlModlet}"
echo "</GhussakTweaks>" >>"${strFlModlet}"

CFGFUNCwriteTotalScriptTimeOnSuccess

FUNCchkError
#if [[ -f ModInfo.xml ]];then
  #CFGFUNCprompt "hit enter to disable this mod now (ctrl+c to cancel)"
  #CFGFUNCexec mv -v ModInfo.xml .DISABLED.ModInfo.xml
#fi

declare -p SECONDS
echo "processing time: $((SECONDS/60))m$((SECONDS%60))s"

if [[ -f .DISABLED.ModInfo.xml ]];then
  CFGFUNCprompt "hit enter to re-enable this mod now (ctrl+c to cancel)"
  CFGFUNCexec mv -v .DISABLED.ModInfo.xml ModInfo.xml
fi

if CFGFUNCprompt -q "DELETE TMP FILES (if not, they will be reused as cache on the next run)?";then trash -v "${strFlModlet}.TMP."*;fi;

#echo "geany ${strFlModlet}"
CFGFUNCmeld "${strFlModlet}" "$strFlModletOld"
