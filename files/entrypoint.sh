#!/bin/bash

# defaults
_config_folder="/conanexiles/ConanSandbox/Saved/Config/WindowsServer"
_config_folder_provided="/tmp/docker-conanexiles"

_bashrc_tag_start="# >> docker-conanexiles"
_bashrc_tag_end="# << docker-conanexiles "

_env_variable_prefix="CONANEXILES"
_env_variable_filter="\
CharacterLOD|\
Compat|\
DeviceProfiles|\
EditorPerProjectUserSettings|\
Engine|\
Game|\
GameUserSettings|\
GameplayTags|\
GraniteCooked|\
GraniteCookedMod|\
Hardware|\
Input|\
Lightmass|\
Scalability|\
ServerSettings\
"

setup_bashrc() {
    cat >> /bash.bashrc <<EOF


$_bashrc_tag_start
export wineprefix=/wine
export winearch=win64
$_bashrc_tag_end
EOF
}

setup_server_config_first_time() {
   
    # config provided, don't override
    [ -d "${_config_folder_provided}" ] && [ ! -d "${_config_folder}" ] && \
	mkdir -p "${_config_folder_provided}" && \
	(cp -rv "${_config_folder_provided}/*" "${_config_folder}" && \
	return 0 || return 1)

    # paste default config pvp
    [ ! -d "${_config_folder}" ] && \
	mkdir -p "${_config_folder}" && ([[ $CONANEXILES_SERVER_TYPE == "pve" ]] && \
					     server_settings_template_pve > "${_config_folder}/ServerSettings.ini" || \
						 server_settings_template_pvp > "${_config_folder}/ServerSettings.ini")
    return 0
}

server_settings_template_pvp() {
    echo """
[ServerSettings]
PVPEnabled=True
AdminPassword=ChangeMe
NPCMindReadingMode=0
MaxNudity=2
ServerCommunity=0
ConfigVersion=3
BlueprintConfigVersion=14
PlayerKnockbackMultiplier=1.000000
NPCKnockbackMultiplier=1.000000
StructureDamageMultiplier=1.000000
StructureDamageTakenMultiplier=1.000000
StructureHealthMultiplier=1.000000
NPCRespawnMultiplier=1.000000
NPCHealthMultiplier=1.000000
CraftingCostMultiplier=1.000000
PlayerDamageMultiplier=1.000000
PlayerDamageTakenMultiplier=1.000000
MinionDamageMultiplier=1.000000
MinionDamageTakenMultiplier=1.000000
NPCDamageMultiplier=1.000000
NPCDamageTakenMultiplier=1.000000
PlayerEncumbranceMultiplier=1.000000
PlayerEncumbrancePenaltyMultiplier=1.000000
PlayerMovementSpeedScale=1.000000
PlayerStaminaCostSprintMultiplier=1.000000
PlayerSprintSpeedScale=1.000000
PlayerStaminaCostMultiplier=1.000000
PlayerHealthRegenSpeedScale=1.000000
PlayerStaminaRegenSpeedScale=1.000000
PlayerXPRateMultiplier=1.000000
PlayerXPKillMultiplier=1.000000
PlayerXPHarvestMultiplier=1.000000
PlayerXPCraftMultiplier=1.000000
PlayerXPTimeMultiplier=1.000000
DogsOfTheDesertSpawnWithDogs=False
CrossDesertOnce=True
WeaponEffectBoundsShorteningFraction=0.200000
EnforceRotationRateWhenRoaming_2=True
EnforceRotationRateInCombat_2=True
ClipVelocityOnNavmeshBoundary=True
UnarmedNPCStepBackDistance=400.000000
PathFollowingAvoidanceMode=257
RotateToTargetSendsAngularVelocity=True
TargetPredictionMaxSeconds=1.000000
TargetPredictionAllowSecondsForAttack=0.400000
MaxAggroRange=9000.000000
serverRegion=256
LandClaimRadiusMultiplier=1.000000
ItemConvertionMultiplier=1.000000
PathFollowingSendsAngularVelocity=False
UnconsciousTimeSeconds=600.000000
ConciousnessDamageMultiplier=1.000000
ValidatePhysNavWalkWithRaycast=True
LocalNavMeshVisualizationFrequency=-1.000000
UseLocalQuadraticAngularVelocityPrediction=True
AvatarsDisabled=False
AvatarLifetime=60.000000
AvatarSummonTime=20.000000
IsBattlEyeEnabled=False
RegionAllowAfrica=True
RegionAllowAsia=True
RegionAllowCentralEurope=True
RegionAllowEasternEurope=True
RegionAllowWesternEurope=True
RegionAllowNorthAmerica=True
RegionAllowOceania=True
RegionAllowSouthAmerica=True
RegionBlockList=
bCanBeDamaged=True
CanDamagePlayerOwnedStructures=True
EnableSandStorm=True
ClanMaxSize=22
HarvestAmountMultiplier=1
ResourceRespawnSpeedMultiplier=1
"""
}

