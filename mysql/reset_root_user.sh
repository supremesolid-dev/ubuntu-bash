#!/bin/bash

echo "Restaurando MySQL para configuração padrão com root via auth_socket..."

echo "[1/8] Parando o serviço MySQL..."
sudo systemctl stop mysql

echo "[2/8] Garantindo que o diretório de socket exista..."
sudo mkdir -p /var/run/mysqld
sudo chown mysql:mysql /var/run/mysqld

echo "[3/8] Iniciando MySQL em modo de recuperação (skip-grant-tables)..."
sudo mysqld_safe --skip-grant-tables --skip-networking &
sleep 5

echo "[4/8] Conectando ao MySQL sem senha para criar root com mysql_native_password..."
sudo mysql -u root <<EOF
FLUSH PRIVILEGES;

-- Cria o usuário root se não existir
CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';

-- Garante acesso total ao root
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "[5/8] Encerrando o processo MySQL temporário..."
sudo pkill -f -- "--skip-grant-tables"
sleep 3

echo "[6/8] Reiniciando o serviço MySQL normalmente..."
sudo systemctl start mysql
sleep 3

echo "[7/8] Convertendo root para usar auth_socket..."
sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;
FLUSH PRIVILEGES;
EOF

echo "[8/8] Testando acesso com sudo mysql..."
if sudo mysql -e "SELECT User, Host, plugin FROM mysql.user WHERE User='root';"; then
    echo "Reset concluído com sucesso! Agora você pode usar: sudo mysql"
else
    echo "Algo deu errado. Verifique os logs ou tente novamente."
fi
