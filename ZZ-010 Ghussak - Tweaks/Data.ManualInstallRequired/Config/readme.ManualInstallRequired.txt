# [commented lines (starting with #) can be ingored if you are using the installer script]

Do this in this order:

# Copy rwgmixer.xml to the 7dtd game folder at:
#   7 Days To Die/Data/Config/rwgmixer.xml

Generate a new world (this will use the new rwgmixer.xml)
  Configurations for a single big town in the radiated wasteland:
   seed: HolyAir2
   size: 10240
   towns: few
   allothers: many
   plains: 0
   hills & mountains: max
   random: 3
   (ignore biomes)
This will create the "East Nikazohi Territory" world, now read "../GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/biomes.png.AddedToRelease.README.txt"

# Follow the instructions at 
#   "../GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/readme.ManualInstallRequired.txt"
# 
# Obs.: these xml files need to be replaced as related patches are ignored
# 
# --------------------------------- SELF NOTES (you can ignore below here) ---------------------------------
# 
# SelfNotes:
#   To patch rwgmixer manually again if needed:
#    - changed all mintiles and maxtiles to 1
#    - changed "few" value to 1 for: oldwest, countrytown, town, city
# 
# SelfTips:
#  Linux: Find all missing POIs on generated world
#   ls *.xml |sort |tr -d "[0-9]" |sort -u |sed 's@[.]xml@@' |sed -r 's"_$""' >AllPOIs.txt
#   cat "../Application Data/7DaysToDie/GeneratedWorlds/East Nikazohi Territory/prefabs.xml" |egrep 'name="[^"]*"' -o |tr -d '"' |sed 's@name=@@' |sort >GenWorldPOIs.txt
#   IFS=$'\n' read -d '' -r -a astrFlList < <(cat AllPOIs.txt);for strFl in "${astrFlList[@]}";do if ! egrep -q "^$strFl" GenWorldPOIs.txt;then echo "$strFl";fi;done
#
# rwgImprovePOIs.sh
#   replaces all dup POIs on generated world with the missing ones (it choses the best/more complex ones)
