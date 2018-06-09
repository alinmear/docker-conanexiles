# docker-conanexiles

[![Docker Pulls](https://img.shields.io/docker/pulls/alinmear/docker-conanexiles.svg?style=flat)](https://hub.docker.com/r/alinmear/docker-conanexiles/) 
[![Github Stars](https://img.shields.io/github/stars/alinmear/docker-conanexiles.svg?style=flat)](https://github.com/alinmear/docker-conanexiles) 
[![Github Forks](https://img.shields.io/github/forks/alinmear/docker-conanexiles.svg?style=flat?label=github%20forks)](https://github.com/alinmear/docker-conanexiles/)
[![Gitter](https://img.shields.io/gitter/room/alinmear/docker-conanexiles.svg?style=flat)](https://gitter.im/alinmear/docker-conanexiles)

Features:
* Full automatic provisioning of steam and conanexiles dedicated server
* Autoupdate and restart of the conanexiles server (Now working, thx for contribution @kijdam) 
* Full control of every config aspect via Environment variables
* Templates for first time setup
* Running multiple Instances with multiple config directories

## New Versioning introduced

NOTE: After PR #12 i introduced versioning for this project. Before the pr we have the version 0.0. With the new multi instance setup (#12) we have the version 1.0.

## Multi Instance Setup

It is now possible to run multiple Server Instances with 1 Server Installation. For better understanding we have to split a conan-exiles installation into two parts: 

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
--> ConfigFoldern
```

The Master-Server is taking care about the binaries, more precisley keeping it up to date. If there is a new update, the master server will notify the Slave-Servers for shutting down to make the update. Afterwards the master informs the Slave-Servers to spin up again.

**NOTE**: There should always be only 1 Master-Server-Instance, otherwise it could break your setup, if two master server are updating at the same time.

!! **STANDARD-Behavior**: The Docker Image itself sets der master-server value to 1, which means that each server is a master server. For a multi instance setup you have to explicit set CONANEXILES_MASTERSERVER=0. You also have to specify the CONANEXILES_INSTANCENAME, otherwise your instances would write changes into the same db --> kaboom.

ENV-VARS to Setup:

- CONANEXILES_MASTERSERVER = 0/1
- CONANEXILES_INSTANCENAME = <name>

Default: CONANEXILES_MASTERSERVER = 1 (only the master server is able to make updates)
Default: CONANEXILES_INSTANCENAME = saved (the default config folder name)

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

###  List of separated environmnent variables:

* `CONANEXILES_SERVER_TYPE` 
This Variable defines the profile for the first time setup at container provisioning, if no config folder has been provided.  
   
	==> **pvp**
	==> pve

* `CONANEXILES_CMDSWITCHES`
With this variable you are able to append switches to the exiles run command.

e.g.  CONANEXILES_CMDSWITCHES="-MULTIHOME=xxx.xxx.xxx.xxx" will result in
command=wine64 /conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log -userdir=%(ENV_CONANEXILES_INSTANCENAME)s -MULTIHOME=xxx.xxx.xxx.xxx

## Usage

#### Get latest image
`docker pull alinmear/docker-conanexiles:latest`

#### Create a `docker-compose.yml` with a multi instance setup
```yaml
version: '2'

services:
  conanexiles0:
    image: alinmear/docker-conanexiles
    restart: always
    environment:
      - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName='My Cool Server'"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
      - "CONANEXILES_INSTANCENAME=exiles0"
    ports:
        - 7777:7777/udp
        - 7778:7778/udp
        - 27015:27015/udp
    volumes:
        - data:/conanexiles

  conanexiles1:
    image: alinmear/docker-conanexiles
    restart: always
    environment:
      - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName='My Cool Server'"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
      - "CONANEXILES_MASTERSERVER=0"
      - "CONANEXILES_INSTANCENAME=exiles1"
    ports:
        - 7779:7777/udp
        - 27017:27015/udp
    volumes:
        - data:/conanexiles

  conanexiles2:
    image: alinmear/docker-conanexiles
    restart: always
    environment:
      - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName='My Cool Server'"
      - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
      - "CONANEXILES_MASTERSERVER=0"
      - "CONANEXILES_INSTANCENAME=exiles2"
    ports:
        - 7780:7777/udp
        - 27018:27015/udp
    volumes:
        - data:/conanexiles

  redis:
    image: redis:alpine
    restart: always

volumes:
    data:
        driver: local
```

#### Create a `docker-compose.yml` with a named volume

```yaml
version: '2'

services:
  conanexiles:
    image: alinmear/docker-conanexiles
    restart: always
    environment:
        - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
        - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName='My Cool Server'"
        - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
    ports:
        - 7777:7777/udp
        - 7778:7778/udp
        - 27015:27015/udp
    volumes:
        - data:/conanexiles

volumes:
    data:
        driver: local
```

#### Create a 'docker-compose.yml' with a volume mapping to host 

```yaml
version: '2'

services:
  conanexiles:
    image: alinmear/docker-conanexiles
    restart: always
    environment:
        - "CONANEXILES_ServerSettings_ServerSettings_AdminPassword=ThanksForThisSmartSolution"
        - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerName='My Cool Server'"
        - "CONANEXILES_Engine_OnlineSubSystemSteam_ServerPassword=MySecret"
    ports:
        - 7777:7777/udp
        - 7778:7778/udp
        - 27015:27015/udp
    volumes:
        - /my-data:/conanexiles
```

#### FirstTime Setup

##### Provide a Config     
If there is a folder with configurations found at `/tmp/docker-conanexiles` this folder will be copied to the config folder of the server. This will only happen if there is no configuration already existing (the case of a clean container initilizaton)

##### Default Templates   
Use the environment variable `CONANEXILES_SERVER_TYPE=pve` to set the pve template; everything other will be the pvp template if no configuration has been provided.
