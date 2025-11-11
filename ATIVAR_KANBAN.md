# 📋 Como Ativar o Kanban no InovaChat

## ⚠️ IMPORTANTE: Por que o Kanban não aparece?

O Kanban está **totalmente implementado no código**, mas **NÃO está na imagem Docker oficial** `chatwoot/chatwoot:v4.1.0`.

Para usar o Kanban, você precisa **compilar uma imagem custom** que inclui os novos componentes.

---

## 🎯 Solução: Usar Build Custom

Criamos um `Dockerfile.kanban` e `docker-compose.inovachat-kanban.yaml` que:
- Usa a imagem oficial como base
- Adiciona o código do Kanban
- Compila os assets JavaScript/Vue
- Roda a migração do banco automaticamente

---

## 🚀 Passo a Passo (VPS)

### 1️⃣ **Fazer commit e push** (Windows)

```bash
git add .
git commit -m "Add: Kanban feature with custom build"
git push origin main
```

---

### 2️⃣ **Na VPS: Atualizar código**

```bash
cd ~/chatwoot
git pull origin main
```

---

### 3️⃣ **Parar stack antiga**

```bash
docker stack rm inovachat
```

⏰ Aguarde ~1 minuto até parar completamente:

```bash
watch docker ps
```

Pressione `Ctrl+C` quando não aparecer mais nenhum container do inovachat.

---

### 4️⃣ **Buildar imagem custom**

**⚠️ ATENÇÃO: Esse comando vai demorar ~10-15 minutos!**

Ele vai compilar todos os assets JavaScript/Vue.

```bash
cd ~/chatwoot
docker build -f Dockerfile.kanban -t inovachat-kanban:latest .
```

Você verá várias linhas de build. Aguarde até ver:

```
Successfully built ...
Successfully tagged inovachat-kanban:latest
```

---

### 5️⃣ **Subir nova stack com Kanban**

```bash
docker stack deploy -c docker-compose.inovachat-kanban.yaml inovachat
```

⏰ Aguarde ~2 minutos para os serviços subirem.

---

### 6️⃣ **Verificar status**

```bash
docker service ls
```

Deve mostrar **1/1** em todos:

```
inovachat_inovachat_app       1/1
inovachat_inovachat_sidekiq   1/1
inovachat_inovachat_redis     1/1
```

---

### 7️⃣ **Ver logs (opcional)**

Se quiser acompanhar o que está acontecendo:

```bash
docker service logs inovachat_inovachat_app --tail 50 --follow
```

Pressione `Ctrl+C` para sair dos logs.

---

## 📍 Acessar o Kanban

### **Kanban de Conversas**

1. Acesse `https://crm.fluxer.com.br`
2. Faça login
3. No menu lateral esquerdo: **Conversas > Kanban**

Ou direto: `https://crm.fluxer.com.br/app/accounts/{ACCOUNT_ID}/conversations/kanban`

### **Kanban de Contatos**

1. No menu lateral esquerdo: **Contatos > Kanban**

Ou direto: `https://crm.fluxer.com.br/app/accounts/{ACCOUNT_ID}/contacts/kanban`

---

## 🎯 Como Usar

### **1. Criar primeira coluna**

1. Clique em **"+ Add Column"**
2. Digite o nome (ex: "Novos", "Em Andamento", "Concluídos")
3. Escolha uma cor
4. Salve

### **2. Adicionar cards**

- Arraste conversas/contatos para as colunas
- Cada usuário tem seu próprio board (colunas privadas)

### **3. Reorganizar**

- **Mover cards**: Arraste entre colunas
- **Reordenar colunas**: Arraste o cabeçalho
- **Editar**: Clique nos 3 pontos > Editar
- **Deletar**: Clique nos 3 pontos > Deletar

---

## 🔧 Troubleshooting

### Build falhou

Se o build falhar, veja os logs:

```bash
docker build -f Dockerfile.kanban -t inovachat-kanban:latest . 2>&1 | tee build.log
```

Procure por erros. Comum: falta de memória.

**Solução**: Aumentar memória temporariamente ou buildar localmente.

---

### Services ficam 0/1

```bash
# Ver logs
docker service logs inovachat_inovachat_app --tail 100

# Se for erro de migração, rodar manualmente:
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
```

---

### Kanban não aparece no menu

1. **Limpe cache**: `Ctrl + Shift + R`
2. **Logout e login novamente**
3. **Verifique se build foi feito**: `docker images | grep inovachat-kanban`

Deve aparecer:
```
inovachat-kanban   latest   ...   ...   ...
```

---

### Kanban de Contatos não aparece

Precisa habilitar feature flag CRM:

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console:
```ruby
account = Account.first
account.enable_features('crm')
account.save!
puts "✅ CRM habilitado!"
exit
```

---

## 🔄 Atualizações Futuras

Quando fizer mudanças no código do Kanban:

### **No Windows:**
```bash
git add .
git commit -m "Update: Kanban ..."
git push
```

### **Na VPS:**
```bash
cd ~/chatwoot
git pull

# Re-buildar imagem (necessário!)
docker build -f Dockerfile.kanban -t inovachat-kanban:latest .

# Atualizar stack
docker stack deploy -c docker-compose.inovachat-kanban.yaml inovachat
```

**Sempre rebuilde a imagem quando mudar código!**

---

## ⚡ Comandos Rápidos - Resumo

```bash
# Fluxo completo de ativação
cd ~/chatwoot
git pull
docker stack rm inovachat
sleep 60
docker build -f Dockerfile.kanban -t inovachat-kanban:latest .
docker stack deploy -c docker-compose.inovachat-kanban.yaml inovachat
docker service ls
```

---

## 💡 Alternativa: Versão SEM Kanban

Se quiser voltar para a versão simples (sem Kanban):

```bash
docker stack rm inovachat
sleep 60
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

Usa a imagem oficial (mais estável, mas sem Kanban).

---

## 📊 Diferenças entre as versões

| Item | inovachat-simples.yaml | inovachat-kanban.yaml |
|------|------------------------|----------------------|
| **Imagem** | `chatwoot/chatwoot:v4.1.0` (oficial) | `inovachat-kanban:latest` (custom) |
| **Kanban** | ❌ Não disponível | ✅ Disponível |
| **Build** | Não precisa | Precisa buildar (~15 min) |
| **Estabilidade** | Alta (imagem oficial) | Boa (custom build) |
| **Atualizações** | Só git pull + redeploy | Git pull + rebuild + redeploy |

---

Agora o Kanban deve funcionar! 🎉

Se tiver problemas, mande os logs:
```bash
docker service logs inovachat_inovachat_app --tail 100 > logs.txt
```
