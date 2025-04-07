#!/bin/bash

# Função para exibir a mensagem de uso
usage() {
  echo "Uso: $0 -h HOST -u USERNAME -p PASSWORD [-a]"
  echo " "
  echo "   -h HOST         : Endereço do host (ex.: localhost)"
  echo "   -u USERNAME     : Nome do usuário a ser criado"
  echo "   -p PASSWORD     : Senha do usuário"
  echo "   -a              : Concede privilégios de administrador (todos os privilégios)"
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
ADMIN=false

# Processa os parâmetros informados
while getopts ":h:u:p:a" opt; do
  case ${opt} in
    h)
      HOST="$OPTARG"
      ;;
    u)
      USERNAME="$OPTARG"
      ;;
    p)
      PASSWORD="$OPTARG"
      ;;
    a)
      ADMIN=true
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
if [ -z "$HOST" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  echo "Erro: Parâmetros obrigatórios ausentes." >&2
  usage
fi

# Verifica se o usuário já existe
USER_EXISTS=$(sudo mysql -N -s -u root -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user='${USERNAME}' AND host='${HOST}');")
if [ "$USER_EXISTS" -eq 1 ]; then
  echo "O usuário '${USERNAME}'@'${HOST}' já existe."
  exit 0
fi

# Cria a string SQL para criação do usuário e concessão de privilégios
SQL="CREATE USER '${USERNAME}'@'${HOST}' IDENTIFIED BY '${PASSWORD}'; "

if [ "$ADMIN" = true ]; then
  SQL+="GRANT ALL PRIVILEGES ON *.* TO '${USERNAME}'@'${HOST}' WITH GRANT OPTION; "
else
  SQL+="GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO '${USERNAME}'@'${HOST}'; "
fi
SQL+="FLUSH PRIVILEGES;"

# Executa os comandos SQL com tratamento de erro
if sudo mysql -u root -e "$SQL"; then
  echo "Usuário '${USERNAME}' criado com sucesso."
else
  echo "Falha ao criar o usuário '${USERNAME}'." >&2
  exit 1
fi
