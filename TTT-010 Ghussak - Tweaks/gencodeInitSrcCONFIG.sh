#this is a config file

#PREPARE_RELEASE:REVIEWED:OK

strModName="[NoMad]" #as short as possible
strModNameForIDs="TheNoMadOverhaul"

strFlGenLoc="Config/Localization.txt"
strFlGenLoa="Config/loadingscreen.xml"
strFlGenRec="Config/recipes.xml"
strFlGenXml="Config/items.xml";strFlGenIte="$strFlGenXml"
strFlGenBuf="Config/buffs.xml"

strGenTmpSuffix=".GenCode.UpdateSection.TMP"

trash "${strFlGenLoc}${strGenTmpSuffix}"&&:
trash "${strFlGenLoa}${strGenTmpSuffix}"&&:
trash "${strFlGenRec}${strGenTmpSuffix}"&&:
trash "${strFlGenXml}${strGenTmpSuffix}"&&:
trash "${strFlGenBuf}${strGenTmpSuffix}"&&:
echo "" #this is to prevent error value returned from missing files to be trashed above
