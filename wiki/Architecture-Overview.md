# Architecture Overview

This document provides a comprehensive overview of Rails AI's architecture, design decisions, and system components.

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Rails AI Architecture                    │
├─────────────────────────────────────────────────────────────┤
│  Application Layer                                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Controllers │ │   Models    │ │    Views    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  Rails Integration Layer                                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Generators  │ │ Components  │ │    Jobs     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  Core AI Layer                                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Context   │ │  Providers  │ │ Performance │          │
│  │  System     │ │   System    │ │   System    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│  External AI Services                                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   OpenAI    │ │  Anthropic  │ │   Gemini    │          │
│  │             │ │  (Claude)   │ │  (Google)   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Custom    │ │   Dummy     │ │   Future    │          │
│  │  Providers  │ │ (Testing)   │ │  Providers  │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## 🧩 Core Components

### 1. Main Module (`RailsAi`)

The central entry point that provides a unified API for all AI operations.

```ruby
module RailsAi
  # Core AI operations
  def self.chat(prompt, **opts)
  def self.generate_image(prompt, **opts)
  def self.analyze_image(image, prompt, **opts)
  
  # Context-aware operations
  def self.analyze_image_with_context(image, prompt, contexts)
  def self.generate_with_context(prompt, contexts)
  
  # Performance utilities
  def self.metrics
  def self.warmup!
  def self.clear_cache!
end
```

**Responsibilities:**
- Provide unified API for all AI operations
- Handle request routing to appropriate providers
- Implement caching and performance optimizations
- Manage configuration and initialization

### 2. Multi-Provider System

Abstract interface for different AI service providers with unified API.

```ruby
module RailsAi::Providers
  class Base
    def chat!(messages:, model:, **opts)
      raise NotImplementedError
    end
    
    def generate_image!(prompt:, model:, **opts)
      raise NotImplementedError
    end
    
    def analyze_image!(image:, prompt:, model:, **opts)
      raise NotImplementedError
    end
  end
  
  class OpenAIAdapter < Base
    # OpenAI-specific implementation (GPT-4, DALL-E, Whisper)
  end
  
  class AnthropicAdapter < Base
    # Anthropic-specific implementation (Claude 3)
  end
  
  class GeminiAdapter < Base
    # Google Gemini-specific implementation
  end
  
  class DummyAdapter < Base
    # Testing and development implementation
  end
end
```

**Provider Capabilities Matrix:**

| Feature | OpenAI | Anthropic | Gemini | Dummy |
|---------|--------|-----------|--------|-------|
| **Text Generation** | ✅ | ✅ | ✅ | ✅ |
| **Text Streaming** | ✅ | ✅ | ✅ | ✅ |
| **Image Generation** | ✅ | ❌ | ❌ | ✅ |
| **Image Analysis** | ✅ | ✅ | ✅ | ✅ |
| **Video Generation** | ✅ | ❌ | ❌ | ✅ |
| **Audio Generation** | ✅ | ❌ | ❌ | ✅ |
| **Audio Transcription** | ✅ | ❌ | ❌ | ✅ |
| **Embeddings** | ✅ | ⚠️ | ⚠️ | ✅ |

**Responsibilities:**
- Abstract AI service differences
- Implement provider-specific logic
- Handle API communication
- Manage authentication and rate limiting
- Provide graceful fallbacks for unsupported operations

### 3. Context System

Intelligent context awareness for enhanced AI interactions.

```ruby
module RailsAi
  class UserContext
    # User-specific information
    attr_reader :id, :email, :role, :preferences, :created_at, :last_activity
  end
  
  class WindowContext
    # Application state information
    attr_reader :controller, :action, :params, :request_method, :request_path
  end
  
  class ImageContext
    # Image metadata and information
    attr_reader :source, :format, :dimensions, :file_size, :metadata
  end
  
  class ContextAnalyzer
    # Context-aware prompt building
    def build_context_aware_prompt(base_prompt, contexts)
    end
  end
end
```

**Responsibilities:**
- Capture user, application, and image context
- Build context-aware prompts
- Provide context to AI operations
- Optimize context for different use cases

### 4. Performance System

Comprehensive performance optimizations and monitoring.

```ruby
module RailsAi::Performance
  class SmartCache
    # Intelligent caching with compression
    def fetch(key, **opts, &block)
    end
  end
  
  class RequestDeduplicator
    # Concurrent request deduplication
    def deduplicate(key, &block)
    end
  end
  
  class ConnectionPool
    # HTTP connection pooling
    def with_connection(&block)
    end
  end
  
  class BatchProcessor
    # Batch processing for multiple operations
    def add_operation(operation)
    end
  end
  
  class PerformanceMonitor
    # Performance metrics and monitoring
    def measure(operation, &block)
    end
  end
end
```

**Responsibilities:**
- Implement caching strategies
- Optimize network operations
- Monitor performance metrics
- Manage resource usage
- Handle batch processing

## 🔄 Data Flow

### 1. Basic AI Operation Flow

```
User Request → RailsAi Module → Provider Selection → AI Service → Response → Cache → User
```

