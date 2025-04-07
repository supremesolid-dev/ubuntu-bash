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

BIND_IP="0.0.0.0"
MYSQLX_BIND_IP="0.0.0.0"
MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"

echo "Atualizando bind-address para $BIND_IP..."
sudo sed -i "s/^bind-address.*/bind-address = ${BIND_IP}/" "$MYSQL_CONF"

echo "Atualizando mysqlx-bind-address para $MYSQLX_BIND_IP..."
sudo sed -i "s/^mysqlx-bind-address.*/mysqlx-bind-address = ${MYSQLX_BIND_IP}/" "$MYSQL_CONF"

echo "Iniciar o serviço MySQL..."
sudo service mysql start
