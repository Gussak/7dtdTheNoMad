#!/bin/bash

# Copyright (c) 2016-2017, ghussak<http://www.nexusmods.com/7daystodie/users/733862> Gussak<https://github.com/Gussak>
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted 
# provided that the following conditions are met:
# 
# 1.	Redistributions of source code must retain the above copyright notice, this list of conditions 
#	and the following disclaimer.
#
# 2.	Redistributions in binary form must reproduce the above copyright notice, this list of conditions 
#	and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
# 3.	Neither the name of the copyright holder nor the names of its contributors may be used to endorse 
#	or promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN 
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#PREPARE_RELEASE:REVIEWED:OK

###########################################################################
######################################## CONFIG
###########################################################################

set -u # error on unbound
set -e # exit on error
set -E # sub calls inherit ERR trap

strSelf="`basename "${0}"`"
strVersion="`egrep "^v" "${strSelf%.sh}-changes.txt" |head -n 1`"&&:
strSelfMd5="`md5sum "$0" |cut -d' ' -f1`" #a kind of version
function FUNCarrayReport(){ local lstrReport="";for lstr in "$@";do lstrReport+="\"$lstr\" ";done;echo "$lstrReport"; }
#strParams="";astrParams=("${@-}");for strParam in "${astrParams[@]}";do strParams+="\"$strParam\" ";done
strParams="`FUNCarrayReport "${@-}"`"
strDtFmt="%Y%m%d-%H%M%S"
strDateTimeStart="`date +"$strDtFmt"`"
strRunId="DT($strDateTimeStart),RunParams($strParams)"

strBaseModPathName="modHSaL_"
strThisModPath="`pwd`/`dirname $0`/"
strBackupFolder="$strThisModPath/${strBaseModPathName}backups/"
if [[ ! -d "$strBackupFolder" ]];then mkdir -v "$strBackupFolder";fi

declare -Ax anActionList
declare -Ax anOriginalDBMValueList
declare -Ax astrExtendsList
declare -ax astrExtAndActList
declare -Ax astrCustomValue

#echo "nOptDBMmultUEXP='${nOptDBMmultUEXP}'"
#echo

# user options
: ${bOptVerboseUEXP:=false};export bOptVerboseUEXP
: ${bOptPauseBetweenUEXP:=true};export bOptPauseBetweenUEXP
: ${bOptUseItemBlackListUEXP:=true};export bOptUseItemBlackListUEXP
: ${nOptDBMmultUEXP:=10};export nOptDBMmultUEXP # new DBM multiplier for headshot/hit, 10 seems a good value to not make it so easy/1shotKill, 
: ${bOptBackupUEXP:=true};export bOptBackupUEXP
bOptClearCache=false
bOptFullSimplePatch=false
bOptApplyPatchNow=false
bOptApplyExtends=false
bOptListNew=false
bOptClearDefaultList=false
bOptShowNotPatchable=false
bOptCallFunc=false
strOptFuncId=""

bTestDbg=false

nErrorRestoreBackup=125

# internal use
astrRemainingParams=()
#bRecreateValBkpFile=true
#bUsingRestoredValBkpFile=false
bOrigValListChanged=false
bAllowFindActValStoreOrigDBM=false
: ${bClearLogFileEXP:=true};export bClearLogFileEXP
: ${bShowDefaultRevalidationEXP:=true};export bShowDefaultRevalidationEXP
: ${bAutoClearSkipProtectedEXP:=false};export bAutoClearSkipProtectedEXP

strBaseWorkFile="items.xml"
strRelativePathWorkFile="./Data/Config/"

: ${strLastBkpFileEXP:=""};export strLastBkpFileEXP

strConfigPath="$strThisModPath/${strBaseModPathName}config/";
if [[ ! -d "$strConfigPath" ]];then mkdir -v "$strConfigPath";fi

strCfgExt=".cfg"
strConfigFile="$strConfigPath/`   			 basename "$0"`${strCfgExt}"
bConfigFileExist=false
if [[ -f "$strConfigFile" ]];then
	source "$strConfigFile"
	bConfigFileExist=true
fi
: ${strConfigVersion:=$strVersion};export strConfigVersion
: ${strGameInstallPathUCFG:=};export strGameInstallPathUCFG
#strPWD="`pwd`";cd "$strGameInstallPathUCFG";strGameInstallPathUCFG="`pwd`";cd "$strPWD" #workaround for windows pathing

strCachePrefix=".cache-"
strCacheValBkpFile="$strConfigPath/`    basename "$0"`${strCachePrefix}DBMValOrigBkp.PROTECTED${strCfgExt}"
strCacheValidItemsFile="$strConfigPath/`basename "$0"`${strCachePrefix}ValidItems${strCfgExt}"
strCacheExtendsFile="$strConfigPath/`   basename "$0"`${strCachePrefix}Extends${strCfgExt}"
strCacheDoorsFile="$strConfigPath/`   	basename "$0"`${strCachePrefix}Doors${strCfgExt}" #blocks.xml

strLogPath="$strThisModPath/${strBaseModPathName}log/";
if [[ ! -d "$strLogPath" ]];then mkdir -v "$strLogPath";fi

strFileRunLog="$strLogPath/`basename "$0"`.log"
strFileRunLogZip="${strFileRunLog}.tar.gz"
strErrDbgSendMsg="\n\tPlease send me the compete debug log '${strFileRunLogZip}'.\n\tOr the console/terminal on screen execution log.\n\tOr it may suffice to paste the last 10 to 100 lines of '${strFileRunLog}' (tail -n 100 '${strFileRunLog}') at ex.: http://pastebin.com/index.php"

#strErrMsgStack=""
function FUNCtrapErr(){
	local lstrFuncName=$1;shift
	local lnLine=$1;shift
	local lstrCmd=$1;shift
	local lnErrVal=$1;shift
	
	local lnSubPid=$BASH_SUBSHELL
	
	local lstrErrMsg="ERROR_STACK(cmd:'$lstrCmd',Ln:$lnLine,TrapAtFunc:$lstrFuncName,spid=$lnSubPid);"
	
	if((lnSubPid==0));then 
		echo >>/dev/stderr 
		echo >>"$strFileRunLog"
	fi
	
	if((lnSubPid==0));then 
		echo "$lstrErrMsg" >>/dev/stderr
	fi
	echo "$lstrErrMsg" >>"$strFileRunLog"; 
	
	if((lnSubPid==0));then 
		echo >>/dev/stderr 
		echo >>"$strFileRunLog"
	
	fi
	
	if((lnSubPid==0));then
		FUNClogZip; 
	
		# no tee below here...
		echo
		echo -e "ERROR:$strErrDbgSendMsg" >>/dev/stderr
		echo
		
		exit $lnErrVal #make sure it exits
	fi
	
	return $lnErrVal
} #;export -f FUNCtrapErr
trap 'FUNCtrapErr "${FUNCNAME-}" "$LINENO" "$BASH_COMMAND" $?' ERR

#TODO add a command to remove entries (case insensitive)?
astrWorkItemList=(
	arrow 
	auger 
	blunderbuss
	boneShiv 
	chainsaw 
	clawHammer 
	clubBarbed
	clubIron
	clubSpiked 
	clubWood 
	explodingCrossbowBolt
	fireaxeIron 
	fireaxeSteel 
	flamingArrow
	gun44Magnum 
	gunAK47 
	gunHuntingRifle 
	gunMP5 
	gunPistol 
	gunPumpShotgun
	gunSawedOffPumpShotgun 
	gunSniperRifle 
	hoeIron 
	huntingKnife 
	ironArrow 
	ironCrossbowBolt 
	machete 
	pickaxeIron 
	pickaxeSteel 
	shovelIron
	shovelSteel
	sledgehammer 
	steelArrow 
	steelCrossbowBolt 
	stoneAxe 
	stoneShovel 
	tazasStoneaxe 
	wrench 
)

astrItemsBlackList=(
	BBGun
	BBRifle
	clubMaster
	femur
	FishingPole
	flashlight02
	handPlayer
	nail
	nailgun
	ShockBaton
	torch
	UnbaitedFishingPole
)

