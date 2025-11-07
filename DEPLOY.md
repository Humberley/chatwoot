# 🚀 Guia de Deploy - Chatwoot Kanban

Este guia detalha como fazer o deploy das novas funcionalidades de Kanban no seu servidor com Docker Swarm/Portainer.

## 📋 Pré-requisitos

- [x] Servidor Ubuntu com Docker instalado
- [x] Docker Compose instalado
- [x] Acesso SSH ao servidor
- [x] Chatwoot já rodando com Docker Compose
- [x] Backup recente do banco de dados

## 🎯 Visão Geral

O deploy envolve:
1. **Backup** dos dados atuais
2. **Parar** containers atuais
3. **Atualizar** código fonte
4. **Build** das novas imagens
5. **Executar** migrations do banco
6. **Compilar** assets frontend
7. **Reiniciar** containers

---

## 🔧 Método 1: Deploy Automatizado (Recomendado)

### Passo 1: Transferir Arquivos

No seu **computador local** (Windows):

```bash
# Transferir código atualizado e scripts
scp -r C:\Users\humbe\Documents\Chatwoot seu-usuario@seu-servidor:/home/seu-usuario/chatwoot-update/
```

### Passo 2: Conectar ao Servidor

```bash
ssh seu-usuario@seu-servidor.com
```

### Passo 3: Preparar Ambiente

```bash
# Navegar para o diretório do Chatwoot
cd /caminho/do/chatwoot

# Copiar arquivos atualizados
cp -r ~/chatwoot-update/* .

# Dar permissão de execução aos scripts
chmod +x deploy.sh backup.sh rollback.sh
```

### Passo 4: Executar Deploy

```bash
# Rodar script de deploy automatizado
./deploy.sh
```

O script irá:
- ✅ Criar backup automático
- ✅ Parar containers
- ✅ Buildar novas imagens
- ✅ Instalar dependências
- ✅ Executar migrations
- ✅ Compilar assets
- ✅ Reiniciar containers

**Tempo estimado:** 15-25 minutos

---

## 🛠️ Método 2: Deploy Manual (Passo a Passo)

Se preferir controle total, execute manualmente:

### 1. Backup

```bash
# Criar backup do banco
docker-compose exec -T postgres pg_dump -U postgres chatwoot_production > backup_$(date +%Y%m%d_%H%M%S).sql

# OU usar o script:
./backup.sh
```

### 2. Parar Containers

```bash
docker-compose stop
```

### 3. Atualizar Código

**Opção A: Se usar Git**
```bash
git pull origin develop
```

**Opção B: Se transferir arquivos**
```bash
# Já transferido via SCP no passo anterior
```

### 4. Build das Imagens

```bash
docker-compose build --no-cache
```

### 5. Instalar Dependências

```bash
# Ruby (Backend)
docker-compose run --rm web bundle install

# Node (Frontend)
docker-compose run --rm web pnpm install
```

### 6. Executar Migration

```bash
# Criar tabela kanban_columns
docker-compose run --rm web bundle exec rails db:migrate
```

### 7. Compilar Assets

```bash
docker-compose run --rm web pnpm build
```

### 8. Iniciar Containers

```bash
docker-compose up -d
```

### 9. Verificar Logs

```bash
docker-compose logs -f
```

---

## 🎛️ Método 3: Via Portainer (Interface Web)

### Acessar Portainer

1. Abra navegador: `https://seu-servidor:9443`
2. Faça login

### Executar via Portainer

**A. Parar Stack**
1. Ir em **Stacks** → Seu stack do Chatwoot
2. Clicar em **Stop**

**B. Editar Stack**
1. Clicar em **Editor**
2. (Opcional) Atualizar configurações
3. Clicar em **Update the stack**

**C. Console dos Containers**

Para executar comandos:
1. Ir em **Containers**
2. Selecionar container `web`
3. Clicar em **Console**
4. Executar:

```bash
bundle exec rails db:migrate
pnpm build
```

**D. Reiniciar Stack**
1. Voltar em **Stacks**
2. Clicar em **Start**

---

## ✅ Verificações Pós-Deploy

### 1. Verificar Containers Rodando

```bash
docker-compose ps
```

Todos devem estar **Up**:
- web
- worker
- postgres
- redis

### 2. Verificar Migration

```bash
docker-compose exec postgres psql -U postgres -d chatwoot_production -c "\d kanban_columns"
```

Deve mostrar a estrutura da tabela.

### 3. Verificar Logs

```bash
# Ver erros nos últimos 100 logs
docker-compose logs --tail=100 web | grep -i error

# Ver logs do worker
docker-compose logs --tail=100 worker
```

### 4. Testar Frontend

Acessar no navegador:

**Kanban de Contatos:**
```
http://seu-dominio.com/app/accounts/1/contacts/kanban
```

**Kanban de Conversas:**
```
http://seu-dominio.com/app/accounts/1/conversations/kanban
```

**Verificar Sidebar:**
- Menu **Contacts** deve ter item "Kanban"
- Menu **Conversations** deve ter item "Kanban"

