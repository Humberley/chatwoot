# 🚀 Deploy InovaChat na VPS (INSTALAÇÃO NOVA - SEM PERDER CHATWOOT ANTIGO)

## ⚠️ IMPORTANTE
Esta instalação vai rodar **EM PARALELO** com sua instalação antiga do Chatwoot.

---

## 📋 Pré-requisitos

1. **Domínio novo**: Configure `inovachat.fluxer.com.br` no seu DNS apontando para a VPS
2. **Banco de dados**: Criará automaticamente banco `inovachat` (separado do `chatwoot`)
3. **Volumes novos**: Criará volumes `inovachat_*` (separados dos `chatwoot_*`)

---

## 🚀 Passo a Passo

### 1️⃣ **Fazer Commit e Push** (no Windows)

```bash
git add .
git commit -m "InovaChat: Instalação independente do Chatwoot"
git push origin main
```

---

### 2️⃣ **Na VPS: Atualizar código**

```bash
cd ~/chatwoot
git pull origin main
```

---

### 3️⃣ **Buildar a imagem InovaChat**

```bash
docker build -f Dockerfile.custom -t inovachat:latest .
```

**⏱️ Isso pode levar 5-10 minutos. Aguarde até ver:** `Successfully tagged inovachat:latest`

---

### 4️⃣ **Criar banco de dados InovaChat**

O banco PostgreSQL já existe (`pgvector`), mas vamos criar o database `inovachat`:

```bash
# Conectar ao postgres
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres

# Dentro do psql:
CREATE DATABASE inovachat;
\q
```

Ou em uma linha:

```bash
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres -c "CREATE DATABASE inovachat;"
```

---

### 5️⃣ **Deploy da Stack InovaChat**

```bash
docker stack deploy -c docker-compose.inovachat.yaml inovachat
```

**Atenção ao nome:** `inovachat` (não `chatwoot` nem `chatwoott`)

---

### 6️⃣ **Verificar se os serviços subiram**

```bash
docker service ls
```

Você deve ver:
- `inovachat_inovachat_app` (1/1)
- `inovachat_inovachat_sidekiq` (1/1)
- `inovachat_inovachat_redis` (1/1)

Se aparecer **0/1**, veja os logs:

```bash
docker service logs inovachat_inovachat_app --tail 50
```

---

### 7️⃣ **Configurar DNS**

Configure no seu provedor de DNS:

```
Tipo: A
Nome: inovachat.fluxer.com.br
Valor: IP_DA_SUA_VPS
```

**Aguarde 5-10 minutos** para propagar.

---

### 8️⃣ **Inicializar banco de dados**

```bash
# Pegar o ID do container
docker ps | grep inovachat_app

# Rodar migrations
docker exec -it <CONTAINER_ID> bundle exec rails db:migrate

# Seed (configurações iniciais)
docker exec -it <CONTAINER_ID> bundle exec rails db:seed
```

Ou de uma vez:

```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") sh -c "bundle exec rails db:migrate && bundle exec rails db:seed"
```

---

### 9️⃣ **Criar primeiro usuário Admin**

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

Dentro do console Rails:

```ruby
user = User.create!(
  name: 'Admin',
  email: 'admin@inovachat.com',
  password: 'SuaSenhaForte123!',
  password_confirmation: 'SuaSenhaForte123!'
)

account = Account.create!(name: 'InovaChat')
AccountUser.create!(account: account, user: user, role: :administrator)

puts "✅ Usuário criado: #{user.email}"
exit
```

---

### 🔟 **Acessar o InovaChat**

Abra no navegador:

```
https://inovachat.fluxer.com.br
```

Login:
- **Email:** `admin@inovachat.com`
- **Senha:** `SuaSenhaForte123!`

---

## ✅ Checklist Final

- [ ] Código commitado e pushed
- [ ] Git pull feito na VPS
- [ ] Imagem `inovachat:latest` buildada
- [ ] Banco `inovachat` criado
- [ ] Stack `inovachat` deployada
- [ ] Serviços com status 1/1
- [ ] DNS configurado
- [ ] Migrations rodadas
- [ ] Seed executado
- [ ] Usuário admin criado
- [ ] Login funcionando em https://inovachat.fluxer.com.br

---

## 🔍 Troubleshooting

### Problema: Serviços com 0/1

```bash
docker service logs inovachat_inovachat_app --tail 100
```

Me envie os logs para análise.

---

### Problema: "Database inovachat does not exist"

```bash
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres -c "CREATE DATABASE inovachat;"
```

---

### Problema: Traefik não roteia para InovaChat

Verifique se o domínio está configurado:

```bash
docker service inspect inovachat_inovachat_app --format '{{json .Spec.Labels}}' | jq
```

Deve mostrar: `"traefik.http.routers.inovachat_app.rule": "Host(\`inovachat.fluxer.com.br\`)"`

---

### Problema: 502 Bad Gateway

O container pode estar demorando para iniciar. Aguarde 2-3 minutos e tente novamente.

---

## 📊 Comparação

| Item | Chatwoot Antigo | InovaChat Novo |
|------|----------------|----------------|
| **Domínio** | `crm.fluxer.com.br` | `inovachat.fluxer.com.br` |
| **Stack** | `chatwoot` | `inovachat` |
| **Database** | `chatwoot` | `inovachat` |
| **Volumes** | `chatwoot_*` | `inovachat_*` |
| **Services** | `chatwoot_chatwoot_*` | `inovachat_inovachat_*` |
| **Redis** | `chatwoot_redis` | `inovachat_redis` |

**As duas instalações rodam lado a lado sem conflitos!** 🎉

---

Boa sorte! 🚀
