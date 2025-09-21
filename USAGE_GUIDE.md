# Rails AI - Quick Usage Guide

## 🚀 Getting Started

### 1. Installation
```bash
# Add to Gemfile
gem 'rails_ai'

# Install
bundle install

# Generate initial files
rails generate rails_ai:install
```

### 2. Configuration
```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  config.api_key = ENV['OPENAI_API_KEY']
  config.cache_ttl = 1.hour
  config.stub_responses = Rails.env.test?
end
```

## 📝 Basic Usage

### Text Operations
```ruby
# Simple chat
RailsAi.chat("Write a blog post about Ruby")

# Streaming
RailsAi.stream("Explain quantum computing") do |token|
  puts token
end

# Common tasks
RailsAi.summarize(long_text)
RailsAi.translate("Hello", "Spanish")
RailsAi.classify("Great product!", ["positive", "negative"])
```

### Image Operations
```ruby
# Generate image
image = RailsAi.generate_image("A sunset over mountains")

# Analyze image
analysis = RailsAi.analyze_image(image_file, "What do you see?")

# Edit image
edited = RailsAi.edit_image(image_file, "Add a rainbow")
```

### Video Operations
```ruby
# Generate video
video = RailsAi.generate_video("A cat playing", duration: 10)

# Analyze video
analysis = RailsAi.analyze_video(video_file, "What's happening?")
```

### Audio Operations
```ruby
# Generate speech
speech = RailsAi.generate_speech("Hello world", voice: "alloy")

# Transcribe audio
text = RailsAi.transcribe_audio(audio_file)
```

## 🧠 Context-Aware Usage

### In Controllers
```ruby
class PostsController < ApplicationController
  include RailsAi::ContextAware

  def analyze_image
    # Automatically includes user and window context
    result = analyze_image_with_context(
      params[:image], 
      "What's in this image?"
    )
    render json: { analysis: result }
  end
end
```

### Manual Context
```ruby
# With custom context
RailsAi.analyze_image_with_context(
  image_file,
  "What do you see?",
  user_context: { id: 1, role: "admin" },
  window_context: { controller: "PostsController" },
  image_context: { format: "png" }
)
```

## 🎨 Rails Integration

### View Components
```erb
<!-- AI Chat -->
<%= render RailsAi::PromptComponent.new(
  prompt: "Ask me anything",
  stream_id: ai_stream_id
) %>

<!-- Image Generation Form -->
<%= form_with url: ai_generate_image_path do |form| %>
  <%= form.text_area :prompt, placeholder: "Describe the image" %>
  <%= form.submit "Generate Image" %>
<% end %>
```

### Helpers
```erb
<!-- In views -->
<%= ai_chat("Write a summary") %>
<%= ai_generate_image("A beautiful landscape") %>
<%= ai_analyze_image_with_context(image, "What do you see?") %>
```

### Jobs
```ruby
class GenerateContentJob < ApplicationJob
  def perform(prompt)
    RailsAi.chat(prompt)
  end
end

# Queue the job
GenerateContentJob.perform_later("Write a blog post")
```

### Models
```ruby
class Article < ApplicationRecord
  include RailsAi::Embeddable
  
  def generate_summary!
    RailsAi.summarize(content)
  end
  
  def generate_thumbnail!
    RailsAi.generate_image("Thumbnail for: #{title}")
  end
end
```

## 🔧 Advanced Usage

### Custom Providers
```ruby
class MyProvider < RailsAi::Providers::Base
  def chat!(messages:, model:, **opts)
    # Your custom implementation
  end
end

# Use in configuration
RailsAi.configure do |config|
  config.provider = :my_provider
end
```

### Streaming with Action Cable
```ruby
class ChatController < ApplicationController
  def stream
    RailsAi.stream(params[:prompt]) do |token|
      ActionCable.server.broadcast("chat_#{params[:room_id]}", {
        type: "token",
        content: token
      })
    end
  end
end
```

### Caching
```ruby
# Automatic caching
RailsAi.chat("Expensive operation") # Cached automatically

# Custom cache
RailsAi::Cache.fetch([:custom, user.id, prompt.hash]) do
  RailsAi.chat(prompt)
end
```

## 🧪 Testing

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
    expect(result).to be_a(String)
  end
end
```

## 🎯 Common Patterns

### Content Generation
```ruby
# Blog post
post = RailsAi.chat("Write a blog post about #{topic}")

# Product description
description = RailsAi.chat("Write a product description for #{product_name}")

# Email content
email = RailsAi.chat("Write a marketing email about #{campaign}")
```

### Image Processing
```ruby
# Generate product images
image = RailsAi.generate_image("Product photo of #{product_name}")

# Analyze user uploads
analysis = RailsAi.analyze_image(uploaded_file, "Is this appropriate for our site?")

# Create variations
variations = RailsAi.create_variation(existing_image)
```

### Data Analysis
```ruby
# Sentiment analysis
sentiment = RailsAi.classify(user_feedback, ["positive", "negative", "neutral"])

# Extract information
entities = RailsAi.extract_entities("Apple Inc. was founded by Steve Jobs")

# Summarize content
summary = RailsAi.summarize(long_document)
```

## 🚨 Best Practices

1. **Always use context** when available for better results
2. **Cache expensive operations** to reduce costs
3. **Use background jobs** for heavy AI operations
4. **Test with dummy providers** in development
5. **Monitor API usage** and costs
6. **Handle errors gracefully** in production
7. **Use streaming** for better user experience
8. **Sanitize inputs** before sending to AI

## 🔍 Troubleshooting

### Common Issues
- **API Key Missing**: Set `OPENAI_API_KEY` environment variable
- **Rate Limits**: Implement retry logic and rate limiting
- **Memory Issues**: Use background jobs for large operations
- **Context Not Working**: Ensure controller includes `RailsAi::ContextAware`

### Debug Mode
```ruby
# Enable debug logging
Rails.logger.level = :debug

# Check configuration
RailsAi.config.provider
RailsAi.config.default_model
```

---

**Need Help?** Check the [full documentation](README.md) or [open an issue](https://github.com/yourusername/rails_ai/issues)!
