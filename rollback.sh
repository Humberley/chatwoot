#!/bin/bash
# Script de Rollback para Chatwoot
# Uso: ./rollback.sh [backup_file.sql.gz]

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}  Chatwoot - Rollback Script${NC}"
echo -e "${RED}========================================${NC}"
echo ""

if [ -z "$1" ]; then
    echo -e "${RED}Erro: Especifique o arquivo de backup${NC}"
    echo "Uso: ./rollback.sh backups/postgres_backup_TIMESTAMP.sql.gz"
    echo ""
    echo "Backups disponíveis:"
    ls -lh backups/*.sql.gz 2>/dev/null || echo "Nenhum backup encontrado"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Erro: Arquivo $BACKUP_FILE não encontrado!${NC}"
    exit 1
fi

echo -e "${YELLOW}AVISO: Este processo irá:${NC}"
echo "  1. Parar todos os containers"
echo "  2. Restaurar o banco de dados"
echo "  3. Reverter código Git (opcional)"
echo "  4. Rebuildar imagens"
echo "  5. Reiniciar containers"
echo ""
echo -e "${RED}Todos os dados atuais serão substituídos!${NC}"
echo ""
read -p "Tem certeza que deseja continuar? (digite 'yes' para confirmar): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Rollback cancelado."
    exit 0
fi

# Passo 1: Parar containers
echo -e "${YELLOW}[1/5] Parando containers...${NC}"
docker-compose down
echo -e "${GREEN}✓ Containers parados${NC}"
echo ""

# Passo 2: Iniciar apenas o PostgreSQL
echo -e "${YELLOW}[2/5] Iniciando PostgreSQL...${NC}"
docker-compose up -d postgres
sleep 5  # Aguardar PostgreSQL inicializar
echo -e "${GREEN}✓ PostgreSQL iniciado${NC}"
echo ""

# Passo 3: Restaurar backup
echo -e "${YELLOW}[3/5] Restaurando banco de dados...${NC}"

# Descompactar se for .gz
if [[ $BACKUP_FILE == *.gz ]]; then
    gunzip -c "$BACKUP_FILE" | docker-compose exec -T postgres psql -U postgres chatwoot_production
else
    docker-compose exec -T postgres psql -U postgres chatwoot_production < "$BACKUP_FILE"
fi

echo -e "${GREEN}✓ Banco de dados restaurado${NC}"
echo ""

# Passo 4: Reverter código Git (opcional)
echo -e "${YELLOW}[4/5] Deseja reverter o código Git? (y/n)${NC}"
read -r REVERT_GIT

if [ "$REVERT_GIT" = "y" ]; then
    git log --oneline -10
    echo ""
    read -p "Digite o hash do commit para reverter (ou deixe vazio para pular): " COMMIT_HASH

    if [ -n "$COMMIT_HASH" ]; then
        git reset --hard "$COMMIT_HASH"
        echo -e "${GREEN}✓ Código revertido para commit $COMMIT_HASH${NC}"
    fi
fi
echo ""

# Passo 5: Rebuildar e reiniciar
echo -e "${YELLOW}[5/5] Rebuildando e reiniciando containers...${NC}"
docker-compose build
docker-compose up -d
echo -e "${GREEN}✓ Containers reiniciados${NC}"
echo ""

# Verificar status
echo -e "${YELLOW}Verificando status...${NC}"
docker-compose ps
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Rollback concluído!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Verifique os logs:"
echo "  docker-compose logs -f"
