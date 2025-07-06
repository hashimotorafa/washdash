#!/bin/bash
set -e

# Função para log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Remover arquivo de PID pré-existente
if [ -f tmp/pids/server.pid ]; then
    log "Removendo arquivo de PID existente..."
    rm tmp/pids/server.pid
fi

# Criar banco de dados se não existir
log "Verificando se o banco de dados existe..."
bundle exec rails db:create 2>/dev/null || log "Banco de dados já existe"

# Executar migrações
log "Executando migrações do banco de dados..."
bundle exec rails db:migrate

log "Executando seeds..."
bundle exec rails db:seed

# Pré-compilar assets
if [ "$RAILS_ENV" = "production" ]; then
    log "Pré-compilando assets..."
    bundle exec rails assets:precompile
fi

# Configurar logs
if [ "$RAILS_ENV" = "production" ]; then
    log "Configurando logs..."
    mkdir -p log
    touch log/production.log
fi

# Verificar permissões
log "Verificando permissões..."
chmod -R 755 tmp/
chmod -R 755 log/

log "Iniciando aplicação..."
exec "$@"