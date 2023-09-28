(A20) The NoMad, unforgiving lands. Explore the world, no fortress building, advance always.  
.  
[color=#00ff00]################### OVERHAUL[/color][color=#ff0000](WIP)[/color][color=#00ff00] ###################[/color]  
  This mod is an overhaul balanced towards exploring (no fortress building) and hardcore (very difficult but not impossible) gameplay.    
  This mod is intended for players that are used with the vanilla gameplay already and want an extra challenge and many new features.  
  This overhaul and server config is intended to be played being a very careful survivor, but mini mods on it may be used alone when they are split from this main mod.  
  Play the game with less progress in mind, less like a RPG and more like a FPS, but still a mix of both.  
  Please follow the server configs below and look for tactical hints (on in-game notes or the journal) on how to survive.  
  I have not visited the whole world yet. Some POIs placed somewhat above or below the ground level, or flooded, or something else..., or some POIs overlapping others are still ok as they create something that is unexpected but still playable. But if you find something too weird (in a game breaking sense) tell me.  
.  
  Beware tho, you may initially spawn (1st game join) in a very difficult place; that is usually related to radiation from sleeping zombies; if that happens, quickly open the free bundles (they have experience penalty tho), mainly the healing bundle and use anti-radiation (all the types) and psyonicResist chem, equip yourself and try to hunt them fast; or you can try to relocate yourself to an easier biome (like in the case you did not spawn in the desert) using the biome or underground free teleporter.  
.  
  No fortress building: you have a low cost teleport to home and from it feature, but the idea is not to stay at home during bloodmoons. Always advance, always explore and discover new places, never (as much as possible) go back. (See TODO*1002,1003).  
.  
  Obs.: I have not tested it multiplayer, so if you have any trouble, describe the problem the best you can.  
.    
[color=#0000ff]###################### [/color][color=#00ffff]MOD FEATURES OVERVIEW:[/color][color=#0000ff] ##################[/color]  
There are several mini mods here that may work without this main mod (the Tweaks folder).  
The main mod (Tweak folder) has a lot of configs that one day will become minimods to let you cherry pick only what you want like:  
  - night vision and flash light energy requirement and degradation/repair  
  - torch fuel  
  - Electronical Hero mods for armor and some weapons, to improve attack, defense and mobility.  
  - many compact info in a tiny HUD to help you on making decisions and understand why something is malfunctioning (degradating)  
  - much more dangerous rad zombies  
  - dangerous mutated bunny  
  - hazardous weather: cold, heat and misma may kill you now anywhere anytime so be careful and carry adequate resources to counter the hazards  
  - anti radiation chem (vs environment, zombies and mutants)  
  - cure poison chem (vs snakes and spiders)  
  - noisy air drops (as the smoke don't last long)  
  - patches to many other mods like RealRad, NPCs, Telrics'HealthBars etc. Many of these patches will let them work on 7dtd A20.  
  - NPC hiring reworked: there is a limit to how many NPCs can follow you now. you can "equip" power armor on them. And they have a ammo limit. Friendly raiders are fixed now so after hired they will show on the hud properly.  
  - NPC spawning reworked: now NPCs are rare, so keep a look for nice ones to be hired!  
  - NPC (hireable) calling items you can harvest thru the world.  
  - NPC at night, following you and near you will gain access to a Ninja Jutso: knock down your enemy and push them far away, but then they will become immune to damage for some time.
  - World Exploration Rewards: each POI has a trials tower. If you succeed you get WER credits to get items you would otherwise have to craft, buy or find by chance. A courier will bring them to you.  
  - NPC couriers non hireable that will help while you are near them.  
  - DeusExMachina: a friendly being that will protect and help (and bother) you while you are still friendly to it.  
  - Stats improvements from: Monster Essences, DeusExMachina defeats, ;  
  - (probably some other major or minor things I forgot to add here..)  
.  
[color=#00ffff]############## [/color][color=#ffff00]INSTRUCTIONS FOR THE END USER:[/color][color=#00ffff] #################[/color]  
FOR YOU THE PLAYER THAT JUST WANTS TO PLAY IT, NOT MOD.  
.  
  [color=#00ffff]Basic:[/color]  
.  
    [color=#00ffff]ThisPackage:[/color]  
      There are many mods at this package file, each in a single folder inside "_ReleasePackageFiles_" folder.  
.  
    [color=#00ffff]ChooseMods:[/color]  
      Place all the ones you want at your game Mods' folder, I suggest using them all tho as they are balanced to create The NoMad world experience.  
.  
    [color=#00ffff]ManualInstallRequired (or run ./installSpecificFilesIntoGameFolder.sh on cygwin):[/color]  
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
    [color=#00ffff]Configuring your server options:[/color]  
    These below are important as this overhaul was balanced to cope with increased difficulty and with all these settings below.  
      [color=#00ffff]General:[/color]  
        Difficulty: Insane (like in black summer)  
        24 hour cycle: 60mins (some realtime calculations are based on this)  
        Daylight length: 12 (to have enough time at night to explore w/o being easily detected)  
      [color=#00ffff]Basic:[/color]  
        Blood moon freq: 7 days (default thematic delay)  
        Blood moon range: 7 (unpredictable average 10 days to explore the world and prepare to survive the blood moon with extra spawns buff)  
        Blood moon warning: Morning (so you have time to run to a safe site to defend)  
        Zombie * Speeds: Nightmare (all speeds are nightmare, like in black summer)  
        Zombie feral sense: Day (so you have the night to explore)  
        Persistent Profiles: w/e  
        XP Multiplier: 25% (or it may quickly get too easy)  
      [color=#00ffff]Advanced:[/color]  
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
        Mark air drops: off (air drops now make permanent 30m dist sound and light easy to see at night), but keep ON if you dont want to promptly hunt or guess mark (from/to) them on map (marking like that is a fun challenge tho).  
.  
    [color=#00ffff]Dependencies:[/color]  
      See the Dependencies.txt file. The game may still run w/o many of them tho, but I suggest using them all.  
.  
.  
.  
.  
.  
  [color=#ff8000]Advanced:[/color]  
.  
    Only these scripts may interest the end user (.sh is for cygwin or linux):  
.  
      [color=#ff8000]HardcodedTips.sh[/color]  (for windows there is a `perl` command too)  
        This one will lower the crouch height to 0.40, letting you move thru 1 block height (even if there is a pile of trash in front of it, when 0.50 wouldn't work). You can run it using cygwin. It patches the binary file "7DaysToDie_Data/resources.assets" using `sed` to replace existing "PhysicsCrouchHeightModifier" value with '0.40'.  
.  
      [color=#ff8000]macroMoveItemsToNPCInventory.sh[/color]  
        This one is not that fast but will still make it easier to move items from your inventory to one hired NPC's inventory.  
        It controls the mouse and move all items in a single row.  
        I dont think it will run in cygwin as it needs to use `xdotool`.  
        So if someone knows how to implement these commands on windows (how to port this logic to a windows native system macro script), your contribution will be welcome :)  
.  
    [color=#ff8000]XML tweaking:[/color]  
.  
      This buff 'buffGSKConfigGeneric' has several settings that may have an in-game activator to configure. If not, you may try changing values there directly, but do that with caution (search the logic context they are used at to tweak the values properly). If you think things improved, propose a patch for review :).  
.  
.  
.  
.  
.  
.  
.  
.  
[color=#ffff00]################## FOR DEVELOPERS [/color][color=#ff0000](WIP)[/color][color=#ffff00] ##################[/color]  
  This mod contains many tools that can be run on Cygwin (in Windows) or Linux and may be adapted to your mod, there are many variables to configure it to your mod, and if something doesn't work as expected, comment here or drop a patch on [url=https://github.com/Gussak/7dtdTheNoMad]github[/url].  
  This mod is also a overhaul that I am still changing, balancing more, improving usability, documentation and adding new features.  
  It is already playable, and if you would like to help (new things or patches for: documentation, scripts, xmlLogic, icons (like more realistic or better drawn), sounds, anything that could be improved), you can create a pull request on github for review, thx!  
.  
  If I patched any of your mods, feel free to copy and adapt the patched code into your original mod (like if I was creating a pull request for your github project, what I could do someday too if you have not already integrated it). I would like to know tho so I can keep and maintain just minor changes here (or further minor adjustments based on your integrated adaptation), and I would appreciate a credits link back to my mod page thx! :)  
.  
  ScriptsForDevelopers:  
    There are many .sh files (bash scripts) that generate code and patch xml files etc.  
    I used them to make it easier to prepare and update the logic in the xml files.  
    You may only want to try them if you would like to further easily patch the config files using them, or if you want to use them in your own mods, yes you can copy, patch and tweak them to your mods, but you need linux or at least cygwin to run them.  
.  
############ TODO(may be): (if there is some mod implementing these I would like to know, thx!) ########  
 Easy:  
  1) Dosimeter helmet mod that uses battery energy and can be damaged (damage will blink the detection indicators). Detects radiation sources (rad zombs and mutants including bunny). have many quality levels based on some skill that determines the detection distance. will substitute the related effect from animal tracker skill.  
  2) Contextualize new notes added to journal based on game events to let the player read them from time to time (like in vanilla).  
 Difficult:  
  1003) A pocket dimension bag of holding (with unlimited storage scrolling slots or slots pages, could also be an indestructible NPC follower or drone that doesnt tank, no luring foes, nor attack) could be used to store all extra items (and accessed with some cost like battery energy per item weight retrieved or stored). That would keep the challenge of not having so many resources in hand w/o a cost. It should only be accessible out of combat. (I think this would required some special mod as .DLL that I don't know how to implement)  
.  
.  
.  
.  
.  
################## CHANGES (full detailed change log only from project on github) ##############  
--------- v1.0aRC1 (A20) -----------    
- this is probably the last patch for A20. Many things are ready for A21 (wont need to be changed) but would need to be split from the main mod at least.
- it is recommended to start a new game as many things changed and so did the first spawn and initial levels challenge and overall gameplay, it is worth the try! (but in case you are just trying to update, !NotRecommended!, you will see several missing buff classes, it just means that they were updated and I forced a name change on them to keep your game in sync)  
- fix: NPC follower above limit prevent dismiss feature;
- fix: repair flow of guns (parts shall now be found, dismantled or bought again like in vanilla)  
- fix: effective weapons mod: protected NPCs from all debuffs like lethal bleeding that could kill them  
- fix: hazmat armor glove mod  
- fix: prevented most POIs from being above the ground that (despite fun) makes things easier  
- fix: effective weapons mod: spiders wont be put in ragdoll mode now. also general protection against spiders in ragdoll mode that would just make it stop attacking and cause many errors on log. And strong stun alternative to spider ragdoll.  
- fix: unnecessarily patching 'melee...' and 'gun...' items that also had 'Schematic' or 'Parts'  
- improved first player spawn to be more friendly if you are new to this overhaul. If you are receiving too much radiation, there are probably rad zombies nearby, quickly open the bundles and use the strong anti radiation chem! If your first spawn is in the wasteland, you may want to use the free item GSKCFGElctrnTeleportToBiome and teleport to Desert biome (that is the default selection) with secondary action.  
- scrap armor makes much more noise, so iron armor becomes valuable  
- melee build: parry chance  
- melee build: if you have high charisma and is using only melee weapons, you can have at most 3 NPCs following you  
- melee build: blunt strong attack will knockdown surrounding foes, but sledgehammer will have a bit more reach and also apply the effective weapons extra damage to them all  
- free dog companion per respawn within the configured limit  
- removed newbie coat protection  
- free bundles now have experience penalty for some time, a courier will bring them to you.  
- fixed HitpointsBlockageByChemUse    
- clearly visible HP, Stamina blockage (also for Food and Water if it is working)    
- new teleport activators fully working now with configurable distances (also to sky)    
- added alternative god mode for devs. also if you use the numpad to move, this will allow you to console disable dm and continue in god mode    
- lowered drop rate for many new items    
- lowered and limited starting free bundles based on respawns    
- added journal for NPC follower changes, and melee npc now has strike limits too    
- simple god mode for player on 1st spawn for 60s in case of 1st spawining over a mob will be fair  
- increased green glow sticks time to be more useful  
- there are downgrade recipes to better use some resources  
- a bit bigger Elctrn HUD for better reading  
- added one hired NPC info on the HUD  
- added near death lvls for Overhydrated Bloated ChemUse  
- added some Notes about buffs. They have dynamic values that would be shown for buffs that have no icon and were bloating the detailed buffs list.  
- it now automatic turns on Elctrn mods if all checks are ok (if it is safe)  
- reorganized notes/journal to be easyer to read  
- some beasts may byte and hold your leg for a few seconds preventing you from moving, others may even knock you down.  
- attacking mutant zombies may make them teleport you, more info on the docs  
- quests may have raiders waiting for the treasure to be found and ambush you  
- treasure maps have crowds of zombies and may probably attract raiders after you unlock and open the treasure  
- poison will block enemies new abilities, including psyonic  
- psyonic resistance chem will help against mutant teleports  
- some chance to knockdown player on fallimpact, higher chance if leg is hurt. also from stumbling on things on the ground and from strong enemies attacks.  
- improved rwgImprovePOIs.sh to place tall buildings only on wasteland and to remove towns that are not on the wasteland  
- drinking rain may be dangerous now, unless you use a water filter. you can collect rain also with an empty jar.  
- added traps around POIs (they can be usefull too)  
- new hazard: cosmic rays/radiation piercing thru ozone layer  
- sneaking with a NPC follower at night is possible now (ninja NPCs workaround), craft GSKCFGNPCproperSneakingWorkaround to enable it  
- extra bloodmoon spawns (optional) mainly to compensate for the initial levels where blood moons may spawn no zombies  
- wetness helps against desert heat now    
- animal spiders will jump now and tiny ones spawns inside buildings always  
- no more easy loot drop from friendly NPCs    
- added workaround to try to quickly place a follower NPC near the player: vehicleGSKNPChelperPlaceable  
- water bucket can only pickup world generated water now, not water placed by the player. this keeps the bucket after being used and prevents unlimited water creation overpower glitch. To pickup water placed by the player, use the new empty drink jar.    
- (and many other minor things I forgot to add here...)
.    
--------- v0.9a (A20) -----------    
- initial release.    
- Some minor things are still missing: still needs better new item's names and descriptions and alternative icons instead of colored vanilla ones.    
- Many other ideas were not implemented yet, so I may release new things soon.    
- if you have trouble installing or making it work, tell me so I can improve install instructions with your improved explanations.    
.    
.    
.    
###FileDescription v1.0aRC1:###    
More friendly 1st spawn and respawns. Starting a new game is recommended. Run `./installSpecificFilesIntoGameFolder.sh` on cygwin to prepare files outside the modlet folder (and create bkps). Details on changelog.    
.    
###FileDescription v0.9a:###    
More friendly first spawn. WIP:Overhaul + DEV tools.For the whole experience,it is better you run `./installSpecificFilesIntoGameFolder.sh` on cygwin, it will guide you on what to do to prepare The NoMad world with files that are outside the modlet folder (and create backups).    
.    
.    
.    
