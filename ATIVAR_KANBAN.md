# 📋 Como Ativar o Kanban no InovaChat

O Kanban está totalmente implementado no código, mas precisa de alguns passos para ativar.

---

## ✅ O que já está pronto:

- ✅ Backend completo (model, controller, API, policies)
- ✅ Frontend completo (componentes Vue, rotas, store Vuex)
- ✅ Navegação no menu (Conversas > Kanban e Contatos > Kanban)
- ✅ Migração do banco de dados criada
- ✅ Associações nos models Account e User

---

## 🚀 Como Ativar (na VPS)

### 1️⃣ **Fazer commit e push** (Windows)

```bash
git add .
git commit -m "Fix: Add Kanban associations and enable feature"
git push origin main
```

---

### 2️⃣ **Atualizar código na VPS**

```bash
cd ~/chatwoot
git pull origin main
```

---

### 3️⃣ **Rodar migração do banco**

Esta é a parte CRÍTICA - cria a tabela `kanban_columns`:

```bash
# Rodar migration dentro do container
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
```

Deve mostrar algo como:
```
== 20251104150000 CreateKanbanColumns: migrating ===============================
-- create_table(:kanban_columns)
   -> 0.0234s
== 20251104150000 CreateKanbanColumns: migrated (0.0235s) ======================
```

---

### 4️⃣ **Restart dos serviços**

```bash
docker service update --force inovachat_inovachat_app
docker service update --force inovachat_inovachat_sidekiq
```

⏰ Aguarde ~30 segundos.

---

### 5️⃣ **Verificar Status**

```bash
docker service ls
```

Deve mostrar **1/1** em todos.

---

## 📍 Como Acessar o Kanban

### **Kanban de Conversas**

1. Faça login em `https://crm.fluxer.com.br`
2. No menu lateral esquerdo, clique em **"Conversas"**
3. Você verá uma opção **"Kanban"** no submenu
4. Ou acesse direto: `https://crm.fluxer.com.br/app/accounts/{ACCOUNT_ID}/conversations/kanban`

### **Kanban de Contatos**

1. No menu lateral esquerdo, clique em **"Contatos"**
2. Você verá uma opção **"Kanban"** no submenu
3. Ou acesse direto: `https://crm.fluxer.com.br/app/accounts/{ACCOUNT_ID}/contacts/kanban`

---

## 🎯 Como Usar

### **Criar Primeira Coluna**

1. Acesse o Kanban
2. Clique no botão **"+ Add Column"**
3. Digite o nome da coluna (ex: "Novos", "Em Andamento", "Concluídos")
4. Escolha uma cor
5. Salve

### **Adicionar Cards (Conversas/Contatos)**

1. Arraste uma conversa ou contato para a coluna
2. Ou clique no card e selecione a coluna

### **Reorganizar**

- **Mover cards**: Arraste entre colunas
- **Reordenar colunas**: Arraste o cabeçalho da coluna
- **Editar coluna**: Clique nos 3 pontos > Editar
- **Deletar coluna**: Clique nos 3 pontos > Deletar

---

## 🔍 Verificar se Migração foi Aplicada

Se quiser confirmar que a tabela foi criada:

```bash
# Acessar PostgreSQL
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres chatwoot
```

No psql:
```sql
\d kanban_columns
```

Deve mostrar a estrutura da tabela. Digite `\q` para sair.

---

## 🔧 Troubleshooting

### Kanban não aparece no menu

1. **Limpe cache do navegador**: `Ctrl + Shift + R`
2. **Faça logout e login novamente**
3. **Verifique permissões**: Usuário precisa ter role de Agent ou Administrator

---

### Erro ao criar coluna

```bash
# Ver logs
docker service logs inovachat_inovachat_app --tail 50 --follow
```

Procure por erros relacionados a `kanban_columns` ou `PG::UndefinedTable`.

Se ver `PG::UndefinedTable: ERROR: relation "kanban_columns" does not exist`, significa que a migração não foi rodada.

**Solução**: Rode novamente o comando de migração:
```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
```

---

### Kanban de Contatos não aparece

O Kanban de Contatos requer a **feature flag CRM** habilitada.

Para verificar/habilitar:

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console:
```ruby
# Ver features habilitadas
account = Account.first
puts account.feature_flags

# Habilitar CRM (se necessário)
account.enable_features('crm')
account.save!

puts "✅ CRM habilitado!"
exit
```

---

## 📊 O que o Kanban faz?

### **Kanban de Conversas**
- Visualize conversas em colunas personalizadas
- Organize por status (Novos, Em Andamento, Resolvidos, etc.)
- Arraste para mudar status
- Cada usuário tem seu próprio board (colunas privadas)

### **Kanban de Contatos**
- Visualize contatos em pipeline
- Organize por estágio (Lead, Qualificado, Cliente, etc.)
- Arraste para avançar no funil
- Cada usuário tem seu próprio board

### **Armazenamento**
Os dados são salvos em:
- Tabela `kanban_columns` - definição das colunas
- Campo `custom_attributes` dos contatos/conversas - qual coluna o item está e posição

---

## 🎨 Personalização

Você pode customizar:
- **Nome das colunas**: Ex: "Novos Leads", "Follow-up", "Fechados"
- **Cores**: 8 cores disponíveis
- **Filtros** (em breve): Filtrar cards por critérios

---

## ⚡ Comandos Rápidos

```bash
# Atualizar e ativar Kanban
cd ~/chatwoot
git pull
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate
docker service update --force inovachat_inovachat_app
```

---

Pronto! O Kanban deve estar funcionando! 🎉
