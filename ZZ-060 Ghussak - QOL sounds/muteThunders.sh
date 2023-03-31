#!/bin/bash

#help: For windows users: look for the line with WINDOWS_USERS below. That command shall work on windows. Always make a backup before patching the file!!! You can also try to run this script on cygwin.

#PREPARE_RELEASE:REVIEWED:OK

set -eu

# binary patching on linux
echo "HELP:"
egrep "[#]help" $0
echo

: ${strFl:="../../7DaysToDie_Data/resources.assets"} #help
ls -l "$strFl"

# there are a few variables (`egrep '.[a-zA-Z0-9_/]*thunder.[a-zA-Z0-9_/]*' ${strPath}/7DaysToDie_Data/* -irnao`) related to controlling thunders, but I dont know where are their values: thunderFreq,isThunderWeather,thunderTimer,thunderDelay
if false;then # THIS DID NOT WORK (I guess it is an array with ignored IDs, therefore the asset ID(name) is ignored and randomly directly picked from the array?
  strFl="${strPath}/7DaysToDie_Data/resources.assets"
  cp -v "${strFl}" "${strFl}.${RANDOM}_BKP"
  strings "${strFl}" |egrep "hund..[0-9]"
  sed -i -r "s'sounds/ambient_oneshots/a_thunder([0-9])'sounds/ambient_oneshots/a_thundno\1'g" "${strFl}"
  strings "${strFl}" |egrep "hund..[0-9]"
fi
if false;then # THIS DID NOT WORK
  strFl="${strPath}/7DaysToDie_Data/globalgamemanagers"
  cp -v "${strFl}" "${strFl}.${RANDOM}_BKP"
  strings "${strFl}" |egrep "sounds/ambient_onesho../a_thunder[0-9]"
  sed -i -r "s'sounds/ambient_oneshots/a_thunder([0-9])'sounds/ambient_oneshono/a_thunder\1'g" "${strFl}"
  strings "${strFl}" |egrep "sounds/ambient_onesho../a_thunder[0-9]"
fi

function FUNCgetData() { #help <lstrId> [liSkip]
  local lstrId="${1}";shift&&:
  local liSkip="${1-}";shift&&:
  
  local lstrData="`perl -w -0777pe 's/.*('"$lstrId"')(.*?)(resources[.]resource).*/$2/sg' "$strFl" |xxd -c 1 |awk '{print $2}' |sed -r 's".*"\x5Cx&"'`"
  if [[ -n "$liSkip" ]];then
    lstrData="`echo "$lstrData" |tail -n +$((liSkip+1))`" #tail is to let the 1st byte be ignored, as this data has 39 bytes while thunders have 38, but they match better this way
  fi
  lstrData="`echo "$lstrData" |tr -d "\n"`"
  echo "$lstrData"
  
  echo "DATA:$lstrId" >&2
}

#function FUNCshowData

#strSilenceFillerData="`perl -w -0777pe 's/.*(silencefiller)(.*?)(resources[.]resource).*/$2/sg' "$strFl" |xxd -c 1 |awk '{print $2}' |sed -r 's".*"\x5Cx&"' |tail -n +2 |tr -d "\n"`" #tail is to let the 1st byte be ignored, as this data has 39 bytes while thunders have 38, but they match better this way
strSilenceFillerData="`FUNCgetData "silencefiller" 1`"
#echo "DATA:silencefiller"
echo "$strSilenceFillerData"

nSz=$(stat -c "%s" "$strFl")
strZeros="";for((i=0;i<38;i++));do strZeros+='\x00';done
#spaces will crash: sed -i -r 's"(a_thunder[0-9]).*(resources.resource)"\1                                      \2"' resources.assets
#this may fail if there is a newline char between: sed -i -r "s@(a_thunder[0-9]).*(resources.resource)@\1${strZeros}\2@" "$strFl"
#this wont work, even if it worked it would match 1st thunder found until last resources.resource string: sed -i -r ':again;$!N;$!b again; '"s@(a_thunder[0-9]).*(resources.resource)@\1${strZeros}\2@g" resources.assets
egrep "a_thunder[0-9].*resources.resource" -ao "$strFl"&&:

strFlBkp="${strFl}.`date +"%Y_%m_%d-%H_%M_%S_%N"`.bkp"
cp -v "${strFl}" "${strFlBkp}"

for((i=1;i<=5;i++));do FUNCgetData "a_thunder${i}";done #BEFORE CHANGES
#thunders are 1 2 3 4 5, I will try to unmute the nice ones, ommited indexes here will NOT be muted!
# 1) is +- good, not too loud, not too abrupt
# 2) BAD: is not good, is not too loud, but begins with abrupt sound
# 3) !!!GOOD: is an EXCELLENT thunder, nice sound and not loud at all!
# 4) didnt test yet
# 5) didnt test yet
# keeping only one enabled will also increase the time between the thunder sfx as it seems to try to play invalid files too w/o erroring tho
strMuteIndexes="1245"
: ${bMuteAllThunders:=false} #help bMuteAllThunders=true, just mute them all
if $bMuteAllThunders;then strMuteIndexes="12345";fi
if false;then # this is just to let the help be show below
  perl -i -w -0777pe 's/(a_thunder[1245])(.*?)(resources[.]resource)/$1\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00$3/sg' resources.assets #help this is a command that may work on windows (WINDOWS_USERS)
  
  #perl -i -w -0777pe 's/(a_thunder[1245])(.*?)(resources[.]resource)/$1\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x44\xac\x00\x00\x10\x00\x00\x00\x00\x00\x80\x3e\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x00\x12\x00\x00\x00$3/sg' resources.assets #help this is a command that may work on windows. uses silencefiller data, but it does not work...
fi
perl -i -w -0777pe 's/(a_thunder['"$strMuteIndexes"'])(.*?)(resources[.]resource)/$1'"${strZeros}"'$3/sg' "$strFl"
#SILENCEFILLER data did not work: perl -i -w -0777pe 's/(a_thunder['"$strMuteIndexes"'])(.*?)(resources[.]resource)/$1'"${strSilenceFillerData}"'$3/sg' "$strFl" #this was not tested
for((i=1;i<=5;i++));do FUNCgetData "a_thunder${i}";done #AFTER CHANGES
ls -l "$strFl"

egrep "a_thunder[0-9].*resources.resource" -ao "$strFl"&&:

if(( nSz != $(stat -c "%s" "$strFl") ));then 
  echo "ERROR, size differs from original! restoring backup...";
  trash -v "${strFl}"
  cp -v "$strFlBkp" "$strFl"
  echo "EXIT WITH ERROR."
  exit 1;
else
  echo "bMuteThunders SUCCESS!!!"
fi
