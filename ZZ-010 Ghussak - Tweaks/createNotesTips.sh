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

#set -Eeu
#strScriptName="`basename "$0"`"

#strModName="The NoMad"
#echo $LINENO
#if [[ -z "${bGskUnique895767852VarNameInitSourceConfigLoadedAlreadyOkYes-}" ]];then
source ./libSrcCfgGenericToImport.sh --gencodeTrashLast
#source ./libSrcCfgGenericToImport.sh
#fi
#echo $LINENO
#he lp first run w/o params and make it sure all is ok
#he lp then run each param alone to get the code to place where it is required

: ${bRomanTitleIndex:=true} #help

#export bShowFullFold=true
bGenAll=true #help will run all options in a good order and exit, just run this script w/o parameter for this to kick in
#if [[ "${1-}" == "--help" ]];then egrep "[#]help" $0;exit;fi #h elp w/o params will generate them all in a loop
#declare -p LINENO
if [[ "${1-}" == "--help" ]];then CFGFUNCshowHelp;exit 0;fi #help w/o params will generate them all in a loop
#declare -p LINENO
: ${bDebug:=false} #help
export bDebug
if [[ "${1-}" == "-D" ]];then bDebug=true;fi #help show debug info
bNiceReading=false;
if [[ "${1-}" == "-n" ]];then #help just shows nice readable text
  shift;bNiceReading=true;bGenAll=false;
fi 
bGenLoc=false;
if [[ "${1-}" == "-l" ]];then #help generate the localization text
  shift;bGenLoc=true;bGenAll=false;
fi 
bGenXml=false;
if [[ "${1-}" == "-x" ]];then #help generate the xml code, only necessary if a new note index is created
  shift;bGenXml=true;bGenAll=false;
fi 
bGenRec=false;
if [[ "${1-}" == "-r" ]];then #help generate the recipes xml code
  shift;bGenRec=true;bGenAll=false;
fi 
bGenArray=false;
if [[ "${1-}" == "-a" ]];then #help generate the array entries to use on the bash script that will create the create_item list at xml code, only necessary if a new note index is created
  shift;bGenArray=true;bGenAll=false;
fi 
echo

if $bGenAll;then
  $0 -n
  $0 -l
  $0 -x
  $0 -r
  $0 -a
  exit
fi

: ${nWidth:=60} #help max text width to prevent too tiny letters
: ${nMaxLines:=11} #help max lines to prevent too tiny letters
strFl="NotesTips.AddedToRelease.txt"

#function FUNCfinishPreviousNote() {
  #echo "${strNewNoteID},\"$1\""
  #echo -e "$1"
  #echo
#}
function FUNCfold() {
  fold -s -w $nWidth "$strFl"
}
function FUNCromanNumbers() {
  local ln="$1"
  if((ln==1));then echo "I";fi
  if((ln==2));then echo "II";fi
  if((ln==3));then echo "III";fi
  if((ln==4));then echo "IV";fi
  if((ln==5));then echo "V";fi
  if((ln==6));then echo "VI";fi
  if((ln==7));then echo "VII";fi
  if((ln==8));then echo "VIII";fi
  if((ln==9));then echo "IX";fi
  if((ln==10));then echo "X";fi
}

#if $bShowFullFold;then
  if $bDebug || $bNiceReading;then FUNCfold |cat -n;fi
#fi
if $bDebug || $bNiceReading;then echo;fi

IFS=$'\n' read -d '' -r -a astrFullLineList < <(cat "$strFl")&&:
iNoteIndex=10
strNewNote=""
strNewNoteName=""
strTitle=""
iLineCount=0
strNewNoteID=""

strSpecialNoteIDs=""
strSpecialNoteCounts=""
astrSpecialNoteNames=()
iSpecialNoteCount=0

strNormalNoteIDs=""
strNormalNoteCounts=""
astrNormalNoteNames=()
iNormalNoteCount=0

iAllNewNoteTot=0
bDontIncTitleIndexOnce=true

