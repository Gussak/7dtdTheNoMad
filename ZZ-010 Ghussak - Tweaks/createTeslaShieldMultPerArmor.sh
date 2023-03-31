#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#strFlGenLoc="Config/Localization.txt"
#strFlGenXml="Config/items.xml"
#strFlGenRec="Config/recipes.xml"
#strGenTmpSuffix=".GenCode.TMP"
#trash "${strFlGenLoc}${strGenTmpSuffix}"&&:
#trash "${strFlGenRec}${strGenTmpSuffix}"&&:
#trash "${strFlGenXml}${strGenTmpSuffix}"&&:
source ./gencodeInitSrcCONFIG.sh

astrArmorTypes=( # values based on protection value, so if they change the protection it should be updated here
  "Cloth|Santa" 0.20
  Leather 0.40
  "Scrap|Military|Iron|Football|Swat|Mining" 0.70
  Steel 1.00
)

astrBodyParts=(
  Head "Hat|Helmet|Hood"
  Torso "Chest|Jacket|Vest"
  Hands "Gloves"
  Legs "Pants|Legs"
  Feet "Boots"
)

function FUNCor() {
  local lstrChk="$1"
  astr=(`echo "$lstrChk" |tr '|' ' '`)
  iCount=0
  for str in "${astr[@]}";do
    if((iCount>0));then strNameMatch+="or ";fi
    strNameMatch+="@name='$str' "
    ((iCount++))&&:
  done
  strNameMatch+=")"
}

for((j=0;j<"${#astrArmorTypes[@]}";j+=2));do
  strATList="${astrArmorTypes[j]}"
  fATMult="${astrArmorTypes[j+1]}"
  for((i=0;i<"${#astrBodyParts[@]}";i+=2));do
    strBP="${astrBodyParts[i]}"
    strBPSuffixList="${astrBodyParts[i+1]}"
    
    strNameMatch=""
    astrAT=(`echo "$strATList" |tr '|' ' '`)
    astrBPSuffix=(`echo "$strBPSuffixList" |tr '|' ' '`)
    iCount=0
    for strAT in "${astrAT[@]}";do
      for strBPSuffix in "${astrBPSuffix[@]}";do
        if((iCount>0));then strNameMatch+="or ";fi
        strNameMatch+="@name='armor${strAT}${strBPSuffix}' "
        ((iCount++))&&:
      done
    done
    
    echo '  <!-- HELPGOOD: CODEGEN:'"`basename "$0"`"' -->
  <append xpath="/items/item['"$strNameMatch"']">
    <effect_group tiered="false">
      <triggered_effect trigger="onSelfEquipStart" action="ModifyCVar" cvar="fGSKarmorAddToMultTS'"${strBP}"'" operation="set" value="'"$fATMult"'"/>
      <triggered_effect trigger="onSelfEquipStop"  action="ModifyCVar" cvar="fGSKarmorAddToMultTS'"${strBP}"'" operation="set" value="'"$fATMult"'"/>
    </effect_group>
  </append>' |tee -a "${strFlGenXml}${strGenTmpSuffix}"
  done
done

#./gencodeApply.sh "${strFlGenLoc}${strGenTmpSuffix}" "${strFlGenLoc}"
./gencodeApply.sh "${strFlGenXml}${strGenTmpSuffix}" "${strFlGenXml}"
#./gencodeApply.sh "AUTO_GENERATED_CODE" "${strFlGenRec}${strGenTmpSuffix}" "${strFlGenRec}"
