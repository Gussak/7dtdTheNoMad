#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK
echo "not working yet"
exit 0

astrNPCVars=(
  fGSKNPCarmorDmgPercent
)

for((j=1;j<=3;j++));do
  for strNpcVar in "${astrNPCVars[@]}";do
    for((i=0;i<100;i+=5));do
      fPerc="0`bc <<< "scale=2;$i/100"`";
      echo '<triggered_effect trigger="onSelfBuffStart" action="ModifyCVar" cvar="'"${strNpcVar}NPC${j}"'" operation="set" value="'"$i"'"><requirement name="CVarCompare" cvar="'"$strNpcVar"'" operation="GTE" value="'"$fPerc"'" /></triggered_effect>';
    done
  done
done
