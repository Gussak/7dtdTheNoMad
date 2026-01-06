#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

source ./libSrcCfgGenericToImport.sh

declare -p strCFGSavesPathIgnorable
ls -ltr "$strCFGSavesPathIgnorable"

declare -p strCFGNewestSavePathIgnorable
ls -ld "$strCFGNewestSavePathIgnorable"

ln -vsfT "$strCFGNewestSavePathIgnorable" _NewestSavegamePath.IgnoreOnBackup #useful to see already opened and updated files easily on geany and meld

if CFGFUNCexec ls -lR ../../Data/Config |egrep "^..w.*[.]xml$";then
  if CFGFUNCprompt -q "you should protect the above files from directly editing them. Do it now?";then
    CFGFUNCexec chmod -Rv ugo-w ../../Data/Config #TODO this will actually protect all files there, not only .xml
  fi
fi
