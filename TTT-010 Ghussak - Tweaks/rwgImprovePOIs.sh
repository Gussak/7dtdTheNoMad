#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

egrep "[#]help" $0

#set -x
set -Eeu

: ${strPathToUserData:="./_7DaysToDie.UserData"} #help relative to game folder (just put a symlink to it there)
strModPath="`pwd`"
strBN="$strModPath/.`basename "$0"`.TMP."
: ${strGenWorldName:="East Nikazohi Territory"} #help
strFlGenPrefabsOrig="${strPathToUserData}/GeneratedWorlds/${strGenWorldName}/prefabs.xml"

astrIgnoreTmp=(
  "house_new_mansion_03" #there is no data for this POI and it cause errors on log when loading the game
  "trader_"
  "part_"
  "rwg_"
  "sign_"
  "player_start"
  "bus_stop_"
  "deco_"
  ".*_filler_"
  ".*_sign"
  ".*_form"
  ".*_blk"
)
astrIgnoreOrig=("${astrIgnoreTmp[@]}")
strRegexIgnoreOrig="^(`echo "${astrIgnoreOrig[@]}" |tr " " "|"`)"

astrIgnoreGen=("${astrIgnoreTmp[@]}")
: ${bIgnoreCavesToo:=true} #help keep RWG caves as they are a nice break from the overworld even when repeated. But missing caves will still be added
if $bIgnoreCavesToo;then astrIgnoreGen+=("cave_" ".*_cave_");fi
strRegexIgnoreGen="^(`echo "${astrIgnoreGen[@]}" |tr " " "|"`)"
astrIgnoreTmp=();unset astrIgnoreTmp # just to make it sure not to use a tmp array elsewhere

strGenPrefabsData="`(
  cd ../..;
  cat "$strFlGenPrefabsOrig"
)`"

IFS=$'\n' read -d '' -r -a astrGenPOIsList < <(
  cd ../..; # bash uses the symlinked path while ls and cat use the realpath
  pwd >/dev/stderr;
  #cat "$strFlGenPrefabsOrig" 
  echo "$strGenPrefabsData" \
    |egrep 'name="[^"]*"' -o \
    |tr -d '"' |sed 's@name=@@' \
    |egrep -v "${strRegexIgnoreGen}"\
    |sort)&&: # sort (non unique) is essential here to make replacing easier
if((${#astrGenPOIsList[@]}==0));then echo "ERROR: astrGenPOIsList empty";exit 1;fi

IFS=$'\n' read -d '' -r -a astrAllPOIsList < <(
  cd ../../Data/Prefabs/POIs;
  pwd >/dev/stderr;
  ls *.xml|sed 's@[.]xml@@'|egrep -v "${strRegexIgnoreOrig}"|sort)&&:
if((${#astrAllPOIsList[@]}==0));then echo "ERROR: astrAllPOIsList empty";exit 1;fi

#strFlTmp="`mktemp`"
strFlTmp="`pwd`/`basename "$0"`.POIsYOS.tmp.txt"
echo -n >"$strFlTmp"
declare -A astrAllPOIsYOS
(
  cd ../../Data/Prefabs/POIs;
  pwd >/dev/stderr;
  for strPOI in "${astrAllPOIsList[@]}";do
    iYOS="`egrep '"YOffset"' "$strPOI.xml" |egrep 'value="[^"]*"' -o |tr -d '[a-zA-Z"=]'`"
    echo "astrAllPOIsYOS[$strPOI]=$iYOS" >>"$strFlTmp"
  done
)
source "$strFlTmp"

astrMissingPOIsList=()
for strPOI in "${astrAllPOIsList[@]}";do
  bFound=false
  for strGenPOI in "${astrGenPOIsList[@]}";do
    if [[ "$strGenPOI" == "$strPOI" ]];then
      bFound=true
      break
    fi
  done
  if ! $bFound;then 
    astrMissingPOIsList+=("$strPOI");
  fi
done
if((${#astrMissingPOIsList[@]}==0));then
  echo "No missing POIs."
  exit 0
fi
#echo "DEBUG:$LINENO:astrMissingPOIsList:Size:${#astrMissingPOIsList[@]}"
astrMPOItmp=("${astrMissingPOIsList[@]}")
astrMissingPOIsList=(`echo "${astrMPOItmp[@]}" |tr " " "\n" |sort -u`)
if((${#astrMissingPOIsList[@]}!=${#astrMPOItmp[@]}));then
  echo "ERROR:$LINENO: sizes should match" >/dev/stderr
  exit 1
fi
astrMPOIbkp=("${astrMissingPOIsList[@]}")
astrMissingPOIsList=() #reset to randomize
#for strPOI in "${astrMPOItmp[@]}";do
RANDOM=1337 #this seed placed the hospital on the wasteland biome (radiated) zone what is great! this seed wont give the same result on other game versions that have a different ammount of POIs.
iTot="${#astrMPOItmp[@]}"
for((i=0;i<iTot;i++));do
  iRnd="$(( RANDOM % ${#astrMPOItmp[@]} ))"
  strPOI="${astrMPOItmp[$iRnd]}"
  unset astrMPOItmp[$iRnd]
  astrMPOItmp=("${astrMPOItmp[@]}") #to update the array size
  astrMissingPOIsList+=("$strPOI")
done
if((${#astrMPOItmp[@]}>0));then
  declare -p astrMPOItmp |tr "[" "\n" >/dev/stderr
  echo "ERROR:$LINENO: not empty" >/dev/stderr
  exit 1
fi
unset astrMPOItmp #to not reuse it empty
if((${#astrMissingPOIsList[@]}!=${#astrMPOIbkp[@]}));then
  echo "ERROR:$LINENO: sizes should match" >/dev/stderr
  exit 1
fi
if [[ "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort`" != "`echo "${astrMPOIbkp[@]}" |tr " " "\n" |sort`" ]];then
  echo "ERROR:$LINENO: contents should match" >/dev/stderr
  exit 1
