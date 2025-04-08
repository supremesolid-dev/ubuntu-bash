#!/bin/bash

CONFIG_FILE="/usr/share/phpmyadmin/config.inc.php"

usage() {
  echo "Uso: $0 -h <host> [-P <port>] [-n <nome>]"
  echo
  echo "Adiciona um novo servidor MySQL ao config.inc.php do phpMyAdmin."
  echo
  echo "Parâmetros:"
  echo "  -h <host>      Endereço do servidor (obrigatório)"
  echo "  -P <port>      Porta do servidor (opcional, padrão: 3306)"
  echo "  -n <nome>      Nome amigável (opcional)"
  echo
  exit 1
}

# Valores padrão
HOST=""
PORT="3306"
NOME=""

# Parse dos parâmetros
while getopts "h:P:n:" opt; do
  case "$opt" in
    h) HOST="$OPTARG" ;;
    P) PORT="$OPTARG" ;;
    n) NOME="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validação
if [ -z "$HOST" ]; then
  echo "Erro: host é obrigatório."
  usage
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Erro: Arquivo $CONFIG_FILE não encontrado."
  exit 1
fi

# Descobre o próximo índice $i
LAST_I=$(grep "\$i++;" "$CONFIG_FILE" | wc -l)
NEXT_I=$((LAST_I + 1))

# Checa duplicidade
if grep -q "$HOST" "$CONFIG_FILE"; then
  echo "Aviso: o host '$HOST' já está configurado em $CONFIG_FILE."
  read -p "Deseja continuar e adicionar mesmo assim? (s/n): " CONT
  [[ "$CONT" != "s" ]] && exit 0
fi

# Monta a configuração
echo "" >> "$CONFIG_FILE"
echo "\$i++;" >> "$CONFIG_FILE"
echo "\$cfg['Servers'][\$i]['host'] = '$HOST';" >> "$CONFIG_FILE"
echo "\$cfg['Servers'][\$i]['port'] = '$PORT';" >> "$CONFIG_FILE"
echo "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';" >> "$CONFIG_FILE"

if [ -n "$NOME" ]; then
  echo "\$cfg['Servers'][\$i]['verbose'] = '$NOME';" >> "$CONFIG_FILE"
fi

echo "✅ Servidor adicionado com sucesso ao $CONFIG_FILE:"
echo "   Host : $HOST"
echo "   Porta: $PORT"
[ -n "$NOME" ] && echo "   Nome : $NOME"
