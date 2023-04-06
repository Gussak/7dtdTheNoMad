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
    
  : ${fCrouchHeight:="0.40"} #help this string must be a float with 4 characters. Keep the float above 0.00 and below 1.00
  if egrep "PhysicsCrouchHeightModifier ${fCrouchHeight}" "${strRequiredBinaryFile}" -ao;then
    CFGFUNCinfo "Skipping, the file '${strRequiredBinaryFile}' is already patched to fCrouchHeight='$fCrouchHeight'!"
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
  
  CFGFUNCinfo "Creating temporary file to be patched: $strPatience"
  CFGFUNCexec cp -v "${strRequiredBinaryFile}" "$strFlTmp"
  ls -l "$strFlTmp"
  
  CFGFUNCinfo "Existing values:"
  egrep "PhysicsCrouchHeightModifier....." "${strFlTmp}" -ao
  
  CFGFUNCinfo "PATCHING the temporary file: $strPatience"
  CFGFUNCexec sed -i -r "s'(PhysicsCrouchHeightModifier)(.)(....)'\1\2${fCrouchHeight}'g" "${strFlTmp}"
  ls -l "$strFlTmp"
  
  CFGFUNCinfo "Patched values:"
  egrep "PhysicsCrouchHeightModifier....." "${strFlTmp}" -ao
  
  if(( nSzBytes != $(stat -c "%s" "$strFlTmp") ));then 
    CFGFUNCinfo "ERROR: Something went wrong! The binary file size differs from original! Deleting the temporary file: '$strFlTmp'";
    CFGFUNCexec rm -v "${strFlTmp}"
    CFGFUNCerrorExit
  else
    CFGFUNCinfo "The file '$strFlTmp' was successfully patched!"
    
    CFGFUNCprompt "The next step will DELETE the final file '${strRequiredBinaryFile}' and rename the temporary file '$strFlTmp' to the final filename. If something wrong happens, you can rename the temporary file manually too as it is already properly patched."
    CFGFUNCexec rm -v "${strRequiredBinaryFile}"
    CFGFUNCexec mv -v "${strFlTmp}" "${strRequiredBinaryFile}"
    
    CFGFUNCinfo "Confirm patched values at final file:"
    if egrep "PhysicsCrouchHeightModifier ${fCrouchHeight}" "${strRequiredBinaryFile}" -ao;then
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
