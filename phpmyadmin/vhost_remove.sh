#!/bin/bash

usage() {
  echo "Uso: $0 -d <domínio>"
  echo
  echo "Remove configuração de proxy reverso no Nginx."
  echo
  echo "Parâmetros:"
  echo "  -d <domínio>"

  echo "Exemplo:"
  echo "  $0 -d exemplo.com"
  exit 1
}

DOMAIN=""

while getopts "d:p:l:" opt; do
  case "$opt" in
    d) DOMAIN="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  echo "Erro: todos os parâmetros são obrigatórios."
  usage
fi

NGINX_CONF_PATH="/etc/nginx/sites-available/$DOMAIN"

rm -rf /etc/nginx/sites-available/$DOMAIN
rm -rf /etc/nginx/sites-enabled/$DOMAIN

# Testa e recarrega o Nginx
echo "Testando configuração do Nginx..."
if nginx -t; then
  echo "Configuração OK. Recarregando Nginx..."
  systemctl reload nginx && echo "Nginx recarregado com sucesso."
else
  echo "Erro na configuração. Verifique o arquivo $NGINX_CONF_PATH"
  exit 1
fi

echo "✅ Proxy reverso removido com sucesso"