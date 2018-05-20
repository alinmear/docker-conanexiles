FROM ubuntu:xenial

MAINTAINER Paul Steinlechner

ENV TIMEZONE=Europe/Vienna DEBIAN_FRONTEND=noninteractive MASTER_SERVER_INSTANCE=1

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y software-properties-common python-software-properties wget unzip xvfb supervisor crudini && \
    add-apt-repository ppa:wine/wine-builds && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes winehq-staging && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /etc/supervisor/conf.d

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

RUN chmod +x /usr/bin/steamcmd_setup /usr/bin/conanexiles_controller /entrypoint.sh /usr/bin/redi.sh

EXPOSE 7777/udp 27015/udp 27016/udp 37015/udp 37016/udp

VOLUME ["/conanexiles"]

ENTRYPOINT ["/entrypoint.sh"]
cmd ["/usr/bin/supervisord"]
