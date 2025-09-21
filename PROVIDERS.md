# AI Providers

Rails AI supports multiple AI providers through a flexible adapter system. This allows you to easily switch between different AI services or use multiple providers in the same application.

## 🚀 Supported Providers

### OpenAI
- **Provider Key**: `:openai`
- **Models**: GPT-5, GPT-4o, GPT-4, GPT-3.5, DALL-E 3, DALL-E 2, Sora, Whisper, TTS
- **Features**: Text generation, image generation, video generation, audio processing, embeddings
- **API Key**: `OPENAI_API_KEY`
- **Dependency**: None! (Uses direct API calls)
- **Best for**: Latest AI models, comprehensive multimodal capabilities

### Anthropic (Claude)
- **Provider Key**: `:anthropic`
- **Models**: Claude 3.5 Sonnet, Claude 3 Sonnet, Claude 3 Haiku, Claude 3 Opus
- **Features**: Text generation, image analysis (Claude 3 Vision)
- **API Key**: `ANTHROPIC_API_KEY`
- **Dependency**: None! (Uses direct API calls)
- **Best for**: Code analysis, text generation, reasoning tasks

### Google Gemini
- **Provider Key**: `:gemini`
- **Models**: Gemini 2.0 Flash, Gemini 1.5 Pro, Gemini 1.5 Flash, Gemini 1.0 Pro
- **Features**: Text generation, image generation, image analysis, video generation, audio processing, embeddings
- **API Key**: `GEMINI_API_KEY`
- **Dependency**: None! (Uses direct API calls)
- **Best for**: Multimodal analysis, Google ecosystem integration, latest AI capabilities

### Dummy (Testing)
- **Provider Key**: `:dummy`
- **Models**: Mock models for testing
- **Features**: All operations with mock responses
- **API Key**: Not required
- **Best for**: Testing and development

## ⚙️ Configuration

### Basic Configuration

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai  # or :gemini, :anthropic, :dummy
  config.default_model = "gpt-5"  # or "gemini-2.0-flash-exp", "claude-3-5-sonnet-20241022"
end
```

### Provider-Specific Configuration

```ruby
# OpenAI configuration (no gem required!)
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-5"  # Latest GPT-5 model!
  config.api_key = ENV['OPENAI_API_KEY']
end

# Anthropic configuration (no gem required!)
RailsAi.configure do |config|
  config.provider = :anthropic
  config.default_model = "claude-3-5-sonnet-20241022"  # Latest Claude 3.5 Sonnet!
  config.api_key = ENV['ANTHROPIC_API_KEY']
end

# Gemini configuration (no gem required!)
RailsAi.configure do |config|
  config.provider = :gemini
  config.default_model = "gemini-2.0-flash-exp"
  config.api_key = ENV['GEMINI_API_KEY']
end
```

### Environment Variables

```bash
# .env
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

## 🔄 Switching Providers

### Runtime Switching

```ruby
# Switch to OpenAI (latest models!)
RailsAi.configure { |c| c.provider = :openai }
result = RailsAi.chat("Hello", model: "gpt-5")

# Switch to Anthropic (latest Claude!)
RailsAi.configure { |c| c.provider = :anthropic }
result = RailsAi.chat("Hello", model: "claude-3-5-sonnet-20241022")

# Switch to Gemini
RailsAi.configure { |c| c.provider = :gemini }
result = RailsAi.chat("Hello", model: "gemini-2.0-flash-exp")
```

### Per-Request Switching

```ruby
# Use specific provider for a request
RailsAi.configure { |c| c.provider = :openai }
openai_result = RailsAi.chat("Generate code", model: "gpt-5")

RailsAi.configure { |c| c.provider = :anthropic }
anthropic_result = RailsAi.chat("Analyze this code", model: "claude-3-5-sonnet-20241022")

RailsAi.configure { |c| c.provider = :gemini }
gemini_result = RailsAi.chat("Explain this code", model: "gemini-2.0-flash-exp")
```

## 📊 Provider Capabilities

| Feature | OpenAI | Anthropic | Gemini | Dummy |
|---------|--------|-----------|--------|-------|
| **Text Generation** | ✅ | ✅ | ✅ | ✅ |
| **Text Streaming** | ✅ | ✅ | ✅ | ✅ |
| **Image Generation** | ✅ | ❌ | ✅ | ✅ |
| **Image Analysis** | ✅ | ✅ | ✅ | ✅ |
| **Video Generation** | ✅ | ❌ | ✅ | ✅ |
| **Audio Generation** | ✅ | ❌ | ✅ | ✅ |
| **Audio Transcription** | ✅ | ❌ | ✅ | ✅ |
| **Embeddings** | ✅ | ⚠️ | ✅ | ✅ |

**Legend:**
- ✅ Fully supported
- ❌ Not supported (raises helpful error)
- ⚠️ Limited support (workaround available)

## 🎯 Provider-Specific Features

### OpenAI Features (Latest Models!)

