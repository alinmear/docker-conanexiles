FROM ubuntu:xenial

MAINTAINER Paul Steinlechner

ENV TIMEZONE=Europe/Vienna DEBIAN_FRONTEND=noninteractive \
CONANEXILES_MASTERSERVER=1 \
CONANEXILES_Game_RconPlugin_RconEnabled=1 \
CONANEXILES_Game_RconPlugin_RconPassword=Password \
CONANEXILES_Game_RconPlugin_RconPort=25575 \
CONANEXILES_Game_RconPlugin_RconMaxKarma=60


RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y software-properties-common python-software-properties wget unzip xvfb supervisor crudini python3-pip lib32z1 && \
    add-apt-repository ppa:wine/wine-builds && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes winehq-staging && \
    pip3 install python-valve && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /etc/supervisor/conf.d

RUN wget https://kent.dl.sourceforge.net/project/mcrcon/0.0.5/mcrcon-0.0.5-bin-linux.zip && \
    unzip mcrcon-0.0.5-bin-linux.zip && \
    rm mcrcon-0.0.5-bin-linux.zip && \
    chmod +x mcrcon && \
    mv mcrcon /usr/bin/mcrcon

RUN wget https://github.com/krisberg/conan-exiles-discord-chatbot/releases/download/0.2.1/conan-exiles-discord-chatbot.zip && \
    unzip conan-exiles-discord-chatbot.zip && \
    rm conan-exiles-discord-chatbot.zip && \
    chmod +x conan-exiles-discord-chatbot && \
    mv conan-exiles-discord-chatbot /usr/bin/conan-exiles-discord-chatbot

RUN ln -snf /usr/share/zoneinfo/Europe/Vienna /etc/localtime && echo $TIMEZONE > /etc/timezone

ADD conanexiles/scripts/entrypoint.sh /entrypoint.sh
ADD conanexiles/installer/steamcmd_setup.sh /usr/bin/steamcmd_setup
ADD conanexiles/installer/install.txt /install.txt
ADD conanexiles/scripts/conanexiles_controller.sh /usr/bin/conanexiles_controller

ADD conanexiles/configs/supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ADD conanexiles/configs/supervisord/conanexiles.conf /etc/supervisor/conf.d/conanexiles.conf

ADD conanexiles/helpers/redi.sh/redi.sh /usr/bin/redi.sh

RUN mkdir -p /var/lib/conanexiles
ADD conanexiles/lib/redis_cmds.sh /var/lib/conanexiles/redis_cmds.sh
ADD conanexiles/lib/notifier.sh /var/lib/conanexiles/notifier.sh

ADD conanexiles/rcon/rconcli.py /usr/bin/rconcli

RUN chmod +x /usr/bin/steamcmd_setup /usr/bin/conanexiles_controller /entrypoint.sh /usr/bin/redi.sh /usr/bin/rconcli

EXPOSE 7777/udp 27015/udp 27016/udp 37015/udp 37016/udp

VOLUME ["/conanexiles"]

ENTRYPOINT ["/entrypoint.sh"]
cmd ["/usr/bin/supervisord"]
