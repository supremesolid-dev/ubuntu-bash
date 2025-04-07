#!/bin/bash
set -e

# Verifica se o caminho do executável foi passado como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 /home/mtasa/mta-server64"
    exit 1
fi

# Caminho do executável passado como argumento
EXECUTAVEL="$1"

# Comando completo com opções fixas
CMD="$EXECUTAVEL -n --child-process"

# Se for root, troca para o usuário mtasa
if [ "$(id -u)" -eq 0 ]; then
    exec su -s /bin/bash mtasa -c "$CMD"
else
    # Se já for o usuário mtasa, executa diretamente
    exec $CMD
fi