**Detailed Flow:**
1. User calls `RailsAi.chat("Hello")`
2. RailsAi normalizes input and checks cache
3. If cached, return cached response
4. If not cached, select appropriate provider based on configuration
5. Provider makes API call to AI service
6. Response is cached and returned to user

### 2. Multi-Provider Operation Flow

```
User Request → Provider Selection → Provider A → Success? → Response
                    ↓                    ↓
              Fallback Provider → Provider B → Success? → Response
                    ↓                    ↓
              Error Handling → User Notification
```

**Detailed Flow:**
1. User calls `RailsAi.chat("Hello")`
2. System selects primary provider (e.g., OpenAI)
3. If primary provider fails, automatically try fallback (e.g., Anthropic)
4. If all providers fail, return error with helpful message
5. Successful response is cached and returned

### 3. Context-Aware Operation Flow

```
User Request → Context Capture → Context Analysis → Enhanced Prompt → Provider → AI Service → Response → Cache → User
```

**Detailed Flow:**
1. User calls `RailsAi.analyze_image_with_context(image, prompt, contexts)`
2. Context system captures user, window, and image context
3. ContextAnalyzer builds enhanced prompt with context
4. Enhanced prompt is sent to appropriate provider
5. Provider makes API call with context-aware prompt
6. Response is cached and returned to user

### 4. Streaming Operation Flow

```
User Request → RailsAi Module → Provider → AI Service → Stream → Action Cable → User (Real-time)
```

**Detailed Flow:**
1. User calls `RailsAi.stream("Long prompt")`
2. RailsAi routes to provider with streaming enabled
3. Provider establishes streaming connection
4. AI service streams response tokens
5. Tokens are sent to user via Action Cable
6. User receives real-time updates

## 🏛️ Design Patterns

### 1. Adapter Pattern

Used for provider abstraction:

```ruby
# All providers implement the same interface
class OpenAIAdapter < Base
  def chat!(messages:, model:, **opts)
    # OpenAI-specific implementation
  end
end

class AnthropicAdapter < Base
  def chat!(messages:, model:, **opts)
    # Anthropic-specific implementation
  end
end

class GeminiAdapter < Base
  def chat!(messages:, model:, **opts)
    # Gemini-specific implementation
  end
end
```

### 2. Strategy Pattern

Used for different AI operations and provider selection:

```ruby
# Different strategies for different operations
RailsAi.chat(prompt)           # Text strategy
RailsAi.generate_image(prompt) # Image strategy
RailsAi.generate_video(prompt) # Video strategy

# Provider selection strategy
def smart_provider_selection(operation_type)
  case operation_type
  when :image_generation then :openai
  when :text_generation then :gemini
  when :code_analysis then :anthropic
  end
end
```

### 3. Observer Pattern

Used for performance monitoring:

```ruby
# Performance monitoring observes all operations
RailsAi.performance_monitor.measure(:chat) do
  provider.chat!(messages: messages, model: model)
end
```

### 4. Factory Pattern

Used for provider creation:

```ruby
def self.provider
  case config.provider.to_sym
  when :openai then Providers::OpenAIAdapter.new
  when :anthropic then Providers::AnthropicAdapter.new
  when :gemini then Providers::GeminiAdapter.new
  when :dummy then Providers::DummyAdapter.new
  else Providers::DummyAdapter.new
  end
end
```

### 5. Chain of Responsibility Pattern

Used for fallback providers:

```ruby
def robust_ai_operation(prompt)
  providers = [:openai, :anthropic, :gemini]
  
  providers.each do |provider|
    begin
      RailsAi.configure { |c| c.provider = provider }
      return RailsAi.chat(prompt)
    rescue => e
      Rails.logger.warn("#{provider} failed: #{e.message}")
      next
    end
  end
  
  raise "All providers failed"
end
```

## 🔧 Configuration System

### Configuration Structure

```ruby
RailsAi::Config = Struct.new(
  :provider,                    # AI provider to use
  :default_model,              # Default AI model
  :token_limit,                # Token limit for requests
  :cache_ttl,                  # Cache time-to-live
  :stub_responses,             # Stub responses for testing
  :connection_pool_size,       # HTTP connection pool size
  :compression_threshold,      # Compression threshold
  :batch_size,                 # Batch processing size
  :flush_interval,             # Batch flush interval
  :enable_performance_monitoring,    # Performance monitoring
  :enable_request_deduplication,     # Request deduplication
  :enable_compression,               # Response compression
  keyword_init: true
)
```

### Provider-Specific Configuration

```ruby
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  config.cache_ttl = 1.hour
  config.enable_performance_monitoring = true
end

# Environment variables for different providers
# OPENAI_API_KEY=your_openai_key
# ANTHROPIC_API_KEY=your_anthropic_key
# GEMINI_API_KEY=your_gemini_key
```

## 🚀 Performance Architecture

### Caching Strategy

```
Request → Cache Check → Hit? → Return Cached Response
                    ↓
                   Miss? → Provider → AI Service → Cache Response → Return
```

### Connection Pooling

```
Request → Connection Pool → Available Connection? → Use Connection
                        ↓
                      None? → Wait/Queue → Use Connection
```

### Request Deduplication

