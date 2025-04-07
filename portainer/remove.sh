#!/bin/bash

# Desabilita SELinux (ignora erros se setenforce não estiver disponível)
setenforce 0 >> /dev/null 2>&1

# Evita prompts interativos
export DEBIAN_FRONTEND=noninteractive

docker rm -f portainer
docker volume rm portainer_data