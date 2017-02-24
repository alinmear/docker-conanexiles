# docker-conanexiles

## Usage

#### Get latest image
     docker pull alinmear/docker-conanexiles:latest

#### Craete a `docker-compose.yml`

```yaml
version: '2'

services:
  conanexiles:
    image: alinmear/docker-conanexiles
    restart: always
    ports:
        - 7777:7777/udp
        - 27015:27015/udp
    volumes:
        - data:/conanexiles

volumes:
    data:
        driver: local
```

```yaml
version: '2'

services:
  conanexiles:
    image: alinmear/docker-conanexiles
    restart: always
    ports:
        - 7777:7777/udp
        - 27015:27015/udp
    volumes:
        - /my-data:/conanexiles
```

#### Configuration
At this stage you have to run the container and wait, till the initialisation process is finished (steam download of the application data).

NOTE: BE AWARE to create a persistent data volume for `/conanexiles`; without a volume, the whole data folder will be lost after container recreation, and with it all configs and dbs.

After the gameserver is started, stop it and copy your actual config to the folder `/my-data/conanexiles/ConanSandbox/Saved`.

#### Work in Progress
When i have more time i will create a logic to set container initialisation state via env variables or a provided config directory. 