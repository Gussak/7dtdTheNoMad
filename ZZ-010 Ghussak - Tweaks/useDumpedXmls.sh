#!/bin/bash

set -Eeu

function FUNCuseDumped() {
	strXmlFl="$1";shift
	strGrp="$1";shift
	strEntry="$1";shift
	
	strFl="../ZZ-990 Ghussak - DumpedCfgsForQuickLoad.SkipOnRelease/Config/${strXmlFl}"

	trash "$strFl"
	echo >"$strFl" #trunc

	echo '
	<GhussakTweaks>
		<!-- DO NOT MODIFY! autogen with '"$(basename "$0")"' -->
		<remove xpath="/'"${strGrp}"'/'"${strEntry}"'[not(@name='"'_SomethingImpossible28758732_'"')]" help="clean everything"/>
		<append xpath="/'"${strGrp}"'" help="append everthing from computed final dump of a running game">
		
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_BEGIN BELOW:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		' >>"$strFl"

	egrep -v "xml.*version.*encoding|${strGrp}" "_NewestSavegamePath.IgnoreOnBackup/ConfigsDump/${strXmlFl}" >>"$strFl"

	echo '
		<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_END ABOVE:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
		</append>
	</GhussakTweaks>
	' >>"$strFl"

	chmod -v ugo-w "$strFl"
	ls -l "$strFl"
}

function FUNCmv() {
	strModFolder="$1";shift
	strFl="$1";shift
	mv -v "../${strModFolder}/Config/${strFl}" "../${strModFolder}/Config/${strFl}.UsingDumped.DoNotCommit.xml"&&:
}

FUNCuseDumped "entitygroups.xml" entitygroups entitygroup
FUNCmv "../ZZ-030 Ghussak - Patch NPC spawn rate" entitygroups.xml

FUNCuseDumped "items.xml" items item
FUNCmv "../ZZ-010 Ghussak - Tweaks" items.xml
FUNCmv "../ZZ-070 Ghussak - Effective and Immersive Weapons Overhaul" items.xml
