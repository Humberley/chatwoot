# 🚀 Deploy InovaChat - VERSÃO SIMPLES (SEM BUILD)

## ✅ Esta versão USA A IMAGEM OFICIAL do Chatwoot
**Não precisa buildar nada!** Muda apenas o nome via variável de ambiente.

---

## 📋 O que vai mudar:

✅ Título da aba: **"InovaChat"** (em vez de "Chatwoot")
✅ Emails: **"InovaChat <email>"**
❌ Textos internos ainda vão aparecer "Chatwoot" (limitação da imagem oficial)

---

## 🚀 Passo a Passo

### 1️⃣ **Commit e Push**

```bash
git add .
git commit -m "InovaChat: Versão simples sem build"
git push origin main
```

---

### 2️⃣ **Na VPS: Atualizar e Parar Stack Antiga**

```bash
cd ~/chatwoot
git pull origin main

# Parar stack antiga
docker stack rm chatwoot

# Aguardar parar (1-2 minutos)
watch docker ps
```

Pressione `Ctrl+C` quando não aparecer mais nenhum container do chatwoot.

---

### 3️⃣ **Criar Banco de Dados**

```bash
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres -c "CREATE DATABASE inovachat;"
```

---

### 4️⃣ **Subir Nova Stack**

```bash
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

**⏰ Aguarde 1-2 minutos para os serviços subirem**

---

### 5️⃣ **Verificar Status**

```bash
docker service ls
```

Deve mostrar **1/1** em todos:
```
inovachat_inovachat_app       1/1
inovachat_inovachat_sidekiq   1/1
inovachat_inovachat_redis     1/1
```

Se aparecer **0/1**, veja os logs:

```bash
docker service logs inovachat_inovachat_app --tail 100 --follow
```

**Me envie os logs se continuar crashando!**

---

### 6️⃣ **Inicializar Banco**

Aguarde até o serviço estar **1/1**, depois:

```bash
# Pegar ID do container
docker ps | grep inovachat_app

# Rodar migrations (use o CONTAINER ID que apareceu acima)
docker exec -it <CONTAINER_ID> bundle exec rails db:migrate
docker exec -it <CONTAINER_ID> bundle exec rails db:seed
```

Ou em uma linha (pode demorar 2-3 minutos):

```bash
sleep 60 && docker exec $(docker ps -qf "name=inovachat_inovachat_app") sh -c "bundle exec rails db:migrate && bundle exec rails db:seed"
```

---

### 7️⃣ **Criar Admin**

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console Rails:

```ruby
user = User.create!(
  name: 'Admin',
  email: 'admin@inovachat.com',
  password: 'Senha123!',
  password_confirmation: 'Senha123!'
)

account = Account.create!(name: 'InovaChat')
AccountUser.create!(account: account, user: user, role: :administrator)

puts "✅ Criado: #{user.email}"
exit
```

---

### 8️⃣ **Acessar**

Abra: **`https://crm.fluxer.com.br`**

Login:
- **Email:** admin@inovachat.com
- **Senha:** Senha123!

---

## ✅ Checklist

- [ ] Git pull na VPS
- [ ] Stack `chatwoot` removida
- [ ] Banco `inovachat` criado
- [ ] Stack `inovachat` deployada
- [ ] Services todos em **1/1** (muito importante!)
- [ ] Migrations rodadas
- [ ] Seed executado
- [ ] Admin criado
- [ ] Login funcionando

---

## 🔍 Se continuar crashando (0/1):

Execute e **me envie a saída**:

```bash
docker service logs inovachat_inovachat_app --tail 100
```

---

## 🎯 Diferença desta versão:

| Item | Versão com Build | **Versão Simples** |
|------|------------------|-------------------|
| Imagem | Custom build | **Oficial** ✅ |
| Build | 10 minutos | **Instantâneo** ✅ |
| Estabilidade | Pode crashar | **Estável** ✅ |
| Customização | Total | **Apenas INSTALLATION_NAME** |

**Esta versão é MUITO mais estável!** 🎉

---

Boa sorte! 🚀
