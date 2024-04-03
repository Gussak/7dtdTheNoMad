#!/bin/bash

#set -x

#help TODO: SUGGEST THEM: a good way to not require this script would be for the 7DTD engine store a md5sum of each modlet xml file, and if any of them changes, or some new one shows up, the whole modding (each modlet loaded in order) for that specific xml file basename, would be reprocessed. Otherwise, the dumped xml files would be reused instead of reprocessing all modlets.

if [[ "${1-}" == "--help" ]];then egrep "[#]help" "$0";exit 0;fi

set -Eeu

bUndo=false;if [[ "${1-}" == "--undo" ]];then bUndo=true;fi #help use this to restore modlets files to edit them

: ${strSuffix:="UsingDumped"} #help

pwd

function FUNCexecEcho() {
	local lbIgnoreError=false;if [[ "$1" == --ignoreerror ]];then lbIgnoreError=true;shift;fi
	echo
	echo "EXEC: $@" >&2
  "$@"&&:;local lnRet=$?
  if ! $lbIgnoreError && ((lnRet!=0));then
    echo "ERROR-EXEC: $@; lnRet=$lnRet (hit ctrl+c)" 
    #trap 'echo "ctrl+c, continuing..."' INT
    sleep 6000 #cant use `read` as it is non iteractive (will ignore keypresses)
    #trap -- INT
  fi
  return 0
};export -f FUNCexecEcho

function FUNCprepareDumpedCfgToOverrideAll() {
	strXmlFl="$1";shift
	strGrp="$1";shift
	strEntry="$1";shift
	
	: ${strNewestSaveGamePath:="../ZZ-010 Ghussak - Tweaks/_NewestSavegamePath.IgnoreOnBackup"} #help
	strFlDumped="${strNewestSaveGamePath}/ConfigsDump/${strXmlFl}"
	FUNCexecEcho ls -l "${strFlDumped}" # to error if not exist
	
	: ${strDumpModPath:="../ZZ-990 Ghussak - DumpedCfgsForQuickLoad"} #help
	FUNCexecEcho ls -ld "$strDumpModPath" # to error if not exist
	strFlFinal="${strDumpModPath}/Config/${strXmlFl}" # this will become just a symlink
	strFlReal="${strFlFinal}.SkipOnRelease.xml"
	
	if $bUndo;then
		FUNCexecEcho trash "$strFlFinal"
		FUNCexecEcho trash "$strFlReal"
		return 0;
	fi
	
	strRmRegex="xml.*version.*encoding|[<]${strGrp}[>]|[<][/]${strGrp}[>]"
	if(($(egrep "${strRmRegex}" "${strFlDumped}" |wc -l) != 3));then # validate
		echo "ERROR: the below should match only 3 lines!"
		set -x;egrep "${strRmRegex}" "${strFlDumped}";set +x
		echo "ERROR: the above should match only 3 lines!"
		exit 1
	fi
	
	strFlClean="${strFlFinal}.CopiedFromConfigsDumpAndCleanedComments.xml"
	FUNCexecEcho cp -vfT "${strFlDumped}" "${strFlClean}"
	FUNCexecEcho chmod -v u+w "${strFlClean}"
	FUNCexecEcho xmlstarlet ed -L -d '//comment()' "${strFlClean}"

	FUNCexecEcho trash "$strFlFinal"
	echo >"$strFlFinal" #trunc/create

	echo '
	<GhussakTweaks>
		<!-- DO NOT MODIFY! autogen with '"$(basename "$0")"' -->
		<remove xpath="/'"${strGrp}"'/'"${strEntry}"'[not(@name='"'_SomethingImpossible28758732_'"')]" help="clean everything"/>
		<append xpath="/'"${strGrp}"'" help="append everthing from computed final dump of a running game">
		
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_BEGIN BELOW:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		' >>"$strFlFinal"
	
	FUNCexecEcho egrep -v "${strRmRegex}" "${strFlClean}" >>"$strFlFinal"
	
	echo '
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_END ABOVE:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		</append>
	</GhussakTweaks>
	' >>"$strFlFinal"
	
	FUNCexecEcho trash "$strFlClean"
	
	chmod -v ugo-w "$strFlFinal" # to help on avoiding misediting it
	ls -l "$strFlFinal"
	
	FUNCexecEcho mv -vfT "$strFlFinal" "${strFlReal}" # to prevent sending to repo
	FUNCexecEcho ln -vsfT "./$(basename "${strFlReal}")" "$strFlFinal" # to let engine detect and use it
	
	return 0
}

function FUNCmv() {
	strModFolder="$1";shift
	strFlFinal="$1";shift
	if $bUndo;then
		FUNCexecEcho --ignoreerror mv -v "${strModFolder}/Config/${strFlFinal}.${strSuffix}.xml" "${strModFolder}/Config/${strFlFinal}"
	else
		FUNCexecEcho --ignoreerror mv -v "${strModFolder}/Config/${strFlFinal}" "${strModFolder}/Config/${strFlFinal}.${strSuffix}.xml"
	fi
	return 0
}

# DATA TO PROCESS
# TODO: detect changes to any xml file prepared at the final override folder modlet and re-apply this script

FUNCprepareDumpedCfgToOverrideAll "entitygroups.xml" entitygroups entitygroup #prepares the dumped override
FUNCmv "../ZZ-030 Ghussak - Patch NPC spawn rate" entitygroups.xml #disables the modlet file

# FAILS: FREEZES ON LOAD: FUNCprepareDumpedCfgToOverrideAll "blocks.xml" blocks block

FUNCprepareDumpedCfgToOverrideAll "items.xml" items item
FUNCmv "../ZZ-010 Ghussak - Tweaks" items.xml
FUNCmv "../ZZ-070 Ghussak - Effective and Immersive Weapons Overhaul" items.xml

# undo mode finalizer
if $bUndo;then
	echo "NOW: run the game, wait it start (wait the player spawn in the world), and hit ENTER here. It will prepare the dumped overrides again."
	read
	"$0"
fi