### 5. Testar Funcionalidade

1. Criar uma coluna nova
2. Arrastar um contato para a coluna
3. Verificar se salvou (recarregar página)
4. Editar coluna (mudar cor/nome)
5. Deletar coluna

---

## 🐛 Troubleshooting

### Problema: Migration falha "table already exists"

**Solução:**
```bash
# Verificar status das migrations
docker-compose run --rm web bundle exec rails db:migrate:status

# Reverter última migration
docker-compose run --rm web bundle exec rails db:rollback

# Rodar novamente
docker-compose run --rm web bundle exec rails db:migrate
```

### Problema: Assets não carregam (404 errors)

**Solução:**
```bash
# Limpar assets antigos
docker-compose run --rm web bundle exec rails assets:clean

# Recompilar
docker-compose run --rm web pnpm build

# Reiniciar web
docker-compose restart web
```

### Problema: Erro "permission denied"

**Solução:**
```bash
# Ajustar permissões
sudo chown -R 1000:1000 /caminho/do/chatwoot

# Ou usar o usuário do container
sudo chown -R $(id -u):$(id -g) /caminho/do/chatwoot
```

### Problema: Container não inicia

**Solução:**
```bash
# Ver logs detalhados
docker-compose logs web

# Ver últimas 200 linhas
docker-compose logs --tail=200 web

# Seguir logs em tempo real
docker-compose logs -f web
```

### Problema: Banco não conecta

**Solução:**
```bash
# Verificar se PostgreSQL está rodando
docker-compose ps postgres

# Verificar logs do PostgreSQL
docker-compose logs postgres

# Testar conexão
docker-compose exec postgres psql -U postgres -c "SELECT version();"
```

---

## 🔄 Rollback (Reverter Deploy)

Se algo der errado, reverter para versão anterior:

### Método Automatizado

```bash
./rollback.sh backups/postgres_backup_TIMESTAMP.sql.gz
```

### Método Manual

```bash
# 1. Parar tudo
docker-compose down

# 2. Iniciar apenas PostgreSQL
docker-compose up -d postgres
sleep 5

# 3. Restaurar backup
gunzip -c backup.sql.gz | docker-compose exec -T postgres psql -U postgres chatwoot_production

# 4. Reverter código
git reset --hard HEAD~1

# 5. Rebuild
docker-compose build
docker-compose up -d
```

---

## 📊 Monitoramento

### Via Portainer

1. Dashboard → Seu stack
2. Ver uso de CPU/RAM
3. Ver logs em tempo real
4. Restart containers individuais

### Via Linha de Comando

```bash
# Stats de recursos
docker stats

# Apenas containers do Chatwoot
docker stats $(docker-compose ps -q)

# Espaço em disco
df -h
docker system df
```

---

## 🔐 Checklist de Segurança

Antes do deploy em produção:

- [ ] Backup criado e testado
- [ ] Usuários notificados sobre manutenção
- [ ] Deploy em horário de baixo tráfego
- [ ] Variáveis de ambiente conferidas
- [ ] Certificados SSL válidos
- [ ] Firewall configurado
- [ ] Logs sendo monitorados
- [ ] Plano de rollback pronto

---

## 📞 Suporte

Em caso de problemas:

1. **Verificar logs:**
   ```bash
   docker-compose logs -f --tail=200
   ```

2. **Verificar issues no GitHub:**
   - https://github.com/chatwoot/chatwoot/issues

3. **Community Discord:**
   - https://discord.gg/cJXdrwS

---

## 📁 Estrutura de Arquivos

Após deploy, você terá:

```
/caminho/do/chatwoot/
├── deploy.sh           # Script de deploy automático
├── backup.sh           # Script de backup
├── rollback.sh         # Script de rollback
├── DEPLOY.md           # Este arquivo
├── docker-compose.yml  # Configuração Docker
├── .env                # Variáveis de ambiente
├── backups/            # Diretório de backups
│   ├── postgres_backup_20251104_143000.sql.gz
│   ├── storage_backup_20251104_143000.tar.gz
│   └── env_backup_20251104_143000
└── app/                # Código Chatwoot
    └── ...
```

---

## ✨ Resultado Esperado

Após deploy bem-sucedido:

✅ Chatwoot rodando normalmente
✅ Sidebar mostra links "Kanban"
✅ Página `/contacts/kanban` funcional
✅ Página `/conversations/kanban` funcional
✅ Criar/editar/deletar colunas funciona
✅ Drag-and-drop de cards funciona
✅ Dados persistem após reload

---

## 🎉 Próximos Passos

Após deploy:

1. **Treinar usuários:**
   - Como criar colunas
   - Como usar drag-and-drop
   - Boas práticas de organização

2. **Monitorar performance:**
   - Tempo de resposta
   - Uso de recursos
   - Erros nos logs

3. **Coletar feedback:**
   - Sugestões de melhorias
   - Bugs reportados
   - Features desejadas

4. **Planejar próximas features:**
   - Filtros automáticos por coluna
   - Automações ao mover cards
   - Métricas e relatórios de Kanban

Bom deploy! 🚀
