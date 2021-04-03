# docker-conanexiles

[![Docker Pulls](https://img.shields.io/docker/pulls/alinmear/docker-conanexiles.svg?style=flat)](https://hub.docker.com/r/alinmear/docker-conanexiles/)
[![Github Stars](https://img.shields.io/github/stars/alinmear/docker-conanexiles.svg?style=flat)](https://github.com/alinmear/docker-conanexiles)
[![Github Forks](https://img.shields.io/github/forks/alinmear/docker-conanexiles.svg?style=flat?label=github%20forks)](https://github.com/alinmear/docker-conanexiles/)
[![Gitter](https://img.shields.io/gitter/room/alinmear/docker-conanexiles.svg?style=flat)](https://gitter.im/alinmear/docker-conanexiles)
[![Donation](https://img.shields.io/badge/Buy%20me%20a-coffee-blue?style=flat)](https://www.paypal.com/donate?business=VGB57FGZRDEFQ&currency_code=EUR)

---
**NOTE**

Mod support reworked. Manual Installation with mods.txt File will no longer work. Use the New Env Variable. See the mods section within this readme for more informations.

While configuring my server and trying to fix some shortcomings it stumbled over an overwhelming good post about server tweaks: <https://steamcommunity.com/sharedfiles/filedetails/?id=2130895654>. After enabling those settings, conanexiles feels indeed like another game. I added those configs within the example `docker-compose.yml` and also within this Readme. Hopefuly this will make you game experience alot better...

---

## Features

* Full automatic provisioning of Steam and Conan Exiles Dedicated Server
* Mod Support
* Autoupdate and restart of the Conan Exiles server
* Full control of every config aspect via Environment variables
* Templates for first time setup
* Running multiple instances with multiple config directories
* RCON Support (Ingame Broadcast Msgs for Server events like update) --> DEFAULT ENABLED

---

## Usage

**READ the following sections [Storage options](#storage-options), [First Time Setup](#first-time-setup), [Multi Instance Setup](#multi-instance-setup) & [Environment Variables and Config Options](#environment-variables-and-config-options) if you have not used this image before!**

### Get started

```sh
curl -LJO https://raw.githubusercontent.com/alinmear/docker-conanexiles/master/docker-compose.yml
docker-compose pull
```

#### Start all services (3 games services and 1 redis)

`docker-compose up -d`

#### Start one game service and redis

`docker compose up -d redis && docker compose up -d ce0`

### Update image and rollout

`docker-compose pull && docker-compose up -d`

### Shutdown

`docker-compose down`

---

## Create a simplified `docker-compose.yml`

The `docker-compose.yml` file can be customized e.g. if you do not want to run several game servers.

**podman-compose**:

``` sh
podman-compose -f podman-compose.yml up

# recreate for testing. CARE: all volumes will be removed and new created --> data will be lost
# podman-compose -f podman-compose.yml up --force-recreate
```

NOTE: if you are on a system using podman instead of docker you can simply install podman-compose via:

```sh
pip3 install --user https://github.com/containers/podman-compose/archive/devel.tar.gz
```

At the moment we need to use the devel branch, because the support for volumes is only available there. Also `restart: unless-stopped` is not supported so we need to replace this with `restart: always`.

### Example

```yaml
version: "3.5"

services:
  ce0:
    image: alinmear/docker-conanexiles:latest
    depends_on: 
      - redis
    restart: unless-stopped
    environment:
      - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName=My Cool Server"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
      - "CONANEXILES_INSTANCENAME=exiles0"
      - "CONANEXILES_Game_RconPlugin_RconEnabled=1"
      - "CONANEXILES_Game_RconPlugin_RconPassword=REDACTED"
      - "CONANEXILES_Game_RconPlugin_RconPort=25575"
      - "CONANEXILES_Game_RconPlugin_RconMaxKarma=60"
      # Very Good Defaults
      - "CONANEXILES_Engine_/script/onlinesubsystemutils.ipnetdriver_NetServerMaxTickRate=30" #INSERT A VALUE OF 30 OR HIGHER
      - "CONANEXILES_Engine_/script/onlinesubsystemutils.ipnetdriver_MaxClientRate=600000"
      - "CONANEXILES_Engine_/script/onlinesubsystemutils.ipnetdriver_MaxInternetClientRate=600000"
      - "CONANEXILES_Engine_SystemSettings_dw.NetClientFloatsDuringNavWalking=0"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.EnableAISpawning=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.EnableInitialAISpawningPass=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NPCsTargetBuildings=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.nav.AvoidNonPawns=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.EnableStaticRoamingPaths=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.nav.InterpolateAvoidanceResult=1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.AILOD1Distance=4000"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.AILOD2Distance=8000"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.AILOD3Distance=11500"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.SkeletalMeshTickRate=0.1"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD2ListenServerControllerTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3ListenServerControllerTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3ListenServerBehaviorTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD2ListenServerMovementTickRate=2.0f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3ListenServerMovementTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD2ControllerTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3ControllerTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3BehaviorTickRate=20.f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD2MovementTickRate=2.0f"
      - "CONANEXILES_Engine_/script/conansandbox.systemsettings_dw.NpcLOD3MovementTickRate=20.f"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.GraphicsAdapter=-1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.Cache.LightingCacheDimension=75"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.AllowLandscapeShadows=1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.HighQualityLightMaps=1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.AOTrimOldRecordsFraction=0.5"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.AOInterpolationAngleScale=1.1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.AOInterpolationRadiusScale=1.1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.AOHeightfieldOcclusion=1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.TemporalAASamples=4"
      - "CONANEXILES_Engine_/script/engine.renderersettings_r.TemporalAACurrentFrameWeight=0.1"
      - "CONANEXILES_Engine_/script/engine.renderersettings_grass.densityScale=1.5"
      - "CONANEXILES_Engine_/script/engine.physicssettings_RagdollAggregateThreshold=2"
      - "CONANEXILES_Engine_/script/engine.physicssettings_bDefaultHasComplexCollision=True"
      - "CONANEXILES_Engine_/script/engine.physicssettings_bSubstepping=True"
      - "CONANEXILES_Engine_/script/engine.physicssettings_bSubsteppingAsync=True"
      - "CONANEXILES_Engine_/script/engine.physicssettings_MaxSubstepDeltaTime=0.025"
      - "CONANEXILES_Engine_/script/engine.physicssettings_MaxSubsteps=4"
      - "CONANEXILES_Engine_/script/aimodule.crowdmanager_NavmeshCheckInterval=0.100000"
      - "CONANEXILES_Engine_/script/aimodule.crowdmanager_PathOptimizationInterval=0.100000"
      - "CONANEXILES_Engine_/script/aimodule.crowdmanager_bResolveCollisions=True"
      - "CONANEXILES_Engine_/script/aimodule.aisystem_bAllowStrafing=True"
      - "CONANEXILES_Engine_/script/engine.audiosettings_bAllowCenterChannel3DPanning=True"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_TotalNetBandwidth=80000000"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MaxDynamicBandwidth=100000"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MinDynamicBandwidth=10000"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MoveRepSize=512.0f"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MAXPOSITIONERRORSQUARED=3.0f"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MAXCLIENTUPDATEINTERVAL=0.25f"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MaxMoveDeltaTime=0.125f"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_MaxClientSmoothingDeltaTime=1.0f"
      - "CONANEXILES_Game_/script/engine.gamenetworkmanager_ClientAuthorativePosition=true"
      - "CONANEXILES_Game_/script/engine.granitesettings_bAdvanced=True"
      - "CONANEXILES_Game_/script/engine.granitesettings_r.GraniteStreamLightMaps=True"
      - "CONANEXILES_Game_/script/conansandbox.aisense_newsight_MaxTracesPerTick=2000"
      - "CONANEXILES_Game_/script/conansandbox.aisenseconfig_newsight_PeripheralVisionAngleDegrees=75"
      - "CONANEXILES_Game_/script/aimodule.envquerymanager_MaxAllowedTestingTime=0.003"
      - "CONANEXILES_Game_/script/aimodule.envquerymanager_bTestQueriesUsingBreadth=false"
      - "CONANEXILES_Game_Settings.Physics.Cloth_MaxClothSimuatingActors=3"
      - "CONANEXILES_Game_Settings.Physics.Cloth_ClothSimulationAdjustmentInterval=0.650000"
      - "CONANEXILES_ServerSettings_ServerSettings_RegionBlockList="
      - "CONANEXILES_ServerSettings_ServerSettings_CorpsesPerPlayer=3"
      - "CONANEXILES_ServerSettings_ServerSettings_MaxDeathMapMarkers=3"
      - "CONANEXILES_ServerSettings_ServerSettings_BuildingPreloadRadius=90"
      - "CONANEXILES_ServerSettings_ServerSettings_EnforceRotationRateWhenRoaming_2=False"
      - "CONANEXILES_ServerSettings_ServerSettings_EnforceRotationRateInCombat_2=False"
      - "CONANEXILES_ServerSettings_ServerSettings_TargetPredictionMaxSeconds=0.5"
      - "CONANEXILES_ServerSettings_ServerSettings_TargetPredictionAllowSecondsForAttack=0.2"
      - "CONANEXILES_ServerSettings_ServerSettings_PlayerKnockbackMultiplier=0.25"
      - "CONANEXILES_ServerSettings_ServerSettings_ClipVelocityOnNavmeshBoundary=True"
      - "CONANEXILES_ServerSettings_ServerSettings_ValidatePhysNavWalkWithRaycast=true"
      - "CONANEXILES_ServerSettings_ServerSettings_LocalNavMeshVisualizationFrequency=0.1"
      - "CONANEXILES_ServerSettings_ServerSettings_RotateToTargetSendsAngularVelocity=True"
      - "CONANEXILES_ServerSettings_ServerSettings_PathFollowingSendsAngularVelocity=True"
      - "CONANEXILES_ServerSettings_ServerSettings_UseLocalQuadraticAngularVelocityPrediction=true"
      - "CONANEXILES_ServerSettings_ServerSettings_LQAVPUseTime=0.150000"
      - "CONANEXILES_ServerSettings_ServerSettings_LQAVPFadeTime=0.100000"
      - "CONANEXILES_ServerSettings_ServerSettings_LQAVPMethod=2"
      - "CONANEXILES_ServerSettings_ServerSettings_NetworkSimulatedSmoothRotationTimeWithLQAVP=0.100000"
      - "CONANEXILES_ServerSettings_ServerSettings_NPCRespawnMultiplier=5.000000"
      - "CONANEXILES_ServerSettings_ServerSettings_NPCMaxSpawnCapMultiplier=1.000000 "
      - "CONANEXILES_Scalability_AntiAliasingQuality@0_r.MSAA.CompositingSampleCount=0"
      - "CONANEXILES_Scalability_AntiAliasingQuality@1_r.MSAA.CompositingSampleCount=2"
      - "CONANEXILES_Scalability_AntiAliasingQuality@2_r.MSAA.CompositingSampleCount=4"
      - "CONANEXILES_Scalability_AntiAliasingQuality@3_r.MSAA.CompositingSampleCount=4"
      - "CONANEXILES_Scalability_ViewDistanceQuality@0_r.ViewDistanceScale=3.4"
      - "CONANEXILES_Scalability_ViewDistanceQuality@1_r.ViewDistanceScale=3.6"
      - "CONANEXILES_Scalability_ViewDistanceQuality@2_r.ViewDistanceScale=3.8"
      - "CONANEXILES_Scalability_ViewDistanceQuality@3_r.ViewDistanceScale=4.0"
      - "CONANEXILES_Scalability_ShadowQuality@0_r.Shadow.CSM.MaxCascades=1"
      - "CONANEXILES_Scalability_ShadowQuality@0_r.Shadow.MaxResolution=512"
      - "CONANEXILES_Scalability_ShadowQuality@0_r.Shadow.DistanceScale=0.6"
      - "CONANEXILES_Scalability_ShadowQuality@0_r.Shadow.MaxPointCasters=0"
      - "CONANEXILES_Scalability_ShadowQuality@0_r.Shadow.CSMDepthBias=30"
      - "CONANEXILES_Scalability_ShadowQuality@1_r.Shadow.CSM.MaxCascades=1"
      - "CONANEXILES_Scalability_ShadowQuality@1_r.Shadow.RadiusThreshold=0.05"
      - "CONANEXILES_Scalability_ShadowQuality@1_r.Shadow.DistanceScale=0.7"
      - "CONANEXILES_Scalability_ShadowQuality@1_r.Shadow.MaxPointCasters=0"
      - "CONANEXILES_Scalability_ShadowQuality@1_r.Shadow.CSMDepthBias=25"
      - "CONANEXILES_Scalability_ShadowQuality@2_r.DistanceFieldAO=1"
      - "CONANEXILES_Scalability_ShadowQuality@2_r.Shadow.MaxPointCasters=1"
      - "CONANEXILES_Scalability_ShadowQuality@2_r.Shadow.CSMDepthBias=20"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.CSM.MaxCascades=10"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.CSM.TransitionScale=2"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.CSMDepthBias=100"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.MaxResolution=4096"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.FadeExponent=0"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.Faderesolution=1024"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.DistanceFieldAO=1"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.PerObjectDirectionalDepthBias=10000"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.PointLightDepthBias=10000"
      - "CONANEXILES_Scalability_ShadowQuality@3_r.Shadow.SpotLightDepthBias=10000"
      - "CONANEXILES_Scalability_PostProcessQuality@0_r.AllowLandscapeShadows=0"
      - "CONANEXILES_Scalability_PostProcessQuality@0_r.HighQualityLightMaps=0"
      - "CONANEXILES_Scalability_PostProcessQuality@0_r.TonemapperQuality=1"
      - "CONANEXILES_Scalability_PostProcessQuality@1_r.AllowLandscapeShadows=0"
      - "CONANEXILES_Scalability_PostProcessQuality@1_r.HighQualityLightMaps=0"
      - "CONANEXILES_Scalability_PostProcessQuality@1_r.TonemapperQuality=1"
      - "CONANEXILES_Scalability_PostProcessQuality@2_r.BloomQuality=4"
      - "CONANEXILES_Scalability_PostProcessQuality@2_r.TonemapperQuality=1"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.AmbientOcclusionLevels=2"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.DepthOfFieldQuality=4"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.RenderTargetPoolMin=1000"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.LensFlareQuality=3"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.EyeAdaptationQuality=3"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.Bloom.Cross=1"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.Tonemapper.Quality=1"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.Tonemapper.Sharpen=0.2"
      - "CONANEXILES_Scalability_PostProcessQuality@3_r.ReflectionEnvironmentLightmapMixLargestWeight=7500"
      - "CONANEXILES_Scalability_TextureQuality@0_r.Streaming.LimitPoolSizeToVRAM=1"
      - "CONANEXILES_Scalability_TextureQuality@0_r.Streaming.PoolSize=500"
      - "CONANEXILES_Scalability_TextureQuality@1_r.Streaming.LimitPoolSizeToVRAM=1"
      - "CONANEXILES_Scalability_TextureQuality@1_r.Streaming.PoolSize=800"
      - "CONANEXILES_Scalability_TextureQuality@2_r.Streaming.LimitPoolSizeToVRAM=1"
      - "CONANEXILES_Scalability_TextureQuality@2_r.Streaming.PoolSize=1500"
      - "CONANEXILES_Scalability_TextureQuality@3_r.Streaming.LimitPoolSizeToVRAM=0"
      - "CONANEXILES_Scalability_TextureQuality@3_r.Streaming.PoolSize=3000"
      - "CONANEXILES_Scalability_EffectsQuality@0_r.SSS.Scale=0"
      - "CONANEXILES_Scalability_EffectsQuality@0_r.SSS.Quality=0"
      - "CONANEXILES_Scalability_EffectsQuality@0_r.SSS.HalfRes=1"
      - "CONANEXILES_Scalability_EffectsQuality@0_r.ParticleLightQuality=0"
      - "CONANEXILES_Scalability_EffectsQuality@1_r.SSS.Scale=0.75"
      - "CONANEXILES_Scalability_EffectsQuality@1_r.SSS.Quality=0"
      - "CONANEXILES_Scalability_EffectsQuality@1_r.SSS.HalfRes=1"
      - "CONANEXILES_Scalability_EffectsQuality@1_r.ParticleLightQuality=0"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.ReflectionEnvironment=1"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.SubsurfaceQuality=0"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.SSS.Scale=1"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.SSS.Quality=-1"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.SSS.HalfRes=1"
      - "CONANEXILES_Scalability_EffectsQuality@2_r.ParticleLightQuality=1"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.ReflectionEnvironment=1"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.SubsurfaceQuality=1"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.EmitterSpawnRateScale=1.5"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.SSR.Quality=4"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.SSS.Scale=1"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.SSS.Quality=1"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.SSS.HalfRes=0"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.ParticleLightQuality=2"
      - "CONANEXILES_Scalability_EffectsQuality@3_r.FluidQuality=2"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.MipBias=1"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.MaxAnisotropy=1"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.GPUCacheSizeScale=1.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.CPUCacheSizeScale=1.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.MinGPUCacheSizeInMB=10"
      - "CONANEXILES_Scalability_GraniteTextureQuality@0_r.GraniteSDK.MinCPUCacheSizeInMB=10"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.MipBias=0.5"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.MaxAnisotropy=2"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.GPUCacheSizeScale=3.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.CPUCacheSizeScale=2.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.MinGPUCacheSizeInMB=10"
      - "CONANEXILES_Scalability_GraniteTextureQuality@1_r.GraniteSDK.MinCPUCacheSizeInMB=10"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.MipBias=0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.MaxAnisotropy=4"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.GPUCacheSizeScale=5.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.CPUCacheSizeScale=3.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.MinGPUCacheSizeInMB=20"
      - "CONANEXILES_Scalability_GraniteTextureQuality@2_r.GraniteSDK.MinCPUCacheSizeInMB=20"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.MipBias=0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.MaxAnisotropy=8"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.GPUCacheSizeScale=10.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.CPUCacheSizeScale=4.0"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.MinGPUCacheSizeInMB=20"
      - "CONANEXILES_Scalability_GraniteTextureQuality@3_r.GraniteSDK.MinCPUCacheSizeInMB=20 "
      - "CONANEXILES_CharacterLOD_/script/conansandbox.characterlodsystem_SimultaneousIK=8"
      - "CONANEXILES_CharacterLOD_/script/conansandbox.characterlodsystem_IKLodUpdateInterval=0.3"
      - "CONANEXILES_CharacterLOD_/script/conansandbox.characterlodsystem_IKRange=6000.000000"
      - "CONANEXILES_CharacterLOD_/script/conansandbox.characterlodsystem_SimultaneousHighQualityHair=8"
      - "CONANEXILES_CharacterLOD_/script/conansandbox.characterlodsystem_HairLodUpdateInterval=0.75 "
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_NumIrradianceCalculationPhotons=2000"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_NumIrradianceCalculationPhotons=4096"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_IndirectPhotonSearchDistance=1000"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_IndirectPhotonSearchDistance=180"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_DirectIrradiancePhotonDensity=1024"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_IndirectPhotonDensity=20000"
      - "CONANEXILES_Lightmass_DevOptions.PhotonMapping_IndirectIrradiancePhotonDensity=16000"
      - "CONANEXILES_Lightmass_DevOptions.StaticLightingProductionQuality_NumHemisphereSamplesScale=100"
      - "CONANEXILES_Lightmass_DevOptions.StaticLightingProductionQuality_NumDirectPhotonsScale=1"
      - "CONANEXILES_Lightmass_DevOptions.StaticLightingProductionQuality_NumIndirectPhotonsScale=1"
      - "CONANEXILES_Lightmass_DevOptions.StaticLightingProductionQuality_NumIndirectIrradiancePhotonsScale=1"
      - "CONANEXILES_Lightmass_DevOptions.StaticLightingProductionQuality_AdaptiveBrightnessThresholdScale=.01"
      - "CONANEXILES_Lightmass_DevOptions.ImportanceTracing_NumHemisphereSamples=256" 

    ports:
        - 7777:7777/udp
        - 7778:7778/udp
        - 27015:27015/udp
    volumes:
        - data:/conanexiles

  redis:
    image: redis:5-alpine
    restart: unless-stopped
    environment:
      - "TZ=Europe/Vienna"
    volumes:
      - redis:/data/

volumes:
    data:
    redis:
```

---

## Storage options

A persistent data storage for the configuration and game data is required.

No persistance = data is gone when the container shuts down!

With Docker you got two options Volumes and Bind mounts - <https://docs.docker.com/storage/#more-details-about-mount-types>

### Volume

```yaml
    volumes:
        - data:/conanexiles
```

### Bind mount

```yaml
    volumes:
        - /my-data:/conanexiles
```

---

## First Time Setup

### Provide a Config

If there is a folder with configurations found at `/tmp/docker-conanexiles` this folder will be copied to the config folder of the server. This will only happen if there is no configuration already existing (the case of a clean container initialization).

### Default Templates

Use the environment variable `CONANEXILES_SERVER_TYPE=pve` to use the pve template; otherwise the pvp template will be used if no configuration has been provided.

---

## Multi Instance Setup

It is possible to run multiple server instances with 1 Server Installation. For better understanding we have to split the conan-exiles installation into two parts:

* Binaries for running the server
* Configurations for an instance (db, configs)

We can create an architecture like this:

```txt
- BINARY
-> Instance 1 (Master-Server)
--> ConfigFolder1
-> Instance 2 (Slave-Server)
--> ConfigFolder2
-> Instance 3 (Slave-Server)
--> ConfigFolder3
-> Instance n (Slave-Server)
--> ConfigFolderN
```

The Master-Server is taking care about the binaries, more precisely keeping it up to date. If there is a new update, the master server will notify the Slave-Servers for shutting down to make the update. Afterwards the master informs the Slave-Servers to spin up again.

**NOTE**: There should always be only 1 Master-Server-Instance, otherwise it could break your setup, if two master server are updating at the same time.

!! **STANDARD-Behavior**: The Docker Image itself sets der master-server value to 1, which means that each server is a master server. For a multi instance setup you have to explicit set CONANEXILES_MASTERSERVER=0. You also have to specify the CONANEXILES_INSTANCENAME, otherwise your instances would write changes into the same db --> kaboom.

ENV-VARS to Setup:

* CONANEXILES_MASTERSERVER = 0/1
* CONANEXILES_INSTANCENAME = `<name>`
  * Used for the DB and config file dir of the instance (-usedir)
* `CONANEXILES_PORT = 7777`
  * Standard Port, for multiple instance you have to increment this per instance e.g. instance 0 Port 7777, instance 1 Port 7779, instance n Port 77yn
  * NOTE: You also have to adjust the proper port mapping within the compose file
* CONANEXILES_QUERYPORT = 27015
  * Standard QueryPort, same as Port for multiple instances e.g. instance 0 QueryPort 27015, instance 1 QueryPort 27017, instance n QueryPort 270yn
  * NOTE: You also have to adjust the proper port mapping within the compose file

Default: CONANEXILES_MASTERSERVER = 1 (only the master server is able to make updates)
Default: CONANEXILES_INSTANCENAME = saved (the default config folder name)

---

## Mod Support

Mods can be install with the global env variable `CONANEXILES_MODS`. Specify ModIDs as comma separated list there. E.g.

```yaml
# Pippi
## ModID: 880454836 

# Fashionist
# ModID: 1159180273

CONANEXILES_MODS: 880454836,1159180273
```

NOTE: Yout can get the modids from Steamworkshop.

After a restart the mods will be downloaded, activated and updated via steamworkshop.

## Environment Variables and Config Options

A conan exiles dedicated server uses a lot of configuration options to influence nearly every aspect of the game logics.
To have full control of this complex configuration situation i implemented a logic to set these values in every config files.

ConanExiles uses a common ini format. That means that a config file has the following logic:

```ini
[section1]
key1=value
key2=value

[section2] 
key1=value
key2=value
```

ConanExiles uses the following config files:

* CharacterLOD.ini
* Compat.ini
* DeviceProfiles.ini
* EditorPerProjectUserSettings.ini
* Engine.ini
* Game.ini
* GameUserSettings.ini
* GameplayTags.ini
* GraniteCooked.ini
* GraniteCookedMod.ini
* Hardware.ini
* Input.ini
* Lightmass.ini
* Scalability.ini
* ServerSettings.ini

### Logic

To set values in one of these ini files use the following logic to set environment variables:
`CONANEXILES_<filename>_<section>_<key>_<value>`

#### Examples

To set e.g. the **AdminPassword** use the following logic:
`CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution`
(Note: The ini files is named   ServerSettings.ini and the Section within the file has also the name ServerSettings)

To set e.g. the **Servername and a ServerPassword**:
`CONANEXILES_Engine_OnlineSubSystemSteam_ServerName="My Cool Server"`
`CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword="MySecret"`

To set e.g. the **Max Number of Players**:
This will be implemented soon, because the smart logic from above won't work. The section within the Game.ini file has the value `[/script/engine.gamesession]` which cannot be addressed via an environment variable name.  
For now you have 2 Options to set this value. First provide at first time startup a configuration or second change it manually when the container has been initialized.

**NOTE**: If an Environment Variable is set it will override the value within the specified ini file at every container startup. If an ServerAdmin manually changes values within the game, these will be lost after container restart.

### List of separated environment variables

* `CONANEXILES_SERVER_TYPE`
This Variable defines the profile for the first time setup at container provisioning, if no config folder has been provided.  

==> **pvp**
==> pve

* `CONANEXILES_CMDSWITCHES`
With this variable you are able to append switches to the exiles run command.

e.g.  CONANEXILES_CMDSWITCHES="-MULTIHOME=xxx.xxx.xxx.xxx" will result in
command=wine64 /conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log -userdir=%(ENV_CONANEXILES_INSTANCENAME)s -MULTIHOME=xxx.xxx.xxx.xxx

* `CONANEXILES_UPDATE_SHUTDOWN_TIMER`
With this variable you can set the amount of time in minutes, the server waits to shutdown for an update.
