#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

set -eu

# binary patching on linux
egrep "[#]help" $0

: ${strPath:="../../"} #help

# this makes crouch height 1 block (0.50 or 0.40 is a bit better)
: ${bCrouchHeight:=false} #help bCrouchHeight=true
if $bCrouchHeight;then
  strFl="${strPath}/7DaysToDie_Data/resources.assets"
  nSz=$(stat -c "%s" "$strFl")
  cp -v "${strFl}" "${strFl}.${RANDOM}_BKP"
  egrep "PhysicsCrouchHeightModifier....." "${strFl}" -ao
  sed -i -r "s'(PhysicsCrouchHeightModifier)(.)(....)'\1\20.40'g" "${strFl}"
  egrep "PhysicsCrouchHeightModifier....." "${strFl}" -ao
  if(( nSz != $(stat -c "%s" "$strFl") ));then echo "ERROR, size differs from original!";exit 1;fi
  echo "bCrouchHeight SUCCESS!!!"
fi

echo "exit"
