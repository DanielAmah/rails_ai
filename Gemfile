# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in rails_ai.gemspec
gemspec

# Test against multiple Rails versions
gem "appraisal", "~> 2.4", group: :development

# Development dependencies
group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "sqlite3", "~> 1.4"
  gem "puma", "~> 5.0"
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "standard", "~> 1.0", require: false
end
