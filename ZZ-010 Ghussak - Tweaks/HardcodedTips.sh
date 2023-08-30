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

source ./libSrcCfgGenericToImport.sh

# binary patching on linux
#egrep "[#]help" $0

# vanilla chouch height is 0.63
# this makes crouch height 1 block (0.50 or 0.40 is a bit better)
: ${bHCTCrouchHeight:=false} #help bHCTCrouchHeight=true
if $bHCTCrouchHeight;then
  : ${strRequiredBinaryFile:="${strCFGGameFolder}/7DaysToDie_Data/resources.assets"} #help strRequiredBinaryFile="FullLinuxPathToRequiredFile" ./HardcodedTips.sh
  if [[ ! -f "${strRequiredBinaryFile}" ]];then
    
    CFGFUNCerrorExit "The required file '${strRequiredBinaryFile}' was not found. You can configure it tho see the help for strRequiredBinaryFile."
  fi
  ls -l "${strRequiredBinaryFile}"
  CFGFUNCprompt "IMPORTANT: this script will binary patch the file '$strRequiredBinaryFile'."
  CFGFUNCprompt "IMPORTANT: it will create a backup of that file, so you need enough space available in your HD (but it will be checked below)."
  #echo "IMPORTANT: if you let this script binary patch the file '$strRequiredBinaryFile', you have to modify this setting:"
  #todoa
  #<set xpath="/blocks/block[@name='ConfigFeatureBlock']/property[@class='AdvancedPlayerFeatures']/
    #property[@name='OneBlockCrouch']/@value">true</set>
    #0-SCore
    
  : ${fCrouchHeight:="0.40"} #help this string must be a float with 4 characters as the original is "0.75". Keep the float above 0.00 and below 1.00, but should be below original value to have a meaning, and <= 0.50 to be useful. Btw, using 'weather fog 1.0' console command will help prevent you seeing what you shouldnt as this will glitch the camera and let you see thru walls TODOA: a proper camera that looks thru 1 block height is required to prevent the glitch.
  
  #TRYING TO GUESS: clear;strings "../../7DaysToDie_Data/resources.assets" |egrep "0[.]25" -C 10 |egrep camera -C 10 -i |egrep "0[.]25|camera" -C 100 -i
  #TRY GUESS: clear;strings "../../7DaysToDie_Data/resources.assets" |egrep '[a-zA-Z]{1,}[a-zA-Z0-9_]{4,} [-]*[0-9]{1,}[0-9.]*' -o |sort -u #shows all existing vars
  #TRY GUESS: clear;strings "../../7DaysToDie_Data/resources.assets" |egrep '[a-zA-Z]{1,}[a-zA-Z0-9_]{4,} [-]*[0-9]{1,}[.][0-9.]{1,}' -o |sort -u #shows all existing vars with floating values
  #TRY GUESS: clear;strings "../../7DaysToDie_Data/resources.assets" |egrep '[a-zA-Z]{1,}[a-zA-Z0-9_]{4,} [-]*[0-9]{1,}[.][0-9.]* *[-0-9.]* *[-0-9.]*' -o |sort -u #shows all existing vars with floating values for v3 vectors too


  #FAILED: PositionSpring2Damping PositionOffset
  #: ${fPositionSpring2Damping:="0.50"} #help this string must be a float with 4 characters as the original is "0.25". Keep the float above 0.00 and below 1.00, but should be below original value to have a meaning, and > 0.25 to be useful
  #: ${strPositionOffset:="0 -0.51 -0.27"} #help
  #strPositionOffsetMask="`echo "$strPositionOffset"|sed -r 's@.@.@g'`"
  bSkipAlreadyDone=true
  if ! egrep "PhysicsCrouchHeightModifier ${fCrouchHeight}" "${strRequiredBinaryFile}" -ao;then
    bSkipAlreadyDone=false
  fi
  #if ! egrep "PositionSpring2Damping ${fPositionSpring2Damping}" "${strRequiredBinaryFile}" -ao;then
    #bSkipAlreadyDone=false
  #fi
  #if ! egrep "PositionOffset ${strPositionOffset}" "${strRequiredBinaryFile}" -ao;then
    #bSkipAlreadyDone=false
  #fi
  if $bSkipAlreadyDone;then
    CFGFUNCinfo "Skipping, the file '${strRequiredBinaryFile}' is already patched!"
    exit 0
  fi
  
  strFlTmp="${strRequiredBinaryFile}.${strCFGScriptName}.TMP"
  if [[ -f "$strFlTmp" ]];then
    CFGFUNCinfo "Removing temp file: '$strFlTmp'"
    CFGFUNCexec rm -v "$strFlTmp"
  fi
  
  nSzBytes="`CFGFUNCchkAvailHDAndGetFlSz "$strRequiredBinaryFile" 2`" #help needs space for 2 new files: OriginalBackup and Temporary files
  
  #CFGFUNCcreateBackup "${strRequiredBinaryFile}"
  strPatience="Working on a huge binary file, this may take some time, please wait..."
  strOrigBkp="${strRequiredBinaryFile}${strCFGOriginalBkpSuffix}"
  if [[ ! -f "$strOrigBkp" ]];then
    CFGFUNCinfo "Backuping: $strPatience"
    CFGFUNCexec cp -v "${strRequiredBinaryFile}" "${strOrigBkp}"
    ls -l "${strOrigBkp}"
  fi
  
  if CFGFUNCprompt -q "Use the original binary file? if yes, the file '${strOrigBkp}' will be copied to apply the patches. This means that any other patches applied to the final file '${strRequiredBinaryFile}' will be lost and will be required to be reapplied. This is probably not a good idea to accept this.";then
    if CFGFUNCprompt -q "Are you really sure?";then
      CFGFUNCexec -m "Creating the temporary file to be patched: $strPatience" cp -v "${strOrigBkp}" "$strFlTmp"
    else
      CFGFUNCinfo "aborting"
      exit 0
    fi
  else
    CFGFUNCexec -m "Creating the temporary file to be patched: $strPatience" cp -v "${strRequiredBinaryFile}" "$strFlTmp"
  fi
  ls -l "$strFlTmp"
  
  CFGFUNCinfo "Existing values:"
  egrep "PhysicsCrouchHeightModifier ...." "${strFlTmp}" -ao
  #egrep "PositionOffset ${strPositionOffsetMask}" "${strFlTmp}" -ao
  #egrep "PositionSpring2Damping ...." "${strFlTmp}" -ao
  
  CFGFUNCinfo "PATCHING the temporary file: $strPatience"
  CFGFUNCexec sed -i -r \
    -e "s'(PhysicsCrouchHeightModifier)( )(....)'\1\2${fCrouchHeight}'g" \
    "${strFlTmp}"
    #-e "s'(PositionOffset)( )(${strPositionOffsetMask})'\1\2${strPositionOffset}'g" \
    #-e "s'(PositionSpring2Damping)( )(....)'\1\2${fPositionSpring2Damping}'g" \
    #
  ls -l "$strFlTmp"
  
  CFGFUNCinfo "Patched values:"
  egrep "PhysicsCrouchHeightModifier ...." "${strFlTmp}" -ao
  #egrep "PositionOffset `echo "$strPositionOffset"|sed -r 's@.@.@g'`" "${strFlTmp}" -ao
  #egrep "PositionSpring2Damping....." "${strFlTmp}" -ao
  
  if(( nSzBytes != $(stat -c "%s" "$strFlTmp") ));then 
    CFGFUNCexec rm -v "${strFlTmp}"
    CFGFUNCerrorExit "ERROR: Something went wrong! The binary file size differs from original! Deleted the temporary file: '$strFlTmp'";
  else
    CFGFUNCinfo "The file '$strFlTmp' was successfully patched!"
    
    CFGFUNCprompt "The next step will DELETE the final file '${strRequiredBinaryFile}' and rename the temporary file '$strFlTmp' to the final filename. If something wrong happens, you can rename the temporary file manually too as it is already properly patched."
    CFGFUNCexec rm -v "${strRequiredBinaryFile}"
    CFGFUNCexec mv -v "${strFlTmp}" "${strRequiredBinaryFile}"
    
    CFGFUNCinfo "Confirm patched values at final file:"
    bOk=true
    if ! egrep "PhysicsCrouchHeightModifier ${fCrouchHeight}" "${strRequiredBinaryFile}" -ao;then bOk=false;fi
    #if ! egrep "PositionOffset ${strPositionOffset}" "${strRequiredBinaryFile}" -ao;then bOk=false;fi
    #if ! egrep "PositionSpring2Damping ${fPositionSpring2Damping}" "${strRequiredBinaryFile}" -ao;then bOk=false;fi
    if $bOk;then
      CFGFUNCinfo "SUCCESS!"
    else
      CFGFUNCerrorExit "something went wrong, the final file has not the patched value..."
    fi
  fi
else
  $0 --help&&:
  exit 0
fi

echo "$0: exiting..."
