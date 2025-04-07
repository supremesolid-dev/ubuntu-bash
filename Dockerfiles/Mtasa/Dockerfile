# Imagem base recomendada
FROM ubuntu:24.04

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
    update-locale LANG=pt_BR.UTF-8

# Remove usuário ubuntu se existir (ignora erro se não existir)
RUN deluser --remove-home ubuntu || true

# Cria usuário do sistema mtasa
RUN adduser \
    --system \
    --shell /bin/bash \
    --gecos 'Multi Theft Auto' \
    --group \
    --disabled-password \
    --home /home/mtasa \
    mtasa && \
    usermod -u 1500 mtasa && \
    groupmod -g 1500 mtasa

# Cria diretório do servidor (você pode copiar seus arquivos depois)
RUN chown -R mtasa:mtasa /home/mtasa

# Mantém container aberto em modo interativo (se desejar usar docker run -it)
CMD []
