#!/bin/bash

echo "Atualizando pacotes..."

apt update -y

apt install -y mysql-server

if ! command -v mysql &> /dev/null; then
  echo "Erro: MySQL não foi instalado corretamente." >&2
  exit 1
fi

echo "MySQL instalado com sucesso."

echo "Garantindo que o diretório de socket exista..."
sudo mkdir -p /var/run/mysqld
sudo chown mysql:mysql /var/run/mysqld

mkdir /nonexistent
chown mysql:mysql /nonexistent

echo "Iniciar o serviço MySQL..."
sudo service mysql start
