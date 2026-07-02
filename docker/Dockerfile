FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

############################################
# Enable i386
############################################

RUN dpkg --add-architecture i386

############################################
# Install dependencies
############################################

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
    steamcmd

############################################
# Create directories
############################################

RUN mkdir -p \
    /data \
    /config \
    /mods \
    /secrets \
    /logs \
    /server \
    /docker

############################################
# Copy startup scripts
############################################

COPY docker/entrypoint.sh /docker/entrypoint.sh
COPY docker/start-master.sh /docker/start-master.sh
COPY docker/start-caves.sh /docker/start-caves.sh

RUN chmod +x /docker/*.sh

############################################
# Working directory
############################################

WORKDIR /server

ENTRYPOINT ["/docker/entrypoint.sh"]