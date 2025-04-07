#!/bin/bash

# Uso: ./mysql_user_remove.sh -h HOST -u USERNAME

#   -h HOST         : Endereço do host do usuário (ex.: localhost)
#   -u USERNAME     : Nome do usuário a ser removido

# Função para exibir a mensagem de uso
usage() {
  echo "Uso: $0 -h HOST -u USERNAME"
  echo " "
  echo "   -h HOST         : Endereço do host do usuário (ex.: localhost)"
  echo "   -u USERNAME     : Nome do usuário a ser removido"
  exit 1
}

# Verifica se os comandos necessários estão disponíveis
if ! command -v sudo &> /dev/null; then
  echo "Erro: 'sudo' não está instalado. Instale-o para prosseguir." >&2
  exit 1
fi

if ! command -v mysql &> /dev/null; then
  echo "Erro: 'mysql' não está instalado. Instale-o para prosseguir." >&2
  exit 1
fi

# Inicializa variáveis
while getopts ":h:u:" opt; do
  case ${opt} in
    h)
      HOST="$OPTARG"
      ;;
    u)
      USERNAME="$OPTARG"
      ;;
    \?)
      echo "Opção inválida: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "A opção -$OPTARG requer um argumento." >&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Verifica se os parâmetros obrigatórios foram fornecidos
if [ -z "$HOST" ] || [ -z "$USERNAME" ]; then
  echo "Erro: Parâmetros obrigatórios ausentes." >&2
  usage
fi

# Verifica se o usuário existe antes de tentar removê-lo
USER_EXISTS=$(sudo mysql -N -s -u root -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user='${USERNAME}' AND host='${HOST}');")
if [ "$USER_EXISTS" -eq 0 ]; then
  echo "O usuário '${USERNAME}'@'${HOST}' não existe."
  exit 0
fi

# Cria a string SQL para remoção do usuário
SQL="DROP USER '${USERNAME}'@'${HOST}'; FLUSH PRIVILEGES;"

# Executa os comandos SQL com tratamento de erro
if sudo mysql -u root -e "$SQL"; then
  echo "Usuário '${USERNAME}'@'${HOST}' removido com sucesso."
else
  echo "Falha ao remover o usuário '${USERNAME}'@'${HOST}'." >&2
  exit 1
fi
