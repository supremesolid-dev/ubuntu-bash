#!/bin/bash

clear

setenforce 0 >> /dev/null 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
    language-pack-gnome-pt language-pack-gnome-pt-base language-pack-pt language-pack-pt-base \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    uuid-dev \
    libxml2-dev \
    libxmlsec1-dev \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    zip \
    cgroup-tools \
    tar \
    ubuntu-standard \
    dnsutils

timedatectl set-timezone America/Sao_Paulo