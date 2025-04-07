#!/bin/bash

usage() {
  echo "Uso: $0 -d <domínio> -p <proxy_pass> -l <listen>"
  echo
  echo "Cria uma configuração de proxy reverso no Nginx."
  echo
  echo "Parâmetros:"
  echo "  -d <domínio>       Domínio a ser configurado (ex: exemplo.com)"
  echo "  -p <proxy_pass>    URL do backend (deve começar com http:// ou https://)"
  echo "  -l <listen>        IP e porta para o Nginx escutar (ex: 80 ou 127.0.0.1:80)"
  echo
  echo "Exemplo:"
  echo "  $0 -d exemplo.com -p http://localhost:3000 -l 80"
  exit 1
}

# Inicializa variáveis
DOMAIN=""
PROXY_PASS=""
LISTEN=""

# Parse dos parâmetros
while getopts "d:p:l:" opt; do
  case "$opt" in
    d) DOMAIN="$OPTARG" ;;
    p) PROXY_PASS="$OPTARG" ;;
    l) LISTEN="$OPTARG" ;;
    *) usage ;;
  esac
done

# Valida os parâmetros
if [ -z "$DOMAIN" ] || [ -z "$PROXY_PASS" ] || [ -z "$LISTEN" ]; then
  echo "Erro: todos os parâmetros são obrigatórios."
  usage
fi

if [[ ! "$PROXY_PASS" =~ ^https?:// ]]; then
  echo "Erro: proxy_pass inválido. Deve começar com http:// ou https://"
  usage
fi

NGINX_CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK_PATH="/etc/nginx/sites-enabled/$DOMAIN"

# Cria o arquivo de configuração Nginx
echo "Criando configuração para $DOMAIN escutando em $LISTEN e apontando para $PROXY_PASS..."

cat <<EOF > "$NGINX_CONF_PATH"
server {
    listen $LISTEN;
    server_name $DOMAIN;

    location / {
        proxy_pass $PROXY_PASS;
        proxy_ssl_verify off;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Cria o link simbólico se necessário
if [ ! -f "$NGINX_LINK_PATH" ]; then
  ln -s "$NGINX_CONF_PATH" "$NGINX_LINK_PATH"
  echo "Link simbólico criado em $NGINX_LINK_PATH"
fi

# Testa e recarrega o Nginx
echo "Testando configuração do Nginx..."
if nginx -t; then
  echo "Configuração OK. Recarregando Nginx..."
  systemctl reload nginx && echo "Nginx recarregado com sucesso."
else
  echo "Erro na configuração. Verifique o arquivo $NGINX_CONF_PATH"
  exit 1
fi

echo "✅ Proxy reverso criado:"
echo "    Domínio      : $DOMAIN"
echo "    Escutando em : $LISTEN"
echo "    Proxy para   : $PROXY_PASS"
