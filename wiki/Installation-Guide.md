# Installation Guide

Complete guide for installing and setting up Rails AI in your Rails application.

## 📋 Prerequisites

### System Requirements

- **Ruby**: 2.7+ (3.x recommended)
- **Rails**: 5.2+ (8.0 recommended)
- **Bundler**: Latest version
- **Git**: For version control

### Optional Dependencies

- **Redis**: For advanced caching (recommended for production)
- **PostgreSQL/MySQL**: For database operations
- **Node.js**: For frontend assets (if using view components)

## 🚀 Quick Installation

### 1. Add to Gemfile

```ruby
# Gemfile
gem 'rails_ai'
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Run Generator

```bash
rails generate rails_ai:install
```

### 4. Configure

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai
  config.api_key = ENV['OPENAI_API_KEY']
  config.cache_ttl = 1.hour
end
```

### 5. Set Environment Variables

```bash
# .env
OPENAI_API_KEY=your_openai_api_key_here
```

## 🔧 Detailed Installation

### Step 1: Add Gem to Gemfile

```ruby
# Gemfile
gem 'rails_ai'

# Optional: Add specific version
gem 'rails_ai', '~> 0.1.0'

# Optional: Add from GitHub
gem 'rails_ai', git: 'https://github.com/yourusername/rails_ai.git'
```

### Step 2: Install Dependencies

```bash
# Install gems
bundle install

# Verify installation
bundle list | grep rails_ai
```

### Step 3: Run Installation Generator

```bash
# Run the installer
rails generate rails_ai:install

# This creates:
# - config/initializers/rails_ai.rb
# - app/controllers/concerns/ai/
# - app/helpers/ai_helper.rb
# - app/views/ai/
```

### Step 4: Configure Rails AI

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  # Provider configuration
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  
  # API configuration
  config.api_key = ENV['OPENAI_API_KEY']
  
  # Caching configuration
  config.cache_ttl = 1.hour
  config.enable_compression = true
  
  # Performance configuration
  config.connection_pool_size = 10
  config.enable_performance_monitoring = true
  
  # Development configuration
  config.stub_responses = Rails.env.development?
end
```

### Step 5: Set Environment Variables

```bash
# .env (for development)
OPENAI_API_KEY=your_openai_api_key_here

# .env.production (for production)
OPENAI_API_KEY=your_production_api_key_here
```

### Step 6: Configure Caching (Optional)

#### Redis (Recommended)

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    namespace: 'rails_ai'
  }
end
```

#### Memory Store (Development)

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.cache_store = :memory_store
end
```

## 🎯 Rails Version Specific Setup

### Rails 8.0

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Rails 8.0 specific configuration
    config.load_defaults 8.0
    
    # Enable Rails AI
    config.rails_ai.enabled = true
  end
end
```

### Rails 7.x

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Rails 7.x specific configuration
    config.load_defaults 7.0
    
    # Enable Rails AI
    config.rails_ai.enabled = true
  end
end
```

### Rails 6.x

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Rails 6.x specific configuration
    config.load_defaults 6.0
    
    # Enable Rails AI
    config.rails_ai.enabled = true
  end
end
```

### Rails 5.2

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Rails 5.2 specific configuration
    config.load_defaults 5.2
    
    # Enable Rails AI
    config.rails_ai.enabled = true
  end
end
```

## 🔐 API Key Setup

### OpenAI

1. **Get API Key**
   - Visit [OpenAI Platform](https://platform.openai.com/)
   - Create account or sign in
   - Go to API Keys section
   - Create new secret key

2. **Set Environment Variable**
   ```bash
   export OPENAI_API_KEY=your_api_key_here
   ```

3. **Verify Setup**
   ```ruby
   # rails console
   RailsAi.chat("Hello")
   ```

### Anthropic (Future)

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :anthropic
  config.api_key = ENV['ANTHROPIC_API_KEY']
end
```

### Custom Provider

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :custom
  config.api_key = ENV['CUSTOM_API_KEY']
  config.api_url = ENV['CUSTOM_API_URL']
