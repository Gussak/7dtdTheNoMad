#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

sI="        " #indent
iCount=0
function FUNCxml() {
  local lbMaxLim=false;if [[ "${1-}" == --maxlimit ]];then lbMaxLim=true;fi
  if((i==iPrev));then return;fi
  #declare -p i iPrev iLim
  ((iCount++))&&:
  if((iCount>120));then echo "PROBLEM: too many will freeze/hang the thread having to SIGKILL the proccess...";exit 1;fi
  strReq=''
  echo "$sI"'<triggered_effect trigger="onSelfBuffStart" action="Ragdoll" duration="'"$i"'" help="iLim='"$iLim"',iStep='"$iStep"',iCount='"$iCount"'">'
  if $lbMaxLim;then
    echo "$sI"'  <requirement name="CVarCompare" cvar="iEWExtExplKORandomTime" operation="GT" value="'"$i"'"/>'
  else
    if((iStep==1));then
      echo "$sI"'  <requirement name="CVarCompare" cvar="iEWExtExplKORandomTime" operation="Equals" value="'"$i"'"/>'
    else
      echo "$sI"'  <requirement name="CVarCompare" cvar="iEWExtExplKORandomTime" operation="GT" value="'"$iPrev"'"/>'
      echo "$sI"'  <requirement name="CVarCompare" cvar="iEWExtExplKORandomTime" operation="LTE" value="'"$i"'"/>'
    fi
  fi
  echo "$sI"'</triggered_effect> <!-- '"HELPGOOD:CODEGEN:`basename "$0"`"' -->'
}

iPrev=0
iLim=0

#((iLim+=15 ))&&:;iStep=1 ;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done
((iLim+=38 ))&&:;iStep=3 ;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done
((iLim+=60 ))&&:;iStep=10;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done
((iLim+=120))&&:;iStep=15;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done
((iLim+=180))&&:;iStep=20;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done
((iLim+=240))&&:;iStep=30;for((i=iPrev;i<=$iLim;i+=iStep));do FUNCxml;iPrev=$i;done

FUNCxml --maxlimit
