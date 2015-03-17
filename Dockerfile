FROM debian:jessie

MAINTAINER Laurent Arnoud <laurent@spkdev.net>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

RUN groupadd -r tarantool && useradd -r -g tarantool tarantool

RUN apt-get update && apt-get -y upgrade && rm -rf /var/lib/apt/lists/*

ENV TARANTOOL_VERSION 1.6.4-472-g53b61a8
ENV TARANTOOL_SHA1 a62f528e408ea681635338cfd2c24b5dafa89eb7

RUN buildDeps='curl devscripts equivs git build-essential cmake libreadline-dev libncurses5-dev binutils-dev libiberty-dev libbfd-dev uuid-dev cdbs libmysqlclient-dev libpq-dev'; \
    set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -SL "http://tarantool.org/dist/master/tarantool-$TARANTOOL_VERSION-src.tar.gz" -o tarantool.tar.gz \
    && echo "$TARANTOOL_SHA1 tarantool.tar.gz" | sha1sum -c - \
    && mkdir -p /usr/src/tarantool \
    && tar -xzf tarantool.tar.gz -C /usr/src/tarantool --strip-components=1 \
    && rm tarantool.tar.gz \
    && cd /usr/src/tarantool \
    && dpkg-buildpackage -b \
    && debi tarantool \
    && cd / && rm -rf /usr/src/tarantool \
    && apt-get purge -y $buildDeps make gcc g++ cpp \
    && apt-get autoremove -y \
    && rm -rf /usr/share/dh-python/dhpython/build "/usr/src/*.{deb,changes}"

COPY tarantool.lua /etc/tarantool.lua
RUN mkdir /data && chown tarantool:tarantool /data
VOLUME /data
WORKDIR /data

USER tarantool

EXPOSE 3301
CMD ["/usr/bin/tarantool", "/etc/tarantool.lua"]
