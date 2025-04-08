#!/bin/bash

usage() {
  echo "Uso: $0 -d <domínio> -l <listen>"
  echo
  echo "Cria uma configuração de proxy reverso no Nginx."
  echo
  echo "Parâmetros:"
  echo "  -d <domínio>       Domínio a ser configurado (ex: exemplo.com)"
  echo "  -l <listen>        IP e porta para o Nginx escutar (ex: 80 ou 127.0.0.1:80)"
  echo
  echo "Exemplo:"
  echo "  $0 -d exemplo.com -l 80"
  exit 1
}

DOMAIN=""
LISTEN=""

# Parse dos parâmetros
while getopts "d:l:" opt; do
  case "$opt" in
    d) DOMAIN="$OPTARG" ;;
    l) LISTEN="$OPTARG" ;;
    *) usage ;;
  esac
done

# Valida os parâmetros
if [ -z "$DOMAIN" ] || [ -z "$LISTEN" ]; then
  echo "Erro: todos os parâmetros são obrigatórios."
  usage
fi

NGINX_CONF_PATH="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK_PATH="/etc/nginx/sites-enabled/$DOMAIN"

# Cria o arquivo de configuração Nginx
echo "Criando configuração para $DOMAIN escutando em $LISTEN"

cat <<EOF > "$NGINX_CONF_PATH"
server {
    listen $LISTEN;
    server_name $DOMAIN;

    root /usr/share/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|ttf|woff|woff2|eot)$ {
        expires max;
        log_not_found off;
    }

    location ~ /\.ht {
        deny all;
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
