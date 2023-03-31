#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

set -eu

egrep "[#]help" "$0"

strHelpCritical="HELP: the game must be run ONCE w/o this mod for this script be run properly"
echo "$strHelpCritical"

strFl="$1" #help required full path to the ConfigDump of a running game entityclasses.xml file

ls -l "$strFl" #will error exit here if file is missing
#if [[ ! -f "$strFl" ]];then echo "ERROR: missing file '$strFl'"; exit 1;fi

if egrep "PatchNPCHireCost" "$strFl";then echo "$strHelpCritical";exit 1;fi

IFS=$'\n' read -d '' -r -a astrNpcList < <(xmlstarlet sel -t -v "//entity_class[starts-with(@name,'npc')]/@name" "$strFl")&&:
declare -p astrNpcList |tr '[' '\n'

declare -A anHireCost=()
declare -A anPDR=()
declare -A astrExtendsNpc=()

#trap 'declare -p astrNpcList anHireCost anPDR |tr "[" "\n";exit 0' INT
trap 'declare -p anHireCost anPDR |tr "[" "\n";exit 0' INT

function FUNCgetExtendedHireCost() {
  :
}

strFlOut="./Config/entityclasses.xml"
if [[ -f "$strFlOut" ]];then mv -v "$strFlOut" "$strFlOut.$RANDOM.bkp";fi
echo "<GhussakTweaks>" >>"$strFlOut"
nCount=0
for strNpc in "${astrNpcList[@]}";do
  nPDR="`xmlstarlet sel -t -v "//entity_class[@name='${strNpc}']/effect_group/passive_effect[@name='PhysicalDamageResist']/@value" "$strFl" |sort -u |head -n 1`"&&:
  nHirecost="`xmlstarlet sel -t -v "//entity_class[@name='${strNpc}']/property[@name='HireCost']/@value" "$strFl"`"&&:
  strExtendsNpc="`xmlstarlet sel -t -v "//entity_class[@name='${strNpc}']/@extends" "$strFl"`"&&:
  
  if [[ -n "$strExtendsNpc" ]];then
    astrExtendsNpc[${strNpc}]="$strExtendsNpc"
  fi
  
  #if [[ -n "$nHirecost" ]];then 
    #anHireCost[${strNpc}]=$nHirecost;
  #elif [[ -n "$strExtendsNpc" ]];then
    #nHirecost="${anHireCost[${strExtendsNpc}]}"
  #fi
  if [[ -z "$nHirecost" ]] && [[ -n "$strExtendsNpc" ]];then
    nHirecost="${anHireCost[${strExtendsNpc}]-}"
    
    # look for the value on the npc that is extended by strExtendsNpc recursive loop
    strExtendsNpcLoop="${strExtendsNpc}"
    while [[ -z "$nHirecost" ]];do
      strExtendsNpcLoop="${astrExtendsNpc[${strExtendsNpcLoop}]-}"
      if [[ -z "$strExtendsNpcLoop" ]];then break;fi
      echo "RECURSIVE:HireCost:$strExtendsNpcLoop"
      nHirecost="${anHireCost[${strExtendsNpcLoop}]-}"
    done
  fi
  if [[ -n "$nHirecost" ]];then
    anHireCost[${strNpc}]=$nHirecost;
  fi
  
  #if [[ -n "$nPDR" ]];then 
    #anPDR[${strNpc}]=$nPDR;
  #elif [[ -n "$strExtendsNpc" ]];then
    #nPDR="${anPDR[${strExtendsNpc}]}"
  #fi
  if [[ -z "$nPDR" ]] && [[ -n "$strExtendsNpc" ]];then
    nPDR="${anPDR[${strExtendsNpc}]-}"
    
    # look for the value on the npc that is extended by strExtendsNpc recursive loop
    strExtendsNpcLoop="${strExtendsNpc}"
    while [[ -z "$nPDR" ]];do
      strExtendsNpcLoop="${astrExtendsNpc[${strExtendsNpcLoop}]-}"
      if [[ -z "$strExtendsNpcLoop" ]];then break;fi
      echo "RECURSIVE:PDR:$strExtendsNpcLoop"
      nPDR="${anPDR[${strExtendsNpcLoop}]-}"
    done
  fi
  if [[ -n "$nPDR" ]];then
    anPDR[${strNpc}]=$nPDR;
  fi
  
  if [[ -n "$nPDR" ]];then # these considerations may change based on new releases of the NPC's mods and changed to mods affecting them
    # this is based on how much damage they can stand (as they go for melee if foes are too close and become weak when doing that)
    nNewHC="`bc <<< "scale=2;(${nPDR}/100)*${nHirecost}" |cut -d. -f1`"
    
    #this is based on the very lowered NPC's HP value
    ((nNewHC/=4))&&: 
    
    # this is based on how effective NPCs' IA are when using them, also balanced to lethal headshots mod
    nExtraHC=0 
    nPowerWeight=1
    if echo "$strNpc" |egrep -i "ashotgun";then nExtraHC=250;nPowerWeight=80;fi #auto
    if echo "$strNpc" |egrep -i "pshotgun";then nExtraHC=180;nPowerWeight=75;fi #pump
    if echo "$strNpc" |egrep -i "pipeshotgun";then nExtraHC=50;nPowerWeight=10;fi
    if echo "$strNpc" |egrep -i "pistol|rifle|bow";then nExtraHC=50;nPowerWeight=15;fi
    if echo "$strNpc" |egrep -i "ak47|rocket";then nExtraHC=75;nPowerWeight=70;fi
    if echo "$strNpc" |egrep -i "smg|pipemg|m60";then nExtraHC=100;nPowerWeight=75;fi
    ((nNewHC+=nExtraHC))&&:
    
    if((nNewHC<1));then nNewHC=1;fi
    
    echo "  <append xpath=\"/entity_classes/entity_class[@name='${strNpc}']\">" >>"$strFlOut"
    echo "    <property name='HireCost' value='${nNewHC}'/> <!-- PatchNPCHireCost: OldHC=$nHirecost PDR=$nPDR -->" >>"$strFlOut"
    echo "    <triggered_effect trigger='onSelfEnteredGame' action='ModifyCVar' cvar='nNPCPowerWeight' operation='set' value='${nPowerWeight}' />"
    echo "  </append>" >>"$strFlOut"
  #else
    #echo -n ".";
  fi
  ((nCount+=1))&&:
  echo " ($nCount/${#astrNpcList[@]}) ${strNpc}/${strExtendsNpc-} nPDR=${nPDR-} nHirecost=${nHirecost-} nNewHC=${nNewHC-}"
done
echo "</GhussakTweaks>" >>"$strFlOut"
