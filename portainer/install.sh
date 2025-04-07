#!/bin/bash

# Desabilita SELinux (ignora erros se setenforce não estiver disponível)
setenforce 0 >> /dev/null 2>&1

# Evita prompts interativos
export DEBIAN_FRONTEND=noninteractive

# Define o IP passado como argumento ou usa 127.0.0.1 como padrão
IP_ADDRESS="${1:-127.0.0.1}"

# Cria volume do Portainer
docker volume create portainer_data

# Executa o container do Portainer usando o IP configurável
docker run -d \
  -p ${IP_ADDRESS}:8000:8000 \
  -p ${IP_ADDRESS}:9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
