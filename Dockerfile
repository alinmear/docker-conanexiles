FROM ubuntu:xenial

MAINTAINER Paul Steinlechner

ENV TIMEZONE=Europe/Vienna DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y software-properties-common python-software-properties wget unzip xvfb supervisor crudini && \
    add-apt-repository ppa:wine/wine-builds && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes winehq-staging && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /etc/supervisor/conf.d
    
RUN ln -snf /usr/share/zoneinfo/Europe/Vienna /etc/localtime && echo $TIMEZONE > /etc/timezone

ADD files/entrypoint.sh /entrypoint.sh
ADD files/steamcmd_setup.sh /usr/bin/steamcmd_setup
ADD files/install.txt /install.txt
ADD files/conanexiles_controller.sh /usr/bin/conanexiles_controller

ADD files/supervisord.conf /etc/supervisor/supervisord.conf
ADD files/conanexiles.conf /etc/supervisor/conf.d/conanexiles.conf

RUN chmod +x /usr/bin/steamcmd_setup /usr/bin/conanexiles_controller /entrypoint.sh

EXPOSE 7777/udp 27015/udp 27016/udp 37015/udp 37016/udp  

VOLUME ["/conanexiles"]

ENTRYPOINT ["/entrypoint.sh"]
cmd ["/usr/bin/supervisord"]
