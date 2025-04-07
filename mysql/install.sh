#!/bin/bash

echo "Atualizando pacotes..."
sudo apt update && sudo apt install -y mysql-server

# Verifica sucesso
if ! command -v mysql &> /dev/null; then
  echo "Erro: MySQL não foi instalado corretamente." >&2
  exit 1
fi

echo "MySQL instalado com sucesso."

# Reinicia o serviço
echo "Reiniciando o serviço MySQL..."
sudo service mysql restart
