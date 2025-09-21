# Quick Start Guide

Get up and running with Rails AI in 5 minutes!

## 🚀 Installation

### 1. Add to Gemfile

```ruby
gem 'rails_ai'
```

### 2. Install and Configure

```bash
bundle install
rails generate rails_ai:install
```

### 3. Set API Key

```bash
export OPENAI_API_KEY=your_api_key_here
```

## ⚡ Basic Usage

### Text Generation

```ruby
# Simple chat
RailsAi.chat("Write a blog post about Ruby on Rails")

# Streaming response
RailsAi.stream("Explain quantum computing") do |token|
  puts token
end
```

### Image Generation

```ruby
# Generate image
image = RailsAi.generate_image("A beautiful sunset over mountains")

# Analyze image
analysis = RailsAi.analyze_image(image, "What do you see?")
```

### Context-Aware AI

```ruby
# With user context
RailsAi.analyze_image_with_context(
  image,
  "What do you see?",
  user_context: { id: 1, role: "admin" },
  window_context: { controller: "PostsController" }
)
```

## 🎨 Rails Integration

### In Controllers

```ruby
class PostsController < ApplicationController
  include RailsAi::ContextAware

  def generate_content
    content = generate_with_context("Write a blog post about #{@post.title}")
    render json: { content: content }
  end
end
```

### In Views

```erb
<!-- AI Chat Interface -->
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

### In Models

```ruby
class Article < ApplicationRecord
  include RailsAi::Embeddable
  
  def generate_summary!
    RailsAi.summarize(content)
  end
end
```

## 🔧 Configuration

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  config.cache_ttl = 1.hour
  config.enable_performance_monitoring = true
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

## 🎯 Common Use Cases

### Content Generation

```ruby
# Blog posts
post = RailsAi.chat("Write a blog post about #{topic}")

# Product descriptions
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

## 🚀 Next Steps

- [Basic Usage](Basic-Usage.md) - Learn more features
- [Configuration](Configuration.md) - Advanced setup
- [API Documentation](API-Documentation.md) - Complete reference
- [Contributing Guide](Contributing-Guide.md) - Contribute to the project

---

**You're ready to build AI-powered Rails applications!** 🚀