server_settings_template_pve() {
    echo """
[ServerSettings]
PVPEnabled=False
AdminPassword=ChangeMe
NPCMindReadingMode=0
MaxNudity=2
ServerCommunity=0
ConfigVersion=3
BlueprintConfigVersion=14
PlayerKnockbackMultiplier=1.000000
NPCKnockbackMultiplier=1.000000
StructureDamageMultiplier=1.000000
StructureDamageTakenMultiplier=1.000000
StructureHealthMultiplier=1.000000
NPCRespawnMultiplier=1.000000
NPCHealthMultiplier=1.000000
CraftingCostMultiplier=1.000000
PlayerDamageMultiplier=1.000000
PlayerDamageTakenMultiplier=1.000000
MinionDamageMultiplier=1.000000
MinionDamageTakenMultiplier=1.000000
NPCDamageMultiplier=1.000000
NPCDamageTakenMultiplier=1.000000
PlayerEncumbranceMultiplier=1.000000
PlayerEncumbrancePenaltyMultiplier=1.000000
PlayerMovementSpeedScale=1.000000
PlayerStaminaCostSprintMultiplier=1.000000
PlayerSprintSpeedScale=1.000000
PlayerStaminaCostMultiplier=1.000000
PlayerHealthRegenSpeedScale=1.000000
PlayerStaminaRegenSpeedScale=1.000000
PlayerXPRateMultiplier=1.000000
PlayerXPKillMultiplier=1.000000
PlayerXPHarvestMultiplier=1.000000
PlayerXPCraftMultiplier=1.000000
PlayerXPTimeMultiplier=1.000000
DogsOfTheDesertSpawnWithDogs=False
CrossDesertOnce=True
WeaponEffectBoundsShorteningFraction=0.200000
EnforceRotationRateWhenRoaming_2=True
EnforceRotationRateInCombat_2=True
ClipVelocityOnNavmeshBoundary=True
UnarmedNPCStepBackDistance=400.000000
PathFollowingAvoidanceMode=257
RotateToTargetSendsAngularVelocity=True
TargetPredictionMaxSeconds=1.000000
TargetPredictionAllowSecondsForAttack=0.400000
MaxAggroRange=9000.000000
serverRegion=256
LandClaimRadiusMultiplier=1.000000
ItemConvertionMultiplier=1.000000
PathFollowingSendsAngularVelocity=False
UnconsciousTimeSeconds=600.000000
ConciousnessDamageMultiplier=1.000000
ValidatePhysNavWalkWithRaycast=True
LocalNavMeshVisualizationFrequency=-1.000000
UseLocalQuadraticAngularVelocityPrediction=True
AvatarsDisabled=False
AvatarLifetime=60.000000
AvatarSummonTime=20.000000
IsBattlEyeEnabled=False
RegionAllowAfrica=True
RegionAllowAsia=True
RegionAllowCentralEurope=True
RegionAllowEasternEurope=True
RegionAllowWesternEurope=True
RegionAllowNorthAmerica=True
RegionAllowOceania=True
RegionAllowSouthAmerica=True
RegionBlockList=
bCanBeDamaged=True
CanDamagePlayerOwnedStructures=False
EnableSandStorm=True
ClanMaxSize=22
HarvestAmountMultiplier=1
ResourceRespawnSpeedMultiplier=1
EverybodyCanLootCorpse=False
"""
}

function override_config() {
    # workarround for whitespaces in env vars
    printenv | grep "$_env_variable_prefix" | grep -E "$_env_variable_filter" > /tmp/override_config.tmp
    env_arr=()
    while read line; do
	env_arr+=( "$line" )
    done < /tmp/override_config.tmp

    rm -f /tmp/override_config.tmp

    if [[ ${#env_arr[@]} > 0 ]]; then
	for env_variable in "${env_arr[@]}";do
	    filename="$(echo $env_variable | cut -d "=" -f1 | cut -d "_" -f2).ini"
	    section=$(echo $env_variable | cut -d "=" -f1 | cut -d "_" -f3)
	    key=$(echo $env_variable | cut -d "=" -f1 | cut -d "_" -f4)
	    # get value
	    value=$(echo $env_variable | cut -d "=" -f2-)

	    crudini --set "${_config_folder}/${filename}" "${section}" "${key}" "${value}"
	done
    fi
}


grep "${_bashrc_tag_start}" /etc/bash.bashrc > /dev/null
[[ $? != 0 ]] && setup_bashrc

steamcmd_setup
setup_server_config_first_time

override_config

# start supervisord
"$@"
