#!/bin/bash

# BSD 3-Clause License
# 
# Copyright (c) 2023, Gussak(github.com/Gussak,ghussak@www.nexusmods.com)
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#PREPARE_RELEASE:REVIEWED:OK

egrep "[#]help" $0

function FUNCmvItemToNPC() { #help xdotool to move item at cursor to npc inventory. 
  iInvSlotWidth=39 #help CFG THIS FOR YOUR RESOLUTION! here is 1366x768 btw
  fSleep="0.5"
  fSleep2="1.0"
  fSleep3="0.25"
  eval "`xdotool getmouselocation --shell`" # X Y
  xdotool click 1;sleep $fSleep
  xdotool mousedown 1;sleep $fSleep
  xdotool mousemove_relative -- -5 0;sleep 0.1
  xdotool mousemove_relative -- -5 0;sleep 0.1
  xdotool mousemove_relative -- -5 0;sleep 0.1
  xdotool mousemove 439 632;sleep $fSleep3 #help CFG THIS TO THE NPC last inv slot POSITION ON YOUR RESOLUTION!
  xdotool mouseup 1;sleep $fSleep3
  xdotool click 1;sleep $fSleep3
  xdotool mousemove 331 122;sleep $fSleep3 #help CFG THIS TO THE NPC sort inv icon POSITION ON YOUR RESOLUTION!
  xdotool click 1;sleep $fSleep3
  xdotool mousemove $((X+iInvSlotWidth)) $Y #restore initial pos on next slot
};export -f FUNCmvItemToNPC

echo "TIP for quickly and easily moving items from one npc to another:"
echo " Remove from your inventory all items that are disorganized into some EMPTY chest using shift+click."
echo " Make it sure there is no empty slots in the top organized lines of your inventory."
echo " Put both NPCs in stayWhereIAmStanding mode."
echo " Get from 1st npc all items you want to to move to the 2nd npc into your inventory."
echo " (continue below on the macro.)"
echo
echo "Please place the mouse on the first column of the line in YOUR inventory that you want to fully transfer (that line of items) and then hit ENTER here and focus the game window in less than 3s.";read&&:
sleep 3
for((i=0;i<20;i++));do 
  FUNCmvItemToNPC
done
