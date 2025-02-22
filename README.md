## Docker - Palworld Dedicated Server

[![Build Docker Image](https://github.com/jammsen/docker-palworld-dedicated-server/actions/workflows/docker-build-and-push.yml/badge.svg)](https://github.com/jammsen/docker-palworld-dedicated-server/actions/workflows/docker-build-and-push.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/jammsen/palworld-dedicated-server)
![Docker Stars](https://img.shields.io/docker/stars/jammsen/palworld-dedicated-server)
![Image Size](https://img.shields.io/docker/image-size/jammsen/palworld-dedicated-server/latest)

This includes a Palworld Dedicated Server based on Linux and Docker.

## Do you need support for this Docker Image

- What to do?
  - Feel free to create a NEW issue
    - It is okay to "reference" that you might have the same problem as the person in issue #number
  - Follow the instructions and answer the questions of people who are willing to help you
  - If your issue is done, close it
    - I will Inactivity-Close any issue thats not been active for a week
- What NOT to do?
  - Dont re-use issues / Necro!
    - You are most likely to chat/spam/harrass thoose participants who didnt agree to be part of your / a new problem and might be totally out of context!
  - If this happens, i reserve the rights to lock the issue or delete the comments, you have been warned!

## What you need to run this

- Basic understanding of Docker, Docker-Compose, Linux and Networking (Port-Forwarding/NAT)

## Getting started

1. Choose a Docker-Compose examples from below
2. Create `game` sub-directories on your Dockernode in your game-server-directory (Example: `/srv/palworld`) and give it with `chmod 777 game` full permissions or use `chown -R 1000:1000 game/`.
3. Setup Port-Forwarding or NAT for the ports in the Docker-Compose file
4. (Build the image if you need) Start via `docker-compose up -d` - See docker-compose.yml and next section for more infos
5. After first start, stop the server, setup your config at `game/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` and start it again

## Environment-Variables
| Variable               | Description                                                                                                                           | Default Value                                          | Allowed Value   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | --------------- |
| ALWAYS_UPDATE_ON_START | Updates the server on startup                                                                                                         | false                                                  | false/true      |
| MAX_PLAYERS            | Maximum amout of players                                                                                                              | 16                                                     | 1-32            |
| MULTITHREAD_ENABLED    | Sets options for "Improved multi-threaded CPU performance"                                                                            | true                                                   | false/true      |
| COMMUNITY_SERVER       | Sets the server to a "Community-Server". If true, the server will appear in the Community-Serverlist. Needs PUBLIC_IP and PUBLIC_PORT | false                                                  | false/true      |
| RCON_ENABLED           | RCON function - use ADMIN_PASSWORD to login after enabling it - Will be listening on port 25575 inside the container                  | true                                                   | false/true      |
| PUBLIC_IP              | Public ip, auto-detect if not specified, see COMMUNITY_SERVER                                                                         | 10.0.0.1                                               | ip address      |
| PUBLIC_PORT            | Public port, auto-detect if not specified, see COMMUNITY_SERVER                                                                       | 8211                                                   | 1024-65535      |
| SERVER_NAME            | Name of the server                                                                                                                    | Default server name                                    | string          |
| SERVER_DESCRIPTION     | Description of the server                                                                                                             | Default server description                             | string          |
| SERVER_PASSWORD        | Password of the server                                                                                                                |                                                        | string          |
| ADMIN_PASSWORD         | Admin password of the server                                                                                                          | admin                                                  | string          |
| BACKUP_ENABLED         | Backup function, creates backups in your `game` directory                                                                             | true                                                   | false/true      |
| BACKUP_CRON_EXPRESSION | Needs a Cron-Expression - See https://github.com/aptible/supercronic#crontab-format or https://crontab-generator.org/                 | 0 * * * * (meaning every hour)                         | Cron-Expression |

Look at https://tech.palworldgame.com/optimize-game-balance for more information and config-settings in `game/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`

## Docker-Compose examples

### Standalone gameserver
```yml
version: '3.9'
services:
  palworld-dedicated-server:
    build: .
    container_name: palworld-dedicated-server
    #image: jammsen/palworld-dedicated-server:latest
    restart: unless-stopped
    network_mode: bridge
    ports:
      - "8211:8211/udp"
      - "25575:25575/tcp"
    environment:
      - ALWAYS_UPDATE_ON_START=false
      - MAX_PLAYERS=16
      - MULTITHREAD_ENABLED=true
      - COMMUNITY_SERVER=false
      - RCON_ENABLED=true
      - RCON_PORT=25575
      - PUBLIC_IP=10.0.0.5
      - PUBLIC_PORT=8211
      - SERVER_NAME=Server name
      - SERVER_DESCRIPTION=Server description
      #- SERVER_PASSWORD=
      - ADMIN_PASSWORD=admin
      - BACKUP_ENABLED=true
      - BACKUP_CRON_EXPRESSION=0 * * * *
    volumes:
      - ./game:/palworld
```
### Gameserver with RCON
```yml
version: '3.9'
services:
  palworld-dedicated-server:
    build: .
    container_name: palworld-dedicated-server
    #image: jammsen/palworld-dedicated-server:latest
    restart: unless-stopped
    network_mode: bridge
    ports:
      - "8211:8211/udp"
      - "25575:25575/tcp"
    environment:
      - ALWAYS_UPDATE_ON_START=false
      - MAX_PLAYERS=16
      - MULTITHREAD_ENABLED=true
      - COMMUNITY_SERVER=false
      - RCON_ENABLED=true
      - RCON_PORT=25575
      - PUBLIC_IP=10.0.0.5
      - PUBLIC_PORT=8211
      - SERVER_NAME=Server name
      - SERVER_DESCRIPTION=Server description
      #- SERVER_PASSWORD=
      - ADMIN_PASSWORD=admin
      - BACKUP_ENABLED=true
      - BACKUP_CRON_EXPRESSION=0 * * * *
    volumes:
      - ./game:/palworld
  
  rcon:
    image: outdead/rcon:latest
    entrypoint: ['/rcon', '-a', '10.0.0.5:25575', '-p', 'adminPasswordHere']
    profiles: ['rcon'] 
```
The profiles defintion, prevents the container from starting with the server and in your console you can run now RCON commands via
#### RCON
In your shell you can now run commands against the gameserver via RCON
```shell
$ docker compose run --rm rcon ShowPlayers
name,playeruid,steamid
$ docker compose run --rm rcon info
Welcome to Pal Server[v0.1.2.0] jammsen-docker-generated-20384
$ docker compose run --rm rcon save
Complete Save
```
**Imporant:**
- Keep the `--rm` in the command line, or you will have many exited containers in your list. 
- All RCON-Commands can be research here: https://tech.palworldgame.com/server-commands

## FAQ

### How can i look into the config of my Palworld container?
You can run this `docker exec -ti palworld-dedicated-server cat /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` and it will show you the config inside the container.

### Im seeing S_API errors in my logs when i start the container
Errors like `[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.` are safe to ignore.

## Planned features in the future

- Feel free to suggest something

## Software used

- CM2Network SteamCMD (Officially recommended by Valve - https://developer.valvesoftware.com/wiki/SteamCMD#Docker) 
- Palworld Dedicated Server (APP-ID: 2394010 - https://steamdb.info/app/2394010/config/)
