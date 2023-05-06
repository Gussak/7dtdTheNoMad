#!/bin/bash

#PREPARE_RELEASE:REVIEWED:OK

#help
# this file will be loaded as a bash script source code
# the ID must only contain a-Z A-Z 0-9 _ characters
# the ID is all the unique data from the RWG configuration screen
# TownID is the last thing, the ID must be unique for each town in that specific world
# the data for each entry is: iXTopLeft;iZTopLeft;iXBottomRight;iZBottomRight
# each town can have more than one rectangle, and each rectangle can overlap, they are just limits to search for POIs within.
# Biomes are: Desert Snow PineForest Wasteland (copy/paste from here as these are IDs and must match)

astrTownList["East_Nikazohi_Territory_CFG_SeedHolyAir2_Size10240_TownsFew_WildPOIsMany_RiversMany_CratersMany_CracksMany_LakesMany_Plains0_Hills10_Mountains10_Random3_BiomeWasteland_TownIDBig"]="645,-523,1019,-899" #lnX>=645 && lnX<=1019 && lnZ<=-523 && lnZ>=-899
astrTownList["East_Nikazohi_Territory_CFG_SeedHolyAir2_Size10240_TownsFew_WildPOIsMany_RiversMany_CratersMany_CracksMany_LakesMany_Plains0_Hills10_Mountains10_Random3_BiomePineForest_TownIDSmall"]="2285,2516,-588,-738" #lnX>=2285 && lnX<=2516 && lnZ<=-588 && lnZ>=-738
astrTownList["East_Nikazohi_Territory_CFG_SeedHolyAir2_Size10240_TownsFew_WildPOIsMany_RiversMany_CratersMany_CracksMany_LakesMany_Plains0_Hills10_Mountains10_Random3_BiomePineForest_TownIDTiny"]="3338,3451,-1259,-1359" #lnX>=3338 && lnX<=3451 && lnZ<=-1259 && lnZ>=-1359
