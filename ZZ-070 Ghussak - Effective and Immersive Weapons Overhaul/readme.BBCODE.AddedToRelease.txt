[b]A19[/b]
[u]Play the game like a FPS while still having vanilla RPG progress.[/u]
[u]Ranged and melee attacks have lethal (over time) or debilitating inherent random effects chances:[/u]
- dismember (only shotguns)
- ragdoll push or knock down for powerful blunt strikes mainly
- multi strikes weak bleeding
- slow but lethal bleeding
- longer knockdown for explosions
- burning may not end even after death
- higher stun chance
.
Tho, with this mod (and the suggested config TIPS), your skills matter more than your RPG progress.

Obs.: I am not touching anything related to skill development, these are just effects inherent to each weapon, like they should be.
.
[u]This mod options:[/u]
At the top of buffs.xml there is buffEWConfig where you can modify some values to:
- make this mod compatible with other mods
- disable or enable some features
- enable logging if you want to debug it
See the comments there explaing what each value means.
.
[u]Config TIPS for a better experience: [/u]
Difficulty: Insane;
Change all zombies speeds to: sprint,sprint,nightmare,nightmare;
Loot probability to 25%;
Disable loot respawining (promotes exploration);
Airdrop to 7 days;
Blood moon zombie block damage to 300%;
.
[u]Recommended mods to complement this one's experience:[/u]
[url=https://7daystodiemods.com/headshot-multiplier/]Headshot Multiplier[/url]
[url=https://www.nexusmods.com/7daystodie/mods/1022]WrathmaniacsMoreZombies_x8[/url] (but I use x12)
[url=https://7daystodiemods.com/zombie-health-bars/]Zombie Health Bars[/url] (I highly recomment this mod until proper effects are working to clearly indicate bleeding)
.
[u]QOL mods:[/u]
[url=https://7daystodiemods.com/annoying-and-loud-sounds-lowered/]Annoying and Loud Sounds Lowered[/url]
[url=https://7daystodiemods.com/lock-picking-doors/]Lock Picking Doors[/url]
.
[u]Trouble Shutting:[/u]
- set bEWOneEffectPerLoop, at buffs.xml, to 1 if effects are not being applied as they should (tho they worked very well til now), but better enable the log iEWLog=2 to be sure first
.
[u]Issues:[/u]
- it if is generating debug log (things like EW...) at buffs.xml, set iEWLog=0, it means I forgot to do it before releasing...
- random knockdown duration for explosions: no trigger will work for land mines :(, see blocks.xml, nothing was logged...
- extra burning wont be extinguished in most cases: should only extinguish if raining or wet, but NPCs seems to have no _wetness value :(. The only thing that worked was onSelfWaterSubmerge but only for zombies...
- I have no idea were to set item's descriptions yet...
.
[u]TODO:[/u] (+- by priority):
- make some weapon's mods useful again
- add visual effects showing clearly what is happening if needed/possible like the missing bleeding
- make enemies more challenging in terms of special abilities (not by increasing their HP or their punch/byte damage)
- change descriptions to match new inherent weapon effects (preferably using the variables values if possible, or an external script to gather and set the comments)
- add chances for all "meleeTool*"
.
[u]Changes Log:[/u]
0.16
- added a general chance for a stronger stun effect
- improved arrows, bolts and thrown spears, to make them still useful even after having most guns
.
0.15
- added item's modMeleeClubBarbedWire, modMeleeClubMetalChain, modMeleeWeightedHead and modGunCrippleEm compatibility (for now the only ones that made sense adding)
.
0.14
- added serrated blade mod compatibility, making it useful again!
- burning will now take longer to fully damage and may extinguish by itself sooner
- added compatibility with other mods by setting bEWUseBulletsEffects=0 (see Options/Configs section)
- added config option to enable fast and slow bleeding effects
.
0.13
- fixed explosives and explosive ammunition not stacking!
- burning may rarely extinguish by itself now
.
0.12
- protected players and traders against all these buffs
- all buffs are from this mod now for easier maintenance (burn still hooks on all vanilla's tho), this should prevent issues (if there is any) related to the player as they are hidden buffs that display nothing to the player, intended for NPCs only
- reworked how weak bleeding works, it increses the damage with more strikes but lasts accordingly
- lethal bleeding was nerfed, max bleeding/s has a limit
- burning now may increase or decrease (down to 1) randomly
.
0.11
- added random stun chance (half of knock down) with random timeout up to 20

0.10
- added much extended random knockdown for explosions of throwables and projectiles
- added endless slow burning
Obs.; read issues section tho, there are some limitations for both new effects
.
0.9
- added pickaxes and fireaxes
- effects are applied faster now with bEWOneEffectPerLoop=0 (default at buffs.xml)
.
0.8
- shotguns, with multiple pellets, reworked. Now there is a minimum pellet hit requirement for ragdoll push, dismember and knockdown.
- added wrench to effects
.
0.7
- normal spear hit has effects chances now
.
0.6
- Shotguns: each pellet hit counts now for effects.
.
0.5
- Added melee weapons with normal and power attacks working properly now
.
0.3
- weak bleeding buff now increases it's duration on stacking
- easy debug log enable/disable
