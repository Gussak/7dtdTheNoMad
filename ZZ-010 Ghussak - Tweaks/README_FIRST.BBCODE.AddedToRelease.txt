The NoMad, unforgiving lands (developer tools, WIP)
.
############################## DEVELOPER(WIP) ##############################   
This mod contains many tools that can be run on Cygwin (in Windows) or Linux and may be adapted to your mod.
This mod is also a (not ready yet for release) overhaul that I am still changing, balancing more, improving usability, documentation and adding new features.
But it is already playable, and if you would like to help (new things or patches for: documentation, scripts, xmlLogic, icons, sounds, anything that could be improved), drop a pull request on github for review, thx!
.
##############################  OVERHAUL(WIP) ##############################    
This mod is an overhaul balanced towards exploring (no fortress building) and hardcore (difficult, or insanely difficult but not impossible) gameplay.    
Please follow the server configs below and look for tactical hints on in-game notes on how to survive (but I may have left something in text files or config files' comments inside help="..." properties on xml files).    
.    
############################## MOD FEATURES OVERVIEW: ##############################   
There are several mini mods here that may work without this main mod (the Tweaks folder).  
The main mod (Tweak folder) has a lot of configs that one day will become minimods to let you cherry pick only what you want like:  
  - night vision and flash light energy requirement and degradation/repair  
  - torch fuel  
  - Tesla Hero mods for armor and some weapons, to improve attack, defense and mobility.  
  - many compact info in a tiny HUD to help you on making decisions and understand why something is malfunctioning (degradating)  
  - much more dangerous rad zombies  
  - dangerous mutated bunny  
  - hazardous weather: cold, heat and misma may kill you now anywhere anytime so be careful and carry adequate resources to combat the hazards  
  - anti radiation chem (vs environment, zombies and bunny)  
  - cure poison chem (vs snakes and spiders)  
  - noisy air drops (as the smoke dont last long)  
  - patches to many other mods like RealRad, NPCs, Telrics'HealthBars etc. Many of these patches will let them work on 7dtd A20.  
  - NPC hiring reworked: there is a limit to how many NPCs can follow you now. you can "equip" power armor on them. And they have a ammo limit. Friendly raiders are fixed now so after hired they will show on the hud properly.  
  - NPC spawning reworked: now NPCs are rare, so keep a look for nice ones to be hired!  
  - (probably some other minor things)  
.  
########### INSTRUCTIONS FOR THE END USER (YOU THE PLAYER THAT JUST WANTS TO PLAY IT, NOT MOD): ###########   
.  
  Basic:  
.  
    ThisPackage:  
      There are many mods at this package file, each in a single folder inside "_ReleasePackageFiles_" folder.  
.  
    ChooseMods:  
      Place all the ones you want at your game Mods' folder, I suggest using them all tho.  
.  
    ManualInstallRequired:  
      There are files that need to be copied manually to the game folder or they wont work.  
      They replace existing files there, so backup them first!  
      They provide extra functionality that a modlet can't do itself.  
        Look for instructions in the files that have this on their filenames "ManualInstallRequired", for now:  
          ZZ-010 Ghussak - Tweaks/Data.ManualInstallRequired/Config/readme.ManualInstallRequired.txt  
            changes random world generator to better spread POIs thru the world. Towns are boring, exploring the world is fun!  
          ZZ-010 Ghussak - Tweaks/GeneratedWorlds.ManualInstallRequired/East Nikazohi Territory/readme.ManualInstallRequired.txt  
            changes spawnpoints and make available all POIs that were ignored by the generator  
          ZZ-040 Ghussak - Patch Telrics Health Bars - Friendly NPCs Only/Resources/readme.ManualInstallRequired.txt  
            read it or it wont work.  
.  
    Configuring your server options:  
    These below are important as this overhaul was balanced to cope with increased difficulty and these settings below.  
      General:  
        Difficulty: Insane (like in black summer)  
        24 hour cycle: 60mins (some realtime calculations are based on this)  
        Daylight length: 12 (to have enough time to explore w/o being easily detected)  
      Basic:  
        Blood moon freq: 5 days (to be predictable, you will need it)  
        Blood moon range: 0 (to be predictable, you will need it)  
        Blood moon warning: Morning (unnecessary now)  
        Zombie * Speeds: Nightmare (all speeds are nightmare, like in black summer)  
        Zombie feral sense: Day (so you have the night to explore)  
        Persistent Profiles: w/e  
        XP Multiplier: 25% (or it may quickly get too easy)  
      Advanced:  
        PlayerBlockDmg: 300% (to avoid wasting time on that so you can explore and fight more often)  
        AIBlockDmg: 100% (vanilla difficulty, this copes with this overhaul)  
        AI Blood moon block dmg: 300% (to grant blood moon is hardcore)  
        Loot Abundance: 25% (to make exploring required to survive, you dont need to search all containers now. only locked containers are really good now)  
        Loot Spawn Time: Disabled (to make exploring required to survive)  
        Drop On death: backpack only (so you have to be careful on what you put on the quick bar, and to allow you a chance to survive after death)  
        Drop on quit: Nothing (better keep your stuff)  
        Blood moon count: 16 enemies (lags a bit, and more than that just lags a lot..)  
        Enemy Spawning: On (duh)  
        Air Drops: every 7 days (is cool to have that but must be little to avoid too much easy free give aways)  
        Cheat mode: if developing only, or to workaround bugs but only if you can hold yourself to not make the game easier.  
        Mark air drops: off (air drops now make a sound and light easy to see at night), but keep ON if you dont want to promptly hunt or guess mark them on map.  
.  
    Dependencies:  
      See the Dependencies.txt file. The game may still run w/o many of them tho, but I suggest using them all.  
.  
.  
.  
.  
.  
.  
  Advanced:  
.  
    Only these scripts may interest the end user:  
.  
      HardcodedTips.sh  
        This one will lower the crouch height to 0.40, letting you move thru 1 block height. You can run it using cygwin. It patches the binary file "7DaysToDie_Data/resources.assets" using `sed` to replace existing "PhysicsCrouchHeightModifier" value with 0.40  
.  
      macroMoveItemsToNPCInventory.sh  
        This one is not that fast but will still make it easier to move items from your inventory to one hired NPC's inventory.  
        It controls the mouse and move all items in a single row.  
        I dont think it will run in cygwin as it needs to use `xdotool`.  
        So if someone knows how to implement these commands on windows, your contribution will be welcome :)  
.  
.  
.  
.  
.  
.  
.  
.  
########### DEVELOPERS: ###########   
.  
  ScriptsForDevelopers:  
    There are many .sh files (bash scripts) that generate code and patch xml files etc.  
    I used them to make it easier to prepare and update the logic in the xml files.  
    You may only want to try them if you would like to further easily patch the config files using them, but you need linux or at least cygwin to run them.  
.  
.  
.  
.  
.  
################## CHANGES ##############  
--------- v0.9a -----------  
- initial release.  
- Some minor things are still missing: still needs better new item's names and descriptions and alternative icons instead of colored vanilla ones.  
- Many other ideas were not implemented yet, so I may release new things soon.  
- if you have trouble installing or making it work, tell me so I can improve install instructions with your improved explanations.  
.  
.  
.  
