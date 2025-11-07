# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chatwoot is a modern, open-source customer support platform built with Ruby on Rails (backend) and Vue 3 (frontend). It provides omnichannel support, help center, AI agents, and real-time communication via ActionCable WebSockets.

## Tech Stack

- **Backend**: Ruby 3.4.4, Rails 7.1
- **Frontend**: Vue 3 (Composition API with `<script setup>`), Vite
- **Database**: PostgreSQL with pgvector (for AI embeddings)
- **Cache/Queue**: Redis, Sidekiq (background jobs)
- **Real-time**: ActionCable (WebSockets)
- **Search**: Searchkick with OpenSearch/Elasticsearch
- **Styling**: Tailwind CSS (no custom CSS or scoped styles)
- **Testing**: RSpec (Ruby), Vitest (JavaScript)

## Development Setup

### Initial Setup
```bash
bundle install && pnpm install
```

### Database Setup
```bash
bundle exec rails db:chatwoot_prepare  # Creates, migrates, and seeds
# OR use individual commands:
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

### Running the Application
```bash
# Development (preferred - runs Rails, Sidekiq, Vite):
overmind start -f Procfile.dev
# OR
pnpm dev

# Individual processes:
bin/rails s -p 3000              # Rails server
bundle exec sidekiq -C config/sidekiq.yml  # Background jobs
bin/vite dev                     # Vite dev server
```

### Testing

#### Ruby Tests
```bash
bundle exec rspec                          # All tests
bundle exec rspec spec/models/user_spec.rb # Specific file
bundle exec rspec spec/models/user_spec.rb:42  # Specific line
```

#### JavaScript Tests
```bash
pnpm test           # Run once
pnpm test:watch     # Watch mode
pnpm test:coverage  # With coverage
```

### Linting & Code Quality

#### JavaScript/Vue
```bash
pnpm eslint         # Check
pnpm eslint:fix     # Auto-fix
```

#### Ruby
```bash
bundle exec rubocop -a              # Auto-fix all
bundle exec rubocop app/models/user.rb  # Specific file
```

### Building Assets
```bash
bin/vite build              # Build main app assets
BUILD_MODE=library bin/vite build  # Build SDK only
```

## Architecture

### Backend Architecture

**Models** (`app/models/`)
- Core: `Account`, `User`, `Conversation`, `Message`, `Contact`, `Inbox`
- Channels: `Channel::WebWidget`, `Channel::Email`, `Channel::Whatsapp`, etc.
- Use concerns for shared behavior (e.g., `Assignable`, `Labelable`)

**Controllers** (`app/controllers/`)
- API routes under `Api::V1::Accounts::` namespace (account-scoped)
- Public routes under `Public::`
- Platform routes under `Platform::` (for integrations)

**Services** (`app/services/`)
- Business logic extracted from models/controllers
- Organized by domain: `Contacts::`, `Conversations::`, `Messages::`, etc.
- Pattern: `ServiceName.new(params).perform`

**Jobs** (`app/jobs/`)
- Background processing via Sidekiq
- Scheduled jobs via `sidekiq-cron`
- Inherit from `ApplicationJob`

**Listeners** (`app/listeners/`)
- Event-driven architecture using Wisper gem
- Listen to model events and trigger side effects
- Examples: `NotificationListener`, `WebhookListener`, `AutomationRuleListener`

**Channels** (`app/channels/`)
- ActionCable WebSocket channels
- `RoomChannel` handles real-time updates

### Frontend Architecture

**Structure** (`app/javascript/`)
```
dashboard/       # Main dashboard app (Vue 3)
  components/    # Legacy Vue components (being deprecated - avoid)
  components-next/  # New components with Tailwind (PREFER THESE!)
  routes/        # Vue Router configuration
  store/         # Vuex store modules
  api/           # API client modules
  helper/        # Utility functions
  composables/   # Vue composables for reusable logic
