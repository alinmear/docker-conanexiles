#!/bin/bash

get_steamcmd_wine() {
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -O /tmp/steamcmd.zip
    unzip /tmp/steamcmd.zip -d /steamcmd
}

get_steamcmd_linux() {
    wget -qO- http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx
}

[ ! -d /steamcmd ] && mkdir -p /steamcmd
[ ! -f /steamcmd/steamcmd.sh ] && get_steamcmd_linux
