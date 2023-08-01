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

#echo WIP;exit 0 #TODO RM

source ./libSrcCfgGenericToImport.sh #place exported arrays above this include

#iExpected="`egrep '="randomfloat\(0\.' * -irnI --include="*.xml" --include="*.sh" |egrep -v "_NewestSavegamePath.IgnoreOnBackup|_ReleasePackageFiles_.IgnoreOnBackup" |wc -l`" #checks all possibilities for all possible files, currently only buffs.xml needs it. TODO: after running with the mod, check the dumped cfgs that contains all other users' mods for any new problems

strHint="FixTinyRandomFloat" #only use letters and numbers

strErrTip=". Adjusting the xml file to not error here is easier than improving this script (unless it is worth like the ignorable/optional properties), so keep the expected order of the xml elements (trigger, action etc), and place no xml comments on that same line before nor after the expected xml token."

CFGFUNCprompt "You can code normally with tiny randomFloat values and then just run this script right after! Also be sure there is nothing that matches on the xml comments${strErrTip}"

strNL="
"

#astrFlList=("Config/buffs.xml")
IFS=$'\n' read -d '' -r -a astrFlList < <(ls Config/*.xml -1 |sort -u)&&:
for strFl in "${astrFlList[@]}";do

  #sed -r 's@="randomfloat[(]0[.]@@' Config/buffs.xml >Config/buffs.fixTinyRandomFloat.xml

  # fix too small random floats that mostly or always result in max value
  #IFS=$'\n' read -d '' -r -a astrDataList < <(cat "$strFl" |tr -d '\r')&&:
  IFS=$'\n' read -d '' -r -a astrLineList < <(egrep '="randomFloat\(0\.' -ihn "$strFl" |egrep -vi "$strHint" |tr -d '\r')&&:
  
  if((${#astrLineList[@]}==0));then CFGFUNCinfo "nothing to do for $strFl";continue;fi
  
  #if((iExpected!="${#astrLineList[@]}"));then CFGFUNCerrorExit "$iExpected!=${#astrLineList[@]}. you may need to add files to be patched.${strErrTip}";fi
  
  iTotLines="`cat ${strFl} |wc -l`"
  cat "$strFl" >"${strFl}.${strHint}.NEW"
  
  #declare -p astrLineList |tr '[' '\n'
  for strOriginalLine in "${astrLineList[@]}";do
    iLineNumber="`echo "$strOriginalLine" |egrep "^[0-9]*:" -io`";iLineNumber="${iLineNumber%:}"
    #strLeadingSpacesAndToken="`echo "$strOriginalLine" |sed -r 's@^[0-9]*:([\t ]*<triggered_effect *).*@\1@i'`"
    strLeadingSpaces="`echo "$strOriginalLine" |sed -r 's@^[0-9]*:([\t ]*).*@\1@i'`"
    strXmlToken="`echo "$strOriginalLine" |sed -r 's@^[0-9]*:[\t ]*< *([a-zA-Z0-9_]*).*@\1@i'`"
    strTrigger="`echo "$strOriginalLine" |sed -r 's@.*trigger="([^"]*)".*@\1@i'`"
    strCVar="`echo "$strOriginalLine" |sed -r 's@.*cvar="([^"]*)".*@\1@i'`";strCVarRegex="`echo "$strCVar" |sed -r 's@[$]@[$]@g'`"
    strRandomFloatString="`echo "$strOriginalLine" |egrep "randomfloat" -io`"
    strRMin="`echo "$strOriginalLine" |sed -r 's@.*randomFloat[(]([^,]*),.*@\1@i'`" #help sed ignore case with 'i' or 'I'
    strRMax="`echo "$strOriginalLine" |sed -r 's@.*randomFloat[(][^,]*,([^)]*)[)].*@\1@i'`" #help sed ignore case with 'i' or 'I'
    strAction="`echo "$strOriginalLine" |sed -r 's@.*action="([^"]*)".*@\1@i'`"
    strOperation="`echo "$strOriginalLine" |sed -r 's@.*operation="([^"]*)".*@\1@i'`"
    #thing that may not exist
    strIgnorableHelp="`echo "$strOriginalLine" |egrep ' *help="[^"]*"' -o`"&&:
    strIgnorableTarget="`echo "$strOriginalLine" |egrep ' *target="[^"]*"' -o`"&&:
    strIgnorableRange="`echo "$strOriginalLine" |egrep ' *range="[^"]*"' -o`"&&:
    strIgnorableTarget_tags="`echo "$strOriginalLine" |egrep ' *target_tags="[^"]*"' -o`"&&:
    strIgnorableCompare_type="`echo "$strOriginalLine" |egrep ' *compare_type="[^"]*"' -o`"&&:
    
    #strHelp="`echo "$strOriginalLine" |sed -r 's@.*help="([^"]*)".*@\1@i'`"&&:
    #strClosing="`echo "$strOriginalLine" |sed -r 's@.*([/]>)$@\1@i'`"
    strClosing="`echo "$strOriginalLine" |egrep " */> *$" -o`"&&:;if [[ -z "$strClosing" ]];then strClosing="`echo "$strOriginalLine" |egrep " *> *$" -o`"&&:;fi
    #declare -p strClosing
    
    if [[ -z "$strClosing" ]];then CFGFUNCerrorExit "invalid strClosing='$strClosing'${strErrTip}";fi
    #strIgnorableHelp="";if [[ -n "${strHelp}" ]];then strIgnorableHelp=" help=\"$strHelp\"";fi
    
    iPrecision=3 # *1000 is easy to think/convert, for me ;)
    if((${#strRMin}>(iPrecision+2)));then #+2 is about prefix '0.'
      iPrecision=$((${#strRMin}-2))&&:
    fi
    if((${#strRMax}>(iPrecision+2)));then #+2 is about prefix '0.'
      iPrecision=$((${#strRMax}-2))&&:
    fi
    
    iPower="`bc <<< "10^$iPrecision"`"
    strRMinFix="$(printf "%.0f" `bc <<< "scale=0;${strRMin}*$iPower"`)" #printf removes the suffix .0
    strRMaxFix="$(printf "%.0f" `bc <<< "scale=0;${strRMax}*$iPower"`)"
    
    bMatchLinesFail=false
    #set -x
    if ! strMatchingLines="`egrep "$strCVarRegex" -i "$strFl" |egrep "$strTrigger" -i |egrep "randomFloat *[(] *$strRMin *, *$strRMax *[)]" -i`";then
      bMatchLinesFail=true
    fi
    if [[ -z "$strMatchingLines" ]];then
      bMatchLinesFail=true
    fi
    #set +x
    iMatchingLines="`echo "$strMatchingLines" |wc -l`"
    
    CFGFUNCinfo "iMatchingLines=$iMatchingLines;iPrecision=$iPrecision;$strTrigger;$strCVar;$strRMin/$strRMinFix;$strRMax/$strRMaxFix;$strOriginalLine"
    
    strIgnorableAll="${strIgnorableTarget}${strIgnorableRange}${strIgnorableTarget_tags}${strIgnorableCompare_type}"
    
    #strOriginalLine="@${strOriginalLine};"
    strRecrOrigLine="${iLineNumber}:${strLeadingSpaces}"'<'"${strXmlToken}"' trigger="'"${strTrigger}"'" action="'"${strAction}"'" cvar="'"${strCVar}"'" operation="'"${strOperation}"'" value="'"${strRandomFloatString}"'('"${strRMin},${strRMax}"')"'"${strIgnorableAll}${strIgnorableHelp}${strClosing}"
    
    if [[ "$strOriginalLine" != "$strRecrOrigLine" ]];then
      declare -p strOriginalLine strRecrOrigLine strLeadingSpaces strXmlToken strTrigger strAction strCVar strOperation strRMin strRMax strClosing strIgnorableHelp
      CFGFUNCerrorExit "unable to recreate original line for matching${strErrTip}"
    fi
    
    strHelpHint="${strHint}: was randomFloat(${strRMin},${strRMax})"
    if [[ -z "${strIgnorableHelp}" ]];then
      strIgnorableHelp=" help=\"${strHelpHint}\""
    else
      strIgnorableHelp="${strIgnorableHelp%\"};${strHelpHint}\""
    fi
    
    #strIdHex="`crc32 <(echo "${strCVar}") |tr '[:lower:]' '[:upper:]'`"; #this grants same ID to avoid seeing too many changes on diff app
    #strIdDec="`printf %d 0x${strIdHex}`"
    #RANDOM=$strIdDec;strIdRnd="$RANDOM"
    #strCVarTmp=".fGSKFixTinyRandomFloat${strIdRnd}Tmp"
    strCVarTmp=".fGSK${strHint}Tmp"
    
    strComment=' <!-- HELPGOOD:'"${strHint}"':OriginalLineData:LineNumber='"${strOriginalLine}"' -->' #the line data begins with the original line number
    
    strFixedLine="${strLeadingSpaces}"'<'"${strXmlToken}"' help="'"${strHint}"':was '"${strCVar}"' '"${strOperation}"' randomFloat('"${strRMin},${strRMax}"')" trigger="'"${strTrigger}"'" action="'"${strAction}"'" cvar="'"${strCVarTmp}"'" operation="set" value="randomInt('"${strRMinFix},${strRMaxFix}"')"/>'"${strNL}"
    strFixedLine+="${strLeadingSpaces}"'<'"${strXmlToken}"' trigger="'"${strTrigger}"'" action="'"${strAction}"'" cvar="'"${strCVarTmp}"'" operation="divide" value="'"${iPower}"'" help="'"${strHint}"'"/>'"${strNL}"
    strFixedLine+="${strLeadingSpaces}"'<'"${strXmlToken}"' trigger="'"${strTrigger}"'" action="'"${strAction}"'" cvar="'"${strCVar}"'" operation="'"${strOperation}"'" value="@'"${strCVarTmp}"'"'"${strIgnorableAll}${strIgnorableHelp}${strClosing}${strComment}"
    
    : ${bSingleLine:=true} #help this is to turn the easy to implement multiline above into the final result single line. That single line will be easier to undo/recreate/repatch later if there is any reason to do that. TODO: prevent xmlstarlet from removing all white spaces formatting. But at least that can be reverted by removing '\n' from lines containing 'FixTinyRandomFloat' that also do not contain 'OriginalLineData' with a multiline perl script
    if $bSingleLine;then
      strFixedLine="`echo "${strFixedLine}" |tr -d '\n'`" 
    fi
    
    CFGFUNCinfo "$strFixedLine"
    
    if $bMatchLinesFail;then CFGFUNCerrorExit "strMatchingLines='$strMatchingLines' empty?${strErrTip}";fi
    if((iMatchingLines==0));then echo "$strMatchingLines";CFGFUNCerrorExit "iMatchingLines=$iMatchingLines != 1${strErrTip}";fi
    #if((${#strRMin}>6));then CFGFUNCerrorExit "strRMin='$strRMin' and it's precision it too much having ${#strRMin} chars. should be at most 0.0000, to work with *10000 what is";exit;fi;
    #if((${#strRMax}>6));then echo ${#strRMax};exit;fi; #0.0000
    
    #astrDataList[$iLineNumber]="${strFixedLine}"
    #strAbove="`head -n $((iLineNumber-1)) "${strFl}.fixTinyRandomFloats.NEW"`"
    #strBelow="`tail -n $((iTotLines-iLineNumber-1)) "${strFl}.fixTinyRandomFloats.NEW"`"
    #echo "${strAbove}" >"${strFl}.fixTinyRandomFloats.NEW"
    #echo "${strFixedLine}" >>"${strFl}.fixTinyRandomFloats.NEW"
    #echo "${strBelow}" >>"${strFl}.fixTinyRandomFloats.NEW"
    head -n $((iLineNumber-1)) "${strFl}.${strHint}.NEW" >"${strFl}.${strHint}.2.NEW"
    echo "${strFixedLine}" >>"${strFl}.${strHint}.2.NEW"
    tail -n $((iTotLines-iLineNumber)) "${strFl}.${strHint}.NEW" >>"${strFl}.${strHint}.2.NEW"
    mv -v "${strFl}.${strHint}.2.NEW" "${strFl}.${strHint}.NEW"
    
    echo
  done

  # prepare the patched new file
  #echo -n >"${strFl}.fixTinyRandomFloats.NEW"
  #for strData in "${astrDataList[@]}";do  
    #echo "${strData}" >>"${strFl}.fixTinyRandomFloats.NEW"
  #done

  if ! CFGFUNCmeld "${strFl}" "${strFl}.${strHint}.NEW";then
    CFGFUNCerrorExit "WARN: user aborted."
  fi

  CFGFUNCapplyChanges "${strFl}" "${strFl}.${strHint}.NEW"

  #CFGFUNCgencodeApply "${strFlGenBuf}${strGenTmpSuffix}" "${strFlGenBuf}"
done

##last
#CFGFUNCgencodeApply --cleanChkDupTokenFiles
#CFGFUNCwriteTotalScriptTimeOnSuccess