widget/          # Customer-facing chat widget
portal/          # Help center/knowledge base
sdk/             # JavaScript SDK (built separately)
v3/              # New design system components
shared/          # Shared utilities across apps
```

**Key Patterns**:
- Always use Composition API with `<script setup>` at the top
- Use Tailwind utility classes only (no custom CSS, no scoped styles)
- Use i18n for all user-facing strings (no bare strings)
- API calls via axios modules in `dashboard/api/`

**State Management**:
- Vuex 4 for global state
- Module-based organization (`store/modules/`)
- Actions for async operations, mutations for state changes

### Data Flow

1. **Incoming Messages** (example flow):
   - Webhook/Channel → `Messages::CreateService`
   - Service creates `Message` → Triggers Wisper events
   - `AutomationRuleListener` checks rules
   - `NotificationListener` creates notifications
   - `ActionCableListener` broadcasts to WebSocket
   - Frontend receives update via `RoomChannel`

2. **Background Jobs**:
   - Event triggered → Job enqueued to Sidekiq
   - Worker processes job (e.g., `ConversationReplyEmailJob`)
   - Updates sent via ActionCable if needed

## Code Style & Guidelines

### Ruby
- Follow RuboCop rules (150 char line length)
- Use compact `module/class` definitions (no nesting)
- Models: Add validations, associations, indexes
- Use custom exceptions from `lib/custom_exceptions/`
- Strong params in controllers

### Vue/JavaScript
- ESLint (Airbnb + Vue 3)
- PascalCase for components
- camelCase for events
- Use PropTypes/defineProps for type safety

### Styling
- **Tailwind only** - no custom CSS, no scoped styles, no inline styles
- Colors defined in `tailwind.config.js`

### General Principles
- MVP focus: minimal code change, happy path first
- No unnecessary defensive programming
- Remove dead/unused code
- Don't write specs unless explicitly asked
- Don't reference Claude in commit messages
- Pick one approach and implement it (no multiple versions)

## Internationalization (i18n)

- **Backend**: Update `config/locales/en.yml` only
- **Frontend**: Update files in `app/javascript/dashboard/i18n/locale/en/` directory
  - Organized by feature (e.g., `conversation.json`, `inbox.json`, `settings.json`)
- Community handles other languages via Crowdin (https://translate.chatwoot.com)

## Enterprise Edition

Chatwoot has an Enterprise overlay in `enterprise/` that extends/overrides OSS code.

### When Making Changes
1. Search for related files in both trees:
   ```bash
   rg -n "ServiceName|ControllerName" app enterprise
   ```
2. Check if Enterprise needs an override or extension point
3. Use `prepend_mod_with` for extending classes
4. Avoid hardcoding plan-specific logic in OSS
5. Keep API contracts stable across OSS and Enterprise
6. Mirror renames/moves in `enterprise/` directory
7. Add Enterprise specs under `spec/enterprise/`

See: https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38

## Environment Configuration

Key environment variables (see `.env.example`):
- `SECRET_KEY_BASE` - Rails secret (use `rake secret`)
- `ACTIVE_RECORD_ENCRYPTION_*` - Required for MFA/2FA (use `rails db:encryption:init`)
- `FRONTEND_URL` - App URL
- `REDIS_URL` - Redis connection
- `POSTGRES_*` - Database config
- `SMTP_*` - Email configuration
- APM: `DD_TRACE_AGENT_URL`, `ELASTIC_APM_SECRET_TOKEN`, `SENTRY_DSN`, etc.

## Database

- PostgreSQL with extensions: pgvector (AI embeddings)
- Migrations: `bundle exec rails db:migrate`
- Use `hairtrigger` gem for database triggers
- Searchkick for full-text search (requires OpenSearch/Elasticsearch)

## Common Patterns

### Creating a Service
```ruby
# app/services/contacts/create_service.rb
module Contacts
  class CreateService
    def initialize(account:, params:)
      @account = account
      @params = params
    end

    def perform
      contact = @account.contacts.create!(@params)
      # Trigger events for listeners
      contact
    end
  end
end
```

### Creating a Job
```ruby
# app/jobs/contacts/notify_job.rb
class Contacts::NotifyJob < ApplicationJob
  queue_as :default

  def perform(contact_id)
    contact = Contact.find(contact_id)
    # Do work
  end
end
```

### Vue Component (Composition API)
```vue
<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'dashboard/composables/useI18n';

const { t } = useI18n();
const props = defineProps({
  message: { type: Object, required: true }
});

const isActive = ref(false);
</script>

<template>
  <div class="flex items-center p-4 bg-slate-50">
    {{ t('LABEL') }}
  </div>
</template>
```

## Additional Resources

- Main docs: https://www.chatwoot.com/help-center
- Self-hosted config: https://www.chatwoot.com/docs/self-hosted/configuration/environment-variables
- Contributing: https://www.chatwoot.com/docs/contributing
- Translation: https://translate.chatwoot.com

## Branching Model

- Uses git-flow branching model
- Base branch for PRs: Check current repository - may be `develop` or `main`
- Stable releases: `master` branch or `v1.x.x` tags

## Helpful Commands

```bash
# Console
bundle exec rails console

# Database
bundle exec rails db:chatwoot_prepare  # Custom task: setup/migrate DB intelligently
bundle exec rails db:reset            # Reset database
bundle exec rails db:migrate          # Run migrations
bundle exec rails g migration MigrationName  # Generate migration

# Routes
bundle exec rails routes | grep pattern

# Rake tasks
bundle exec rake -T  # List all available tasks

# Asset precompilation (production)
bundle exec rake assets:precompile  # Builds both SDK and app assets

# Sidekiq monitoring
# Visit /sidekiq in browser (requires authentication)

# Captain AI assistant (interactive chat)
bundle exec rake captain:chat[assistant_id]
```