end
```

## 🧪 Testing Setup

### RSpec

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  # Include Rails AI helpers
  config.include RailsAi::TestHelpers
  
  # Configure for testing
  config.before(:each) do
    RailsAi.configure do |ai_config|
      ai_config.provider = :dummy
      ai_config.stub_responses = true
    end
  end
end
```

### Test Configuration

```ruby
# spec/support/rails_ai.rb
RSpec.configure do |config|
  config.before(:suite) do
    RailsAi.configure do |ai_config|
      ai_config.provider = :dummy
      ai_config.stub_responses = true
      ai_config.cache_ttl = 1.minute
    end
  end
end
```

## �� Production Setup

### Environment Variables

```bash
# .env.production
OPENAI_API_KEY=your_production_api_key
REDIS_URL=redis://your-redis-server:6379
RAILS_AI_CACHE_TTL=3600
RAILS_AI_CONNECTION_POOL_SIZE=20
```

### Production Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Rails AI production configuration
  config.rails_ai.cache_ttl = 24.hours
  config.rails_ai.connection_pool_size = 20
  config.rails_ai.enable_compression = true
  config.rails_ai.enable_performance_monitoring = true
end
```

### Caching Setup

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Redis caching for production
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    namespace: 'rails_ai',
    expires_in: 24.hours
  }
end
```

## 🔧 Advanced Configuration

### Custom Models

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.default_model = "gpt-4o-mini"
  
  # Custom models for different operations
  config.models = {
    chat: "gpt-4o-mini",
    image: "dall-e-3",
    video: "sora",
    audio: "tts-1",
    embedding: "text-embedding-3-small"
  }
end
```

### Rate Limiting

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.rate_limiting = {
    enabled: true,
    requests_per_minute: 60,
    requests_per_hour: 1000
  }
end
```

### Content Filtering

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.content_filtering = {
    enabled: true,
    redact_emails: true,
    redact_phones: true,
    redact_ssn: true
  }
end
```

## 🐳 Docker Setup

### Dockerfile

```dockerfile
FROM ruby:3.2.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm

# Set working directory
WORKDIR /app

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

## 🔍 Verification

### Test Installation

```ruby
# rails console
RailsAi.chat("Hello, world!")
# => "Hello! How can I help you today?"

RailsAi.generate_image("A beautiful sunset")
# => "data:image/png;base64,..."

RailsAi.metrics
# => { chat: { count: 1, total_duration: 0.5, ... } }
```

### Check Configuration

```ruby
# rails console
RailsAi.config.provider
# => :openai

RailsAi.config.default_model
# => "gpt-4o-mini"

RailsAi.config.cache_ttl
# => 3600
```

## 🚨 Troubleshooting

### Common Issues

#### 1. API Key Not Set

```bash
# Error: API key not found
# Solution: Set environment variable
export OPENAI_API_KEY=your_api_key_here
```

#### 2. Gem Not Found

```bash
# Error: Could not find gem 'rails_ai'
# Solution: Run bundle install
bundle install
```

#### 3. Configuration Not Loaded

```ruby
# Error: Configuration not found
# Solution: Check initializer file
# config/initializers/rails_ai.rb should exist
```

#### 4. Cache Not Working

```ruby
# Error: Cache not working
# Solution: Check cache store configuration
Rails.cache.class
# Should return a cache store class
```

### Debug Mode

```ruby
# Enable debug logging
Rails.logger.level = :debug

# Check Rails AI configuration
RailsAi.config.inspect

# Check provider
RailsAi.provider.class
```

## 📚 Next Steps

After installation, check out these guides:

- [Quick Start](Quick-Start.md) - Get up and running quickly
- [Basic Usage](Basic-Usage.md) - Learn the basics
- [Configuration](Configuration.md) - Advanced configuration
- [API Documentation](API-Documentation.md) - Complete API reference

---

**Rails AI is now installed and ready to use!** 🚀
