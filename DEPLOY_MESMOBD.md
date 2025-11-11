# 🔄 Migrar Chatwoot para InovaChat (MESMO BANCO DE DADOS)

## ✅ Mantém TODOS os dados:
- ✅ Conversas
- ✅ Contatos
- ✅ Usuários (mesmos logins)
- ✅ Configurações
- ✅ Histórico completo

**Apenas muda o nome de "Chatwoot" para "InovaChat"!**

---

## ⚠️ IMPORTANTE
**NÃO pode ter duas stacks rodando ao mesmo tempo no mesmo banco!**

---

## 🚀 Passo a Passo

### 1️⃣ **Commit e Push** (Windows)

```bash
git add .
git commit -m "InovaChat: Usar mesmo banco do Chatwoot"
git push origin main
```

---

### 2️⃣ **Na VPS: Atualizar Código**

```bash
cd ~/chatwoot
git pull origin main
```

---

### 3️⃣ **Parar Stack Antiga (Chatwoot)**

```bash
docker stack rm chatwoot
```

**⏰ Aguarde 1-2 minutos** até todos os containers pararem:

```bash
watch docker ps
```

Pressione `Ctrl+C` quando não aparecer mais nenhum container do chatwoot.

---

### 4️⃣ **Subir Nova Stack (InovaChat)**

```bash
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

**⏰ Aguarde 1-2 minutos** para os serviços subirem.

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

Se aparecer **0/1**, veja logs:

```bash
docker service logs inovachat_inovachat_app --tail 50 --follow
```

---

### 6️⃣ **Atualizar Configurações do Banco**

**Opção A: Usar o script Ruby** (recomendado)

```bash
# Copiar script para o container
docker cp atualizar_configs.rb $(docker ps -qf "name=inovachat_inovachat_app"):/app/

# Executar o script
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails runner atualizar_configs.rb
```

---

**Opção B: Manualmente via console Rails**

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console Rails:

```ruby
# Atualizar configurações
InstallationConfig.find_or_create_by(name: 'INSTALLATION_NAME').update(value: 'InovaChat')
InstallationConfig.find_or_create_by(name: 'BRAND_NAME').update(value: 'InovaChat')
InstallationConfig.find_or_create_by(name: 'BRAND_URL').update(value: 'https://www.inovachat.com')
InstallationConfig.find_or_create_by(name: 'WIDGET_BRAND_URL').update(value: 'https://www.inovachat.com')

puts "✅ Configurações atualizadas!"
exit
```

---

### 7️⃣ **Forçar Restart dos Serviços**

Para aplicar as novas configurações:

```bash
docker service update --force inovachat_inovachat_app
docker service update --force inovachat_inovachat_sidekiq
```

**⏰ Aguarde 1 minuto** para os serviços reiniciarem.

---

### 8️⃣ **Acessar e Testar**

Abra: **`https://crm.fluxer.com.br`**

**Use seus logins ANTIGOS do Chatwoot!**

Limpe o cache do navegador: `Ctrl + Shift + R`

---

## ✅ Checklist

- [ ] Git pull na VPS
- [ ] Stack `chatwoot` removida (PARADA!)
- [ ] Stack `inovachat` deployada
- [ ] Services todos em **1/1**
- [ ] Script de atualização executado
- [ ] Services reiniciados (force update)
- [ ] Login com credenciais antigas funcionando
- [ ] Título mostra "InovaChat" em vez de "Chatwoot"

---

## 🔍 Troubleshooting

### Ainda aparece "Chatwoot"

1. **Limpe cache do navegador:** `Ctrl + Shift + R`

2. **Verifique as configs:**
```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

```ruby
InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.value
# Deve retornar: "InovaChat"
exit
```

3. **Force restart:**
```bash
docker service update --force inovachat_inovachat_app
```

---

### Serviços 0/1 (crashando)

```bash
docker service logs inovachat_inovachat_app --tail 100
```

Me envie os logs para análise.

---

### Erro de conexão com banco

Verifique se o container `pgvector` está rodando:

```bash
docker ps | grep pgvector
```

Se não estiver, suba ele primeiro.

---

## 🎯 Vantagens desta abordagem:

✅ **Zero perda de dados** - usa o banco existente
✅ **Mesmos logins** - não precisa criar usuários novos
✅ **Todas as conversas preservadas**
✅ **Configurações mantidas**
✅ **Rápido** - não precisa migrar dados

---

## 🔄 Voltar para Chatwoot (Rollback)

Se quiser voltar:

```bash
docker stack rm inovachat
docker stack deploy -c docker-compose.yaml chatwoot
```

---

## 📊 Resumo

| Item | Antes | Depois |
|------|-------|--------|
| **URL** | `crm.fluxer.com.br` | `crm.fluxer.com.br` ✅ (mesma) |
| **Stack** | `chatwoot` | `inovachat` |
| **Database** | `chatwoot` | `chatwoot` ✅ (mesmo!) |
| **Dados** | Todos os dados | **Preservados** ✅ |
| **Logins** | Usuários existentes | **Funcionam** ✅ |
| **Branding** | Chatwoot | **InovaChat** 🎉 |

---

Boa sorte! 🚀
