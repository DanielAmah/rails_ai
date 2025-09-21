# Rails AI - Complete Structure

This Rails AI gem is designed to be a comprehensive AI toolkit that's deeply integrated into Rails applications, supporting Rails 5.2+ through Rails 8 with Ruby 3.x compatibility.

## Directory Structure

```
rails_ai/
├─ README.md                    # Comprehensive documentation
├─ rails_ai.gemspec            # Gem specification with Rails 5.2-8.0 support
├─ Gemfile                     # Development dependencies
├─ Rakefile                    # Rake tasks for testing and linting
├─ LICENSE                     # MIT License
├─ .gitignore                  # Git ignore patterns
├─ Appraisals                  # Multi-Rails version testing
├─ lib/
│ ├─ rails_ai.rb              # Main module with version compatibility
│ ├─ rails_ai/
│ │ ├─ version.rb             # Version constant
│ │ ├─ config.rb              # Configuration with Struct
│ │ ├─ context.rb             # CurrentAttributes for context
│ │ ├─ cache.rb               # Intelligent caching
│ │ ├─ redactor.rb            # Content redaction for security
│ │ ├─ events.rb              # Event logging and metrics
│ │ ├─ provider.rb            # Provider base classes
│ │ ├─ engine.rb              # Rails engine with version compatibility
│ │ ├─ railtie.rb             # Railtie with version-specific configs
│ │ └─ providers/
│ │   ├─ base.rb              # Base provider interface
│ │   ├─ openai_adapter.rb    # OpenAI integration
│ │   └─ dummy_adapter.rb     # Dummy provider for testing
│ └─ generators/
│   └─ rails_ai/
│     ├─ install/
│     │ ├─ install_generator.rb
│     │ └─ templates/         # Generator templates
│     └─ feature/
│       ├─ feature_generator.rb
│       └─ templates/         # Feature templates
├─ app/
│ ├─ channels/
│ │ └─ ai_stream_channel.rb   # Action Cable streaming
│ ├─ components/
│ │ └─ ai/
│ │   └─ prompt_component.rb  # ViewComponent for AI UI
│ ├─ controllers/
│ │ └─ concerns/ai/
│ │   └─ streaming.rb         # Streaming controller concern
│ ├─ helpers/
│ │ └─ ai_helper.rb           # AI helper methods
│ ├─ jobs/
│ │ └─ ai/
│ │   ├─ generate_embedding_job.rb
│ │   └─ generate_summary_job.rb
│ ├─ models/
│ │ └─ concerns/ai/
│ │   └─ embeddable.rb        # Model concern for embeddings
│ └─ views/
│   └─ rails_ai/
│     └─ dashboard/
│       └─ index.html.erb     # Dashboard view
├─ config/
│ └─ routes.rb                # Engine routes
└─ spec/
  ├─ spec_helper.rb           # RSpec configuration
  └─ rails_ai_spec.rb         # Main test suite
```

## Key Features

### Rails Version Compatibility
- **Rails 5.2+**: Full backward compatibility
- **Rails 6.0, 6.1**: Enhanced features
- **Rails 7.0, 7.1**: Importmap support, enhanced streaming
- **Rails 8.0**: Latest features, enhanced performance

### Ruby Version Support
- **Ruby 3.0+**: Primary target
- **Ruby 2.7+**: Backward compatibility

### Core AI Capabilities
- **Universal Interface**: `RailsAi.chat()`, `RailsAi.stream()`, `RailsAi.embed()`
- **Multiple Providers**: OpenAI, custom adapters, dummy for testing
- **Intelligent Caching**: Cost optimization with configurable TTL
- **Content Security**: Built-in redaction for PII
- **Observability**: Comprehensive event logging
- **Streaming**: Real-time AI responses via Action Cable

### Rails Integration
- **Generators**: Easy setup and feature generation
- **View Components**: Reusable AI UI components
- **Jobs**: Background AI processing
- **Models**: Embeddable concern for semantic search
- **Helpers**: Convenient AI methods
- **Controllers**: Streaming concerns

### Testing & Quality
- **Multi-Rails Testing**: Appraisal for version compatibility
- **RSpec**: Comprehensive test suite
- **Standard**: Code style enforcement
- **CI/CD**: GitHub Actions for multiple Rails/Ruby versions

## Usage Examples

```ruby
# Basic AI operations
RailsAi.chat("Write a blog post about Ruby")
RailsAi.stream("Explain quantum computing") { |token| puts token }
RailsAi.embed(["Ruby on Rails", "Django"])

# Convenience methods
RailsAi.summarize(long_article)
RailsAi.translate("Hello", "Spanish")
RailsAi.classify("Great product!", ["positive", "negative"])
RailsAi.generate_code("User authentication", language: "ruby")

# Rails integration
class Article < ApplicationRecord
  include RailsAi::Embeddable
end

# View components
<%= render RailsAi::PromptComponent.new(prompt: "Ask me anything") %>
```

## Configuration

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  config.token_limit = 4000
  config.cache_ttl = 1.hour
  config.stub_responses = Rails.env.test?
end
```

This structure provides a solid foundation for building AI-powered Rails applications with full backward compatibility and forward-looking features.
