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
egrep --color "${astrOptList[@]}" 
egrep -c      "${astrOptList[@]}" |grep -v :0