```ruby
# Text generation with latest models
RailsAi.chat("Write a blog post", model: "gpt-5")  # GPT-5!
RailsAi.chat("Write a blog post", model: "gpt-4o")  # GPT-4o
RailsAi.chat("Write a blog post", model: "gpt-4")   # GPT-4

# Image generation with DALL-E 3
RailsAi.generate_image("A sunset over mountains", model: "dall-e-3")

# Video generation with Sora
RailsAi.generate_video("A cat playing with a ball", model: "sora")

# Audio processing
RailsAi.generate_speech("Hello world", voice: "alloy")
RailsAi.transcribe_audio(audio_file)

# Embeddings
RailsAi.embed(["Ruby on Rails", "Django"])

# Advanced configuration
RailsAi.chat("Write code", 
  model: "gpt-5",
  temperature: 0.7,
  top_p: 0.9,
  frequency_penalty: 0.1,
  presence_penalty: 0.1
)
```

### Anthropic (Claude) Features (Latest Models!)

```ruby
# Text generation with latest Claude models
RailsAi.chat("Write a blog post", model: "claude-3-5-sonnet-20241022")  # Latest Claude 3.5 Sonnet!
RailsAi.chat("Write a blog post", model: "claude-3-sonnet-20240229")   # Claude 3 Sonnet
RailsAi.chat("Write a blog post", model: "claude-3-haiku-20240307")    # Claude 3 Haiku

# Image analysis with Claude 3 Vision
RailsAi.analyze_image(image_file, "What do you see?", model: "claude-3-5-sonnet-20241022")

# Streaming with Claude
RailsAi.stream("Write a long story", model: "claude-3-5-sonnet-20241022") do |token|
  puts token
end

# Advanced configuration
RailsAi.chat("Write code", 
  model: "claude-3-5-sonnet-20241022",
  temperature: 0.7,
  top_p: 0.9,
  top_k: 40
)
```

### Google Gemini Features

```ruby
# Text generation with Gemini models
RailsAi.chat("Write a blog post", model: "gemini-2.0-flash-exp")

# Image generation with Gemini 2.0 Flash
RailsAi.generate_image("A sunset over mountains", model: "gemini-2.0-flash-exp")

# Image analysis with Gemini Vision
RailsAi.analyze_image(image_file, "What do you see?", model: "gemini-2.0-flash-exp")

# Video generation with Gemini 2.0 Flash
RailsAi.generate_video("A cat playing with a ball", model: "gemini-2.0-flash-exp")

# Audio processing with Gemini 2.0 Flash
RailsAi.generate_speech("Hello world", model: "gemini-2.0-flash-exp")
RailsAi.transcribe_audio(audio_file, model: "gemini-2.0-flash-exp")

# Streaming with Gemini
RailsAi.stream("Write a long story") do |token|
  puts token
end

# Advanced configuration with Gemini
RailsAi.chat("Write code", 
  model: "gemini-2.0-flash-exp",
  temperature: 0.7,
  top_p: 0.8,
  top_k: 40
)
```

## 🔧 Advanced Usage

### Custom Provider Selection

```ruby
# Select provider based on operation type
def smart_ai_operation(prompt, operation_type)
  case operation_type
  when :text_generation
    RailsAi.configure { |c| c.provider = :openai }
    RailsAi.chat(prompt, model: "gpt-5")  # Use latest GPT-5!
  when :code_analysis
    RailsAi.configure { |c| c.provider = :anthropic }
    RailsAi.chat(prompt, model: "claude-3-5-sonnet-20241022")  # Use latest Claude!
  when :image_generation
    RailsAi.configure { |c| c.provider = :openai }
    RailsAi.generate_image(prompt, model: "dall-e-3")
  when :image_analysis
    RailsAi.configure { |c| c.provider = :gemini }
    RailsAi.analyze_image(image, prompt)
  end
end
```

### Fallback Providers

```ruby
def robust_ai_operation(prompt)
  providers = [:openai, :anthropic, :gemini]  # All with latest models!
  
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

### Provider-Specific Models

```ruby
# OpenAI models (latest and most capable)
openai_models = {
  text: "gpt-5",                    # Latest GPT-5!
  text_advanced: "gpt-4o",         # GPT-4o
  text_standard: "gpt-4",          # GPT-4
  image: "dall-e-3",               # DALL-E 3
  video: "sora",                   # Sora video generation
  audio: "tts-1",                  # Text-to-speech
  embedding: "text-embedding-3-small"  # Embeddings
}

# Anthropic models (latest and most capable)
anthropic_models = {
  text: "claude-3-5-sonnet-20241022",  # Latest Claude 3.5 Sonnet!
  text_standard: "claude-3-sonnet-20240229",  # Claude 3 Sonnet
  text_fast: "claude-3-haiku-20240307",       # Claude 3 Haiku
  vision: "claude-3-5-sonnet-20241022"        # Vision capabilities
}

