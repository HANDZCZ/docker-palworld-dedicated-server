#!/bin/bash

GAME_PATH="/palworld"

function installServer() {
    # force a fresh install of all
    echo ">>> Doing a fresh install of the gameserver"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
}

function updateServer() {
    # force an update and validation
    echo ">>> Doing an update of the gameserver"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
}

function startServer() {
    echo ">>> Starting the gameserver"
    cd $GAME_PATH

    echo "Checking for config"
    if [ ! -f ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini ]; then
        echo "No config found, copying default one"
        if [ ! -d ${GAME_PATH}/Pal/Saved/Config/LinuxServer ]; then
            mkdir -p ${GAME_PATH}/Pal/Saved/Config/LinuxServer
        fi
        # Copy default config
        cp ${GAME_PATH}/DefaultPalWorldSettings.ini ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi

    if [[ -n $PUBLIC_IP ]]; then
        echo "Setting public ip to $PUBLIC_IP"
        sed -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $PUBLIC_PORT ]]; then
        echo "Setting public port to $PUBLIC_PORT"
        sed -i "s/PublicPort=[^,]*/PublicPort=$PUBLIC_PORT/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $SERVER_NAME ]]; then
        echo "Setting server name to $SERVER_NAME"
        sed -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $SERVER_DESC ]]; then
        echo "Setting server description to $SERVER_DESC"
        sed -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESC\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $SERVER_PASSWORD ]]; then
        echo "Setting server password to $SERVER_PASSWORD"
        SERVER_PASSWORD=$SERVER_PASSWORD
        if [[ $SERVER_PASSWORD == "NONE" ]]; then
            SERVER_PASSWORD=""
        fi
        sed -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"${SERVER_PASSWORD}\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $ADMIN_PASSWORD ]]; then
        echo "Setting admin password to $ADMIN_PASSWORD"
        sed -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
    if [[ -n $MAX_PLAYERS ]]; then
        echo "Setting maximum player count to $MAX_PLAYERS"
        sed -i "s/ServerPlayerMaxNum=[^,]*/ServerPlayerMaxNum=$MAX_PLAYERS/" ${GAME_PATH}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi

    START_OPTIONS=""
    if [[ -n $COMMUNITY_SERVER ]] && [[ $COMMUNITY_SERVER == "true" ]]; then
        START_OPTIONS="$START_OPTIONS EpicApp=PalServer"
    fi
    if [[ -n $MULTITHREAD_ENABLED ]] && [[ $MULTITHREAD_ENABLED == "true" ]]; then
        START_OPTIONS="$START_OPTIONS -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"
    fi
    ./PalServer.sh "$START_OPTIONS"
}

function startMain() {
    # Check if server is installed, if not try again
    if [ ! -f "/palworld/PalServer.sh" ]; then
        installServer
    fi
    if [ $ALWAYS_UPDATE_ON_START == "true" ]; then
        updateServer
    fi
    startServer
}

startMain
