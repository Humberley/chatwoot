# ⚡ Comandos Rápidos - InovaChat

## 🚀 Deploy/Update Básico

```bash
# Na VPS
cd ~/chatwoot
git pull
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
docker service ls
```

---

## 📊 Monitoramento

```bash
# Ver status dos services
docker service ls

# Ver logs
docker service logs inovachat_inovachat_app --tail 50 --follow
docker service logs inovachat_inovachat_sidekiq --tail 50 --follow

# Ver containers rodando
docker ps

# Ver uso de recursos
docker stats
```

---

## 🔄 Restart

```bash
# Restart de um service específico
docker service update --force inovachat_inovachat_app
docker service update --force inovachat_inovachat_sidekiq

# Restart de todos
docker service update --force inovachat_inovachat_app
docker service update --force inovachat_inovachat_sidekiq
docker service update --force inovachat_inovachat_redis
```

---

## 💾 Backup

```bash
# Backup completo do banco
docker exec $(docker ps -qf "name=pgvector") pg_dump -U postgres chatwoot > backup_inovachat_$(date +%Y%m%d_%H%M).sql

# Restaurar backup
docker exec -i $(docker ps -qf "name=pgvector") psql -U postgres chatwoot < backup_inovachat_20251111_1430.sql
```

---

## 🗄️ Database

```bash
# Acessar console Rails
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console

# Rodar migrations
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:migrate

# Seed
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails db:seed

# Acessar PostgreSQL direto
docker exec -it $(docker ps -qf "name=pgvector") psql -U postgres chatwoot
```

---

## 🔍 Debug

```bash
# Entrar no container
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bash

# Ver variáveis de ambiente
docker exec $(docker ps -qf "name=inovachat_inovachat_app") env | grep INSTALLATION_NAME

# Ver erros do Sidekiq
docker service logs inovachat_inovachat_sidekiq --tail 100

# Ver todas as tasks do Sidekiq
docker exec $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
# No console: Sidekiq::Queue.all
```

---

## 🧹 Limpeza

```bash
# Remover imagens antigas
docker image prune -a

# Remover volumes não usados
docker volume prune

# Limpar tudo (CUIDADO!)
docker system prune -a --volumes
```

---

## 🔄 Rollback

```bash
# Voltar para versão anterior (Git)
cd ~/chatwoot
git log --oneline -5  # Ver últimos commits
git checkout <commit-hash>
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat

# Voltar para versão anterior (Stack)
docker stack rm inovachat
# Esperar parar
docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat
```

---

## 📈 Escalar Services

```bash
# Aumentar réplicas
docker service scale inovachat_inovachat_app=2
docker service scale inovachat_inovachat_sidekiq=2

# Voltar para 1
docker service scale inovachat_inovachat_app=1
docker service scale inovachat_inovachat_sidekiq=1
```

---

## 🎯 Atalhos Úteis

```bash
# Alias para facilitar (adicione no ~/.bashrc)
alias inova-logs='docker service logs inovachat_inovachat_app --tail 50 --follow'
alias inova-status='docker service ls | grep inovachat'
alias inova-restart='docker service update --force inovachat_inovachat_app'
alias inova-console='docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console'
alias inova-deploy='cd ~/chatwoot && git pull && docker stack deploy -c docker-compose.inovachat-simples.yaml inovachat'

# Recarregar bashrc
source ~/.bashrc

# Usar
inova-status
inova-logs
inova-deploy
```

---

## 🔑 Criar Novo Admin

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console:

```ruby
user = User.create!(
  name: 'Novo Admin',
  email: 'admin2@inovachat.com',
  password: 'SenhaForte123!',
  password_confirmation: 'SenhaForte123!'
)

# Adicionar a conta existente
account = Account.first  # ou Account.find_by(name: 'InovaChat')
AccountUser.create!(account: account, user: user, role: :administrator)

puts "✅ Admin criado: #{user.email}"
exit
```

---

## 🔧 Atualizar Configuração

```bash
docker exec -it $(docker ps -qf "name=inovachat_inovachat_app") bundle exec rails console
```

No console:

```ruby
# Ver configuração atual
InstallationConfig.find_by(name: 'INSTALLATION_NAME')&.value

# Atualizar
InstallationConfig.find_or_create_by(name: 'INSTALLATION_NAME').update(value: 'Novo Nome')

# Listar todas
InstallationConfig.all.pluck(:name, :value)

exit
```

---

## 🌐 SSL/Certificados

```bash
# Ver certificados do Traefik
docker exec $(docker ps -qf "name=traefik") cat /acme.json | jq

# Forçar renovação (se usar certbot)
certbot renew --force-renewal
```

---

Salve esses comandos! 🚀
