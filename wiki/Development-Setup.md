# Development Setup

This guide will help you set up a development environment for Rails AI.

## 🛠️ Prerequisites

### Required Software

- **Ruby**: 2.7+ (3.x recommended)
- **Rails**: 5.2+ (8.0 recommended)
- **Git**: Latest version
- **Bundler**: Latest version
- **Node.js**: 16+ (for frontend assets)

### Optional Software

- **Docker**: For containerized development
- **Redis**: For caching and background jobs
- **PostgreSQL**: For database operations
- **VS Code**: Recommended editor with extensions

## 🚀 Quick Setup

### 1. Clone the Repository

```bash
# Clone your fork
git clone https://github.com/yourusername/rails_ai.git
cd rails_ai

# Add upstream remote
git remote add upstream https://github.com/original/rails_ai.git
```

### 2. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install Node.js dependencies (if any)
npm install
```

### 3. Run Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/rails_ai_spec.rb
bundle exec rspec spec/performance_spec.rb
```

### 4. Run Linter

```bash
# Check code style
bundle exec standardrb

# Auto-fix issues
bundle exec standardrb --fix
```

## 🔧 Detailed Setup

### Ruby Version Management

#### Using rbenv

```bash
# Install rbenv
brew install rbenv

# Install Ruby
rbenv install 3.2.0
rbenv local 3.2.0

# Verify installation
ruby --version
```

#### Using RVM

```bash
# Install RVM
curl -sSL https://get.rvm.io | bash -s stable

# Install Ruby
rvm install 3.2.0
rvm use 3.2.0

# Verify installation
ruby --version
```

### Rails Version Testing

We test against multiple Rails versions using Appraisal:

```bash
# Install all Rails versions
bundle exec appraisal install

# Run tests against specific Rails version
bundle exec appraisal rails-8.0 rspec
bundle exec appraisal rails-7.1 rspec
bundle exec appraisal rails-6.1 rspec
bundle exec appraisal rails-5.2 rspec

# Run tests against all Rails versions
bundle exec appraisal rspec
```

### Database Setup

#### SQLite (Default)

```bash
# No additional setup needed
# SQLite is included in the gemfile
```

#### PostgreSQL

```bash
# Install PostgreSQL
brew install postgresql

# Start PostgreSQL
brew services start postgresql

# Create database
createdb rails_ai_test
```

#### MySQL

```bash
# Install MySQL
brew install mysql

# Start MySQL
brew services start mysql

# Create database
mysql -u root -e "CREATE DATABASE rails_ai_test;"
```

### Redis Setup (Optional)

```bash
# Install Redis
brew install redis

# Start Redis
brew services start redis

# Test Redis connection
redis-cli ping
```

## 🐳 Docker Development

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
    volumes:
      - .:/app
    environment:
      - RAILS_ENV=development
    depends_on:
      - redis
      - postgres

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: rails_ai_development
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Docker Commands

```bash
# Build and start services
docker-compose up --build

# Run tests
docker-compose exec app bundle exec rspec

# Run linter
docker-compose exec app bundle exec standardrb

# Access Rails console
docker-compose exec app bundle exec rails console
```

## 🔧 IDE Setup

### VS Code Extensions

```json
{
  "recommendations": [
    "rebornix.ruby",
    "castwide.solargraph",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-typescript-next"
  ]
}
```

### VS Code Settings

```json
{
  "ruby.rubocop.executePath": "bundle exec",
  "ruby.rubocop.configFilePath": ".standard.yml",
  "ruby.format": "rubocop",
  "ruby.lint": {
    "rubocop": true
  },
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Solargraph Setup

```bash
# Install Solargraph
gem install solargraph

# Generate documentation
bundle exec yard gems

# Start Solargraph server
bundle exec solargraph socket
```

## 🧪 Testing Setup

### Test Database

```bash
# Create test database
bundle exec rails db:create RAILS_ENV=test

# Run migrations
bundle exec rails db:migrate RAILS_ENV=test

# Seed test data
bundle exec rails db:seed RAILS_ENV=test
```

### Test Configuration

```ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Include Rails helpers
  config.include Rails.application.routes.url_helpers

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Include time helpers
  config.include ActiveSupport::Testing::TimeHelpers
end
```

### Performance Testing

```bash
# Run performance tests
bundle exec rspec spec/performance_spec.rb

# Run with detailed output
bundle exec rspec spec/performance_spec.rb --format documentation

# Run specific performance test
bundle exec rspec spec/performance_spec.rb -e "caching performance"
```

## 🔍 Debugging Setup

### Debugging Tools

```ruby
# Add to Gemfile
group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
end
```

### Debugging Configuration

```ruby
# config/environments/development.rb
Rails.application.configure do
  # Enable debugging
  config.log_level = :debug
  
  # Enable detailed error pages
  config.consider_all_requests_local = true
  
  # Enable caching in development
  config.cache_store = :memory_store
end
```

### Debugging Commands

```ruby
# In Rails console
RailsAi.chat("test") # Basic usage
RailsAi.metrics # Performance metrics
RailsAi.clear_cache! # Clear cache
RailsAi.warmup! # Warmup components
```

## 📊 Performance Monitoring

### Benchmarking

```ruby
# Benchmark specific operations
require 'benchmark'

Benchmark.bm do |x|
  x.report("chat") { RailsAi.chat("test") }
  x.report("image") { RailsAi.generate_image("test") }
  x.report("embed") { RailsAi.embed(["test"]) }
end
```

### Memory Profiling

```ruby
# Profile memory usage
require 'memory_profiler'

report = MemoryProfiler.report do
  RailsAi.chat("test")
end

puts report.pretty_print
```

### CPU Profiling

```ruby
# Profile CPU usage
require 'ruby-prof'

RubyProf.start
RailsAi.chat("test")
result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
```

## 🚀 Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        ruby: [2.7, 3.0, 3.1, 3.2]
        rails: [5.2, 6.0, 6.1, 7.0, 7.1, 8.0]
    
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
      - run: bundle install
      - run: bundle exec rspec
      - run: bundle exec standardrb
```

### Local CI

```bash
# Run full test suite
bundle exec appraisal rspec

# Run linter
bundle exec standardrb

# Run security audit
bundle audit

# Run performance tests
bundle exec rspec spec/performance_spec.rb
```

## 🔧 Troubleshooting

### Common Issues

#### Bundle Install Fails

```bash
# Clear bundle cache
bundle clean --force

# Reinstall gems
bundle install --redownload
```

#### Tests Fail

```bash
# Check test database
bundle exec rails db:test:prepare

# Clear test cache
bundle exec rails tmp:clear

# Run tests with verbose output
bundle exec rspec --format documentation
```

#### Linter Fails

```bash
# Auto-fix issues
bundle exec standardrb --fix

# Check specific files
bundle exec standardrb lib/rails_ai.rb
```

#### Performance Issues

```bash
# Clear cache
bundle exec rails tmp:clear

# Reset performance metrics
RailsAi.reset_performance_metrics!

# Check memory usage
bundle exec rspec spec/performance_spec.rb
```

## 📚 Additional Resources

- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Style Guide](https://rails.rubystyle.guide/)
- [RSpec Best Practices](https://rspec.info/documentation/)
- [StandardRB Documentation](https://github.com/standardrb/standardrb)
- [Appraisal Documentation](https://github.com/thoughtbot/appraisal)

---

Happy coding! 🚀
