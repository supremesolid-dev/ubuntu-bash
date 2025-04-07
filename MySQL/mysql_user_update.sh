#!/bin/bash

# Uso: ./mysql_update_user.sh -h HOST -u USERNAME [-p NEW_PASSWORD] [-m PERMISSION] [-a PLUGIN]
#
#   -h HOST         : Endereço do host (ex.: localhost)
#   -u USERNAME     : Nome do usuário a ser atualizado
#   -p NEW_PASSWORD : Nova senha do usuário (opcional)
#   -m PERMISSION   : Permissão a ser configurada (admin, readonly ou standard). Opcional.
#   -a PLUGIN       : Plugin de autenticação (native, sha256, sha2cached, socket). Opcional.
#                     Se não informado, será usado o plugin nativo (mysql_native_password).

# Função para exibir a mensagem de uso
usage() {
  echo "Uso: $0 -h HOST -u USERNAME [-p NEW_PASSWORD] [-m PERMISSION] [-a PLUGIN]"
  echo " "
  echo "   -h HOST         : Endereço do host (ex.: localhost)"
  echo "   -u USERNAME     : Nome do usuário a ser atualizado"
  echo "   -p NEW_PASSWORD : Nova senha do usuário (opcional)"
  echo "   -m PERMISSION   : Permissão (admin, readonly ou standard). Opcional."
  echo "   -a PLUGIN       : Plugin de autenticação (native, sha256, sha2cached, socket). Opcional."
  echo "                    Informe pelo menos uma opção (-p ou -m)."
  exit 1
}

# Verifica se os comandos necessários estão disponíveis
if ! command -v sudo &> /dev/null; then
  echo "Erro: 'sudo' não está instalado." >&2
  exit 1
fi

if ! command -v mysql &> /dev/null; then
  echo "Erro: 'mysql' não está instalado." >&2
  exit 1
fi

# Inicializa variáveis
NEW_PASSWORD=""
PERMISSION=""
AUTH_PLUGIN="mysql_native_password"

# Processa os parâmetros informados
while getopts ":h:u:p:m:a:" opt; do
  case ${opt} in
    h) HOST="$OPTARG" ;;
    u) USERNAME="$OPTARG" ;;
    p) NEW_PASSWORD="$OPTARG" ;;
    m) PERMISSION="$OPTARG" ;;
    a)
      case "$OPTARG" in
        native) AUTH_PLUGIN="mysql_native_password" ;;
        sha256) AUTH_PLUGIN="sha256_password" ;;
        sha2cached) AUTH_PLUGIN="caching_sha2_password" ;;
        socket) AUTH_PLUGIN="auth_socket" ;;
        *)
          echo "Erro: Plugin de autenticação inválido. Use: native, sha256, sha2cached ou socket." >&2
          usage
          ;;
      esac
      ;;
    \?) echo "Opção inválida: -$OPTARG" >&2; usage ;;
    :) echo "A opção -$OPTARG requer um argumento." >&2; usage ;;
  esac
done
shift $((OPTIND -1))

# Verifica parâmetros obrigatórios
if [ -z "$HOST" ] || [ -z "$USERNAME" ]; then
  echo "Erro: Parâmetros obrigatórios ausentes." >&2
  usage
fi

# Verifica se ao menos uma opção foi informada
if [ -z "$NEW_PASSWORD" ] && [ -z "$PERMISSION" ]; then
  echo "Erro: Informe pelo menos a nova senha (-p) ou permissão (-m)." >&2
  usage
fi

# Valida permissões
if [ -n "$PERMISSION" ]; then
  case "$PERMISSION" in
    admin|readonly|standard) ;;
    *) echo "Erro: Permissão inválida. Use: admin, readonly ou standard." >&2; usage ;;
  esac
fi

# Verifica existência do usuário
USER_EXISTS=$(sudo mysql -N -s -u root -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user='${USERNAME}' AND host='${HOST}');")
if [ "$USER_EXISTS" -eq 0 ]; then
  echo "O usuário '${USERNAME}'@'${HOST}' não existe."
  exit 0
fi

echo "Atualizando usuário '${USERNAME}'@'${HOST}'..."

# Monta comandos SQL
SQL=""

if [ -n "$NEW_PASSWORD" ]; then
  SQL+="ALTER USER '${USERNAME}'@'${HOST}' IDENTIFIED WITH '${AUTH_PLUGIN}' BY '${NEW_PASSWORD}'; "
fi

if [ -n "$PERMISSION" ]; then
  case "$PERMISSION" in
    admin)
      SQL+="GRANT ALL PRIVILEGES ON *.* TO '${USERNAME}'@'${HOST}' WITH GRANT OPTION; "
      ;;
    readonly)
      SQL+="REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USERNAME}'@'${HOST}'; "
      SQL+="GRANT SELECT ON *.* TO '${USERNAME}'@'${HOST}'; "
      ;;
    standard)
      SQL+="REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USERNAME}'@'${HOST}'; "
      SQL+="GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO '${USERNAME}'@'${HOST}'; "
      ;;
  esac
fi

SQL+="FLUSH PRIVILEGES;"

# Executa o SQL
if sudo mysql -u root -e "$SQL"; then
  echo "Usuário '${USERNAME}' atualizado com sucesso."
else
  echo "Falha ao atualizar o usuário '${USERNAME}'." >&2
  exit 1
fi
