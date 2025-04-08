#!/bin/bash

# Abort on any error
set -e

# Definir diretório de instalação
INSTALL_DIR="/usr/share"
PMA_VERSION="5.2.2"
PMA_ZIP="phpMyAdmin-${PMA_VERSION}-all-languages.zip"
PMA_URL="https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/${PMA_ZIP}"
PMA_DIR="${INSTALL_DIR}/phpmyadmin"

# Gerar chave aleatória para blowfish_secret (32 caracteres)
BLOWFISH_SECRET=$(openssl rand -base64 32)

# Ir para o diretório de instalação
cd "$INSTALL_DIR"

# Baixar o phpMyAdmin
echo "Baixando phpMyAdmin ${PMA_VERSION}..."
wget -q --show-progress -O "$PMA_ZIP" "$PMA_URL"

# Extrair o conteúdo
echo "Extraindo arquivos..."
unzip -q "$PMA_ZIP"

# Remover o ZIP
rm -f "$PMA_ZIP"

# Renomear a pasta
mv "phpMyAdmin-${PMA_VERSION}-all-languages" "$PMA_DIR"

# Criar diretório temporário
cd "$PMA_DIR"
mkdir -p tmp
chmod 750 tmp
chown www-data:www-data tmp

# Criar o config.inc.php com o conteúdo personalizado
cat <<EOF > config.inc.php
<?php

declare(strict_types=1);

\$cfg['blowfish_secret'] = '${BLOWFISH_SECRET}';

\$i = 0;

\$i++;

\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['compress'] = false;
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;

\$cfg['UploadDir'] = '';
\$cfg['SaveDir'] = '';
EOF

# Mensagem final
echo "phpMyAdmin ${PMA_VERSION} instalado com sucesso em ${PMA_DIR}"
echo "Arquivo config.inc.php criado com sucesso com chave blowfish segura."