fi
if [[ "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort`" != "`echo "${astrMissingPOIsList[@]}" |tr " " "\n" |sort -u`" ]];then
  echo "ERROR:$LINENO: contents should match" >/dev/stderr
  exit 1
fi
declare -p astrMissingPOIsList |tr "[" "\n"

declare -A astrGenPOIsDupCountList=()
for strGenPOI in "${astrGenPOIsList[@]}";do
  #strPos="`echo "$strGenPrefabsData" |grep "$strGenPOI" |grep 'position="[^"]*"' -o |sed 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
  #eval "$strPos" #nX nY nZ
  astrGenPOIsDupCountList["$strGenPOI"]=$((${astrGenPOIsDupCountList["$strGenPOI"]-0}+1))
done
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  if((${astrGenPOIsDupCountList[$strGPD]}==1));then
    unset astrGenPOIsDupCountList[$strGPD]
  fi
done

strFlPatched="$strModPath/prefabs.xml.`basename "$0"`.tmp"
(cd ../..;cp -fv "$strFlGenPrefabsOrig" "$strFlPatched")
bEnd=false
iCountAtMissingPOIs=0
iSkipped=0
strFlRunLog="`basename "$0"`.LastRun.log.txt"
echo -n >"$strFlRunLog"
astrRestoredPOIs=()
for strGPD in "${!astrGenPOIsDupCountList[@]}";do
  for((i=${astrGenPOIsDupCountList[$strGPD]};i>1;i--));do
    # get 2nd match pos data
    strPos="`echo "$strGenPrefabsData" |grep "$strGPD" |head -n 2 |tail -n 1 |grep 'position="[^"]*"' -o |sed 's@position=@@' |tr -d '"' |sed -r 's@([.0-9-]*),([.0-9-]*),([.0-9-]*)@nX=\1;nY=\2;nZ=\3;@' |head -n 1`"
    eval "$strPos" #nX nY nZ
    #declare -p nX nY nZ
    
    # TODO make this configurable
    # town 1 in radiated area
    # x 662 645 1019 962
    # z -899 -530 -523 -899
    # topLeftXZ=645,-523;bottomRightXZ=1019,-899
    bSkip=false
    if((nX>=645 && nX<=1019 && nZ<=-523 && nZ>=-899));then
      echo " >>> WARN:SKIPPING:InTown1Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    # t2 x 2285 2516 2434 z -738 -730 -588
    if((nX>=2285 && nX<=2516 && nZ<=-588 && nZ>=-738));then
      echo " >>> WARN:SKIPPING:InTown2Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    # t3 x 3359 3338 3451 z -1259 -1351 -1359
    if((nX>=3338 && nX<=3451 && nZ<=-1259 && nZ>=-1359));then
      echo " >>> WARN:SKIPPING:InTown3Limits:$strGPD:strPos" |tee -a "$strFlRunLog" >/dev/stderr
      bSkip=true
    fi
    
    if $bSkip;then
      #add ignore mark @@@ so when perl runs, trying the 2nd match will ignore this one
      perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"@@@${strGPD}"'"/s' "$strFlPatched"
      ((iSkipped++))&&:
    else
      strMissingPOI="${astrMissingPOIsList[$iCountAtMissingPOIs]}"
      echo "$strGPD:$i:$strMissingPOI($iCountAtMissingPOIs):($nX,$nY,$nZ):YOS[no-TODO](${astrAllPOIsYOS[$strGPD]-}/${astrAllPOIsYOS[$strMissingPOI]-})" |tee -a "$strFlRunLog"&&: >/dev/stderr
      # this will change the 2nd match only of a dup entry strGPD
      perl -i -w -0777pe 's/("'"$strGPD"'".*?)("'"$strGPD"'")/$1"'"$strMissingPOI"'"/s' "$strFlPatched"
      
      : ${bApplyYOSDiff:=true} #help Wont TODO change prefab Y pos to be the difference between old and new prefab YOS
      if $bApplyYOSDiff;then
        : #Wont TODO: Better use xmlstarlet for YOS ...
        # BUT THERE IS A BIGGER PROBLEM: the rwg game engine considers several things to make it look good and fit perfectly on the surrounding environment. What is impossible to do with this script.
      fi
      
      if echo " ${astrRestoredPOIs[@]} " |grep " $strMissingPOI ";then
        echo "ERROR: using again a missing POI $strMissingPOI"
        exit 1
      fi
      astrRestoredPOIs+=("$strMissingPOI")
      
      ((iCountAtMissingPOIs++))&&:
      if((iCountAtMissingPOIs>=${#astrMissingPOIsList[@]}));then bEnd=true;break;fi
    fi
  done
  if $bEnd;then break;fi
done
sed -i -r 's"@@@""' "$strFlPatched" #clean ignore mark

#TODOA: append at "$strFlPatched" this:
# <decoration type="model" name="bombshelter_02" position="-3131,31,-3131" rotation="2" help="oasis, teleport -3131 37 -3131"/>
# <decoration type="model" name="ranger_station_04" position="-2105,43,-2313" rotation="0" help="extra spawn point"/>

#echo;echo "#####################################################################################"
#declare -p astrAllPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrMissingPOIsList |tr '[' '\n'
#echo;echo "#####################################################################################"
#declare -p astrGenPOIsDupCountList |tr '[' '\n' #|egrep -v '="1"'

iStillMissingPOIs=$((${#astrMissingPOIsList[@]}-iCountAtMissingPOIs))

echo "Totals:"
echo "missing POIs: ${#astrMissingPOIsList[@]}"
echo "astrGenPOIsList: ${#astrGenPOIsList[@]}"
echo "astrAllPOIsList: ${#astrAllPOIsList[@]}"
echo "changed POIs: $iCountAtMissingPOIs"
echo "skipped in town limits: $iSkipped"
echo "still missing POIs: $iStillMissingPOIs"

if((iStillMissingPOIs>0));then
  read -n 1 -p "list still missing POIs(y/...)?" strResp;echo
  if [[ "$strResp" == y ]];then
    for((i=iCountAtMissingPOIs;i<${#astrMissingPOIsList[@]};i++));do
      echo "${astrMissingPOIsList[i]}"
    done
  fi
fi

read -n 1 -p "apply patch (will bkp original)(y/...)?" strResp;echo
if [[ "$strResp" == y ]];then
  (
    cd ../..;
    ls -l "$strFlGenPrefabsOrig" "$strFlPatched"
    cp -v "$strFlGenPrefabsOrig" "${strFlGenPrefabsOrig}.`date +'%Y_%m_%d-%H_%M_%S_%N'`.bkp"
    cp -vf "$strFlPatched" "$strFlGenPrefabsOrig"
    trash -v "$strFlPatched"
  )
  echo "SUCCESS!!!"
fi

exit





######################################## OLD CODE

(
  cd ../../Data/Prefabs/POIs
  ls *.xml |sort |tr -d "[0-9]" |sort -u |sed 's@[.]xml@@' |sed -r 's"_$""' >"${strBN}.AllPOIs.txt"
  pwd
  ls -l "${strBN}.AllPOIs.txt"
)

cat "../../_7DaysToDie.UserData/GeneratedWorlds/East Nikazohi Territory/prefabs.xml" |egrep 'name="[^"]*"' -o |tr -d '"' |sed 's@name=@@' |sort >"${strBN}.GenWorldPOIs.txt"
ls -l "${strBN}.GenWorldPOIs.txt"

IFS=$'\n' read -d '' -r -a astrFlList < <(cat "${strBN}.AllPOIs.txt");for strFl in "${astrFlList[@]}";do if ! egrep -q "^$strFl" "${strBN}.GenWorldPOIs.txt";then echo "$strFl";fi;done
