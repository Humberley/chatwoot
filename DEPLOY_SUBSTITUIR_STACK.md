# 🔄 Trocar Chatwoot por InovaChat (Mesma URL)

## ⚠️ IMPORTANTE
Este processo vai **SUBSTITUIR** a stack antiga do Chatwoot pela nova do InovaChat.
- **URL permanece:** `crm.fluxer.com.br`
- **Stack nova:** `inovachat` (independente)
- **Database novo:** `inovachat`
- **Volumes novos:** `inovachat_*`

---

## 📋 Opções de Migração

### **Opção A: Começar do Zero** (recomendado para testar)
Nova instalação limpa, sem migrar dados do Chatwoot antigo.

### **Opção B: Migrar Dados** (preservar conversas)
Copiar banco de dados do Chatwoot antigo para o InovaChat.

---

## 🚀 OPÇÃO A: Instalação Limpa (Do Zero)

### 1️⃣ **Commit e Push** (Windows)

```bash
git add .
git commit -m "InovaChat: Nova stack mantendo mesma URL"
git push origin main
```

---

### 2️⃣ **Na VPS: Parar Stack Antiga**

```bash
cd ~/chatwoot
git pull origin main

# Parar stack antiga (Chatwoot)
docker stack rm chatwoot

# Aguardar containers pararem (~1 minuto)
docker ps -a
```

**⏰ Aguarde até não aparecer nenhum container do `chatwoot`**

---

### 3️⃣ **Buildar Imagem InovaChat**

```bash
docker build -f Dockerfile.custom -t inovachat:latest .
```

**⏱️ Leva 5-10 minutos**

---

### 4️⃣ **Criar Banco de Dados InovaChat**

```bash
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres -c "CREATE DATABASE inovachat;"
```

---

### 5️⃣ **Subir Nova Stack InovaChat**

```bash
docker stack deploy -c docker-compose.inovachat.yaml inovachat
```

---

### 6️⃣ **Verificar Status**

```bash
docker service ls
```

Deve mostrar:
- `inovachat_inovachat_app` (1/1)
- `inovachat_inovachat_sidekiq` (1/1)
- `inovachat_inovachat_redis` (1/1)

Se aparecer **0/1**, veja logs:

```bash
docker service logs inovachat_inovachat_app --tail 100
```

---

### 7️⃣ **Inicializar Banco**

```bash
# Migrations
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate

# Seed
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:seed
```

---

### 8️⃣ **Criar Usuário Admin**

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console Rails:

```ruby
user = User.create!(
  name: 'Admin',
  email: 'admin@inovachat.com',
  password: 'SuaSenhaForte123!',
  password_confirmation: 'SuaSenhaForte123!'
)

account = Account.create!(name: 'InovaChat')
AccountUser.create!(account: account, user: user, role: :administrator)

puts "✅ Admin criado: #{user.email}"
exit
```

---

### 9️⃣ **Acessar**

Abra: `https://crm.fluxer.com.br`

Login:
- **Email:** `admin@inovachat.com`
- **Senha:** `SuaSenhaForte123!`

**Agora deve aparecer "InovaChat" em vez de "Chatwoot"!** 🎉

---

## 🔄 OPÇÃO B: Migrar Dados do Chatwoot Antigo

### 1️⃣ **Backup do Banco Antigo**

```bash
# Fazer dump do banco chatwoot
docker exec $(docker ps -qf "name=pgvector") pg_dump -U postgres chatwoot > backup_chatwoot.sql
```

---

### 2️⃣ **Seguir Passos 1-4 da Opção A**

Até criar o banco `inovachat`.

---

### 3️⃣ **Restaurar Dados**

```bash
# Restaurar no banco inovachat
docker exec -i $(docker ps -qf "name=pgvector") psql -U postgres inovachat < backup_chatwoot.sql
```

---

### 4️⃣ **Atualizar Configurações**

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console:

```ruby
# Atualizar INSTALLATION_NAME nas configs
InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.update(value: 'InovaChat')
InstallationConfig.find_by(name: 'BRAND_NAME')&.update(value: 'InovaChat')

puts "✅ Configurações atualizadas!"
exit
```

---

### 5️⃣ **Rodar Migrations Pendentes**

```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
```

---

### 6️⃣ **Acessar com Usuários Antigos**

Acesse: `https://crm.fluxer.com.br`

Use as **mesmas credenciais** que você usava no Chatwoot antigo!

---

## ✅ Checklist

- [ ] Git pull na VPS
- [ ] Stack `chatwoot` removida
- [ ] Imagem `inovachat:latest` buildada
- [ ] Banco `inovachat` criado
- [ ] Stack `inovachat` deployada
- [ ] Services em 1/1
- [ ] Migrations rodadas
- [ ] Seed/Admin criado (Opção A) ou Dados migrados (Opção B)
- [ ] Acesso em https://crm.fluxer.com.br funcionando
- [ ] Aparece "InovaChat" no título

---

## 🔍 Troubleshooting

### Problema: Services 0/1

```bash
docker service logs inovachat_inovachat_app --tail 100
```

Erros comuns:
- **Database não existe:** Execute o comando CREATE DATABASE
- **Erro ao buildar imagem:** Verifique se o git pull trouxe todos os arquivos
- **Conflito de porta:** Certifique-se que removeu a stack antiga

---

### Problema: Ainda mostra "Chatwoot"

1. Limpe cache do browser: `Ctrl + Shift + R`
2. Verifique variáveis:
```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") env | grep INSTALLATION_NAME
```
Deve retornar: `INSTALLATION_NAME=InovaChat`

---

### Voltar para Chatwoot Antigo (Rollback)

Se der problema, volte:

```bash
docker stack rm inovachat
docker stack deploy -c docker-compose.yaml chatwoot
```

---

## 📊 Resumo dos Nomes

| Item | Antes | Depois |
|------|-------|--------|
| **URL** | `crm.fluxer.com.br` | `crm.fluxer.com.br` ✅ (mesma) |
| **Stack** | `chatwoot` | `inovachat` |
| **Database** | `chatwoot` | `inovachat` |
| **Volumes** | `chatwoot_*` | `inovachat_*` |
| **Services** | `chatwoot_chatwoot_*` | `inovachat_inovachat_*` |
| **Branding** | Chatwoot | **InovaChat** 🎉 |

---

Boa sorte! 🚀
