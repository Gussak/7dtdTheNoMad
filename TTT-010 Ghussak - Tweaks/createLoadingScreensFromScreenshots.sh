#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

source ./gencodeInitSrcCONFIG.sh

IFS=$'\n' read -d '' -r -a astrFlList < <(cd ../../Screenshots/;realpath *.jpg)
for strFl in "${astrFlList[@]}";do
  if [[ -L "$strFl" ]];then continue;fi
  strBN="`basename "$strFl"`"
  ln -sf "$strFl" "LoadingScreens/$strBN"
  echo '      <tex file="@modfolder:LoadingScreens/'"$strBN"'" />' |tee -a "${strFlGenLoa}${strGenTmpSuffix}"
done

./gencodeApply.sh "${strFlGenLoa}${strGenTmpSuffix}" "${strFlGenLoa}"
