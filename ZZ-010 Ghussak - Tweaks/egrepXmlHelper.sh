#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

clear;

astrOptList=(
  -iRnI 
  --include="*.xml" 
  --include="*.txt" 
  --include="*.sh" 
  --exclude-dir="_*" 
  "$@" 
  *
)
set -x;egrep --color "${astrOptList[@]}";set +x
egrep -c      "${astrOptList[@]}" |grep -v :0
