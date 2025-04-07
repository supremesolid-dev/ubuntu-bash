FROM ubuntu:24.04

WORKDIR /bash

ENV NODE_ENV=production
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8
ENV TZ=America/Sao_Paulo

RUN apt update && apt upgrade -y \
    && apt install -y tzdata apt-transport-https sudo software-properties-common curl wget gnupg ca-certificates locales \
    && locale-gen pt_BR.UTF-8 \
    && update-locale LANG=pt_BR.UTF-8 \
    && curl -s https://supremesolid-dev.github.io/ubuntu-bash/mysql/install.sh | bash \
    && service mysql stop || true \
    && mkdir -p /opt/mysql-default/etc /opt/mysql-default/lib \
    && cp -r /etc/mysql/* /opt/mysql-default/etc/ \
    && cp -r /var/lib/mysql/* /opt/mysql-default/lib/ \
    && apt clean && rm -rf /var/lib/apt/lists/*
