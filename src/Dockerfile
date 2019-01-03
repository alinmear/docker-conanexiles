FROM ubuntu:18.04

LABEL maintainer="Paul Steinlechner"

ENV TIMEZONE=Europe/Vienna \
    DEBIAN_FRONTEND=noninteractive \
    CONANEXILES_MASTERSERVER=1 \
    CONANEXILES_Game_RconPlugin_RconEnabled=1 \
    CONANEXILES_Game_RconPlugin_RconPassword=Password \
    CONANEXILES_Game_RconPlugin_RconPort=25575 \
    CONANEXILES_Game_RconPlugin_RconMaxKarma=60

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y crudini python3-pip redis-tools software-properties-common supervisor unzip wget xvfb \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/' \
    && apt-get update \
    && apt-get install --no-install-recommends --assume-yes winehq-staging \
    && pip3 install python-valve \
    && apt-get clean \
    && rm -rf winehq.key /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . ./

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /entrypoint.sh \
    && cd /usr/bin/ \
    && chmod +x conanexiles_controller rconcli steamcmd_setup
    
EXPOSE 7777/udp 27015/udp 27016/udp 37015/udp 37016/udp

VOLUME ["/conanexiles"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]
