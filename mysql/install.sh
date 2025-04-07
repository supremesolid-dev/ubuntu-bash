#!/bin/bash

echo "Atualizando pacotes..."

apt update && apt upgrade -y

bash <(curl -s https://supremesolid-dev.github.io/ubuntu-bash/system/install_utils.sh)

echo "Instalando o MySQL Server..."

apt install -y mysql-server

# Verifica sucesso
if ! command -v mysql &> /dev/null; then
  echo "Erro: MySQL não foi instalado corretamente." >&2
  exit 1
fi

echo "MySQL instalado com sucesso."

echo "Garantindo que o diretório de socket exista..."
sudo mkdir -p /var/run/mysqld
sudo chown mysql:mysql /var/run/mysqld

# Reinicia o serviço
echo "Iniciar o serviço MySQL..."
sudo service mysql start
