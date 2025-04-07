# Imagem base recomendada

FROM ubuntu:24.04

WORKDIR /home

ENV NODE_ENV=production

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8
ENV TZ=America/Sao_Paulo

# Atualiza sistema e instala pacotes necessários
RUN apt update && apt upgrade -y && \
    apt install -y tzdata language-pack-gnome-pt language-pack-gnome-pt-base \
    sudo software-properties-common libssl-dev libreadline-dev zlib1g-dev \
    libbz2-dev libsqlite3-dev libffi-dev liblzma-dev uuid-dev libxml2-dev \
    libxmlsec1-dev build-essential curl wget apt-transport-https \
    ca-certificates gnupg lsb-release dnsutils locales && \
    locale-gen pt_BR.UTF-8 && \
    update-locale LANG=pt_BR.UTF-8 && \
    bash <(curl -s https://supremesolid-dev.github.io/ubuntu-bash/mysql/install.sh) -b 0.0.0.0 -x 0.0.0.0 -o && \
    wget https://supremesolid-dev.github.io/ubuntu-bash/entrypoints/mysql.sh -d /opt/

ENTRYPOINT [ "opt/mysql.sh" ]