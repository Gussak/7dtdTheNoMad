#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#set -e # the xmlstarlet entitygroup collect line is returning 1 and I have no idea why I cant determine the problem :( so keep this commented for now :(
set -u

egrep "[#]help" $0
echo

if [[ "$1" == "--help" ]];then #help but using no param will error and also show the help
  shift&&:
  exit 0
fi

bChkNotAppliedAlready=true
bConfirmIfPatchWasFullyApplied=false
if [[ "$1" == "--chk" ]];then #help bConfirmIfPatchWasFullyApplied
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
strFlLastSavegameEntitygroupsXmlFile="$1" #help
if [[ ! -f "$strFlLastSavegameEntitygroupsXmlFile" ]];then
  echo "ERROR: missing file param. requires the game to be started once w/o this patch, and '.../ConfigsDump/entitygroups.xml' passed here as a parameter, to collect the entity groups ids"
  exit 1
fi
strModNameAtXmlFile="Gussak - Patch lower NPC spawn rate" #TODO collect from that file thru xmlstarlet
if $bChkNotAppliedAlready && egrep "replaced by: \"${strModNameAtXmlFile}" "$strFlLastSavegameEntitygroupsXmlFile";then
  echo "ERROR: requires the game to be started w/o this patch to collect vanilla npc prob values!!! To do that, ModInfo.xml needs to be renamed to .DISABLED.ModInfo.xml temporarily!"
  ls -l ModInfo.xml*
  if [[ -f ModInfo.xml ]];then
    read -p "hit enter to disable this mod now (ctrl+c to cancel)"
    mv -v ModInfo.xml .DISABLED.ModInfo.xml
  fi
  exit 1
fi
if $bConfirmIfPatchWasFullyApplied;then
  strChkOutput="`egrep 'name="(npc|Raider|survivor).*prob' -i "$strFlLastSavegameEntitygroupsXmlFile" |grep -v Gussak |egrep 'npc[^"]*' -o |sort -u`"
  echo "$strChkOutput"
  if [[ -n "$strChkOutput" ]];then
    echo "$strChkOutput" |wc -l
    echo "PROBLEM: the above entities were not patched..."
  fi
  exit 1
fi
#IFS=$'\n' read -d '' -r -a astrEntitygroupList < <(FUNCexec xmlstarlet sel -t -v "//entitygroup/@name" "$strFlLastSavegameEntitygroupsXmlFile")
IFS=$'\n' read -d '' -r -a astrEntitygroupList < <(FUNCexec xmlstarlet sel -t -v "/entitygroups/entitygroup/entity[${strXmlCondition}]/../@name" "$strFlLastSavegameEntitygroupsXmlFile" |sort -u)
if((${#astrEntitygroupList[@]}==0));then echo "ERROR: astrEntitygroupList is empty";exit 1;fi
declare -p astrEntitygroupList |tr '[' '\n'
#exit 1 #TODO comment THIS LINE

# find mods that add friendly NPCs
IFS=$'\n' read -d '' -r -a astrFlList < <(
  FUNCexec egrep "whiteriver|bandits" --include="entityclasses.xml" ../* -irnI -c \
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
: ${strFlModlet:="./Config/entitygroups.xml"} #help change this to create variants
mkdir -vp ./Config
trash "${strFlModlet}"&&:
#trash -v "${strFlModlet}.TMP."* &&:
trash -v $(ls "${strFlModlet}.TMP."* |grep -v "[.]DONE$")&&: #ls creates a valid list as filenames have no spaces
echo "<GhussakTweaks>" >>"${strFlModlet}"
: ${nDiv:=50} #help change by how much default will be divided
: ${nTotCores:=$(grep "core id" /proc/cpuinfo |wc -l)} #help force 1 to prevent multithreading
nCount=0
nActiveThreads=0
SECONDS=0
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
      fNewVal="`bc <<< "scale=6;${fVal}/${nDiv}"`"
      echo "  <set xpath=\"/entitygroups/entitygroup[@name='${strEntityGroup}']/entity[@name='${strNpcId}']/@prob\">${fNewVal}</set> <!-- was $fVal -->" >>"${strFlModlet}.TMP.${strEntityGroup}"
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

for strEntityGroup in "${astrEntitygroupList[@]}";do
  ((nCount++))&&:
  if((nTotCores>1));then
    FUNCchkError
    FUNCthreadWork&
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
while((`FUNCgetActiveThreadsCount`>0));do 
  read -p "<> <> <> <> <> WAITING ALL THREADS FINISH, press 'y' to force finish. <> <> <> <> <> " -t 1 -n 1 strResp;
  if [[ "$strResp" == y ]];then break;fi;
  sleep 1;
done
FUNCchkError
cat "${strFlModlet}.TMP."* >>"${strFlModlet}"
echo '
  <insertAfter xpath="/entitygroups/entitygroup[@name='"'"'SnowZombies'"'"']/entity[@name='"'"'zombieLumberjack'"'"']">
    <!-- HELP: there are too many friendly npcs on snow biome. may be it is because on other biomes there are about 20 other zombies probabilities? so, lets try this, if it is a list (not a specific entity cfg) this may help. Worked!!! -->
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

FUNCchkError
if [[ -f ModInfo.xml ]];then
  read -p "hit enter to disable this mod now (ctrl+c to cancel)"
  mv -v ModInfo.xml .DISABLED.ModInfo.xml
fi

declare -p SECONDS
echo "processing time: $((SECONDS/60))m$((SECONDS%60))s"

if [[ -f .DISABLED.ModInfo.xml ]];then
  read -p "hit enter to re-enable this mod now (ctrl+c to cancel)"
  mv -v .DISABLED.ModInfo.xml ModInfo.xml 
fi

read -p "DELETE TMP FILES? (y/...)" strResp;if [[ "$strResp" == y ]];then trash -v "${strFlModlet}.TMP."*;fi;

echo "geany ${strFlModlet}"
