# API Documentation

Complete API reference for Rails AI.

## 📚 Table of Contents

- [Core Methods](#core-methods)
- [Text Operations](#text-operations)
- [Image Operations](#image-operations)
- [Video Operations](#video-operations)
- [Audio Operations](#audio-operations)
- [Context-Aware Operations](#context-aware-operations)
- [Performance Methods](#performance-methods)
- [Provider Configuration](#provider-configuration)
- [Error Handling](#error-handling)

## 🔧 Core Methods

### `RailsAi.chat(prompt_or_messages, **opts)`

Generate text using AI.

**Parameters:**
- `prompt_or_messages` (String|Array) - Text prompt or conversation messages
- `model` (String, optional) - AI model to use (default: config.default_model)
- `**opts` (Hash) - Additional options

**Returns:** String - AI-generated text

**Example:**
```ruby
# Simple prompt
RailsAi.chat("Write a blog post about Ruby")

# Conversation
RailsAi.chat([
  { role: "user", content: "Hello" },
  { role: "assistant", content: "Hi there!" },
  { role: "user", content: "How are you?" }
])

# Provider-specific models
RailsAi.chat("Hello", model: "gpt-4o-mini")           # OpenAI
RailsAi.chat("Hello", model: "claude-3-sonnet-20240229") # Anthropic
RailsAi.chat("Hello", model: "gemini-1.5-pro")        # Gemini
```

### `RailsAi.stream(prompt_or_messages, **opts, &block)`

Generate text with streaming response.

**Parameters:**
- `prompt_or_messages` (String|Array) - Text prompt or conversation messages
- `model` (String, optional) - AI model to use
- `**opts` (Hash) - Additional options
- `&block` (Proc) - Block to handle streaming tokens

**Returns:** Nil

**Example:**
```ruby
RailsAi.stream("Write a long story") do |token|
  puts token
end
```

### `RailsAi.embed(texts, **opts)`

Generate embeddings for text.

**Parameters:**
- `texts` (String|Array) - Text(s) to embed
- `model` (String, optional) - Embedding model to use
- `**opts` (Hash) - Additional options

**Returns:** Array - Embedding vectors

**Example:**
```ruby
embeddings = RailsAi.embed(["Ruby on Rails", "Django", "Express.js"])
```

## 📝 Text Operations

### `RailsAi.summarize(content, **opts)`

Summarize text content.

**Parameters:**
- `content` (String) - Text to summarize
- `**opts` (Hash) - Additional options

**Returns:** String - Summary

**Example:**
```ruby
summary = RailsAi.summarize(long_article)
```

### `RailsAi.translate(content, target_language, **opts)`

Translate text to another language.

**Parameters:**
- `content` (String) - Text to translate
- `target_language` (String) - Target language
- `**opts` (Hash) - Additional options

**Returns:** String - Translated text

**Example:**
```ruby
translation = RailsAi.translate("Hello world", "Spanish")
```

### `RailsAi.classify(content, categories, **opts)`

Classify text into categories.

**Parameters:**
- `content` (String) - Text to classify
- `categories` (Array) - Available categories
- `**opts` (Hash) - Additional options

**Returns:** String - Classification result

**Example:**
```ruby
classification = RailsAi.classify("I love this product!", ["positive", "negative", "neutral"])
```

### `RailsAi.extract_entities(content, **opts)`

Extract named entities from text.

**Parameters:**
- `content` (String) - Text to analyze
- `**opts` (Hash) - Additional options

**Returns:** String - Extracted entities

**Example:**
```ruby
entities = RailsAi.extract_entities("Apple Inc. was founded by Steve Jobs in Cupertino, California")
```

### `RailsAi.generate_code(prompt, language: "ruby", **opts)`

Generate code based on description.

**Parameters:**
- `prompt` (String) - Code description
- `language` (String, optional) - Programming language (default: "ruby")
- `**opts` (Hash) - Additional options

**Returns:** String - Generated code

**Example:**
```ruby
code = RailsAi.generate_code("Create a user authentication system", language: "ruby")
```

### `RailsAi.explain_code(code, language: "ruby", **opts)`

Explain code functionality.

**Parameters:**
- `code` (String) - Code to explain
- `language` (String, optional) - Programming language (default: "ruby")
- `**opts` (Hash) - Additional options

**Returns:** String - Code explanation

**Example:**
```ruby
explanation = RailsAi.explain_code("def hello; puts 'world'; end")
```

## 🖼️ Image Operations

### `RailsAi.generate_image(prompt, **opts)`

Generate an image from text description.

**Parameters:**
- `prompt` (String) - Image description
- `model` (String, optional) - Image model to use (default: "dall-e-3")
- `size` (String, optional) - Image size (default: "1024x1024")
- `quality` (String, optional) - Image quality (default: "standard")
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded image data

**Example:**
```ruby
image = RailsAi.generate_image("A beautiful sunset over mountains")
# => "data:image/png;base64,..."

# Note: Only supported by OpenAI provider
RailsAi.configure { |c| c.provider = :openai }
RailsAi.generate_image("A cat playing with a ball")
```

### `RailsAi.edit_image(image, prompt, **opts)`

Edit an existing image.

**Parameters:**
- `image` (String|File) - Image to edit
- `prompt` (String) - Edit description
- `mask` (String|File, optional) - Mask for editing
- `size` (String, optional) - Output size (default: "1024x1024")
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded edited image

**Example:**
```ruby
edited = RailsAi.edit_image(image_file, "Add a rainbow in the sky")
# Note: Only supported by OpenAI provider
```

### `RailsAi.create_variation(image, **opts)`

Create variations of an image.

**Parameters:**
- `image` (String|File) - Base image
- `size` (String, optional) - Output size (default: "1024x1024")
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded variation

**Example:**
```ruby
variation = RailsAi.create_variation(image_file)
# Note: Only supported by OpenAI provider
```

### `RailsAi.analyze_image(image, prompt, **opts)`

Analyze an image with AI.

**Parameters:**
- `image` (String|File) - Image to analyze
- `prompt` (String) - Analysis prompt
- `model` (String, optional) - Analysis model (default: "gpt-4-vision-preview")
- `**opts` (Hash) - Additional options

**Returns:** String - Analysis result

**Example:**
```ruby
# Works with OpenAI, Anthropic, and Gemini
analysis = RailsAi.analyze_image(image_file, "What objects do you see?")

# Provider-specific models
RailsAi.configure { |c| c.provider = :openai }
RailsAi.analyze_image(image_file, "What do you see?", model: "gpt-4-vision-preview")

RailsAi.configure { |c| c.provider = :anthropic }
RailsAi.analyze_image(image_file, "What do you see?", model: "claude-3-sonnet-20240229")

RailsAi.configure { |c| c.provider = :gemini }
RailsAi.analyze_image(image_file, "What do you see?", model: "gemini-1.5-pro")
```

## 🎥 Video Operations

### `RailsAi.generate_video(prompt, **opts)`

Generate a video from text description.

**Parameters:**
- `prompt` (String) - Video description
- `model` (String, optional) - Video model to use (default: "sora")
- `duration` (Integer, optional) - Video duration in seconds (default: 5)
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded video data

**Example:**
```ruby
video = RailsAi.generate_video("A cat playing with a ball", duration: 10)
# => "data:video/mp4;base64,..."

# Note: Only supported by OpenAI provider
RailsAi.configure { |c| c.provider = :openai }
RailsAi.generate_video("A sunset over the ocean")
```

### `RailsAi.edit_video(video, prompt, **opts)`

Edit an existing video.

**Parameters:**
- `video` (String|File) - Video to edit
- `prompt` (String) - Edit description
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded edited video

**Example:**
```ruby
edited = RailsAi.edit_video(video_file, "Add background music")
# Note: Only supported by OpenAI provider
```

### `RailsAi.analyze_video(video, prompt, **opts)`

Analyze a video with AI.

**Parameters:**
- `video` (String|File) - Video to analyze
- `prompt` (String) - Analysis prompt
- `model` (String, optional) - Analysis model (default: "gpt-4-vision-preview")
- `**opts` (Hash) - Additional options

**Returns:** String - Analysis result

**Example:**
```ruby
analysis = RailsAi.analyze_video(video_file, "What's happening in this video?")
# Note: Limited support across providers
```

## 🎵 Audio Operations

### `RailsAi.generate_speech(text, **opts)`

Generate speech from text.

**Parameters:**
- `text` (String) - Text to convert to speech
- `model` (String, optional) - Speech model to use (default: "tts-1")
- `voice` (String, optional) - Voice to use (default: "alloy")
- `**opts` (Hash) - Additional options

**Returns:** String - Base64-encoded audio data

**Example:**
```ruby
speech = RailsAi.generate_speech("Hello, welcome to our application!", voice: "alloy")
# => "data:audio/mp3;base64,..."

# Note: Only supported by OpenAI provider
RailsAi.configure { |c| c.provider = :openai }
RailsAi.generate_speech("Welcome to our app!")
```

### `RailsAi.transcribe_audio(audio, **opts)`

Transcribe audio to text.

**Parameters:**
- `audio` (String|File) - Audio to transcribe
- `model` (String, optional) - Transcription model (default: "whisper-1")
- `**opts` (Hash) - Additional options

**Returns:** String - Transcribed text

**Example:**
```ruby
transcription = RailsAi.transcribe_audio(audio_file)
# Note: Only supported by OpenAI provider
```

## 🧠 Context-Aware Operations

### `RailsAi.analyze_image_with_context(image, prompt, **contexts)`

Analyze image with context information.

**Parameters:**
- `image` (String|File) - Image to analyze
- `prompt` (String) - Analysis prompt
- `user_context` (Hash, optional) - User context information
- `window_context` (Hash, optional) - Application context information
- `image_context` (Hash, optional) - Image context information
- `**opts` (Hash) - Additional options

**Returns:** String - Context-aware analysis result

**Example:**
```ruby
result = RailsAi.analyze_image_with_context(
  image_file,
  "What do you see?",
  user_context: { id: 1, role: "admin" },
  window_context: { controller: "PostsController" },
  image_context: { format: "png" }
)
```

### `RailsAi.generate_with_context(prompt, **contexts)`

Generate text with context information.

**Parameters:**
- `prompt` (String) - Text prompt
- `user_context` (Hash, optional) - User context information
- `window_context` (Hash, optional) - Application context information
- `**opts` (Hash) - Additional options

**Returns:** String - Context-aware generated text

**Example:**
```ruby
result = RailsAi.generate_with_context(
  "Write a summary",
  user_context: { id: 1, role: "admin" },
  window_context: { controller: "PostsController" }
)
```

### `RailsAi.generate_image_with_context(prompt, **contexts)`

Generate image with context information.

**Parameters:**
- `prompt` (String) - Image description
- `user_context` (Hash, optional) - User context information
- `window_context` (Hash, optional) - Application context information
- `**opts` (Hash) - Additional options

**Returns:** String - Context-aware generated image

**Example:**
```ruby
result = RailsAi.generate_image_with_context(
  "Create an image for this blog post",
  user_context: { id: 1, role: "admin" },
  window_context: { controller: "PostsController" }
)
```

## ⚡ Performance Methods

### `RailsAi.batch_chat(requests)`

Process multiple chat requests in batch.

**Parameters:**
- `requests` (Array) - Array of request hashes

**Returns:** Array - Array of responses

**Example:**
```ruby
requests = [
  { prompt: "Write a blog post" },
  { prompt: "Generate a summary" },
  { prompt: "Create a title" }
]
results = RailsAi.batch_chat(requests)
```

### `RailsAi.batch_embed(texts_array)`

Process multiple embedding requests in batch.

**Parameters:**
- `texts_array` (Array) - Array of text arrays

**Returns:** Array - Array of embedding arrays

**Example:**
```ruby
texts_array = [
  ["Ruby on Rails", "Django"],
  ["Express.js", "FastAPI"],
  ["Laravel", "Symfony"]
]
results = RailsAi.batch_embed(texts_array)
```

### `RailsAi.metrics`

Get performance metrics.

**Returns:** Hash - Performance metrics

**Example:**
```ruby
metrics = RailsAi.metrics
# => {
#   chat: { count: 100, total_duration: 5.2, avg_duration: 0.052 },
#   generate_image: { count: 50, total_duration: 12.3, avg_duration: 0.246 }
# }
```

### `RailsAi.warmup!`

Warmup components for faster first requests.

**Returns:** Nil

**Example:**
```ruby
RailsAi.warmup!
```

### `RailsAi.clear_cache!`

Clear all cached responses.

**Returns:** Nil

**Example:**
```ruby
RailsAi.clear_cache!
```

### `RailsAi.reset_performance_metrics!`

Reset performance metrics.

**Returns:** Nil

**Example:**
```ruby
RailsAi.reset_performance_metrics!
```

## 🔧 Provider Configuration

### `RailsAi.configure(&block)`

Configure Rails AI settings.

**Parameters:**
- `&block` (Proc) - Configuration block

**Example:**
```ruby
RailsAi.configure do |config|
  config.provider = :openai
  config.default_model = "gpt-4o-mini"
  config.cache_ttl = 1.hour
  config.enable_performance_monitoring = true
end
```

### Provider Selection

```ruby
# OpenAI
RailsAi.configure { |c| c.provider = :openai }
RailsAi.chat("Hello") # Uses OpenAI

# Anthropic (Claude)
RailsAi.configure { |c| c.provider = :anthropic }
RailsAi.chat("Hello") # Uses Anthropic

# Google Gemini
RailsAi.configure { |c| c.provider = :gemini }
RailsAi.chat("Hello") # Uses Gemini

# Dummy (Testing)
RailsAi.configure { |c| c.provider = :dummy }
RailsAi.chat("Hello") # Uses dummy provider
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `provider` | Symbol | `:openai` | AI provider to use |
| `default_model` | String | `"gpt-4o-mini"` | Default AI model |
| `token_limit` | Integer | `4000` | Token limit for requests |
| `cache_ttl` | Integer | `3600` | Cache time-to-live in seconds |
| `stub_responses` | Boolean | `false` | Stub responses for testing |
| `connection_pool_size` | Integer | `10` | HTTP connection pool size |
| `compression_threshold` | Integer | `1024` | Compression threshold in bytes |
| `batch_size` | Integer | `10` | Batch processing size |
| `flush_interval` | Float | `0.1` | Batch flush interval in seconds |
| `enable_performance_monitoring` | Boolean | `true` | Enable performance monitoring |
| `enable_request_deduplication` | Boolean | `true` | Enable request deduplication |
| `enable_compression` | Boolean | `true` | Enable response compression |

### Environment Variables

```bash
# OpenAI
OPENAI_API_KEY=your_openai_api_key

# Anthropic (Claude)
ANTHROPIC_API_KEY=your_anthropic_api_key

# Google Gemini
GEMINI_API_KEY=your_gemini_api_key
```

### Provider-Specific Models

#### OpenAI Models
```ruby
text_models = ["gpt-4o-mini", "gpt-4o", "gpt-3.5-turbo"]
image_models = ["dall-e-3", "dall-e-2"]
audio_models = ["tts-1", "tts-1-hd"]
embedding_models = ["text-embedding-3-small", "text-embedding-3-large"]
```

#### Anthropic Models
```ruby
text_models = ["claude-3-sonnet-20240229", "claude-3-haiku-20240307", "claude-3-opus-20240229"]
vision_models = ["claude-3-sonnet-20240229", "claude-3-opus-20240229"]
```

#### Gemini Models
```ruby
text_models = ["gemini-1.5-pro", "gemini-1.5-flash", "gemini-1.0-pro"]
vision_models = ["gemini-1.5-pro", "gemini-1.5-flash"]
```

## 🚨 Error Handling

### Common Exceptions

#### `RailsAi::Provider::RateLimited`
Raised when API rate limit is exceeded.

```ruby
begin
  RailsAi.chat("Hello")
rescue RailsAi::Provider::RateLimited => e
  # Handle rate limiting
  sleep(1)
  retry
end
```

#### `RailsAi::Provider::UnsafeInputError`
Raised when input contains unsafe content.

```ruby
begin
  RailsAi.chat("Unsafe content")
rescue RailsAi::Provider::UnsafeInputError => e
  # Handle unsafe input
  Rails.logger.warn("Unsafe input detected: #{e.message}")
end
```

#### `NotImplementedError`
Raised when operation is not supported by current provider.

```ruby
begin
  RailsAi.configure { |c| c.provider = :gemini }
  RailsAi.generate_image("A sunset")
rescue NotImplementedError => e
  # Handle unsupported operation
  Rails.logger.warn("Operation not supported: #{e.message}")
  # Switch to supported provider
  RailsAi.configure { |c| c.provider = :openai }
  RailsAi.generate_image("A sunset")
end
```

#### `LoadError`
Raised when required gem is not installed.

```ruby
begin
  RailsAi.configure { |c| c.provider = :anthropic }
  RailsAi.chat("Hello")
rescue LoadError => e
  # Handle missing gem
  Rails.logger.error("Missing gem: #{e.message}")
  # Install gem or use different provider
end
```

#### `StandardError`
General errors from AI providers.

```ruby
begin
  RailsAi.chat("Hello")
rescue StandardError => e
  # Handle general errors
  Rails.logger.error("AI operation failed: #{e.message}")
end
```

### Error Handling Best Practices

```ruby
def safe_ai_operation
  RailsAi.chat("Hello")
rescue RailsAi::Provider::RateLimited => e
  # Retry with exponential backoff
  sleep(2 ** retry_count)
  retry
rescue RailsAi::Provider::UnsafeInputError => e
  # Log and return safe response
  Rails.logger.warn("Unsafe input: #{e.message}")
  "I cannot process that request."
rescue NotImplementedError => e
  # Switch to supported provider
  Rails.logger.warn("Operation not supported: #{e.message}")
  RailsAi.configure { |c| c.provider = :openai }
  RailsAi.chat("Hello")
rescue StandardError => e
  # Log and return fallback
  Rails.logger.error("AI error: #{e.message}")
  "Sorry, I'm having trouble right now."
end
```

### Provider Fallback Strategy

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

---

This API documentation provides comprehensive coverage of all Rails AI methods and their usage across multiple providers. For more examples and advanced usage, see the [Basic Usage](Basic-Usage.md) and [Advanced Topics](Advanced-Topics.md) guides. 🚀
