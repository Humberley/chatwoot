# 🚀 Deploy InovaChat na VPS

## Passo a Passo para Instalar o InovaChat Customizado

### 1️⃣ **Fazer Commit e Push das Mudanças**

No seu computador local (Windows):

```bash
git add .
git commit -m "Rebrand: Chatwoot -> InovaChat"
git push origin main
```

---

### 2️⃣ **Atualizar Código na VPS**

Conecte-se na sua VPS e vá até o diretório do projeto:

```bash
cd /caminho/do/projeto/chatwoot
git pull origin main
```

---

### 3️⃣ **Buildar a Imagem Customizada**

**OPÇÃO A: Docker Compose (se estiver usando `docker-compose`)**

```bash
docker-compose -f docker-compose.inovachat.yaml build
```

**OPÇÃO B: Docker Swarm (se estiver usando `docker stack`)**

```bash
# Primeiro, build a imagem manualmente
docker build -f Dockerfile.custom -t inovachat:latest .

# Depois, fazer deploy da stack
docker stack deploy -c docker-compose.inovachat.yaml chatwoot
```

---

### 4️⃣ **Parar Stack Antiga (se necessário)**

Se você já tem uma stack rodando com o nome "chatwoot":

```bash
docker stack rm chatwoot

# Aguarde todos os containers pararem (pode levar ~1 minuto)
docker ps -a
```

---

### 5️⃣ **Subir a Nova Stack com InovaChat**

```bash
docker stack deploy -c docker-compose.inovachat.yaml chatwoot
```

Ou se estiver usando `docker-compose`:

```bash
docker-compose -f docker-compose.inovachat.yaml up -d
```

---

### 6️⃣ **Verificar se os Containers Estão Rodando**

```bash
docker service ls
# Ou
docker ps
```

Você deve ver:
- `chatwoot_chatwoot_app`
- `chatwoot_chatwoot_sidekiq`
- `chatwoot_chatwoot_redis`

---

### 7️⃣ **Resetar Configurações do Banco de Dados** (IMPORTANTE!)

Para que as mudanças de `INSTALLATION_NAME` e `BRAND_NAME` apareçam, execute:

```bash
# Opção 1: Seed do banco (mais rápido)
docker exec -it $(docker ps -qf "name=chatwoot_app") bundle exec rails db:seed

# Opção 2: Reset completo (CUIDADO! Apaga dados)
# docker exec -it $(docker ps -qf "name=chatwoot_app") bundle exec rails db:reset
```

**⚠️ ATENÇÃO:** O comando `db:reset` apaga TODOS OS DADOS! Use apenas se for uma instalação nova.

Se já tem dados, use apenas `db:seed` ou faça backup antes.

---

### 8️⃣ **Verificar Logs**

```bash
# Ver logs da aplicação
docker service logs chatwoot_chatwoot_app -f

# Ou com docker-compose
docker-compose -f docker-compose.inovachat.yaml logs -f chatwoot_app
```

---

### 9️⃣ **Acessar no Navegador**

Abra: `https://crm.fluxer.com.br`

Você deverá ver:
- ✅ Título da página: "InovaChat"
- ✅ Login: "Login to InovaChat"
- ✅ Widget: "Powered by InovaChat"

---

## 🔥 Troubleshooting

### Problema: Ainda aparece "Chatwoot"

**Solução 1:** Limpar cache do navegador (Ctrl + Shift + R)

**Solução 2:** Verificar variáveis de ambiente:

```bash
docker exec -it $(docker ps -qf "name=chatwoot_app") env | grep INSTALLATION_NAME
```

Deve retornar: `INSTALLATION_NAME=InovaChat`

**Solução 3:** Entrar no container e verificar arquivos:

```bash
docker exec -it $(docker ps -qf "name=chatwoot_app") bash
cat config/installation_config.yml | grep INSTALLATION_NAME
```

---

### Problema: Erro ao buildar imagem

**Solução:** Verificar se todos os arquivos foram copiados:

```bash
git status
git log --oneline -5
```

Se faltaram arquivos, adicione e commite novamente.

---

## 📌 Resumo dos Comandos

```bash
# Na VPS
cd /caminho/do/projeto
git pull
docker build -f Dockerfile.custom -t inovachat:latest .
docker stack rm chatwoot
docker stack deploy -c docker-compose.inovachat.yaml chatwoot
docker service logs chatwoot_chatwoot_app -f
```

---

## 🎯 Checklist Final

- [ ] Git pull feito na VPS
- [ ] Imagem `inovachat:latest` buildada com sucesso
- [ ] Stack antiga removida
- [ ] Nova stack deployada
- [ ] Containers rodando (verificar com `docker ps`)
- [ ] Seed do banco executado
- [ ] Browser acessando https://crm.fluxer.com.br
- [ ] Cache do browser limpo (Ctrl + Shift + R)
- [ ] Título mostra "InovaChat"

---

Boa sorte! 🚀
