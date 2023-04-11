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

astrReqs=(
  BlockStandingOn
  BurstRoundCount
  CompareLightLevel
  CVarCompare
  EntityHasMovementTag
  EntityTagCompare
  Equals
  Greater
  GreaterOrEqual
  GreaterThan
  GreaterThanOrEqualTo
  GT
  GTE
  HasBuff
  HasTrackedEntity
  HitLocation
  HoldingItemBroken
  HoldingItemHasTags
  InBiome
  IsAlive
  IsAttachedToEntity
  IsBloodMoon
  IsDay
  IsFPV
  IsIndoors
  IsItemActive
  IsLocalPlayer
  IsLookingAtBlock
  IsLookingAtEntity
  IsMale
  IsNight
  IsPrimaryAttack
  IsSecondaryAttack
  IsSleeping
  IsStatAtMax
  ItemHasTags
  Less
  LessOrEqual
  LessThan
  LessThanOrEqualTo
  LT
  LTE
  None
  NotEquals
  NotHasBuff
  NPCIsAlert
  PerksUnlocked
  PlayerItemCount
  PlayerLevel
  ProgressionLevel
  ProjectileHasTags
  RandomRoll
  RecipeUnlocked
  RequirementItemTier
  RoundsInMagazine
  StatCompare
  StatCompareCurrent
  StatCompareMax
  StatCompareModMax
  StatComparePercCurrentToMax
  StatComparePercCurrentToModMax
  StatComparePercent
  StatComparePercModMaxToMax
  TargetRange
  TimeOfDay
  TriggerHasTags
  WornItems
)
astrActions=( #help for actions: ignoring case sensitive in buffs.xml may make some things not work like onSelfBuffStart/update addBuff will not add the buff sometimes
	AddBuff
	AnimatorSetBool
	AnimatorSetFloat
	AnimatorSetInt
	AttachParticleEffectToEntity
	CVarLogValue
	FadeOutSound
	GiveExp
	LogMessage
	ModifyCVar
	ModifyScreenEffect
	ModifyStat
	ModifyStats
	PlaySound
	Ragdoll
	RemoveBuff
	RemoveParticleEffectFromEntity
	ResetProgression
	ShakeCamera
	ShowToolbeltMessage
	StopSound
)
astrETC=(
  ActiveCraftingSlots
  AttacksPerMinute
  AttributeLevel
  BagSize
  BarteringBuying
  BarteringSelling
  Bashing
  BashingDamage
  BashingProtection
  BatteryDischargeTimeInMinutes
  BatteryMaxLoadInVolts
  BlackOut
  BlockDamage
  BlockPenetrationFactor
  BlockRange
  BlockRepairAmount
  BloodLoss
  Break
  BreathHoldDuration
  BuffBlink
  BuffProcChance
  BuffResistance
  BurstRoundCount
  CarryCapacity
  Cold
  ColdDamage
  ColdProtection
  Concuss
  CoreTempChangeOT
  CoreTempGain
  CoreTempLoss
  Corrosive
  CorrosiveDamage
  CorrosiveProtection
  CraftingIngredientCount
  CraftingOutputCount
  CraftingSlots
  CraftingSmeltTime
  CraftingTier
  CraftingTime
  CriticalChance
  CrouchSpeed
  Crushing
  CrushingDamage
  CrushingProtection
  DamageBonus
  DamageFalloffRange
  DamageModifier
  DegradationMax
  DegradationPerUse
  Dehydration
  DehydrationProtection
  DisableItem
  Disease
  DiseaseProtection
  DismemberChance
  DistractionEatTicks
  DistractionLifetime
  DistractionRadius
  DistractionResistance
  DistractionStrength
  EconomicValue
  Electrical
  ElectricalDamage
  ElectricalProtection
  ElectricalTrapXP
  ElementalDamageResist
  ElementalDamageResistMax
  EntityDamage
  EntityHeal
  EntityPenetrationCount
  ExpDeficitMaxPercentage
  ExpDeficitPerDeathPercentage
  ExplosionRadius
  ExplosiveDamage
  ExplosiveProtection
  FallDamageReduction
  Falling
  FallingBlockDamage
  FallingProtection
  FeverProtection
  FoodChangeOT
  FoodGain
  FoodLoss
  FoodLossPerHealthPointLost
  FoodMax
  FoodMaxBlockage
  GameStage
  GrazeDamageMultiplier
  GrazeStaminaMultiplier
  HarvestCount
  HealthChangeOT
  HealthGain
  HealthLoss
  HealthLossMaxMult
  HealthMax
  HealthMaxBlockage
  HealthMaxModifierOT
  HealthSteal
  Heat
  HeatDamage
  HeatGain
  HeatProtection
  HyperthermalResist
  HypothermalResist
  IncrementalSpreadMultiplier
  Infection
  InfectionProtection
  JumpStrength
  JunkTurretActiveCount
  JunkTurretActiveRange
  KickDegreesHorizontalMin
  KickDegreesVerticalMin
  KnockDown
  KnockOut
  LandClaimDamageModifier
  LandMineImmunity
  LandMineTriggerDelay
  LightIntensity
  LightMultiplier
  LockPickBreakChance
  LockPickTime
  LootDropProb
  LootGamestage
  LootQuantity
  LootTier
  MagazineSize
  MaxRange
  Mobility
  ModPowerBonus
  ModSlots
  MovementFactorMultiplier
  NoiseMultiplier
  PerkLevel
  PhysicalDamageResist
  PhysicalDamageResistMax
  Piercing
  PiercingDamage
  PiercingProtection
  PlayerExpGain
  ProjectileGravity
  ProjectileStickChance
  ProjectileVelocity
  QuestBonusItemReward
  QuestRewardChoiceCount
  QuestRewardOptionCount
  Radiation
  RadiationDamage
  RadiationProtection
  RecipeTagUnlocked
  ReloadSpeedMultiplier
  RepairAmount
  RepairTime
  RoundRayCount
  RoundsPerMinute
  RunSpeed
  ScavengingItemCount
  ScavengingTier
  ScavengingTime
  ScrappingTime
  SecretStash
  SilenceBlockSteps
  SkillExpGain
  SkillLevel
  Slashing
  SlashingDamage
  SlashingProtection
  SphereCastRadius
  Sprain
  SpreadDegreesHorizontal
  SpreadDegreesVertical
  SpreadMultiplierAiming
  SpreadMultiplierCrouching
  SpreadMultiplierHip
  SpreadMultiplierIdle
  SpreadMultiplierRunning
  SpreadMultiplierWalking
  StaminaChangeOT
  StaminaGain
  StaminaLoss
  StaminaLossMaxMult
  StaminaMax
  StaminaMaxBlockage
  StaminaMaxModifierOT
  Starvation
  StarvationProtection
  Stun
  Suffocation
  SuffocationProtection
  TargetArmor
  Tier
  Toxic
  TrackDistance
  TrapDoorTriggerDelay
  TreasureBlocksPerReduction
  TreasureRadius
  TurretWakeUp
  VehicleAcceleration
  VehicleBlockDamage
  VehicleBoostedSpeedMax
  VehicleBraking
  VehicleCarryCapacity
  VehicleDamagePassedToPlayer
  VehicleDrag
  VehicleEntityDamage
  VehicleFuelUsePer
  VehicleHopStrength
  VehicleIdleSecondsPerLiter
  VehicleMaxSpeed
  VehicleMaxSteeringAngle
  VehicleMetersPerLiter
  VehicleNoise
  VehiclePlayerStaminaDrainRate
  VehicleReflectedDamage
  VehicleSpeedMax
  VehicleSteering
  VehicleStorageHeight
  VehicleStorageWidth
  VehicleTankSize
  VehicleTraction
  VehicleVelocityMaxPer
  VehicleVelocityMaxTurboPer
  WalkSpeed
  WaterChangeOT
  WaterGain
  WaterLoss
  WaterLossPerHealthPointGained
  WaterLossPerStaminaPointGained
  WaterMax
  WaterMaxBlockage
  WaterRegenRate
  WeaponHandling
)

