# docker-conanexiles

[![Docker Pulls](https://img.shields.io/docker/pulls/alinmear/docker-conanexiles.svg?style=flat)](https://hub.docker.com/r/alinmear/docker-conanexiles/) 
[![Github Stars](https://img.shields.io/github/stars/alinmear/docker-conanexiles.svg?style=flat)](https://github.com/alinmear/docker-conanexiles) 
[![Github Forks](https://img.shields.io/github/forks/alinmear/docker-conanexiles.svg?style=flat?label=github%20forks)](https://github.com/alinmear/docker-conanexiles/)
[![Gitter](https://img.shields.io/gitter/room/alinmear/docker-conanexiles.svg?style=flat)](https://gitter.im/alinmear/docker-conanexiles)

## Features
* Full automatic provisioning of Steam and Conan Exiles Dedicated Server
* Autoupdate and restart of the Conan Exiles server
* Full control of every config aspect via Environment variables
* Templates for first time setup
* Running multiple instances with multiple config directories
* RCON Support (Ingame Broadcast Msgs for Server events like update) --> DEFAULT ENABLED

---

## Usage
**READ the following sections [Storage options](#storage-options), [First Time Setup](#first-time-setup), [Multi Instance Setup](#multi-instance-setup) & [Environment Variables and Config Options](#environment-variables-and-config-options) if you have not used this image before!**

### Get started
```
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

### Example
```yaml
version: "3.5"

services:
  ce0:
    build: src/
    image: alinmear/docker-conanexiles:1.2
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

With Docker you got two options Volumes and Bind mounts - https://docs.docker.com/storage/#more-details-about-mount-types

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

- Binaries for running the server
- Configurations for an instance (db, configs)

We can create an architecture like this:

```
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

- CONANEXILES_MASTERSERVER = 0/1
- CONANEXILES_INSTANCENAME = <name>
  - Used for the DB and config file dir of the instance (-usedir)
- CONANEXILES_PORT = 7777
  - Standard Port, for multiple instance you have to increment this per instance e.g. instance 0 Port 7777, instance 1 Port 7779, instance n Port 77yn
  - NOTE: You also have to adjust the proper port mapping within the compose file
- CONANEXILES_QUERYPORT = 27015
  - Standard QueryPort, same as Port for multiple instances e.g. instance 0 QueryPort 27015, instance 1 QueryPort 27017, instance n QueryPort 270yn
  - NOTE: You also have to adjust the proper port mapping within the compose file

Default: CONANEXILES_MASTERSERVER = 1 (only the master server is able to make updates)
Default: CONANEXILES_INSTANCENAME = saved (the default config folder name)

---

## Environment Variables and Config Options
A conan exiles dedicated server uses a lot of configuration options to influence nearly every aspect of the game logics.
To have full control of this complex configuration situation i implemented a logic to set these values in every config files.

ConanExiles uses a common ini format. That means that a config file has the following logic:
   
```
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

###  List of separated environment variables:

* `CONANEXILES_SERVER_TYPE` 
This Variable defines the profile for the first time setup at container provisioning, if no config folder has been provided.  
   
	==> **pvp**
	==> pve

* `CONANEXILES_CMDSWITCHES`
With this variable you are able to append switches to the exiles run command.

e.g.  CONANEXILES_CMDSWITCHES="-MULTIHOME=xxx.xxx.xxx.xxx" will result in
command=wine64 /conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log -userdir=%(ENV_CONANEXILES_INSTANCENAME)s -MULTIHOME=xxx.xxx.xxx.xxx
