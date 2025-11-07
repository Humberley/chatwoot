#!/bin/bash
# Script de Backup para Chatwoot
# Uso: ./backup.sh

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Chatwoot - Backup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Criar diretório de backups se não existir
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup do PostgreSQL
echo -e "${YELLOW}[1/3] Backup do banco de dados PostgreSQL...${NC}"
BACKUP_FILE="$BACKUP_DIR/postgres_backup_$TIMESTAMP.sql"
docker-compose exec -T postgres pg_dump -U postgres chatwoot_production > "$BACKUP_FILE"
gzip "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup do banco: ${BACKUP_FILE}.gz${NC}"
echo ""

# Backup dos volumes (storage, uploads)
echo -e "${YELLOW}[2/3] Backup dos volumes Docker...${NC}"
STORAGE_BACKUP="$BACKUP_DIR/storage_backup_$TIMESTAMP.tar.gz"
docker run --rm \
  -v chatwoot_storage:/data \
  -v $(pwd)/$BACKUP_DIR:/backup \
  ubuntu tar czf /backup/storage_backup_$TIMESTAMP.tar.gz /data
echo -e "${GREEN}✓ Backup de storage: $STORAGE_BACKUP${NC}"
echo ""

# Backup do .env
echo -e "${YELLOW}[3/3] Backup das variáveis de ambiente...${NC}"
if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/env_backup_$TIMESTAMP"
    echo -e "${GREEN}✓ Backup do .env: $BACKUP_DIR/env_backup_$TIMESTAMP${NC}"
else
    echo -e "${YELLOW}Aviso: Arquivo .env não encontrado${NC}"
fi
echo ""

# Resumo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Backup concluído!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Arquivos criados em: $BACKUP_DIR/"
ls -lh "$BACKUP_DIR/"
echo ""
echo "Para restaurar:"
echo "  ./restore.sh $BACKUP_DIR/postgres_backup_$TIMESTAMP.sql.gz"
