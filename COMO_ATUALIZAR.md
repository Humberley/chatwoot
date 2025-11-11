# 🔄 Como Fazer Atualizações no InovaChat

## 📋 Tipos de Atualizações

### 1️⃣ **Mudanças em Variáveis de Ambiente** (mais comum)
Exemplo: Mudar SECRET_KEY_BASE, SMTP, etc.

### 2️⃣ **Mudanças em Configurações do Banco**
Exemplo: Mudar INSTALLATION_NAME, adicionar integrações

### 3️⃣ **Atualizar Versão do Chatwoot**
Exemplo: v4.1.0 → v4.2.0

### 4️⃣ **Customizações de Código** (avançado)
Exemplo: Mudar textos, templates, adicionar funcionalidades

---

## 🔄 1. Mudanças em Variáveis de Ambiente

### **No Windows:**

1. Edite o arquivo `docker-compose.inovachat-simples.yaml`
2. Altere as variáveis que deseja:

```yaml
environment:
  - INSTALLATION_NAME=InovaChat  # Pode mudar aqui
  - SMTP_ADDRESS=novo-smtp.com   # Ou aqui
  - FRONTEND_URL=https://novo-dominio.com  # Ou aqui
```

3. Commit e push:

```bash
git add docker-compose.inovachat-simples.yaml
git commit -m "Update: Mudança em variáveis de ambiente"
git push origin main
```

### **Na VPS:**

```bash
cd ~/chatwoot
git pull origin main

# Atualizar stack (aplica novas variáveis)
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat

# Aguardar aplicar (~30 segundos)
docker service ls
```

**Pronto!** As mudanças já estarão aplicadas.

---

## 🗄️ 2. Mudanças em Configurações do Banco

Exemplo: Mudar nome do app, adicionar API keys, etc.

### **Criar script de atualização:**

Crie um arquivo `update_config_YYYYMMDD.rb` (ex: `update_config_20251111.rb`):

```ruby
#!/usr/bin/env ruby
# Atualização de configuração - 11/11/2025

puts "🔄 Atualizando configuração..."

# Exemplo: Adicionar Facebook App ID
InstallationConfig.find_or_create_by(name: 'FB_APP_ID').update(value: 'seu-app-id-aqui')

# Exemplo: Mudar limite de algo
InstallationConfig.find_or_create_by(name: 'SOME_LIMIT').update(value: '100')

puts "✅ Configurações atualizadas!"
```

### **Aplicar na VPS:**

```bash
cd ~/chatwoot

# Copiar script
docker cp update_config_20251111.rb $(docker ps -qf "name=inovachat_inovachat_app"):/app/

# Executar
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails runner update_config_20251111.rb

# Restart (opcional, dependendo da config)
docker service update --force inovachat_inovachat_app
```

---

## ⬆️ 3. Atualizar Versão do Chatwoot

**Exemplo:** Atualizar de v4.1.0 para v4.2.0

### **No Windows:**

Edite `docker-compose.inovachat-simples.yaml`:

```yaml
# ANTES
image: chatwoot/chatwoot:v4.1.0

# DEPOIS
image: chatwoot/chatwoot:v4.2.0
```

Commit e push:

```bash
git add docker-compose.inovachat-simples.yaml
git commit -m "Update: Chatwoot v4.1.0 → v4.2.0"
git push origin main
```

### **Na VPS:**

```bash
cd ~/chatwoot
git pull origin main

# Fazer backup do banco (IMPORTANTE!)
docker exec $(docker ps -qf "name=pgvector") pg_dump -U postgres chatwoot > backup_antes_update_$(date +%Y%m%d).sql

# Atualizar stack
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat

# Aguardar baixar nova imagem e subir (~2-5 minutos)
docker service logs inovachat_inovachat_app --follow

# Rodar migrations (se houver)
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate

# Verificar
docker service ls
```

**⚠️ SEMPRE faça backup antes de atualizar versão!**

---

## 🎨 4. Customizações de Código (Avançado)

Se você quiser mudar textos, templates, ou adicionar funcionalidades.

### **Opção A: Usar Dockerfile Custom**

Já criamos o `Dockerfile.custom` antes. Para usar:

1. Edite os arquivos que quer customizar (ex: `app/views/...`)
2. Commit e push
3. Na VPS:

```bash
cd ~/chatwoot
git pull

# Buildar nova imagem
docker build -f Dockerfile.custom -t inovachat:latest .

# Usar docker-compose.inovachat.yaml (o que tem build)
docker stack deploy -c docker-compose.inovachat.yaml inovachat
```

**⚠️ Isso pode causar crashloop se não for feito corretamente.**

---

### **Opção B: Volumes Montados (Recomendado para textos/templates)**

Adicione volumes no docker-compose:

```yaml
volumes:
  - ./app/views/installation/onboarding:/app/app/views/installation/onboarding
  - ./app/javascript/dashboard/i18n/locale/en:/app/app/javascript/dashboard/i18n/locale/en
```

Assim você edita os arquivos localmente e eles refletem direto no container!

---

## 🚀 Fluxo Completo de Update (Passo a Passo)

### **Desenvolvimento Local (Windows):**

```bash
# 1. Fazer mudanças
# 2. Testar localmente (opcional)
# 3. Commit
git add .
git commit -m "Update: Descrição da mudança"
git push origin main
```

---

### **Deploy na VPS:**

```bash
# 1. Conectar na VPS
ssh usuario@sua-vps

# 2. Ir para o diretório
cd ~/chatwoot

# 3. Backup (se for mudança crítica)
docker exec $(docker ps -qf "name=pgvector") pg_dump -U postgres chatwoot > backup_$(date +%Y%m%d_%H%M).sql

# 4. Atualizar código
git pull origin main

# 5. Aplicar mudanças
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat

# 6. Verificar status
docker service ls

# 7. Ver logs se necessário
docker service logs inovachat_inovachat_app --tail 50 --follow

# 8. Rodar migrations se houver
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
```

---

## 📊 Checklist de Deploy

- [ ] Mudanças commitadas e pushed
- [ ] Backup do banco feito (se mudança crítica)
- [ ] Git pull na VPS
- [ ] Stack atualizada com `docker stack deploy`
- [ ] Services em 1/1
- [ ] Migrations rodadas (se necessário)
- [ ] Testado no navegador
- [ ] Cache do browser limpo

---

## 🔍 Troubleshooting

### Services ficam 0/1 após update

```bash
# Ver logs
docker service logs inovachat_inovachat_app --tail 100

# Rollback se necessário
git checkout HEAD~1 docker-compose.inovachat-simples.yaml
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

---

### Mudança não aparece

1. **Limpar cache:** `Ctrl + Shift + R`
2. **Force restart:**
```bash
docker service update --force inovachat_inovachat_app
```

---

## 🎯 Resumo dos Comandos

```bash
# Fluxo básico de update
cd ~/chatwoot
git pull
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
docker service ls
```

Simples assim! 🚀

---

## 📝 Exemplo Prático

**Cenário:** Você quer mudar o SMTP para SendGrid

### 1. No Windows:

Edite `docker-compose.inovachat-simples.yaml`:

```yaml
- SMTP_ADDRESS=smtp.sendgrid.net
- SMTP_PORT=587
- SMTP_USERNAME=apikey
- SMTP_PASSWORD=SG.sua-api-key-aqui
```

```bash
git add docker-compose.inovachat-simples.yaml
git commit -m "Update: Trocar SMTP para SendGrid"
git push
```

### 2. Na VPS:

```bash
cd ~/chatwoot
git pull
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

**Pronto!** Emails agora saem pelo SendGrid.

---

Ficou claro? 😊
