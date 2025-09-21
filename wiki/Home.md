# Rails AI Wiki

Welcome to the Rails AI documentation! This wiki provides comprehensive guides for developers working with Rails AI.

## 🚀 Quick Start

- **[Installation Guide](Installation-Guide.md)** - Get Rails AI up and running
- **[Quick Start](Quick-Start.md)** - Your first AI-powered Rails app
- **[API Documentation](API-Documentation.md)** - Complete API reference

## 📚 Core Documentation

### Getting Started
- **[Installation Guide](Installation-Guide.md)** - Step-by-step installation
- **[Quick Start](Quick-Start.md)** - Build your first AI app
- **[Configuration](Configuration.md)** - Configure Rails AI for your needs

### API Reference
- **[API Documentation](API-Documentation.md)** - Complete method reference
- **[Provider Support](Provider-Support.md)** - Multi-provider configuration
- **[Context System](Context-System.md)** - Context-aware AI operations

### Architecture
- **[Architecture Overview](Architecture-Overview.md)** - System design and components
- **[Performance Guide](Performance-Guide.md)** - Optimization strategies
- **[Security Guide](Security-Guide.md)** - Security best practices

## 🤖 AI Providers

Rails AI supports multiple AI providers with a unified interface:

### OpenAI
- **Models**: GPT-4, GPT-3.5, DALL-E, Whisper, TTS
- **Features**: Text generation, image generation, audio processing
- **Best for**: General AI tasks, image generation, audio processing

### Anthropic (Claude)
- **Models**: Claude 3 Sonnet, Haiku, Opus
- **Features**: Text generation, image analysis
- **Best for**: Code analysis, text generation, reasoning tasks

### Google Gemini
- **Models**: Gemini 1.5 Pro, Flash, Vision
- **Features**: Text generation, image analysis
- **Best for**: Multimodal analysis, Google ecosystem integration

### Dummy (Testing)
- **Models**: Mock models
- **Features**: All operations with mock responses
- **Best for**: Testing and development

## 🎯 Use Cases

### Content Generation
```ruby
# Blog posts
RailsAi.chat("Write a technical blog post about Rails 8")

# Social media content
RailsAi.chat("Create engaging Twitter posts about AI")

# Product descriptions
RailsAi.chat("Write product descriptions for an e-commerce site")
```

### Code Assistance
```ruby
# Code generation
RailsAi.generate_code("Create a user authentication system", language: "ruby")

# Code explanation
RailsAi.explain_code("def authenticate_user; end")

# Code review
RailsAi.chat("Review this code for security issues: #{code}")
```

### Image Processing
```ruby
# Image analysis
RailsAi.analyze_image(image_file, "Extract text from this document")

# Image generation (OpenAI only)
RailsAi.generate_image("A modern website homepage design")

# Image editing (OpenAI only)
RailsAi.edit_image(image_file, "Add a company logo to the top right")
```

### Multimodal Applications
```ruby
# Document analysis
RailsAi.analyze_image_with_context(
  document_image,
  "Summarize this contract",
  user_context: { role: "lawyer" },
  image_context: { format: "pdf" }
)

# Content moderation
RailsAi.analyze_image(
  user_uploaded_image,
  "Check if this image contains inappropriate content"
)
```

## ⚡ Performance Features

### Smart Caching
```ruby
# Automatic caching with compression
RailsAi.chat("Expensive AI operation")  # Cached automatically

# Clear cache when needed
RailsAi.clear_cache!
```

### Batch Processing
```ruby
# Process multiple requests efficiently
requests = [
  { prompt: "Write a title" },
  { prompt: "Write a summary" },
  { prompt: "Write a conclusion" }
]
results = RailsAi.batch_chat(requests)
```

### Performance Monitoring
```ruby
# Get performance metrics
metrics = RailsAi.metrics
# => { chat: { count: 100, avg_duration: 0.5 }, ... }

# Warmup for faster first requests
RailsAi.warmup!
```

## 🔧 Advanced Features

### Multi-Provider Support
```ruby
# Switch providers dynamically
RailsAi.configure { |c| c.provider = :openai }
openai_result = RailsAi.chat("Generate code")

RailsAi.configure { |c| c.provider = :anthropic }
anthropic_result = RailsAi.chat("Analyze this code")

RailsAi.configure { |c| c.provider = :gemini }
gemini_result = RailsAi.chat("Explain this code")
```

### Context-Aware Operations
```ruby
# User-specific context
user_context = {
  id: 1,
  name: "John Doe",
  role: "admin",
  preferences: { theme: "dark" }
}

# Application context
window_context = {
  controller: "PostsController",
  action: "show",
  params: { id: 123 }
}

# Context-aware generation
RailsAi.generate_with_context(
  "Create personalized content",
  user_context: user_context,
  window_context: window_context
)
```

### Provider Fallback
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

## 🧪 Testing

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

## 🚀 Rails Compatibility

- **Rails 8.0** ✅ (Primary target)
- **Rails 7.x** ✅ (Fully supported)
- **Rails 6.x** ✅ (Fully supported)
- **Rails 5.2+** ✅ (Supported)

## 📦 Dependencies

### Required
- Rails >= 5.2
- Ruby >= 2.7

### Optional (for specific providers)
- `ruby-anthropic` - For Anthropic (Claude) support
- `gemini-ai` - For Google Gemini support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

See [Contributing Guide](Contributing-Guide.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- OpenAI for GPT and DALL-E models
- Anthropic for Claude models
- Google for Gemini models
- The Rails community for inspiration

---

**Built with ❤️ for the Rails community**

[Documentation](wiki/) • [Features](FEATURES.md) • [Usage](USAGE_GUIDE.md) • [Providers](PROVIDERS.md) • [Contributing](wiki/Contributing-Guide.md)