#strFlGenLoc="Config/Localization.txt"
#strFlGenXml="Config/items.xml"
#strFlGenRec="Config/recipes.xml"
#strGenTmpSuffix=".GenCode.TMP"
#trash "${strFlGenLoc}${strGenTmpSuffix}"&&:
#trash "${strFlGenRec}${strGenTmpSuffix}"&&:
#trash "${strFlGenXml}${strGenTmpSuffix}"&&:
#source ./libSrcCfgGenericToImport.sh

function FUNCfinishPreviousNote() {
  if $bDebug;then echo "$FUNCNAME()";fi
  #local lbResetTitleIndex="$1"
  
  local lbEcho=false
  if [[ -n "$strNewNote" ]];then lbEcho=true;fi
  #if [[ -z "$strNewNote" ]];then return 0;fi
  
  # dump previous note
  if $lbEcho;then
    if $bDebug || $bNiceReading;then echo "========== ${strNewNoteID} \"${strNewNoteName}\" iLineCount=$iLineCount ==============================";fi
    if $bDebug || $bNiceReading;then echo -e "$strNewNote";fi
    if $bDebug || $bGenLoc;then
      echo "${strNewNoteID},\"${strModName}NT:${strNewNoteName}\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
      echo "dk${strNewNoteID},\"${strNewNote}\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
    fi
    if $bDebug || $bGenXml || $bGenLoc;then
      if $bDebug;then declare -p strTitle;fi
      if $bIsSpecialNote;then
        if [[ -n "$strSpecialNoteIDs" ]];then strSpecialNoteIDs+=",";fi
        strSpecialNoteIDs+="${strNewNoteID}"
        if [[ -n "$strSpecialNoteCounts" ]];then strSpecialNoteCounts+=",";fi
        strSpecialNoteCounts+="1"
        ((iSpecialNoteCount++))&&:
        
        astrSpecialNoteNames+=("${strTitle}")
        if $bDebug;then declare -p astrSpecialNoteNames;fi
      else
        if [[ -n "$strNormalNoteIDs" ]];then strNormalNoteIDs+=",";fi
        strNormalNoteIDs+="${strNewNoteID}"
        if [[ -n "$strNormalNoteCounts" ]];then strNormalNoteCounts+=",";fi
        strNormalNoteCounts+="1"
        ((iNormalNoteCount++))&&:
        
        #declare -p astrNormalNoteNames strTitle
        astrNormalNoteNames+=("${strTitle}")
        if $bDebug;then declare -p astrNormalNoteNames;fi
      fi
      ((iAllNewNoteTot++))&&:
    fi
    if $bDebug || $bGenXml;then
      echo "\
    <item name=\"${strNewNoteID}\">${strXmlExtra}
      <!-- HELPGOOD:GENCODE:${strScriptName}: $strNewNoteName -->
      <property name=\"Extends\" value=\"GSKNoteSNGBase\" />
      <property name=\"DescriptionKey\" value=\"dk${strNewNoteID}\" />
    </item>"  |tee -a "${strFlGenXml}${strGenTmpSuffix}"
    fi
    if $bDebug || $bGenRec;then
      echo "    <recipe name=\"${strNewNoteID}\" count=\"1\"/>" |tee -a "${strFlGenRec}${strGenTmpSuffix}"
    fi
    if $bDebug || $bGenArray;then
      echo "\
          ${strNewNoteID} 1"
    fi
    
    if $bDebug || $bNiceReading;then echo;fi
  fi
}
function FUNCinitNextNote() {
  local lbResetTitleIndex="$1"
  # init next Note
  ((iNoteIndex++))&&:
  strNewNoteID="GSKNoteStartNewGame${iNoteIndex}"
  if $lbResetTitleIndex;then
    iTitleIndex=1
  else
    ((iTitleIndex++))&&:
  fi
  #strNewNote="[GSKNote] ${strTitle} `FUNCromanNumbers $iTitleIndex`\n"
  strNewNote=""
  strNewNoteName="${strTitle} `FUNCromanNumbers $iTitleIndex`"
  iLineCount=1
}
for strFullLine in "${astrFullLineList[@]}";do
  if [[ "${strFullLine:0:1}" == "#"   ]];then continue;fi #skip empty lines
  if [[ "${strFullLine}" =~ ^\ *$     ]];then continue;fi #skip empty lines
  
  if [[ "${strFullLine}" =~ ^\ *_\ *$ ]];then strFullLine="\n";fi #single underscore alone becomes newline
  if $bDebug;then echo "strFullLine='$strFullLine'";fi
  if [[ "${strFullLine:0:1}" == "+" ]];then #title indicator
    if $bDebug;then declare -p astrSpecialNoteNames;fi
    if $bDebug;then declare -p astrNormalNoteNames;fi
    #declare -p astrNormalNoteNames astrSpecialNoteNames
    FUNCfinishPreviousNote
    #declare -p astrNormalNoteNames astrSpecialNoteNames
    
    # prepare next note
    strTitle="${strFullLine:1}"
    bIsSpecialNote=false
    if [[ "${strTitle:0:1}" == "&" ]];then #special note indicator
      bIsSpecialNote=true
      strTitle="${strTitle:1}"
    fi
    strXmlExtra=""
    if [[ "${strTitle}" =~ .*\; ]];then # extra xml afte ';'
      strXmlExtra="`echo "${strTitle}" |sed -r 's@(.*?);(.*)@\2@'`"
      strTitle="`   echo "${strTitle}" |sed -r 's@(.*?);(.*)@\1@'`"
    fi
    if $bDebug;then declare -p strXmlExtra;fi
    #FUNCfinishPreviousNote
    FUNCinitNextNote true
    #((iNoteIndex++))&&:
    #strTitle="${strFullLine:1}"
  else
    if [[ "${strFullLine}" =~ .*\".* ]];then echo "${strFullLine}. ERROR: invalid character found on description's text: \"";exit 1;fi
    IFS=$'\n' read -d '' -r -a astrFoldLineList < <(echo "$strFullLine" |fold -s -w $nWidth)&&:
    if(( (iLineCount+"${#astrFoldLineList[@]}") > nMaxLines ));then # look ahead if will overlow the note limit
      FUNCfinishPreviousNote
      FUNCinitNextNote false
    fi
    for strFoldLine in "${astrFoldLineList[@]}";do
      if((iLineCount>=nMaxLines));then
        FUNCfinishPreviousNote
        FUNCinitNextNote false
        #((iNoteIndex++))&&:
        #strNewNoteID="dkGSKNoteStartNewGame${iNoteIndex}"
        #strNewNote="${strTitle}\n"
        #iLineCount=0
      fi
      strNewNote+="${strFoldLine}\n"
      ((iLineCount++))&&:
    done
  fi
  #declare -p astrNormalNoteNames astrSpecialNoteNames
done
FUNCfinishPreviousNote #finishes last note
#FUNCinitNextNote false
#declare -p astrNormalNoteNames astrSpecialNoteNames

if $bGenXml;then
  echo '    <!-- HELPGOOD:GENCODE:'"${strScriptName}"' -->
    <item name="GSKTRNotesBundle">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIconTint" value="200,200,200" />
      <property name="DescriptionKey" value="dkGSKTRNotesBundle" />
      <property class="Action0">
        <property name="Create_item" help="it has '"${iNormalNoteCount}"' notes" value="'"${strNormalNoteIDs}"'" />
        <property name="Create_item_count" value="'"${strNormalNoteCounts}"'" />
      </property>
    </item>' |tee -a "${strFlGenXml}${strGenTmpSuffix}"
  echo '    <!-- HELPGOOD:GENCODE:'"${strScriptName}"' -->
    <item name="GSKTRSpecialNotesBundle">
      <property name="Extends" value="GSKTRBaseBundle" />
      <property name="CustomIconTint" value="255,0,0" />
      <property name="DescriptionKey" value="dkGSKTRSpecialNotesBundle" />
      <property class="Action0">
        <property name="Create_item" help="it has '"${iSpecialNoteCount}"' notes" value="'"${strSpecialNoteIDs}"'" />
        <property name="Create_item_count" value="'"${strSpecialNoteCounts}"'" />
      </property>
    </item>' |tee -a "${strFlGenXml}${strGenTmpSuffix}"
fi

function FUNCnoteTitlesUnique() {
  #echo "$@"
  for str in "$@";do
   # echo "TITLE: $str" >&2
    echo "$str"
  done |sort -u |tr '\n' ';' |sed -r 's@;@, @g'
}
#set -x;declare -p astrNormalNoteNames;FUNCnoteTitlesUnique "${astrNormalNoteNames[@]}";exit 1
if $bGenLoc;then
  #declare -p astrNormalNoteNames astrSpecialNoteNames
  
  echo "GSKTRSpecialNotesBundle,\"${strModName}NT:Critical Survival Notes bundle\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
  echo "dkGSKTRSpecialNotesBundle,\"Here you must read these critical notes: `FUNCnoteTitlesUnique "${astrSpecialNoteNames[@]}"`\"\nTotal notes: ${iSpecialNoteCount}.\n" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
  
  echo "GSKTRNotesBundle,\"${strModName}NT:Survival Notes bundle\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
#  echo "dkGSKTRNotesBundle,\"Reading them will help you:\n - survive the first week\n - understand the new world\n - understand how to use the new items\nTotal notes: ${iNormalNoteCount}. Notes' names: `FUNCnoteTitlesUnique "${astrNormalNoteNames[@]}"`\nObs.: You dont need to open this bundle, each note can be crafted at anytime or just read at crafting menu, or only open this if you have many free inventory slots or are in a really good safe place.\nPS.: If you ignore these notes, it may become unreasonably difficult to survive. If that happens, restart and read at least combat, explore and defense notes for a better experience!\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
  echo "dkGSKTRNotesBundle,\"Reading them will help you:\n - survive the first week\n - understand the new world\n - understand how to use the new items\nTotal notes: ${iNormalNoteCount}.\nObs.: You don't need to open this bundle, each note can just be read at crafting menu.\nPS.: I recommend reading at least combat, explore and defense notes for a better experience!\"" |tee -a "${strFlGenLoc}${strGenTmpSuffix}"
  
  ##INFO Device
     ##|sed -r 's@(\{cvar\()(.*)(:.*\)\})@\2=\1\2\3, @'   \
     ##|tr -d '\n'                                        
  #IFS=$'\n' read -d '' -r -a astrInfoDeviceList < <(    \
    #cat Config/Localization.txt                         \
     #|egrep '\{cvar\([^:]*:[^)]*\)\}' -o                \
     #|egrep "fGSKDmgColdProt|fGSKDmgHeatProt|fGSKHitpointsBlockageChemUse|fGSKFireHeatingMult|fGSKarmorAddToMultTS" \
     #|sort -u                                           \
  #)&&:
  #strAllInfoDevice=""
  #for strInfoDevice in "${astrInfoDeviceList[@]}";do
    #strInfoDevice="`echo "$strInfoDevice" |sed -r -e 's@(\{cvar\()(.*)(:.*\)\})@\2=\1\2\3@' -e 's@.GSK(.*?=.*)@\1@'`"
    ##strInfoDevice="${strInfoDevice#iGSK}"
    ##strInfoDevice="${strInfoDevice#fGSK}"
    #strAllInfoDevice+="${strInfoDevice}\n"
  #done
  #echo "dkGSKNoteInfoDevice,\"Extra info:\n${strAllInfoDevice}\""
fi

#ls -l *"${strGenTmpSuffix}"&&:
if $bGenLoc;then
  ./gencodeApply.sh "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
fi 
if $bGenXml;then
  ./gencodeApply.sh "${strFlGenXml}${strGenTmpSuffix}" "${strFlGenXml}"
fi 
if $bGenRec;then
  ./gencodeApply.sh "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"
fi 
