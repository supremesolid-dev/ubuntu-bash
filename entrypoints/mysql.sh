#!/bin/bash

set -e

echo "[INFO] Iniciando container..."

# Verifica se /etc/mysql está vazio
if [ -z "$(ls -A /etc/mysql 2>/dev/null)" ]; then
    echo "[INFO] /etc/mysql está vazio, restaurando a configuração padrão..."
    cp -r /opt/mysql-default/etc/* /etc/mysql/
else
    echo "[INFO] /etc/mysql já possui arquivos, mantendo configuração atual."
fi

# Verifica se /var/lib/mysql está vazio
if [ -z "$(ls -A /var/lib/mysql 2>/dev/null)" ]; then
    echo "[INFO] /var/lib/mysql está vazio, restaurando dados padrão..."
    cp -r /opt/mysql-default/lib/* /var/lib/mysql/
else
    echo "[INFO] /var/lib/mysql já possui arquivos, mantendo dados existentes."
fi

# Corrige permissões (importante caso o volume seja novo)
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /etc/mysql

# Garante que o socket e diretórios existem
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

echo "[INFO] Iniciando MySQL..."

exec mysqld