###########################################################################
######################################## FUNCTIONS
###########################################################################
function _FUNCimpossibleCheck01(){ # "impossible" to happen things, TODO remove one day?
	if((${#astrPatchableItems[@]-}==0));then # this should not happen at all as default list was already validated..
		FUNCecho "PROBLEM: ??? no patchable items found? is '$strWorkFile' broken?"
		FUNCexit 1
	fi
}

#function FUNCnewRecipes(){ #help #some new recipes
#	local lstrFile="recipes.xml"
#	local lstrFullPathFile="`FUNCfullPathFile "$lstrFile"`"
#	
#	FUNCnewRecipesXPath(){ echo "/recipes/recipe[@name='$1']/ingredient[@name='$2']"; }
#	
#	local lbDoBkp=true
function FUNCaddRecipe(){ #help [lastrRecipeAttributeList] <lstrRecipeName> <lstrRecipeOutputCount> <<[@]lstrNameNewIng> <lnCountNewIng>>... #add new recipe if key ingredient @lstrNameNewIng doesnt exist yet ('@' indicates what ingredient is the key one)
    local bHasAttrib=false
		local lastrRecipeAttributeList=()
		while [[ "$1" =~ .*=.* ]];do
			lastrRecipeAttributeList+=("$1")
      bHasAttrib=true
			shift
		done
		local lstrRecipeName="$1";shift
		local lstrRecipeOutputCount="$1";shift
		
		local lstrKeyIngredient="" #;shift
		local lastrIngList=("$@")
		#local lstrTmp=""
#		for lstrTmp in "${lastrIngList[@]}";do
		for((i=0;i<${#lastrIngList[@]};i++));do
			local lstrTmp="${lastrIngList[i]}"
			if [[ "$lstrTmp" =~ ^@.* ]];then
				lstrKeyIngredient="${lstrTmp#@}"
				lastrIngList[i]="$lstrKeyIngredient"
			fi
		done
#		if [[ "$lstrKeyIngredient" =~ ^keyIng=$ ]];then
		if [[ -z "$lstrKeyIngredient" ]];then
			FUNCecho "invalid lstrKeyIngredient='$lstrKeyIngredient'"
			FUNCexit 1
		fi
#		lstrKeyIngredient="${lstrKeyIngredient#keyIng=}"
		
		local lstrFile="recipes.xml"
		local lstrFullPathFile="`FUNCfullPathFile "$lstrFile"`"
	
		FUNCnewRecipesXPath(){ echo "/recipes/recipe[@name='$1']/ingredient[@name='$2']"; }
	
		if FUNCexecxml sel -t -c "`FUNCnewRecipesXPath "$lstrRecipeName" "$lstrKeyIngredient"`" "$lstrFullPathFile" 2>&1 >>/dev/null;then
			FUNCecho "recipe found for lstrRecipeName='$lstrRecipeName' lstrKeyIngredient='$lstrKeyIngredient'"
			return 0
		else
#			if $lbDoBkp;then FUNCbkp "$lstrFile"; lbDoBkp=false;fi
			FUNCbkp "$lstrFile"
			
			FUNCecho "Filling lstrRecipeName='$lstrRecipeName' lstrRecipeOutputCount='$lstrRecipeOutputCount'"
				
			FUNCexecxml ed -P -L -s "/recipes" \
				-t elem -n "recipe_DUMMY_TMP" -v "" \
				-i "//recipe_DUMMY_TMP" -t attr -n "name"  -v "$lstrRecipeName" \
				-i "//recipe_DUMMY_TMP" -t attr -n "count"  -v "$lstrRecipeOutputCount" \
				"$lstrFullPathFile"
			
      if $bHasAttrib;then
        for strRecipeAttribute in "${lastrRecipeAttributeList[@]}";do
          local lstrAttrName="`echo "$strRecipeAttribute" |cut -d= -f1`"
          local lstrAttrValue="`echo "$strRecipeAttribute" |cut -d= -f2`"
          
          FUNCecho "(attribute $strRecipeAttribute)"
        
          FUNCexecxml ed -P -L -i "//recipe_DUMMY_TMP" \
            -t attr -n "$lstrAttrName" -v "$lstrAttrValue" \
            "$lstrFullPathFile"
        done
      fi
			
			FUNCingredient(){ 
				local lstrName="$1"
				local lnCount="$2"
				
				FUNCecho "with lstrName='$lstrName' lnCount='$lnCount'"
				
				FUNCexecxml ed -P -L -s "/recipes/recipe_DUMMY_TMP" \
					-t elem -n "ingredient_TMP"  -v "" \
					-i "//ingredient_TMP" -t attr -n "name"  -v "$lstrName" \
					-i "//ingredient_TMP" -t attr -n "count"  -v "$lnCount" \
					-r "//ingredient_TMP" -v "ingredient" \
					"$lstrFullPathFile"
			}			
			
#			while ! ${1+false} && [[ -n "$1" ]];do
#				local lstrNameNewIng="$1";shift
#				local lnCountNewIng="$1";shift
			for((i=0;i<${#lastrIngList[@]};i+=2));do
				local lstrNameNewIng="${lastrIngList[i]}"
				local lnCountNewIng="${lastrIngList[i+1]}"
				if ! FUNCisValidNumber $lnCountNewIng;then return 1;fi
				FUNCingredient "$lstrNameNewIng" "$lnCountNewIng"
			done
		
			FUNCexecxml ed -P -L -r "//recipe_DUMMY_TMP" -v "recipe" "$lstrFullPathFile"
		fi
}
#	FUNCaddRecipe "keyIng=paper" "arrow" 1 "rockSmall" 1 "wood" 1 "paper" 1
#	FUNCaddRecipe "keyIng=grass" "arrow" 1 "rockSmall" 1 "wood" 1 "grass" 10
#	
#}

function FUNCmakeXmlPrettyReadable(){ #help <lstrFile> #use this after applying these mods and comparing with the backup file, by default the edits will not change the file whitespaces formatting
	local lstrFile="$1"
	local lstrFullPathFile="`FUNCfullPathFile "$lstrFile"`"
	FUNCbkp "$lstrFile"
	FUNCexecxml ed -L "$lstrFullPathFile" #DO NOT USE -P here!!!
}

function FUNCbonusModUnlockDoors(){ #help #all doors will be unlocked (it would be better to allow breaking just the door knob/lock... is it implementable at all? and a better but more complex implementation would be a top layer locked door, and all downgrades be unlocked)
	local lstrFile="blocks.xml"
	
	#local lstrFullPathFile="$strGameInstallPathUCFG/$strRelativePathWorkFile/$lstrFile"
	local lstrFullPathFile="`FUNCfullPathFile "$lstrFile"`"
	
	function FUNCbmudXPath() { echo "/blocks/block[@name='$1']/property[@name='Class']/@value"; }
	
	if [[ -f "$strCacheDoorsFile" ]];then
		source "$strCacheDoorsFile"
	else
		local lastrAllBlocks=(`FUNCexecxml sel -t -v "/blocks/block/@name" "$lstrFullPathFile"`)
		astrDoorList=()
		local lnCount=0;
		for strBlock in "${lastrAllBlocks[@]}";do
			echo -en "($((lnCount++))/${#lastrAllBlocks[@]})$strBlock.\r"
			strVal="`FUNCexecxml sel -t -v "$(FUNCbmudXPath $strBlock)" "$lstrFullPathFile"`"&&:
			if [[ "$strVal" == "DoorSecure" ]];then
				echo "DoorSecure: $strBlock."
				astrDoorList+=("$strBlock");
			fi
		done
	
		for((i=0;i<"${#astrDoorList[@]}";i++));do
			echo "astrDoorList[$i]=\"${astrDoorList[$i]}\"" >>"$strCacheDoorsFile"
		done
	fi
	
	FUNCbkp "$lstrFile"
	for strDoor in "${astrDoorList[@]}";do
		echo "unlocking: $strDoor"
		FUNCexecxml ed -P -L -u "$(FUNCbmudXPath $strDoor)" -v "Door" "$lstrFullPathFile"
	done
}

function FUNCbinaryPatch(){ #help <lstrFile> "<lstrRegexMatch>" "<lstrReplaceWith>" #Modify binary files (may be seen as a cheat). It is advised to make the replacement string with the same size of the matching one.
	local lstrFile="$1";shift
	local lstrRegexMatch="$1";shift
	local lstrReplaceWith="$1";shift
	
	lstrFile="$strGameInstallPathUCFG/$lstrFile"
	
	if [[ ! -f "$lstrFile" ]];then
		FUNCecho "missing lstrFile='$lstrFile'"
		return 1
	fi
	
	if grep "$lstrReplaceWith" "$lstrFile";then
		FUNCecho "already patched..."
	else
		FUNCecho "WARNING! this may take a LOT of time if the file is too big..."
		FUNCbkp "$lstrFile"
		FUNCexec sed --follow-symlinks -i -r "s'$lstrRegexMatch'$lstrReplaceWith'g" "$lstrFile"
	fi
}

function FUNCmodCustom(){ #help <lstrFile> <lstrNameOwner> <lstrNameSub> <lstrValueId> <lstrNewValue> #modify specific values
	local lstrFile="${1-}";shift
	local lstrNameOwner="${1-}";shift
	local lstrNameSub="${1-}";shift
	local lstrValueId="${1-}";shift
	local lstrNewValue="${1-}";shift
	
	local lstrXPath="//*[@*='$lstrNameOwner']//*[@*='$lstrNameSub']/@$lstrValueId"
	
#	local lstrFullPathFile="$strGameInstallPathUCFG/$strRelativePathWorkFile/$lstrFile"
#	if [[ ! -f "$lstrFullPathFile" ]];then
#		FUNCecho "PROBLEM: not found lstrFullPathFile='$lstrFullPathFile'"
#		return 1
#	fi
	local lstrFullPathFile="`FUNCfullPathFile "$lstrFile"`"
	
	#FUNCexecxml sel -t -v "$lstrXPath" "$lstrFile";echo ">>>>>$?"
	local lstrExisting
	if ! lstrExisting="`FUNCexecxml sel -t -v "$lstrXPath" "$lstrFullPathFile"`";then	return 1;fi
	FUNCexec declare -p lstrExisting
	
	if(("`echo "$lstrExisting" |wc -l`"!=1));then
		FUNCecho "PROBLEM: should exactly match only one value."
		return 1
	fi
	
	FUNCbkp "$lstrFile"
	
	FUNCexecxml ed -P -L -u "$lstrXPath" -v "$lstrNewValue" "$lstrFullPathFile"
	
	local lstrApplied
	if ! lstrApplied="`FUNCexecxml sel -t -v "$lstrXPath" "$lstrFullPathFile"`";then return 1;fi
	FUNCexec declare -p lstrApplied
	
	if [[ "$lstrNewValue" != "$lstrApplied" ]];then
		FUNCecho "PROBLEM: failed to apply new value, restoring backup."
		FUNCexec cp -vf "$lstrBkp" "$lstrFullPathFile"
		FUNCexec rm -v "$lstrBkp"
		return 1
	fi
	
	return $?
}

function FUNCfullPathFile() {
	local lstrFile="${1-}";shift
	
	local lstrFullPathFile="$strGameInstallPathUCFG/$strRelativePathWorkFile/$lstrFile"
	if [[ ! -f "$lstrFullPathFile" ]];then
		FUNCecho "PROBLEM: not found lstrFullPathFile='$lstrFullPathFile'"
		return 1
	fi
	
	echo "$lstrFullPathFile"
}

function FUNCloadCache(){ #<arrayId> <cacheFile>  # WARNING!!! do not use as sub-shell or inside `if` statements!
	local lstrArrayId="$1";shift
	local lstrCacheFile="$1";shift
	
	declare -n refArray="$lstrArrayId"
	refArray=();
	
	if egrep -q "^$lstrArrayId" "$lstrCacheFile" >>/dev/null 2>&1;then
		FUNCecho "loading $lstrArrayId cache file $lstrCacheFile"
		source "$lstrCacheFile"
		
		if [[ -n "${refArray[@]-}" ]];then
#			bUsingRestoredValBkpFile=true
			FUNCecho "restored values for $lstrArrayId"
			FUNCdumpArrayDbg $lstrArrayId
			return 0
		else
			FUNCecho "PROBLEM!!! corrupt lstrCacheFile='$lstrCacheFile'? delete it, see --help option."
			return 1
		fi
	fi
	
	return 1
}

function FUNCsysValid(){ 
	if ! which $1 >>/dev/null;then 
		echo "ERROR: Cygwing '$1' package is required." |tee -a "${strFileRunLog}";
		exit 1;
	fi 
	
	if $bShowDepsEXP;then
		echo "[ok] '$1' version '`$1 --version |head -n 1`'" |tee -a "${strFileRunLog}";
	fi
}

function FUNCcleanLog(){
	# removes from the log any user info, usually from commands like `ls -l`
	# more tips are appreciated!
	sed -i -r \
		-e "s'$USER'USERNAME'g" \
		-e "s'$HOSTNAME'HOSTNAME'g" \
		"$strFileRunLog"
}

function FUNClogZip(){ 
	FUNCecho "Compressing strFileRunLog='$strFileRunLog'"
	
	FUNCexec ls -l "${strFileRunLogZip}"&&:
	
	FUNCexec rm -vf "${strFileRunLogZip}"&&:
	
	FUNCcleanLog
	tar -vczf "${strFileRunLogZip}" "${strFileRunLog}"&&: #DO NOT USE FUNCexec !!!!!!!! because will mess the log zipping!
	
	FUNCexec ls -l "${strFileRunLogZip}"&&:;
	FUNCcleanLog
	
	echo
}

function FUNCbkp() {
	if ! $bOptBackupUEXP;then return 0;fi
	local lstrFile="${1-}";shift
#	echo "lstrFile='$lstrFile'";exit
	
	local lbIsXml=false
	if [[ "$lstrFile" =~ .*[.]xml$ ]];then
		lstrFile="`FUNCfullPathFile "$lstrFile"`"
		lbIsXml=true
	fi
	
	if [[ ! -f "$lstrFile" ]];then
		FUNCecho "PROBLEM: not found lstrFile='$lstrFile'"
		return 1
	fi
	
	local lstrFileBaseName="`basename "$lstrFile"`"
	if $lbIsXml;then
		strLastBkpFileEXP="$strBackupFolder/${lstrFileBaseName%.xml}.bkp`date +"$strDtFmt"`.xml"
	else
		local lnSize="`stat -L -c %s "$lstrFile"`"
		#echo "lnSize='$lnSize' lstrFile='$lstrFile'";exit
		if((lnSize<1000000));then
			strLastBkpFileEXP="$strBackupFolder/${lstrFileBaseName}.`date +"$strDtFmt"`.bkp"
		else
			strLastBkpFileEXP="$strBackupFolder/${lstrFileBaseName}.bkp"
			if [[ -f "$strLastBkpFileEXP" ]];then
				FUNCecho "backup for big lstrFile='$lstrFile' non xml file already exists, skipping!"
				return 0
			fi
		fi
	fi
		
	FUNCexec cp -v "$lstrFile" "$strLastBkpFileEXP"
	
	#strLastBkpFileEXP="$lstrBkp"
}

function FUNCBkpMain(){
	FUNCbkp "$strBaseWorkFile"
#	strLastBkpFileEXP="$strBackupFolder/${strBaseWorkFile%.xml}-`date +"$strDtFmt"`.xml"
#	FUNCexec cp -v "$strWorkFile" "$strLastBkpFileEXP"
	FUNCecho "CREATED BACKUP ABOVE"
}

function FUNCexit(){ #<2> means to restore a backup!
	local lnExit="${1}";shift
	
	if((lnExit==0));then
		FUNCecho "exiting: ($strRunId)"
	else
		FUNCecho "Error, exiting!!! ($strRunId)"
	fi
	
	if((lnExit==nErrorRestoreBackup));then
		FUNCecho "Do RESTORE a backup before continuing!!! last one is: ${strLastBkpFileEXP-}"
	fi
	
	FUNCcleanLog
	
	exit $lnExit
}

function FUNCisValidNumber(){
	local lnNumber="${1-}";shift
#	local lstrMsg="${1}";shift
	
	# can be floating
	if [[ -n "$lnNumber" ]] && [[ "$lnNumber" =~ ^[0-9]+[.]*[0-9]*$ ]];then
	#((${#lnNumber}>0))
#		if((lnNumber<=0));then #only positive
#			return 1
#		fi
		
		# Must be positive 
		if [[ "`bc <<< "$lnNumber>0"`" == "0" ]];then # bc true is output "1", false is "0"
			FUNCechoDbg "is negative lnNumber='$lnNumber'"
			return 1
		fi
		
		return 0
#	else
#		FUNCecho "Invalid value! $lstrMsg"
#		return 1
	fi
	
	FUNCechoDbg "is invalid lnNumber='$lnNumber'"
	return 1
}

function FUNCcalc(){ # [lnMult] custom per item
	local lstrItem="${1}";shift
	local lnOriginalDBM="${1}";shift
	local lstrCustomValue="${1-}";shift
#	if ! which bc;then
#		echo ">>> PROBLEM!!! package 'bc' is missing"
#		FUNCexit $nErrorRestoreBackup
#	fi
	
	local lnMult="$nOptDBMmultUEXP"
	if [[ -n "${lstrCustomValue-}" ]];then
		if [[ "${lstrCustomValue:0:1}" == "x" ]];then
			lnMult="${lstrCustomValue:1}"
		elif [[ "${lstrCustomValue:0:1}" == "=" ]];then
			local lnOverride="${lstrCustomValue:1}"
			if ! FUNCisValidNumber $lnOverride;then FUNCecho "$lstrItem, invalid lnOverride='$lnOverride'";FUNCexit $nErrorRestoreBackup;fi
			echo "$lnOverride"
			return 0
		else
			FUNCecho "PROBLEM!!! $lstrItem, invalid lstrCustomValue='$lstrCustomValue'"
			FUNCexit $nErrorRestoreBackup
		fi
	fi
#	if [[ -z "$lnMult" ]];then
#		lnMult="$nOptDBMmultUEXP"
#	fi
	
	if ! FUNCisValidNumber $lnMult;then FUNCecho "$lstrItem, invalid lnMult='$lnMult'";FUNCexit $nErrorRestoreBackup;fi

#	if which bc >>/dev/null;then #this allows floating point (not that useful tho...)
	strResult="`bc <<< "scale=2;$lnMult*$lnOriginalDBM"`"
	
	echo "$strResult"
#	else
#		echo "$(($lnMult*$nOriginalDBM))"
#	fi
	
	return 0
}

function FUNCstoreOrigDBM(){ #<item> <value>
	if ! $bAllowFindActValStoreOrigDBM;then return 0;fi

	local lstrItem="$1";shift
	local lstrVal="$1";shift

	if [[ -z "${anOriginalDBMValueList[$lstrItem]-}" ]];then
		anOriginalDBMValueList[$lstrItem]="$lstrVal"	
		bOrigValListChanged=true
		
		echo "anOriginalDBMValueList[$lstrItem]=\"$lstrVal\"" |tee -a "$strFileRunLog" >>"$strCacheValBkpFile"
	fi	
}

function FUNCexec(){ #[--fixcr] removes CR from output
	bFixOutputCR=false
	if [[ "$1" == "--fixcr" ]];then bFixOutputCR=true;shift;fi
	
	local lstr="EXEC: `FUNCarrayReport "$@"`"
	if $bOptVerboseUEXP;then echo "$lstr" >>/dev/stderr;fi
	echo                   				"$lstr" >>"$strFileRunLog"
	
	#####
	## do NOT use tee, it ignores (of course) the cmd return value
	#####
	
#	"$@" 2>&1 |tee -a "$strFileRunLog"

	# WHY this may not work as expected?: local lstrOutput="`"$@" 2>&1`"&&:;local lnRet=$?;
	local lstrOutput
	local lstrErr
	local lnRet
	# WHY this may not work as expected?: lstrErr="$(lstrOutput="$("$@")" 2>&1)"&&:;local nRet=$?;
#	if lstrErr=$(lstrOutput=$("$@"); 2>&1);then lnRet=$?; else	lnRet=$?; fi #necessary to work properly...
#	source lstrErr=$({ lstrOutput=$("$@"); lnRet=$?; } 2>&1);
	source <({ lstrErr=$({ lstrOutput=$("$@")&&:; lnRet=$?; } 2>&1; declare -p lstrOutput lnRet >&2); declare -p lstrErr; } 2>&1)
	#echo "lstrErr=<'$lstrErr'>"
	#if lstrOutput="`"$@" 2>&1`";then local lnRet=$?; else	local lnRet=$?; fi #necessary to work properly...
	if $bFixOutputCR;then lstrOutput="`echo "$lstrOutput" |tr -d "\r"`";fi #removes windows CR from results
	echo "EXEC_OUTPUT: '$lstrOutput'" >>"$strFileRunLog"
	if((lnRet!=0));then
		local lstrErrMsg="EXEC_MSG_ERR: '$lstrErr'"
		if [[ -n "$lstrErr" ]];then 
			echo "$lstrErrMsg" >>/dev/stderr;
			echo "$lstrErrMsg" >>"$strFileRunLog"
		fi
		
		echo "EXEC_RET_VAL: '$lnRet'" >>"$strFileRunLog"
	fi
	echo >>"$strFileRunLog"
	
	if [[ -n "$lstrOutput" ]];then
		echo "$lstrOutput"
	fi
	
	return $lnRet
}

function FUNCechoFastCond(){ # quick conditional show or not to end user (verbose), but will always log
	local lbShow="$1";shift
	local lstrMsg="$@"
	if $lbShow;then echo -e "$lstrMsg";fi
	echo -e "$lstrMsg" >>"$strFileRunLog"
}

function FUNCechoDbg(){
	echo ">>> DBG: $@" >>"$strFileRunLog"
	echo >>"$strFileRunLog"
}

function FUNCechoImportant(){
	FUNCecho "$@"
	read -p "Important message above, press a key to continue..." -n 1
}

function FUNCecho(){
	echo >>/dev/stderr
	local lstrTime="`date +"%H%M%S.%N"`"
	echo -e ">>> [$lstrTime] $@ <<<" >>/dev/stderr
	echo -e ">>> [$lstrTime] $@ <<<" >>"$strFileRunLog"
	if $bOptPauseBetweenUEXP;then
		echo "([$lstrTime] Press ENTER key to continue or hit Ctrl+c to exit)" >>/dev/stderr
		read
	fi
	echo >>/dev/stderr
}

function FUNCdumpArrayDbg(){
	local lbForce=false
	if [[ "$1" == "--force" ]];then lbForce=true;shift;fi
	
	local lstrArrayId="${1-}"
	
	if declare -p $lstrArrayId >>/dev/null 2>&1;then
		local lbShow=$bOptVerboseUEXP
		local lpipeOutput="/dev/null"
		if $lbForce;then 
			lbShow=true;
			lpipeOutput="/dev/stdout"
		fi
		
		local lcmdSort="cat" #skipper
		if declare -p $lstrArrayId |egrep -q "declare -[^ ]*A";then
			lcmdSort="sort"
		fi
		
		local lstrMsg="ArrayDump: $lstrArrayId"
		if $lbShow;then FUNCecho "$lstrMsg";fi
		FUNCechoDbg "$lstrMsg"
		
#		declare -p $1 |tr "[" "\n" |egrep "[]]" |sort
		declare -n refArray="$lstrArrayId"
		for strIndexId in "${!refArray[@]}";do
#			local lstrRefValueAt="!$lstrArrayId[$strIndexId]"
			local lstrOutput="\t$lstrArrayId[$strIndexId]=\"${refArray[$strIndexId]}\""
#			if $lbShow;then echo -e "$lstrOutput";fi
			echo -e "$lstrOutput"
#			echo -e "$lstrOutput" >>"$strFileRunLog"
		done |$lcmdSort |tee -a "$strFileRunLog" >>$lpipeOutput
		echo
	else
		FUNCechoDbg "array not found: $lstrArrayId"
	fi
}

#function FUNCxmlPath(){
#	local lstrItem="$1";shift
#	local lnAction="$1";shift
#	echo "/items/item[@name='${lstrItem}']/property[@class='Action${lnAction}']/property[@name='DamageBonus.head']/@value"
#}

function FUNCxmlPath(){ # <item> "[action]" [property]
	local lstrItem="$1";shift
	local lnAction="$1";shift # can be empty "" but not unset
	local lstrProp="${1-}";shift
	
	local lstrActionPart=""
	if [[ -n "$lnAction" ]];then
		lstrActionPart="/property[@class='Action${lnAction}']"
	fi
	
	if [[ -z "${lstrProp-}" ]];then
		lstrProp="DamageBonus.head"
	fi
	local lstrPropertyPart="/property[@name='$lstrProp']"
	
	local lstrOutput="/items/item[@name='${lstrItem}']${lstrActionPart}${lstrPropertyPart}/@value"
	echo "$lstrOutput"
	
	if $bOptVerboseUEXP;then	echo "XPATH: $lstrOutput" >>/dev/stderr;fi
}

function FUNCexecxml(){
	#trap >>/dev/stderr
	if [[ "$1" == "sel" ]];then 
		#DO NOT DO THIS!: if ! FUNCexec --fixcr xmlstarlet "$@";then FUNCexit $nErrorRestoreBackup;fi		
		FUNCexec --fixcr xmlstarlet "$@" #&&:;local lnRet=$?;
		#echo ">>$FUNCNAME>>$lnRet" >>/dev/stderr
		#echo ">>>>>$lnRet"
#		return $lnRet
		return $? #not 0 because it may not be err trapped
#		return $lnRet #not 0 because it may not be err trapped
	fi
	
	if [[ "$1" == "ed" ]];then 
		#DO NOT DO THIS!: if ! FUNCexec xmlstarlet "$@";then FUNCexit $nErrorRestoreBackup;fi		
		FUNCexec xmlstarlet "$@" #&&:;local lnRet=$?;
#		return $lnRet
		return $? #not 0 because it may not be err trapped
	fi
	
	FUNCecho "DEV_OVERLOOK:UNSUPPORTED: `FUNCarrayReport "$@"`"
	FUNCexit $nErrorRestoreBackup
}

function FUNCxmlFillExtends(){
	local lstrItem="$1";shift
	
	local lstrVal=$(FUNCexecxml sel -t -v "`FUNCxmlPath "$lstrItem" "" Extends`" "$strWorkFile")
	
	if [[ -n "$lstrVal" ]];then
		if [[ -z "${astrExtendsList[$lstrItem]-}" ]];then
			echo "astrExtendsList[$lstrItem]=\"$lstrVal\"" >>"$strCacheExtendsFile"
		fi
		
		astrExtendsList[$lstrItem]="$lstrVal"
		
		return 0;
	fi
		
	return 1
}

function FUNCapplyExtends(){
	local lstrItem="$1";shift
	local lstrExtends="$1";shift
	local lnAct="$1";shift
	
	echo -e "\tApplyingExtendsOn: lnAct='$lnAct',\tlstrItem='$lstrItem',\tlstrExtends='$lstrExtends'"
	
	local lnValue="${anOriginalDBMValueList[$lstrExtends]}"
	
	if ! FUNCexecxml sel -t -c "/items/item[@name='$lstrItem']/property[@class='Action${lnAct}']" "$strWorkFile" >>/dev/null;then
		# This basically creates a new property with a non conflictable identifier, and after it is completely setup, renames that id to 'property'
		FUNCexecxml ed -P -L -s "/items/item[@name='$lstrItem']" \
			-t elem -n "property_DUMMY_TMP" -v "" \
			-i "//property_DUMMY_TMP" -t attr -n "class"  -v "Action${lnAct}" \
			-r "//property_DUMMY_TMP" -v "property" \
			"$strWorkFile"
	fi
	
	FUNCexecxml ed -P -L -s "/items/item[@name='$lstrItem']/property[@class='Action${lnAct}']" \
		-t elem -n "property_DUMMY_TMP" -v "" \
		-i "//property_DUMMY_TMP" -t attr -n "name"  -v "DamageBonus.head" \
		-i "//property_DUMMY_TMP" -t attr -n "value" -v "$lnValue" \
		-r "//property_DUMMY_TMP" -v "property" \
		"$strWorkFile"
	
	bAllowFindActValStoreOrigDBM=true	
	FUNCstoreOrigDBM "$lstrItem" "$lnValue"
	#~ if ! FUNCxmlFillActDBM "$lstrItem" "$lnAct";then 
		#~ FUNCecho "PROBLEM!!! unable to fill lnAct='$lnAct' or store DBM lnValue='$lnValue' for patched (extended) lstrItem='$lstrItem'  "
		#~ FUNCexit 1
	#~ fi 
	bAllowFindActValStoreOrigDBM=true	
}

function FUNCxmlFillActDBM(){
	local lstrItem="$1";shift
	local nAct="$1";shift
	
	local lstrVal=$(FUNCexecxml sel -t -v "`FUNCxmlPath "$lstrItem" $nAct`" "$strWorkFile")
	if [[ -n "$lstrVal" ]];then
		anActionList[$lstrItem]="$nAct"
#		echo "$nAct";
		FUNCstoreOrigDBM "$lstrItem" "$lstrVal"
		return 0;
	fi
		
	return 1
}

function FUNCxmlFindAct(){
	local lbQuiet=false;if [[ "$1" == "--quiet" ]];then lbQuiet=true;shift;fi
	local lstrItem="$1";shift
	
	if FUNCxmlFillActDBM "$lstrItem" 0;then return 0;fi #echo -e "\t${lstrItem}->0";
	if FUNCxmlFillActDBM "$lstrItem" 1;then return 0;fi
	
	if ! $lbQuiet;then FUNCecho "PROBLEM!!! no action for item lstrItem='$lstrItem'?";fi
	return 1 # failed to find
}

###########################################################################
######################################## System validation
###########################################################################

if $bClearLogFileEXP;then echo >"$strFileRunLog";fi

echo "<> <> <> ModVersion($strVersion),$strRunId <> <> <>" |tee -a "${strFileRunLog}"
echo "MD5Self=$strSelfMd5" >>"${strFileRunLog}"
echo

: ${bShowDepsEXP:=true};export bShowDepsEXP
FUNCsysValid bash #just to show the version
FUNCsysValid grep #just to show the version
FUNCsysValid bc
FUNCsysValid tee
FUNCsysValid sed
FUNCsysValid xmlstarlet
echo
bShowDepsEXP=false #top runner only

###########################################################################
######################################## OPTIONS
###########################################################################

if [[ -z "${@-}" ]];then 
	bOptPauseBetweenUEXP=false
	$0 --help;
	exit 0; # do not use FUNCexit here to lower unnecessary messages
fi

while ! ${1+false} && [[ "${1:0:1}" == "-" ]];do # checks if param is set
	if [[ "$1" == "--help" ]];then #help show this help
		echo "Help:"
		nHelpIndex=1
		echo -e "\t<$((nHelpIndex++))> DBM stands for: Damage Bonus Multiplier, and this script can further multiply it or just override it."
		echo -e "\tCache files will be created to speed up subsequent runs."
		echo
		echo -e "\t<$((nHelpIndex++))> You can add new items on the command line as parameters to this script ex.:"
		echo -e "\t$0 -- clubWood clubIron:x8 fireaxeSteel:=100"
		echo
		echo -e "\t<$((nHelpIndex++))> Example of applying patch while using many options:"
		echo -e "\t$0 -x 9 -a -P -- clubIron:x12 clubWood"
		echo
		echo -e "\t<$((nHelpIndex++))> Config variables:"
#		for strVar in "`egrep "[U]CFG:=" $0 |sed -r "s'.*[{]([^:]*):=.*'\t\1'"`";do
#			echo -e "\t`declare -p $strVar`"
#		done
		declare -p `egrep "[U]CFG:=" $0 |sed -r "s'.*[{]([^:]*):=.*'\1'"` |sed -r 's".*"\t&"' |sort
		echo
		echo -e "\t<$((nHelpIndex++))> Exported variables (for nested calls):"
#		egrep "[U]EXP:=" $0 |sed -r "s'.*[{]([^:]*):=.*'\t\1'"
#		for strVar in "`egrep "[U]EXP:=" $0 |sed -r "s'.*[{]([^:]*):=.*'\t\1'"`";do
#			echo -e "\t`declare -p $strVar`"
#		done
		declare -p `egrep "[U]EXP:=" $0 |sed -r "s'.*[{]([^:]*):=.*'\1'"` |sed -r 's".*"\t&"' |sort
		echo
		echo -e "\t<$((nHelpIndex++))> Internal functions help:"
#		egrep "^function [^(]*[(][)][{] #help" "$0" |sed -r "s'^function ([^(]*)[^#]*help (.*)$'\t\1 \2'"
		egrep "^function .*[#]help .*" "$0" |sed -r "s'^function ([^(]*)[^#]*[#]help (.*)$'\t\1 \2'" |sort
		echo
		echo -e "\t<$((nHelpIndex++))> Custom modding framework:"
		echo -e "\t+ Change anything you want in any file."
		echo -e "\t+ Helps you create any custom mods you can imagine."
		echo -e "\t+ Store these changes/commands as a script to easily apply in future releases."
		echo -e "\t- To create new nodes, look for 'property_DUMMY_TMP' inside this script, or at the log file for the full commands."
		echo -e "\tExamples (bonus mods):"
		echo -e "\t$0 --call FUNCmodCustom -- entityclasses.xml Backpack TimeStayAfterDeath value 3600000 #dropped backpacks will last 1000 hours (41 days)"
		echo -e "\t$0 --call FUNCaddRecipe -- arrow 1 rockSmall 1 wood 1 @paper 1"
		echo -e "\t$0 --call FUNCaddRecipe -- arrow 2 rockSmall 2 wood 2 @oldCash 1 #better quality 'paper'"
		echo -e "\t$0 --call FUNCaddRecipe -- arrow 1 rockSmall 1 wood 1 @yuccaFibers 10 #grass is too cheap"
		echo -e "\t$0 --call FUNCaddRecipe -- femur 1 @boneShiv 2 #just to recover a femur for other recipes..."
		echo -e "\t$0 --call FUNCaddRecipe -- craft_time=1 emptyJar 1 @bottledWater 1 #just to empty the jar..."
		echo -e "\t$0 --call FUNCaddRecipe -- craft_time=1 emptyJar 1 @bottledRiverWater 1 #just to empty the jar..."
		echo -e "\t$0 --call FUNCaddRecipe -- craft_time=1 bottledRiverWater 1 @bottledWater 1 #downgrade just to easify recipes depending on murky water..."
		echo -e "\t$0 --call FUNCaddRecipe -- craft_time=1 feather 1 @arrow 1 #to recover the precious feather..."
		echo -e "\t$0 --call FUNCaddRecipe -- craft_area=chemistryStation beer 1 hopsFlower 4 @bottledWater 1 #just an example of recipe attributes that can be many"
		echo -e "\t$0 --call FUNCmakeXmlPrettyReadable -- recipes.xml"
		echo -e "\t$0 --call FUNCbonusModUnlockDoors"
		echo -e "\t$0 --call FUNCbinaryPatch -- '7DaysToDie_Data/resources.assets' 'PhysicsCrouchHeightModifier 0[.]63' 'PhysicsCrouchHeightModifier 0.50' #This is just an alternative patching method for original mod at https://7daystodie.com/forums/showthread.php?41860-Crouching-Through-1-Block-Tall-Spaces-UABE"
		echo
		echo "Options:"
		strHelp="`egrep "[#]help" "$0" |egrep -v "^([[:blank:]]*#|function)"`" 
		if which sed >>/dev/null;then
		 echo "$strHelp" |sed -r "s'.*\"(-[^\"]*)\".*[#]help(.*)'\t\1\t\2'"
		else
		 echo "$strHelp"
		fi
		exit 0; # do not use FUNCexit here to lower unnecessary messages
	elif [[ "$1" == "-A" ]];then #help fully apply all default patch options (easy/simple). It recursively calls this very script some times. Some options are passed to the sub calls, see Exported variables above. Also the custom items you want to add will work together with this option too.
		bOptFullSimplePatch=true
		bOptPauseBetweenUEXP=false
	elif [[ "$1" == "-a" ]];then #help apply patch now (will run only the apply patch procedure)
		bOptApplyPatchNow=true
	elif [[ "$1" == "--noBlackList" ]];then #help disable black list items validation, allowing any item to be patched
		bOptUseItemBlackListUEXP=false
	elif [[ "$1" == "-P" ]];then #help do NOT pause between tasks preventing you from calmly reading them
		bOptPauseBetweenUEXP=false
	elif [[ "$1" == "-x" ]];then #help <nOptDBMmultUEXP> use this global DBM multiplier instead of default one
		shift
		nOptDBMmultUEXP="${1-}"
	elif [[ "$1" == "-c" ]];then #help clear default list and lets you chose each every item to be considered
		bOptClearDefaultList=true
	elif [[ "$1" == "-l" ]];then #help will list items not on the default list so you can add them
		bOptListNew=true
	elif [[ "$1" == "-L" ]];then #help like -l, but will also show the items this script is unable to patch without applying the Extends
		bOptListNew=true
		bOptShowNotPatchable=true
	elif [[ "$1" == "-v" ]];then #help verbose, shows extra and debug info
		bOptVerboseUEXP=true
	elif [[ "$1" == "--applyExtends" ]];then #help this option will make items compatible with this patcher by applying their extended-item value
		bOptListNew=true
		bOptShowNotPatchable=true
		bOptApplyExtends=true
	elif [[ "$1" == "--clearCache" ]];then #help clear this mod cache files then exit
		bOptClearCache=true
		bOptPauseBetweenUEXP=false
	elif [[ "$1" == "--call" ]];then #help <strFuncId> lets you directly call an internal function. The remaining params (after --) will be used as the internal funcion's params. See example above. Run this option alone (tho some options like -v and --nobackup will work fine).
		shift;strOptFuncId="${1-}"
		bOptCallFunc=true
		bOptPauseBetweenUEXP=false #must be here
	elif [[ "$1" == "--cfg" ]];then #help <strCfgId> <strCfgValue> changes a config variable for the script, see above. Run it alone.
		shift;strCfgId="${1-}"
		shift;strCfgValue="${1-}"
		bOptPauseBetweenUEXP=false
	elif [[ "$1" == "--nobackup" ]];then #help will not create backup on the current run
		bOptBackupUEXP=false
	elif [[ "$1" == "--test" ]];then #put no help here, internal tests
		bTestDbg=true
		bOptPauseBetweenUEXP=false
		bOptVerboseUEXP=true
	elif [[ "$1" == "--" ]];then #help <<itemId[[:=<nOverride>]|[:x<nMult>]]> ...> after this param, new items can be added to the patching work, individual item DBM override can be customized with ex.: "clubIron:=75". Or it can be a custom multiplier like "clubIron:x13"
		shift
		while ! ${1+false};do	# checks if param is set
			astrRemainingParams+=("$1")
			shift #will consume all remaining params
		done
	else
		bOptPauseBetweenUEXP=false
		FUNCecho "invalid option '$1'"
		$0 --help #$0 considers ./, works best anyway..
		FUNCexit 1
	fi
	shift&&:
done
if [[ -n "$@" ]];then
	FUNCecho "Unrecognized params: $@"
	FUNCexit 1
fi
FUNCdumpArrayDbg astrRemainingParams

###########################################################################
######################################## CONFIG
###########################################################################

if [[ -n "${strCfgId-}" ]];then
	FUNCecho "Current Value:"
	declare -p "$strCfgId"&&:
	
	FUNCecho "Set Value:"
	if [[ -f "$strConfigFile" ]];then
		sed -i "/^export $strCfgId=\".*/d" "$strConfigFile"
	fi
	echo "export $strCfgId=\"$strCfgValue\";" |tee -a "$strConfigFile"
	
	FUNCecho "Config file:"
	FUNCexec cat "$strConfigFile"
	
	FUNCexit 0
fi

# Consistency grants
#declare -p strConfigVersion strVersion
if ! $bConfigFileExist || [[ "${strConfigVersion-}" != "$strVersion" ]];then
	$0 --cfg strConfigVersion "$strVersion" #initialize BEFORE FURTHER CALLS!!!!
	if $bConfigFileExist;then
		FUNCecho "This script was updated from '${strConfigVersion-}' to '${strVersion}', auto cleaning cache files for quality/consistency."
		bAutoClearSkipProtectedEXP=true $0 -P --clearCache
	fi
fi

if [[ ! -d "$strGameInstallPathUCFG" ]];then
	# try to guess
	if [[ -f "./${strBaseWorkFile}" ]];then # at Data/Config/
		strGameInstallPathUCFG="../../"
	elif [[ -f "../${strRelativePathWorkFile}/${strBaseWorkFile}" ]];then # at 7DTD/modFolder/
		strGameInstallPathUCFG="../"
	elif [[ -f "./${strRelativePathWorkFile}/${strBaseWorkFile}" ]];then # at 7DTD install folder
		strGameInstallPathUCFG="./"
	else
		FUNCecho "PROBLEM: unable to guess game install path. So, invalid strGameInstallPathUCFG='$strGameInstallPathUCFG', see mod install instructions."
		FUNCexit 1
	fi
fi

# main work file
strGameInstallPathUCFG="`readlink -e "$strGameInstallPathUCFG"`" #workaround for windows pathing
strWorkFile="${strGameInstallPathUCFG}/${strRelativePathWorkFile}/${strBaseWorkFile}"
if [[ ! -f "$strWorkFile" ]];then
	FUNCecho "PROBLEM: missing strWorkFile='$strWorkFile'"
	FUNCexit 1
fi

###########################################################################
######################################## Fast call internal functions
###########################################################################

if $bOptCallFunc;then
	#bOptVerboseUEXP=true
 	FUNCecho "Calling: $strOptFuncId `FUNCarrayReport "${astrRemainingParams[@]-}"`"
	$strOptFuncId "${astrRemainingParams[@]-}" #do not use with FUNCexec as messed the log
	FUNCexit 0
fi

###########################################################################
######################################## VALIDATE and APPLY OPTIONS
###########################################################################

if $bTestDbg;then FUNCexec ls "dbgTest$RANDOM";exit 0;fi

if $bOptClearCache;then
	#FUNCexec rm -vf "$strConfigPath/$strSelf.cache-"*".cfg"
	IFS=$'\n' read -d '' -r -a astrCacheFileList < <(find "$strConfigPath/" -iname "$strSelf.cache-*.cfg")&&:
	for strCacheFile in "${astrCacheFileList[@]-}";do
		if $bAutoClearSkipProtectedEXP;then
			if [[ "$strCacheFile" =~ .*[.]PROTECTED.* ]];then
				FUNCecho "skipping strCacheFile='$strCacheFile'"
				continue
			fi
		fi
		
		FUNCexec rm -vf "$strCacheFile"
	done
	FUNCechoImportant "it is recommended to restore the oldest/first backup of '$strWorkFile' of before the first apply of this patcher, before continuing (hit ctrl+c to stop this script so you can do that if you want)."
	FUNCexit 0
fi

if [[ ! -f "$strWorkFile" ]];then
	FUNCecho "PROBLEM!!! file $strWorkFile is missing, is it in the right path?"
	FUNCexec pwd
	FUNCexit 1
fi

if ! FUNCisValidNumber $nOptDBMmultUEXP;then
	echo "invalid nOptDBMmultUEXP='$nOptDBMmultUEXP'"
	FUNCexit 1
fi

if $bOptClearDefaultList;then
	astrWorkItemList=()
	FUNCecho "Default list was cleared for this script run only!"
fi

################### custom items
if [[ -n "${astrRemainingParams[@]-}" ]];then
#	if $bOptFullSimplePatch;then
#		FUNCecho "PROBLEM: to add "
#	fi
	
	for strNewItem in "${astrRemainingParams[@]}";do
		if [[ -z "$strNewItem" ]];then continue;fi
		
		echo -e "\tAdding new item: $strNewItem"
		
		if echo "$strNewItem" |grep -q ":";then
			strCustomValue="`echo "$strNewItem" |cut -d":" -f2`"
			strNewItem="`    echo "$strNewItem" |cut -d":" -f1`"
			astrCustomValue[$strNewItem]="$strCustomValue"
		fi
		
		if ! echo "${astrWorkItemList[@]-}" |grep -qw "$strNewItem";then
			astrWorkItemList+=("$strNewItem")
		fi
	done
	astrWorkItemList=(`echo "${astrWorkItemList[@]}" |tr " " "\n" |sort`)
	
	FUNCdumpArrayDbg --force astrCustomValue
fi
#declare -p astrWorkItemList |tr "[" "\n"
#FUNCecho "ALL ITEMS THAT WILL BE PATCHED ABOVE"

#################### VALIDATE work list

# protected caches may be present, so load them now to avoid filling them with new values
anOriginalDBMValueList=()
FUNCloadCache anOriginalDBMValueList "$strCacheValBkpFile"&&:

if((${#astrWorkItemList[@]-}>0));then
	if $bOptUseItemBlackListUEXP;then
#		FUNCecho "black listed items:"
		if $bShowDefaultRevalidationEXP;then
			FUNCdumpArrayDbg --force astrItemsBlackList
			echo
		fi
	fi
	
	if $bShowDefaultRevalidationEXP;then FUNCecho "Revalidating default list:";fi
	astrWorkItemListBkp=("${astrWorkItemList[@]-}")
	FUNCechoDbg "tot:astrWorkItemList=${#astrWorkItemList[@]-}"
	astrWorkItemList=()
	for strNewItem in "${astrWorkItemListBkp[@]}";do
		if $bOptUseItemBlackListUEXP;then
			if echo "${astrItemsBlackList[@]-}" |grep -qw "$strNewItem";then
				FUNCecho "PROBLEM: Black listed item '$strNewItem' still forbidden, see --help option."
				FUNCexit 1
			fi
		fi
		
		echo -en "\t${strNewItem}                                 \r"
		if FUNCxmlFindAct --quiet "$strNewItem";then
			astrWorkItemList+=("$strNewItem")
			FUNCechoFastCond $bShowDefaultRevalidationEXP "\tValid:    $strNewItem" 
#			if $bShowDefaultRevalidationEXP;then echo -e "\tValid:    $strNewItem";fi
		else
			FUNCechoFastCond $bShowDefaultRevalidationEXP "\tREMOVING: $strNewItem (requires extends or is unsupported/missing)"
#			if $bShowDefaultRevalidationEXP;then echo -e "\tREMOVING: $strNewItem (requires extends or is unsupported/missing)";fi
		fi
	done
	echo -e "\tValid items count: ${#astrWorkItemList[@]}                         " |tee -a "$strFileRunLog" #no FUNCecho, to overwrite the last progress line
#	FUNCechoDbg "totValid:astrWorkItemList=${#astrWorkItemList[@]-}"
	echo
fi

astrAllItems=(`FUNCexecxml sel -t -v "/items/item/@name" "$strWorkFile" |sort`)
FUNCdumpArrayDbg astrAllItems
FUNCechoDbg "astrAllItems:tot=${#astrAllItems[@]}"

############################ first time will prepare caches
#bRecreateCache=false
#function FUNCsaveCache(){
#	FUNCecho "Filling Extends cache (first time is slow)."
#	echo >"$strCacheExtendsFile" #clear it
#	
#	iCount=0
#	for strNewItem in "${astrAllItems[@]}";do
#		((iCount++))&&:
#		echo -en "CheckAndFillExtends($iCount/${#astrAllItems[@]}): $strNewItem.\r"
#		FUNCxmlFillExtends "$strNewItem"&&:
#	done
#}

astrExtendsList=()
FUNCloadCache astrExtendsList    "$strCacheExtendsFile"   &&:;nRet=$?
#if((nRet!=0));then bRecreateCache=true;fi
if((nRet!=0));then 
#	FUNCsaveCache 
	FUNCecho "Filling Extends cache (first time is slow)."
	echo >"$strCacheExtendsFile" #clear it
	
	iCount=0
	for strNewItem in "${astrAllItems[@]}";do
		((iCount++))&&:
		echo -en "CheckAndFillExtends($iCount/${#astrAllItems[@]}): $strNewItem.\r"
		FUNCxmlFillExtends "$strNewItem"&&:
	done
fi
FUNCdumpArrayDbg astrExtendsList

astrPatchableItems=()
#	if [[ -f "$strCacheValidItemsFile" ]] && ((`cat "$strCacheValidItemsFile" |wc -l`>0)) && egrep -q "^astrPatchableItems";then
FUNCloadCache astrPatchableItems "$strCacheValidItemsFile"&&:;nRet=$?
#if((nRet!=0));then bRecreateCache=true;fi
if((nRet!=0));then
#fi
#if egrep -q "^astrPatchableItems" "$strCacheValidItemsFile" >>/dev/null 2>&1;then
#	FUNCecho "loading cache: $strCacheValidItemsFile"
#	source "$strCacheValidItemsFile"
#	source "$strCacheExtendsFile"
#else
#if $bRecreateCache;then
	FUNCecho "All proper items will be validated to determine if this script's current algorithm complexity can handle them (first time is slow)."
	echo >"$strCacheValidItemsFile" #clear it
	astrNotSupportedItems=()
#	iCount=0
#	for strNewItem in "${astrAllItems[@]}";do
#		((iCount++))&&:
#		echo -en "CheckAndFillExtends($iCount/${#astrAllItems[@]}): $strNewItem.\r"
#		FUNCxmlFillExtends "$strNewItem"&&:
#	done
	
	iCount=0
	for strNewItem in "${astrAllItems[@]}";do
		((iCount++))&&:
		echo -en "Pre-validate($iCount/${#astrAllItems[@]}): $strNewItem.\r"
#		echo -en "Validating: $strNewItem                          \r"
	
#		FUNCxmlFillExtends "$strNewItem"&&:
		
		bAllowFindActValStoreOrigDBM=true
		if FUNCxmlFindAct --quiet "$strNewItem";then
			astrPatchableItems+=($strNewItem)
		else
			astrNotSupportedItems+=($strNewItem)
		fi
		bAllowFindActValStoreOrigDBM=false
	done
	
	for((i=0;i<${#astrPatchableItems[@]-};i++));do
		strNewItem="${astrPatchableItems[$i]}"
		echo "astrPatchableItems[$i]=\"$strNewItem\"" >>"$strCacheValidItemsFile"
	done
	
	FUNCechoDbg "tot:astrNotSupportedItems=${#astrNotSupportedItems[@]-}"
fi
FUNCechoDbg "tot:astrPatchableItems=${#astrPatchableItems[@]-}"
_FUNCimpossibleCheck01
FUNCdumpArrayDbg anActionList
echo

anOriginalDBMValueList=()
FUNCloadCache anOriginalDBMValueList "$strCacheValBkpFile"&&:;nRet=$?
if((nRet!=0));then
	FUNCecho "WARNING: Better restore the vanilla or oldest/first backup of '$strWorkFile'"
	FUNCexit $nErrorRestoreBackup
fi

###########################################################################
######################################## EXCLUSIVELY RUNNABLE OPTIONS
###########################################################################

if $bOptFullSimplePatch;then
	
	bShowDefaultRevalidationEXP=false
	bClearLogFileEXP=false
	
#	if [[ "${strConfigVersion-}" != "$strVersion" ]];then
#		FUNCecho "This script was updated from '${strConfigVersion-}' to '${strVersion}', auto cleaning cache files for quality/consistency."
#		$0 -P --clearCache
#		$0 --cfg strConfigVersion "$strVersion"
#	fi
	
	nShotgunMult=200
	$0 -P --applyExtends #DO NOT USE FUNCexec !!!!!!!! because will mess the log zipping!
	$0 -P -a -- gunPumpShotgun:x$nShotgunMult gunSawedOffPumpShotgun:x$nShotgunMult blunderbuss:x$nShotgunMult	"${astrRemainingParams[@]-}" #DO NOT USE FUNCexec !!!!!!!! because will mess the log zipping!
	FUNCexit 0
	
elif $bOptListNew;then
	
	if $bOptShowNotPatchable;then
		#astrExtAndActList=()
		for strNewItem in "${astrAllItems[@]}";do
			if [[ -z "${anActionList[$strNewItem]-}" ]];then # there is already no action containing requirements
				strExtended="${astrExtendsList[$strNewItem]-}"
				if [[ -n "$strExtended" ]];then # but extends another
					if [[ -n "${anActionList[$strExtended]-}" ]];then # and the extended has valid action!
						if ! FUNCxmlFindAct --quiet "$strNewItem";then # and make it sure/confirm there REALLY is no action looking at the xml file
							astrExtAndActList+=($strNewItem)
						fi
					fi
				fi
			fi
		done
		
		if [[ -n "${astrExtAndActList[@]-}" ]];then
#			declare -p astrExtAndActList
			FUNCdumpArrayDbg --force astrExtAndActList
			FUNCecho "Extends can be applied to these currently unsupported items above, making them patchable by this patcher:"
		else
			FUNCecho "No Extends' pending items found."
		fi
	fi
		
#	for strNewItem in "${astrAllItems[@]}";do
#		FUNCxmlFillExtends "$strNewItem"&&:
#	done
#	FUNCdumpArrayDbg astrExtendsList
#	echo
	
#	if $bOptShowNotPatchable;then
#		echo
#		FUNCecho "Some of these items below may be MANUALLY patchable by you, others not. This patch complexity does NOT support any of them, as it's xml is still too complex for this script. This limitation is mainly related to the property 'Extends' (inherited values)."
#		for strNewItem in "${astrNotSupportedItems[@]}";do
#			echo -e "\t$strNewItem"
#		done
#	fi
#	echo
	
	FUNCecho "Default supported items list:"
	for strNewItem in "${astrWorkItemList[@]}";do
		strExtends="${astrExtendsList[$strNewItem]-}"
		if [[ -n "$strExtends" ]];then
			strExtends="\t(Extends:$strExtends)"
		fi
		
		echo -e "\t$strNewItem${strExtends}"
	done
	echo
	
	FUNCecho "You can add these extra patchable items below (if there is any) to this script parameters, and see if they will work on the game (this list will increase if Extends are applied):"
	for strNewItem in "${astrPatchableItems[@]}";do
		if echo "${astrWorkItemList[@]-}" |grep -qw "$strNewItem";then continue;fi
		if $bOptUseItemBlackListUEXP;then
			if echo "${astrItemsBlackList[@]-}" |grep -qw "$strNewItem";then continue;fi
		fi
		
		strExtends="${astrExtendsList[$strNewItem]-}"
		if [[ -n "$strExtends" ]];then
			strExtends="\t(Extends:$strExtends)"
		fi
		
		echo -e "\t$strNewItem${strExtends}"
	done
	echo
	
	if $bOptApplyExtends && [[ -n "${astrExtAndActList[@]-}" ]];then
		FUNCBkpMain
		for strNewItem in "${astrExtAndActList[@]}";do
			strExtended="${astrExtendsList[$strNewItem]}"
			FUNCapplyExtends $strNewItem $strExtended ${anActionList[$strExtended]}
		done
		
		FUNCecho "Now that extends were applied, these items will be available for patching, re-run to see the new available items!"
	fi
	
	FUNCexit 0
fi

###########################################################################
######################################## MAIN (pacthing happens below here)
###########################################################################

if ! $bOptApplyPatchNow;then $0 --help;FUNCexit 0;fi

FUNCecho "nOptDBMmultUEXP='${nOptDBMmultUEXP}'"

FUNCBkpMain

for strItem in "${astrWorkItemList[@]}";do
	if ! FUNCxmlFindAct "$strItem";then
		FUNCecho "PROBLEM!!! unsupported/invalid item: lstrItem='$strItem'"
		FUNCexit 1
	fi
#	anActionList[$strItem]="`FUNCxmlFindAct "$strItem"`"
done

# apply
for strItem in "${astrWorkItemList[@]}";do
	FUNCechoDbg "strItem='$strItem'"
	
	nAction="${anActionList[$strItem]}"
	FUNCechoDbg "nAction='$nAction'"
	
	nOriginalDBM="${anOriginalDBMValueList[$strItem]}"
	FUNCechoDbg "nOriginalDBM='$nOriginalDBM'"
	
	nNewDBM="`FUNCcalc $strItem $nOriginalDBM ${astrCustomValue[$strItem]-}`"
	FUNCechoDbg "nNewDBM='$nNewDBM'"
	
	echo -e "\tpatching nAction='$nAction',\tnOriginalDBM='$nOriginalDBM',\tnNewDBM='$nNewDBM',\tstrItem='$strItem'" |tee -a "$strFileRunLog"
	FUNCexecxml ed -P -L -u "`FUNCxmlPath "$strItem" $nAction`" -v "$nNewDBM" "$strWorkFile"
	
	# verify
	nAppliedPatchValue=$(FUNCexecxml sel -t -v "`FUNCxmlPath "$strItem" $nAction`" "$strWorkFile")
	FUNCechoDbg "nAppliedPatchValue='$nAppliedPatchValue'"
	if [[ "$nAppliedPatchValue" != "$nNewDBM" ]] || ! FUNCisValidNumber "$nAppliedPatchValue";then
		FUNCecho "PROBLEM!!! something went wrong... nAppliedPatchValue='$nAppliedPatchValue' nNewDBM='$nNewDBM'"
#		FUNCexecxml sel -t -c "`FUNCxmlPath "$strItem" $nAction`" "$strWorkFile"
		FUNCexit $nErrorRestoreBackup
	fi
done

FUNClogZip
FUNCecho "If you think that there is something wrong, $strErrDbgSendMsg"

FUNCecho "Patch completed successfully, have fun!"

FUNCexit 0 #just to log properly

