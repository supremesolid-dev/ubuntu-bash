#!/bin/bash

usage() {
  echo "Uso: $0 [-v \"5.6 7.4 8.2\"] [-m] [-p]"
  echo ""
  echo "  -v \"VERSÕES\"     : Espaço separado com versões desejadas (ex: \"7.4 8.1 8.2\")"
  echo "  -m               : Instala módulos comuns para todas as versões"
  echo "  -p               : Instala o módulo PAM (autenticação via PECL)"
  echo "  -h               : Exibe esta ajuda"
  exit 1
}

# Variáveis padrão
PHP_VERSOES=""
INSTALAR_MODULOS=false
INSTALAR_PAM=false

# Lê os parâmetros
while getopts ":v:mph" opt; do
  case ${opt} in
    v) PHP_VERSOES="$OPTARG" ;;
    m) INSTALAR_MODULOS=true ;;
    p) INSTALAR_PAM=true ;;
    h) usage ;;
    \?) echo "Opção inválida: -$OPTARG" >&2; usage ;;
    :) echo "A opção -$OPTARG requer um argumento." >&2; usage ;;
  esac
done

if [ -z "$PHP_VERSOES" ]; then
  echo "Erro: Você deve informar pelo menos uma versão com -v"
  usage
fi

# Adiciona repositório PPA se necessário
echo "Adicionando repositório do PHP (ppa:ondrej/php)..."
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Instala dependências básicas
sudo apt install -y zip curl software-properties-common

# Instala php-pear e dev libs se for instalar PAM
if $INSTALAR_PAM; then
  echo "Instalando dependências para PECL PAM..."
  sudo apt install -y libpam0g-dev php-pear
fi

# Instala cada versão
for V in $PHP_VERSOES; do
  echo "Instalando PHP $V..."
  sudo apt install -y php$V php$V-fpm php$V-dev

  if $INSTALAR_MODULOS; then
    echo "Instalando módulos para PHP $V..."
    sudo apt install -y php$V-{cli,common,bcmath,imap,redis,snmp,zip,curl,bz2,intl,gd,mbstring,mysql,xml,sqlite3,pgsql}
  fi
done

# Instala módulo PAM via PECL
if $INSTALAR_PAM; then
  echo "Instalando módulo PAM via PECL..."
  sudo pecl install pam || { echo "Erro ao instalar PECL PAM" >&2; exit 1; }
fi