export astrRegexAndFixListForItemsXml=( #help requirements names: at items.xml, !HasBuff may not work sometimes for some items, but NotHasBuff will work!
  '[!] *HasBuff' 'NotHasBuff'
  '[!] *Equals'  'NotEquals'
)
export astrRegexAndFixList=() #help the match will be case insensitive but the fix will be case sensitive, so the match can be equal to the fix
for str in "${astrActions[@]}";do astrRegexAndFixList+=("$str" "$str");done
for str in "${astrReqs[@]}";do astrRegexAndFixList+=("$str" "$str");done
for str in "${astrETC[@]}";do astrRegexAndFixList+=("$str" "$str");done

source ./libSrcCfgGenericToImport.sh #place exported arrays above this include

#TODO read all correct case sensitive things from vanilla xml cfg files and use them here in a loop!

#strRegexAll="`echo "${astrRegexAndFixList[@]}" |tr ' ' '|'`"
#export strCfgFlDBToImportOnChildShellFunctions=`mktemp` #help this contains all arrays marked to export
#export |egrep "[-][aA]x" >>"$strCfgFlDBToImportOnChildShellFunctions"
function FUNCfix() {
  local lstrFl="$1"
  
  source "$strCfgFlDBToImportOnChildShellFunctions"
  #cat $strCfgFlDBToImportOnChildShellFunctions
  #declare -p astrRegexAndFixList
  #exit 1
  
  #set -x
  echo "========================== $lstrFl ===========================" >&2
  local lstrFlNew="${lstrFl}.${strScriptName}.NEW"
  trash "$lstrFlNew"
  
  local lastrCmdSed=(sed -r)
  function FUNCsedExp() {
    local lastrList=("$@")
    for((i=0;i<${#lastrList[*]};i+=2));do
      local lstrRegex="${lastrList[i]}"
      local lstrFix="${lastrList[i+1]}"
      lastrCmdSed+=(-e 's@" *'"${lstrRegex}"' *"@"'"${lstrFix}"'"@gi')
    done
  }
  if [[ "${lstrFl}" =~ .*/items.xml$ ]];then
    FUNCsedExp "${astrRegexAndFixListForItemsXml[@]}"
  fi
  FUNCsedExp "${astrRegexAndFixList[@]}"
  "${lastrCmdSed[@]}" "$lstrFl" >>"$lstrFlNew"
  
  if ! colordiff --minimal --suppress-common-lines "$lstrFl" "$lstrFlNew";then
    echo "WARN: Hit ctrl+c to end meld and stop this script if you do not like the results." >&2
    declare -p lstrFl lstrFlNew
    #echo "INFO: lastrCmdSed: ${lastrCmdSed[@]}" >&2
    if CFGFUNCmeld "${lstrFl}" "$lstrFlNew";then
      mv -v "${lstrFl}" "${lstrFl}.`date +"${strCFGDtFmt}"`.bkp"
      mv -v "$lstrFlNew" "${lstrFl}"
    fi
  else
    echo "MSG: nothing changed." >&2
  fi
};export -f FUNCfix

IFS=$'\n' read -d '' -r -a astrFlList < <(find -iname "*.xml")&&:
for strFl in "${astrFlList[@]}";do
  FUNCfix "$strFl"
done

#trash "$strFlDB"
#exit ##################################################################3

## tst2
#function FUNCfix() {
  #local lstrRegex="$1";shift
  #local lstrFix="$1";shift
  #local lastrCmdGrep=(egrep '" *'"${lstrRegex}"' *"' * -iRnIw --include="*.xml")
  #"${lastrCmdGrep[@]}"
  #IFS=$'\n' read -d '' -r -a astrFlList < <("${lastrCmdGrep[@]}" -c |egrep -v :0 |cut -f1 -d:)&&:
  #for strFl in "${astrFlList[@]}";do
    #strFlNew="${strFl}.${strScriptName}.NEW"
    #trash "$strFlNew"
    #sed -r -e 's@" *'"${lstrRegex}"' *"@"'"${lstrFix}"'"@gi' "$strFl" >>"$strFlNew"
    #echo "WARN: Hit ctrl+c to end meld and stop this script if you do not like the results."
    #meld "${strFl}" "$strFlNew"
  #done
#}

#for((i=0;i<${#astrRegexAndFixList[*]};i+=2));do
  #strRegex="${astrRegexAndFixList[i]}"
  #strFix="${astrRegexAndFixList[i+1]}"
  #FUNCfix "$strRegex" "$strFix"
#done
#exit ##################################################################3


## tst1
#egrep '" *[!]hasbuff *"' * -iRnIw --include="*.xml"
#IFS=$'\n' read -d '' -r -a astrFlList < <(egrep '" *[!]hasbuff *"' * -iRnIw --include="*.xml" -c |egrep -v :0 |cut -f1 -d:)&&:
#for strFl in "${astrFlList[@]}";do
  #strFlNew="${strFl}.${strScriptName}.NEW"
  #trash "$strFlNew"
  #sed -r -e 's@" *[!]hasbuff *"@"NotHasBuff"@gi' "$strFl" >>"$strFlNew"
  #echo "WARN: Hit ctrl+c to end meld and stop this script if you do not like the results."
  #meld "${strFl}" "$strFlNew"
#done
