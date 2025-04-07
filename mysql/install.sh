#!/bin/bash

usage() {
  echo "Uso: $0 [-b BIND_IP] [-x MYSQLX_BIND_IP] [-o]"
  echo ""
  echo "  -b BIND_IP         : IP para bind-address no mysqld.cnf (padrão: 127.0.0.1)"
  echo "  -x MYSQLX_BIND_IP  : IP para mysqlx-bind-address (padrão: 127.0.0.1)"
  echo "  -o                 : Ativa configurações otimizadas adicionais para performance"
  exit 1
}

# Variáveis padrão
BIND_IP="127.0.0.1"
MYSQLX_BIND_IP="127.0.0.1"
OPTIMIZE=false

# Processa parâmetros
while getopts ":b:x:o" opt; do
  case ${opt} in
    b) BIND_IP="$OPTARG" ;;
    x) MYSQLX_BIND_IP="$OPTARG" ;;
    o) OPTIMIZE=true ;;
    \?) echo "Opção inválida: -$OPTARG" >&2; usage ;;
    :) echo "A opção -$OPTARG requer um argumento." >&2; usage ;;
  esac
done

# Atualiza e instala o MySQL
echo "Atualizando pacotes..."
sudo apt update && sudo apt install -y mysql-server

# Verifica sucesso
if ! command -v mysql &> /dev/null; then
  echo "Erro: MySQL não foi instalado corretamente." >&2
  exit 1
fi

echo "MySQL instalado com sucesso."

# Caminho do arquivo de configuração
MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"

# Faz backup do original
echo "Criando backup do mysqld.cnf..."
sudo cp "$MYSQL_CONF" "${MYSQL_CONF}.bak"

# Atualiza bind-address e mysqlx-bind-address
echo "Atualizando bind-address para $BIND_IP..."
sudo sed -i "s/^bind-address.*/bind-address = ${BIND_IP}/" "$MYSQL_CONF"

echo "Atualizando mysqlx-bind-address para $MYSQLX_BIND_IP..."
sudo sed -i "s/^mysqlx-bind-address.*/mysqlx-bind-address = ${MYSQLX_BIND_IP}/" "$MYSQL_CONF"

# Aplica otimizações, se ativado
if $OPTIMIZE; then
  echo "Aplicando configurações otimizadas..."

  sudo sed -i "/^\[mysqld\]/a \\
max_connections = 300\\
innodb_buffer_pool_size = 512M\\
innodb_log_file_size = 128M\\
query_cache_type = 0\\
query_cache_size = 0\\
skip-name-resolve\\
" "$MYSQL_CONF"
fi

# Reinicia o serviço
echo "Reiniciando o serviço MySQL..."
sudo systemctl restart mysql

# Verifica status
if systemctl is-active --quiet mysql; then
  echo "MySQL configurado e rodando!"
else
  echo "Erro ao iniciar o MySQL. Verifique as configurações." >&2
  exit 1
fi
