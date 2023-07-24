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

source ./libSrcCfgGenericToImport.sh --LIBgencodeTrashLast

bAnnotate=false
if CFGFUNCprompt -q "write (paint) the screenshot filename on the image data of the copied file? (you will see the filename when the game is loading on the bottom right corner) (tip: accept once, then move original Screenshots to a sub-folder there and move the files from LoadingScreens to the Screenshots folder and run this script again denying writing the filename on them (to create symlinks))";then
  bAnnotate=true
fi

#set -x
#IFS=$'\n' read -d '' -r -a astrFlList < <(cd LoadingScreens;realpath ScreenShotTest*.jpg;cd "${strCFGGameFolder}/Screenshots/";realpath *.jpg)&&:
IFS=$'\n' read -d '' -r -a astrFlList < <(cd "${strCFGGameFolder}/Screenshots/";realpath *.jpg)&&: #todo add .tga too but convert will need flip flop
for strFl in "${astrFlList[@]}";do
  if [[ -L "$strFl" ]];then continue;fi
  strBN="`basename "$strFl"`"
  CFGFUNCtrash "LoadingScreens/$strBN"
  if $bAnnotate;then
    CFGFUNCexec convert "$strFl" -gravity SouthEast -pointsize 17 -fill white -annotate +0+0 "LoadingScreens/$strBN" "jpeg:LoadingScreens/$strBN"
  else
    if ! ln -sf "$strFl" "LoadingScreens/$strBN";then #better to save space if it works
      CFGFUNCexec cp -f "$strFl" "LoadingScreens/$strBN"
    fi
  fi
  echo '      <tex file="@modfolder:LoadingScreens/'"$strBN"'" />' >>"${strFlGenLoa}${strGenTmpSuffix}"
  echo -n .
done

CFGFUNCgencodeApply "${strFlGenLoa}${strGenTmpSuffix}" "${strFlGenLoa}"

#last
CFGFUNCgencodeApply --cleanChkDupTokenFiles
CFGFUNCwriteTotalScriptTimeOnSuccess
