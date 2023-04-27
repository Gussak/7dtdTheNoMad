#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

source ./libSrcCfgGenericToImport.sh

ls -ld "$strCFGNewestSavePathIgnorable"
ln -vsfT "$strCFGNewestSavePathIgnorable" _NewestSavegamePath #useful to see already opened and updated files easily on geany and meld
