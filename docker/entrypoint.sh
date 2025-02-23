#!/bin/bash
set -e

# Remove o arquivo de PID pré-existente para evitar conflitos
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo "Verificando se o banco de dados existe e criando se necessário..."
# Tenta criar o banco de dados; se já existir, ignora o erro
bundle exec rails db:create || true

echo "Executando migrações do banco de dados..."
bundle exec rails db:migrate

# Executa o comando passado ao container (geralmente o rails server)
exec "$@"
