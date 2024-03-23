#!/bin/bash

#set -x

set -Eeu

bUndo=false;if [[ "${1-}" == "--undo" ]];then bUndo=true;fi #help use this to restore modlets files to edit them

function FUNCuseDumped() {
	if $bUndo;then return 0;fi
	
	strXmlFl="$1";shift
	strGrp="$1";shift
	strEntry="$1";shift
	
	strFlDumped="_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/${strXmlFl}"
	
	strFl="../ZZ-990 Ghussak - DumpedCfgsForQuickLoad.SkipOnRelease/Config/${strXmlFl}"
	
	strRmRegex="xml.*version.*encoding|[<]${strGrp}[>]|[<][/]${strGrp}[>]"
	if(($(egrep "${strRmRegex}" "${strFlDumped}" |wc -l) != 3));then
		echo "ERROR: the below should match only 3 lines!"
		set -x;egrep "${strRmRegex}" "${strFlDumped}";set +x
		echo "ERROR: the above should match only 3 lines!"
		exit 1
	fi
	
	trash "$strFl"
	echo >"$strFl" #trunc

	echo '
	<GhussakTweaks>
		<!-- DO NOT MODIFY! autogen with '"$(basename "$0")"' -->
		<remove xpath="/'"${strGrp}"'/'"${strEntry}"'[not(@name='"'_SomethingImpossible28758732_'"')]" help="clean everything"/>
		<append xpath="/'"${strGrp}"'" help="append everthing from computed final dump of a running game">
		
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_BEGIN BELOW:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		' >>"$strFl"

	egrep -v "${strRmRegex}" "${strFlDumped}" >>"$strFl"

	echo '
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_END ABOVE:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		</append>
	</GhussakTweaks>
	' >>"$strFl"

	chmod -v ugo-w "$strFl"
	ls -l "$strFl"
	
	return 0
}

function FUNCmv() {
	strModFolder="$1";shift
	strFl="$1";shift
	if $bUndo;then
		mv -v "${strModFolder}/Config/${strFl}.UsingDumped.DoNotCommit.xml" "${strModFolder}/Config/${strFl}"&&:
	else
		mv -v "${strModFolder}/Config/${strFl}" "${strModFolder}/Config/${strFl}.UsingDumped.DoNotCommit.xml"&&:
	fi
	return 0
}

FUNCuseDumped "entitygroups.xml" entitygroups entitygroup
FUNCmv "../ZZ-030 Ghussak - Patch NPC spawn rate" entitygroups.xml

FUNCuseDumped "items.xml" items item
FUNCmv "../ZZ-010 Ghussak - Tweaks" items.xml
FUNCmv "../ZZ-070 Ghussak - Effective and Immersive Weapons Overhaul" items.xml

if $bUndo;then
	echo "NOW: run the game, wait it start, and hit ENTER here. It will prepare the dumped overrides again."
	read
	"$0"
fi