```
Request → Deduplication Check → Duplicate? → Wait for Existing Request
                            ↓
                          Unique? → Process Request → Cache Result
```

### Batch Processing

```
Multiple Requests → Batch Queue → Batch Size Reached? → Process Batch → Return Results
                                    ↓
                                 Timeout? → Process Partial Batch → Return Results
```

## 🔒 Security Architecture

### Content Redaction

```ruby
module RailsAi::Redactor
  EMAIL = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  PHONE = /\+?\d[\d\s().-]{7,}\d/
  
  def self.call(text)
    text.to_s.gsub(EMAIL, "[email]").gsub(PHONE, "[phone]")
  end
end
```

### Parameter Sanitization

```ruby
def sanitized_params
  params.except('password', 'password_confirmation', 'token', 'secret', 'key')
end
```

### Provider-Specific Security

```ruby
# Each provider handles its own security concerns
class OpenAIAdapter < Base
  def initialize
    @api_key = ENV.fetch("OPENAI_API_KEY")
    # Additional OpenAI-specific security measures
  end
end

class AnthropicAdapter < Base
  def initialize
    @api_key = ENV.fetch("ANTHROPIC_API_KEY")
    # Additional Anthropic-specific security measures
  end
end
```

## 📊 Monitoring Architecture

### Performance Metrics

```ruby
{
  chat: {
    count: 100,
    total_duration: 5.2,
    avg_duration: 0.052,
    min_duration: 0.001,
    max_duration: 0.5,
    total_memory: 1024
  },
  generate_image: {
    count: 50,
    total_duration: 12.3,
    avg_duration: 0.246,
    min_duration: 0.1,
    max_duration: 2.0,
    total_memory: 2048
  }
}
```

### Provider-Specific Metrics

```ruby
{
  providers: {
    openai: { requests: 100, errors: 2, avg_latency: 0.5 },
    anthropic: { requests: 50, errors: 1, avg_latency: 0.7 },
    gemini: { requests: 75, errors: 0, avg_latency: 0.6 }
  }
}
```

### Event Logging

```ruby
RailsAi::Events.log!(
  kind: :image_analysis,
  name: "completed",
  payload: { 
    user_id: 1, 
    image_format: "png",
    provider: "gemini",
    model: "gemini-1.5-pro"
  },
  latency_ms: 1500
)
```

## 🔄 Extension Points

### Adding New Providers

1. Create provider class inheriting from `Base`
2. Implement required methods
3. Add to provider selection logic
4. Add tests and documentation
5. Update capability matrix

```ruby
# Example: Adding a new provider
class MyCustomProvider < RailsAi::Providers::Base
  def initialize
    unless defined?(::MyCustomGem)
      raise LoadError, "my-custom gem is required for MyCustom provider"
    end
    super
  end

  def chat!(messages:, model:, **opts)
    # Custom implementation
  end
end
```

### Adding New Operations

1. Add method to main `RailsAi` module
2. Implement in all providers
3. Add caching if appropriate
4. Add performance monitoring
5. Add tests and documentation

### Adding New Context Types

1. Create context class
2. Add to `ContextAnalyzer`
3. Update context-aware methods
4. Add tests and documentation

## 🎯 Design Principles

### 1. Simplicity

- Simple, intuitive API
- Minimal configuration required
- Clear error messages
- Comprehensive documentation

### 2. Performance

- Intelligent caching
- Connection pooling
- Request deduplication
- Performance monitoring
- Batch processing

### 3. Flexibility

- Multiple provider support
- Configurable options
- Extensible architecture
- Plugin system
- Graceful fallbacks

### 4. Reliability

- Comprehensive testing
- Error handling
- Graceful degradation
- Monitoring and alerting
- Provider fallbacks

### 5. Security

- Content redaction
- Parameter sanitization
- Secure credential handling
- Rate limiting
- Provider-specific security

## 📈 Scalability Considerations

### Horizontal Scaling

- Stateless design
- Connection pooling
- Caching strategies
- Load balancing support
- Provider distribution

### Vertical Scaling

- Memory optimization
- CPU efficiency
- I/O optimization
- Resource management
- Performance monitoring

### Performance Scaling

- Batch processing
- Async operations
- Streaming support
- Background jobs
- Provider load balancing

## 🔮 Future Architecture Considerations

### Planned Enhancements

1. **Additional Providers**
   - Azure OpenAI
   - AWS Bedrock
   - Cohere
   - Local models (Ollama)

2. **Advanced Features**
   - Multi-modal streaming
   - Real-time collaboration
   - Advanced caching strategies
   - A/B testing framework

3. **Enterprise Features**
   - Multi-tenant support
   - Advanced monitoring
   - Compliance features
   - Custom model support

### Architecture Evolution

The current architecture is designed to be:
- **Extensible** - Easy to add new providers and features
- **Maintainable** - Clear separation of concerns
- **Testable** - Comprehensive test coverage
- **Scalable** - Handles growth gracefully
- **Future-proof** - Adapts to new AI capabilities

---

This architecture provides a solid foundation for building AI-powered Rails applications with excellent performance, reliability, and maintainability across multiple AI providers. 🚀