# Gemini models (latest and most capable)
gemini_models = {
  text: "gemini-2.0-flash-exp",    # Latest Gemini 2.0 Flash!
  vision: "gemini-2.0-flash-exp",  # Vision capabilities
  fast: "gemini-1.5-flash",        # Fast responses
  pro: "gemini-1.5-pro"            # Pro version
}
```

## 🧪 Testing with Providers

### Using Dummy Provider

```ruby
# In your tests
RSpec.describe "AI Features" do
  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
    end
  end

  it "generates content" do
    result = RailsAi.chat("Hello")
    expect(result).to include("Hello")
  end
end
```

### Testing Multiple Providers

```ruby
RSpec.describe "Provider Compatibility" do
  %i[openai anthropic gemini dummy].each do |provider|
    context "with #{provider} provider" do
      before do
        RailsAi.configure { |c| c.provider = provider }
      end

      it "generates text" do
        result = RailsAi.chat("Test")
        expect(result).to be_a(String)
      end
    end
  end
end
```

## 🚀 Adding New Providers

### 1. Create Provider Class

```ruby
# lib/rails_ai/providers/my_provider.rb
module RailsAi
  module Providers
    class MyProvider < Base
      def initialize
        @api_key = ENV.fetch("MY_API_KEY")
        super
      end

      def chat!(messages:, model:, **opts)
        # Implementation using direct API calls
      end

      def generate_image!(prompt:, model:, **opts)
        # Implementation
      end
    end
  end
end
```

### 2. Add to Provider Selection

```ruby
# lib/rails_ai.rb
def provider
  @provider ||= Performance::LazyProvider.new do
    case config.provider.to_sym
    when :openai then Providers::OpenAIAdapter.new
    when :anthropic then Providers::AnthropicAdapter.new
    when :gemini then Providers::GeminiAdapter.new
    when :my_provider then Providers::MyProvider.new
    when :dummy then Providers::DummyAdapter.new
    else Providers::DummyAdapter.new
    end
  end
end
```

### 3. Add Tests

```ruby
# spec/providers/my_provider_spec.rb
RSpec.describe RailsAi::Providers::MyProvider do
  # Test implementation
end
```

## 📚 Provider Documentation

### OpenAI
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [OpenAI Models](https://platform.openai.com/docs/models)

### Anthropic
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [Anthropic Models](https://docs.anthropic.com/en/docs/models)

### Google Gemini
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Gemini API Reference](https://ai.google.dev/api/rest)

## 🔍 Troubleshooting

### Common Issues

#### Provider Not Found
```ruby
# Error: Unknown provider
# Solution: Check provider name
RailsAi.configure { |c| c.provider = :openai }  # Correct
RailsAi.configure { |c| c.provider = :OpenAI }  # Wrong
```

#### API Key Missing
```bash
# Error: API key not found
# Solution: Set environment variable
export OPENAI_API_KEY=your_key_here
export ANTHROPIC_API_KEY=your_key_here
export GEMINI_API_KEY=your_key_here
```

#### Unsupported Operation
```ruby
# Error: Operation not supported
# Solution: Check provider capabilities
RailsAi.configure { |c| c.provider = :anthropic }
RailsAi.generate_image("test")  # Will raise NotImplementedError
```

### Debug Mode

```ruby
# Enable debug logging
Rails.logger.level = :debug

# Check current provider
RailsAi.provider.class
# => RailsAi::Providers::OpenAIAdapter

# Check configuration
RailsAi.config.provider
# => :openai
```

## 🎯 Best Practices

### Provider Selection Strategy

1. **OpenAI** - Best for latest models (GPT-5!), comprehensive capabilities
2. **Anthropic** - Best for code analysis, reasoning tasks (Claude 3.5 Sonnet!)
3. **Gemini** - Best for multimodal tasks, Google ecosystem integration
4. **Dummy** - Best for testing and development

### Performance Optimization

```ruby
# Use appropriate models for tasks
RailsAi.configure { |c| c.provider = :openai }
RailsAi.chat("Quick response", model: "gpt-4o")  # Fast
RailsAi.chat("Complex analysis", model: "gpt-5")  # Latest and most advanced

# Use Claude for code analysis
RailsAi.configure { |c| c.provider = :anthropic }
RailsAi.chat("Analyze this code", model: "claude-3-5-sonnet-20241022")

# Cache expensive operations
RailsAi.generate_image("Complex image", model: "dall-e-3")
```

### Error Handling

```ruby
def safe_ai_operation(prompt)
  begin
    RailsAi.chat(prompt, model: "gpt-5")
  rescue => e
    Rails.logger.error("AI operation failed: #{e.message}")
    "Sorry, I'm having trouble right now."
  end
end
```

---

**Rails AI supports multiple providers for maximum flexibility!** ��

**All providers now offer zero-dependency access to the latest AI models!** ✨

**GPT-5, Claude 3.5 Sonnet, Gemini 2.0 Flash, and Sora are all available with direct API calls!** 🎉
