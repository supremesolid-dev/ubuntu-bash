#!/bin/bash
set -e

# Inicia o serviço MySQL em background
start_mysql() {
  echo "Iniciando o MySQL..."
  mysqld_safe --skip-syslog &
  MYSQL_PID=$!

  # Espera o MySQL subir
  echo "Aguardando o MySQL ficar pronto..."
  until mysqladmin ping --silent; do
    sleep 1
  done
}

# Mantém o processo vivo
tail_logs() {
  wait $MYSQL_PID
}

start_mysql
tail_logs
