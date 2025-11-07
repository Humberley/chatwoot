#!/bin/bash
# Deploy Script para Chatwoot Kanban
# Uso: ./deploy.sh

set -e  # Para execução em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Chatwoot Kanban - Deploy Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar se está no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Erro: docker-compose.yml não encontrado!${NC}"
    echo "Execute este script no diretório raiz do Chatwoot"
    exit 1
fi

# Passo 1: Backup
echo -e "${YELLOW}[1/8] Criando backup do banco de dados...${NC}"
BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
docker-compose exec -T postgres pg_dump -U postgres chatwoot_production > "$BACKUP_FILE" || {
    echo -e "${RED}Aviso: Falha no backup automático. Continue manualmente.${NC}"
}
echo -e "${GREEN}✓ Backup salvo em: $BACKUP_FILE${NC}"
echo ""

# Passo 2: Verificar estado do Git
echo -e "${YELLOW}[2/8] Verificando repositório Git...${NC}"
git status
echo ""

# Passo 3: Confirmar continuação
echo -e "${YELLOW}Deseja continuar com o deploy? (y/n)${NC}"
read -r CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Deploy cancelado."
    exit 0
fi
echo ""

# Passo 4: Parar containers
echo -e "${YELLOW}[3/8] Parando containers...${NC}"
docker-compose stop
echo -e "${GREEN}✓ Containers parados${NC}"
echo ""

# Passo 5: Build das imagens
echo -e "${YELLOW}[4/8] Buildando novas imagens Docker...${NC}"
echo "Isso pode levar alguns minutos..."
docker-compose build
echo -e "${GREEN}✓ Build concluído${NC}"
echo ""

# Passo 6: Instalar dependências (se necessário)
echo -e "${YELLOW}[5/8] Instalando dependências...${NC}"
docker-compose run --rm web bundle install
docker-compose run --rm web pnpm install
echo -e "${GREEN}✓ Dependências instaladas${NC}"
echo ""

# Passo 7: Executar migrations
echo -e "${YELLOW}[6/8] Executando migrations do banco de dados...${NC}"
docker-compose run --rm web bundle exec rails db:migrate
echo -e "${GREEN}✓ Migrations executadas${NC}"
echo ""

# Passo 8: Compilar assets
echo -e "${YELLOW}[7/8] Compilando assets...${NC}"
docker-compose run --rm web pnpm build
echo -e "${GREEN}✓ Assets compilados${NC}"
echo ""

# Passo 9: Iniciar containers
echo -e "${YELLOW}[8/8] Iniciando containers...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Containers iniciados${NC}"
echo ""

# Verificar status
echo -e "${YELLOW}Verificando status dos containers...${NC}"
docker-compose ps
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Para ver os logs:"
echo "  docker-compose logs -f"
echo ""
echo "Para verificar o Kanban:"
echo "  Acesse: http://seu-dominio/app/accounts/1/contacts/kanban"
echo ""
echo -e "${YELLOW}Backup salvo em: $BACKUP_FILE${NC}"
echo "Guarde este arquivo em local seguro!"
