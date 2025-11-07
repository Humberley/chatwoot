# ⚡ Quick Start - Deploy Chatwoot Kanban

Guia rápido de deploy para referência.

## 🚀 Deploy Completo (5 minutos)

```bash
# 1. SSH no servidor
ssh usuario@seu-servidor.com
cd /caminho/do/chatwoot

# 2. Dar permissão aos scripts
chmod +x *.sh

# 3. Executar deploy automatizado
./deploy.sh
```

**Pronto!** ✅

---

## 📦 Comandos Essenciais

### Deploy Manual Rápido

```bash
# Backup
docker-compose exec -T postgres pg_dump -U postgres chatwoot_production > backup.sql

# Parar
docker-compose down

# Build
docker-compose build

# Migration
docker-compose run --rm web bundle exec rails db:migrate

# Iniciar
docker-compose up -d

# Logs
docker-compose logs -f
```

### Backup

```bash
./backup.sh
```

### Rollback

```bash
./rollback.sh backups/postgres_backup_TIMESTAMP.sql.gz
```

### Health Check

```bash
./health-check.sh
```

---

## 🔍 Verificações Rápidas

```bash
# Status containers
docker-compose ps

# Logs
docker-compose logs -f --tail=50

# Verificar tabela criada
docker-compose exec postgres psql -U postgres chatwoot_production -c "\d kanban_columns"

# Testar API
curl http://localhost:3000/api
```

---

## 🌐 URLs para Testar

**Kanban Contatos:**
```
http://seu-dominio.com/app/accounts/1/contacts/kanban
```

**Kanban Conversas:**
```
http://seu-dominio.com/app/accounts/1/conversations/kanban
```

---

## 🐛 Troubleshooting Rápido

### Container não inicia

```bash
docker-compose logs web
docker-compose restart web
```

### Migration falha

```bash
docker-compose run --rm web bundle exec rails db:rollback
docker-compose run --rm web bundle exec rails db:migrate
```

### Assets não carregam

```bash
docker-compose run --rm web pnpm build
docker-compose restart web
```

### Banco não conecta

```bash
docker-compose restart postgres
docker-compose logs postgres
```

---

## 📞 Comandos de Diagnóstico

```bash
# CPU/RAM usage
docker stats

# Espaço em disco
df -h
docker system df

# Ver processos
docker-compose top

# Restart tudo
docker-compose restart

# Rebuild forçado
docker-compose build --no-cache
docker-compose up -d --force-recreate
```

---

## 🔄 Ciclo de Deploy Completo

```bash
# 1. Backup
./backup.sh

# 2. Deploy
./deploy.sh

# 3. Verificar
./health-check.sh

# 4. Monitorar
docker-compose logs -f

# Se der problema:
# 5. Rollback
./rollback.sh backups/postgres_backup_TIMESTAMP.sql.gz
```

---

## 📊 Monitoramento Contínuo

```bash
# Deixar rodando em terminal separado
watch -n 5 'docker-compose ps'

# Ou
watch -n 5 './health-check.sh'
```

---

## ⚙️ Variáveis de Ambiente Importantes

Verificar `.env`:

```bash
# Essenciais
SECRET_KEY_BASE=xxxxx
POSTGRES_PASSWORD=xxxxx
REDIS_PASSWORD=xxxxx

# Para Kanban
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=xxxxx
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=xxxxx
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=xxxxx
```

---

## 🎯 Checklist Pré-Deploy

- [ ] Backup criado
- [ ] Horário de baixo tráfego
- [ ] Usuários notificados
- [ ] Espaço em disco OK (>20% livre)
- [ ] Scripts com permissão de execução

---

## 📁 Arquivos Criados

```
/chatwoot/
├── deploy.sh          # Deploy automatizado
├── backup.sh          # Backup automatizado
├── rollback.sh        # Rollback automatizado
├── health-check.sh    # Verificação de saúde
├── DEPLOY.md          # Guia completo
├── QUICKSTART.md      # Este arquivo
└── backups/           # Diretório de backups
    └── postgres_backup_YYYYMMDD_HHMMSS.sql.gz
```

---

## 🎉 Após Deploy

1. Testar Kanban de Contatos
2. Testar Kanban de Conversas
3. Criar coluna teste
4. Arrastar card teste
5. Monitorar logs por 15min

---

## 💡 Dicas

- **Execute health-check regularmente:** `./health-check.sh`
- **Mantenha backups:** Rode `./backup.sh` semanalmente
- **Monitore logs:** `docker-compose logs -f --tail=100`
- **Use Portainer:** Para gerenciamento visual

---

## 📖 Documentação Completa

Para detalhes completos, ver: **DEPLOY.md**

---

**Deploy rápido e seguro! 🚀**
