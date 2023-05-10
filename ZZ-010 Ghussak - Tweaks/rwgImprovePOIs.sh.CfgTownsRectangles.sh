#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#help
# this file will be loaded as a bash script source code (therefore this is bash script code)
# the ID must only contain a-Z A-Z 0-9 _ characters
# the ID is all the unique data from the RWG configuration screen
# TownID is the last thing, TownID must be unique for each town in that specific world
# the data for each entry is: iXTopLeft;iZTopLeft;iXBottomRight;iZBottomRight
# each town can have more than one rectangle, and each rectangle can overlap, they are just limits to search for POIs within and protect or destroy them (towns outside wasteland will be removed as they will make things easier and you would need to explore the world much less).
# Biomes are: Desert Snow PineForest Wasteland (copy/paste from here as these are IDs and must match case sensitive)
# in developer mode 'dm', in the map, turn on the static map view and click the left arrow to show the biomes, then navigate and position the mouse and collect the coordinates: West and South are negative values. Position the cursor with a good big margin for the top left and bottom right corners, but only for the town limits, not other buildings nearby.
# spaces characters are not allowed (they could be but is much more trouble to code)

astrWorldDataTNMList=( #here you can configure your world data, this is for TheNoMad (TNM)
  East_Nikazohi_Territory #paste here and replace the world name spaces with _
  CFG #ignore this but keep here!
  SeedHolyAir2 #each below is a KeyValue thing, so key=Seed Value=HolyAir2
  Size10240 #as all worlds are square
  TownsFew
  WildPOIsMany
  RiversMany
  CratersMany
  CracksMany
  LakesMany
  Plains0
  Hills10
  Mountains10
  Random3
);strWorldDataTNM="";for strWorldData in "${astrWorldDataTNMList[@]}";do strWorldDataTNM+="${strWorldData}_";done #DONT TOUCH THIS LINE (unless your know what your are doing)! it will mix the above to prepare the bash script array key below


# here are the specific towns rectangles. you have to configure the Biome, the TownID and the rectangle data. Do NOT put spaces in each of the below lines!
astrTownList["${strWorldDataTNM}BiomeWasteland_TownIDBig"]="582,-351,1120,-928"

astrTownList["${strWorldDataTNM}BiomePineForest_TownIDSmall1"]="2166,-440,2638,-808"
astrTownList["${strWorldDataTNM}BiomePineForest_TownIDSmall2"]="2426,-287,2638,-808"

astrTownList["${strWorldDataTNM}BiomePineForest_TownIDTiny"]="3254,-976,3536,-1415"

astrTownList["${strWorldDataTNM}BiomeWasteland_TownIDTinyToo"]="-405,-2164,-238,-2429"

#OBS.: you can keep the above and create another world data below here, just copy the above and adjust to your new world!

strWorldDataCurrent="${strWorldDataTNM}" # !!! SET THIS TO YOUR CURRENT WORLD being prepared. it will be used later for other specific world configurations.

