# as we cant move thru dug terrain... :( (diamond shape hole), we can only move thru cubic blocks that are 0.49f, it could be 0.40f or an option in the blocks.xml file? may be a xml cvar?

# workaround (pointless tho): dig terrain tunnels 2 blocks wide, 1 block tall, but the whole point of quickly digging a single block to pass thru is lost anyway..
# workaround (not bad): strike one extra normal hit (not power hit) in the side wall to change the terrain enough to let you pass thru
# workaround (not very useful) dig near shape blocks of buildings, that will allow the the player to pass thru 1 block tall terrain tunnel

##### FAIL block shapes do not affect the terrain: workaround: use this block shape in terrain one block tall tunnels to "fix" the tunnel: ?

######################## BINARY PATCH TRICK FAIL ############################

# 0.49f from .cs file is in hexa 48E1FA3E big endian (double would be 5C8FC2F5285CDF3F btw)

# THESE BELOW FAIL, will cause a lot of errors on the log... probably the match in the dll was just "luck"?
# use some online float to hexa calculator then ex.: 
#  0.40f is CDCCCC3E but has a lot of matches in the dll
#  so use 0.401f that is DF4FCD3E and has no matches
#  0.41f is 85EBD13E
# replace that hexa in the DLL (in overwerite mode, not insert edit mode) and it is done

