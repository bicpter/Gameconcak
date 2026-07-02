FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    curl \
    wget \
    unzip \
    tar \
    git \
    ca-certificates \
    lib32gcc-s1 \
    libstdc++6:i386 \
    libgcc-s1:i386 \
    libcurl4:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /data \
    /config \
    /mods \
    /secrets \
    /logs \
    /server \
    /docker \
    /steamcmd

WORKDIR /steamcmd

RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz

RUN printf '#!/bin/sh\ncd /steamcmd\nexec ./steamcmd.sh "$@"\n' > /usr/local/bin/steamcmd \
    && chmod +x /usr/local/bin/steamcmd

COPY docker/entrypoint.sh /docker/entrypoint.sh
COPY docker/start-master.sh /docker/start-master.sh
COPY docker/start-caves.sh /docker/start-caves.sh

RUN chmod +x /docker/*.sh

WORKDIR /server

ENTRYPOINT ["/docker/entrypoint.sh"]