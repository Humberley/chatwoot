#!/bin/bash
# Script de Health Check para Chatwoot
# Uso: ./health-check.sh

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Chatwoot - Health Check${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

PASS=0
FAIL=0

# Função para check
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
        ((PASS++))
    else
        echo -e "${RED}✗ $1${NC}"
        ((FAIL++))
    fi
}

# 1. Verificar se Docker está rodando
echo -e "${YELLOW}[1/10] Verificando Docker...${NC}"
docker ps > /dev/null 2>&1
check "Docker está rodando"
echo ""

# 2. Verificar containers
echo -e "${YELLOW}[2/10] Verificando containers...${NC}"
WEB_STATUS=$(docker-compose ps -q web | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null)
if [ "$WEB_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ Container web está rodando${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Container web não está rodando (status: $WEB_STATUS)${NC}"
    ((FAIL++))
fi

WORKER_STATUS=$(docker-compose ps -q worker | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null)
if [ "$WORKER_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ Container worker está rodando${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Container worker não está rodando (status: $WORKER_STATUS)${NC}"
    ((FAIL++))
fi

POSTGRES_STATUS=$(docker-compose ps -q postgres | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null)
if [ "$POSTGRES_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ Container postgres está rodando${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Container postgres não está rodando (status: $POSTGRES_STATUS)${NC}"
    ((FAIL++))
fi

REDIS_STATUS=$(docker-compose ps -q redis | xargs docker inspect -f '{{.State.Status}}' 2>/dev/null)
if [ "$REDIS_STATUS" = "running" ]; then
    echo -e "${GREEN}✓ Container redis está rodando${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Container redis não está rodando (status: $REDIS_STATUS)${NC}"
    ((FAIL++))
fi
echo ""

# 3. Verificar PostgreSQL
echo -e "${YELLOW}[3/10] Verificando conexão PostgreSQL...${NC}"
docker-compose exec -T postgres psql -U postgres -c "SELECT 1;" > /dev/null 2>&1
check "PostgreSQL está acessível"
echo ""

# 4. Verificar tabela kanban_columns
echo -e "${YELLOW}[4/10] Verificando tabela kanban_columns...${NC}"
TABLE_EXISTS=$(docker-compose exec -T postgres psql -U postgres chatwoot_production -c "\dt kanban_columns" 2>/dev/null | grep -c "kanban_columns")
if [ "$TABLE_EXISTS" -gt 0 ]; then
    echo -e "${GREEN}✓ Tabela kanban_columns existe${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Tabela kanban_columns não encontrada${NC}"
    ((FAIL++))
fi
echo ""

# 5. Verificar Redis
echo -e "${YELLOW}[5/10] Verificando Redis...${NC}"
docker-compose exec -T redis redis-cli ping > /dev/null 2>&1
check "Redis está respondendo"
echo ""

# 6. Verificar porta 3000
echo -e "${YELLOW}[6/10] Verificando porta da aplicação...${NC}"
PORT_CHECK=$(netstat -tuln 2>/dev/null | grep -c ":3000" || ss -tuln 2>/dev/null | grep -c ":3000")
if [ "$PORT_CHECK" -gt 0 ]; then
    echo -e "${GREEN}✓ Porta 3000 está em uso (aplicação rodando)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Porta 3000 não está em uso${NC}"
    ((FAIL++))
fi
echo ""

# 7. Verificar endpoint da API
echo -e "${YELLOW}[7/10] Verificando API endpoint...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✓ API está respondendo (HTTP $HTTP_STATUS)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ API não está respondendo corretamente (HTTP $HTTP_STATUS)${NC}"
    ((FAIL++))
fi
echo ""

# 8. Verificar espaço em disco
echo -e "${YELLOW}[8/10] Verificando espaço em disco...${NC}"
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${GREEN}✓ Espaço em disco OK (${DISK_USAGE}% usado)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Espaço em disco crítico (${DISK_USAGE}% usado)${NC}"
    ((FAIL++))
fi
echo ""

# 9. Verificar logs por erros recentes
echo -e "${YELLOW}[9/10] Verificando logs por erros...${NC}"
ERROR_COUNT=$(docker-compose logs --tail=100 web 2>/dev/null | grep -i "error" | wc -l)
if [ "$ERROR_COUNT" -lt 5 ]; then
    echo -e "${GREEN}✓ Poucos erros nos logs recentes (${ERROR_COUNT})${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⚠ Muitos erros nos logs recentes (${ERROR_COUNT})${NC}"
    echo "Execute: docker-compose logs --tail=100 web | grep -i error"
    ((FAIL++))
fi
echo ""

# 10. Verificar Sidekiq
echo -e "${YELLOW}[10/10] Verificando Sidekiq worker...${NC}"
SIDEKIQ_RUNNING=$(docker-compose logs --tail=50 worker 2>/dev/null | grep -c "Booting Sidekiq")
if [ "$SIDEKIQ_RUNNING" -gt 0 ]; then
    echo -e "${GREEN}✓ Sidekiq está rodando${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Sidekiq pode não estar rodando corretamente${NC}"
    ((FAIL++))
fi
echo ""

# Resumo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Resumo${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Passou: $PASS${NC}"
echo -e "${RED}Falhou: $FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}✓ Todos os checks passaram! Sistema está saudável.${NC}"
    exit 0
elif [ "$FAIL" -lt 3 ]; then
    echo -e "${YELLOW}⚠ Alguns checks falharam, mas sistema pode estar funcional.${NC}"
    echo "Verifique os logs para mais detalhes:"
    echo "  docker-compose logs -f"
    exit 1
else
    echo -e "${RED}✗ Muitos checks falharam! Sistema pode estar com problemas.${NC}"
    echo ""
    echo "Ações recomendadas:"
    echo "  1. Verificar logs: docker-compose logs -f"
    echo "  2. Verificar status: docker-compose ps"
    echo "  3. Reiniciar: docker-compose restart"
    exit 2
fi
