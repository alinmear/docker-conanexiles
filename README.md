# docker-conanexiles

![Docker Pulls](https://img.shields.io/docker/pulls/alinmear/docker-conanexiles.svg?style=flat)

Features:
* Full automatic provisioning of steam and conanexiles dedicated server
* Autoupdate and restart of the conanexiles server (Now working, thx for contribution @kijdam) 
* Full control of every config aspect via Environment variables
* Templates for first time setup

**Note**: *Starting the server via wine needs several minutes (Wine 2.2, 2017-02-28). So be patient till the messages from stdout state "Server started".*

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

## Usage

#### Get latest image
`docker pull alinmear/docker-conanexiles:latest`

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
