#!/bin/bash

set -Eeu

set -x
strFl="../ZZ-990 Ghussak - DumpedCfgsForQuickLoad.SkipOnRelease/Config/entitygroups.xml"

trash "$strFl"
echo >"$strFl" #trunc

echo '
<GhussakTweaks>
	<!-- DO NOT MODIFY! autogen with '"$(basename "$0")"' -->
	<remove xpath="/entitygroups/entitygroup[not(@name='"'_SomethingImpossible28758732_'"')]" help="clean everything"/>
	<append xpath="/entitygroups" help="append everthing from computed final dump of a running game">
	
	<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_BEGIN BELOW:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
	' >>"$strFl"

egrep -v "xml.*version.*encoding|entitygroups" _NewestSavegamePath.IgnoreOnBackup/ConfigsDump/entitygroups.xml >>"$strFl"

echo '
	<!-- HELPGOOD:_AUTOGENCODE_CopyLastCfgDump_EntityGroups_END ABOVE:===== DO NOT MODIFY, USE THE AUTO-GEN SCRIPT: '"$(basename "$0")"' ===== -->
	</append>
</GhussakTweaks>
' >>"$strFl"

chmod -v ugo-w "$strFl"
ls -l "$strFl"
