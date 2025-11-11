#!/usr/bin/env ruby
# Script para atualizar configurações do Chatwoot para InovaChat
# Execute dentro do container Rails: bundle exec rails runner atualizar_configs.rb

puts "🔄 Atualizando configurações de Chatwoot para InovaChat..."

# Atualizar INSTALLATION_NAME
config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_NAME')
config.value = 'InovaChat'
config.save!
puts "✅ INSTALLATION_NAME = InovaChat"

# Atualizar BRAND_NAME
config = InstallationConfig.find_or_initialize_by(name: 'BRAND_NAME')
config.value = 'InovaChat'
config.save!
puts "✅ BRAND_NAME = InovaChat"

# Atualizar BRAND_URL (opcional)
config = InstallationConfig.find_or_initialize_by(name: 'BRAND_URL')
config.value = 'https://www.inovachat.com'
config.save!
puts "✅ BRAND_URL = https://www.inovachat.com"

# Atualizar WIDGET_BRAND_URL (opcional)
config = InstallationConfig.find_or_initialize_by(name: 'WIDGET_BRAND_URL')
config.value = 'https://www.inovachat.com'
config.save!
puts "✅ WIDGET_BRAND_URL = https://www.inovachat.com"

puts ""
puts "🎉 Configurações atualizadas com sucesso!"
puts ""
puts "Agora faça:"
puts "1. Restart da stack: docker service update --force inovachat_inovachat_app"
puts "2. Limpe o cache do navegador (Ctrl + Shift + R)"
puts "3. Acesse: https://crm.fluxer.com.br"
