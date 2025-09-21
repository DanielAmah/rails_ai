# frozen_string_literal: true

require "rails"
require "concurrent-ruby"
require "zlib"
require "digest"
require "net/http"
require "json"
require "base64"
require "securerandom"
require_relative "rails_ai/version"
require_relative "rails_ai/config"
require_relative "rails_ai/context"
require_relative "rails_ai/cache"
require_relative "rails_ai/redactor"
require_relative "rails_ai/events"
require_relative "rails_ai/provider"
require_relative "rails_ai/engine"
require_relative "rails_ai/railtie"
require_relative "rails_ai/providers/base"
require_relative "rails_ai/providers/secure_openai_adapter"
require_relative "rails_ai/providers/secure_anthropic_adapter"
require_relative "rails_ai/providers/gemini_adapter"
require_relative "rails_ai/providers/dummy_adapter"
require_relative "rails_ai/context_analyzer"
require_relative "rails_ai/window_context"
require_relative "rails_ai/image_context"
require_relative "rails_ai/performance"
require_relative "rails_ai/agents/base_agent"
require_relative "rails_ai/agents/memory"
require_relative "rails_ai/agents/agent_manager"
require_relative "rails_ai/agents/message_bus"
require_relative "rails_ai/agents/task_queue"
require_relative "rails_ai/agents/agent_team"
require_relative "rails_ai/agents/collaboration"
require_relative "rails_ai/agents/specialized_agents"
require_relative "rails_ai/security"

module RailsAi
  # Performance optimizations
  @connection_pool = nil
  @batch_processor = nil
  @smart_cache = nil
  @request_deduplicator = nil
  @performance_monitor = nil
  @agent_manager = nil

  class << self
    # Version compatibility helpers
    def rails_version
      Rails.version.to_s
    end

    def rails_8?
      Rails.version >= "8.0"
    end

    def rails_7?
      Rails.version >= "7.0" && Rails.version < "8.0"
    end

    def rails_6?
      Rails.version >= "6.0" && Rails.version < "7.0"
    end

    def rails_5?
      Rails.version >= "5.2" && Rails.version < "6.0"
    end

    # Performance-optimized provider with lazy loading
    def provider
      @provider ||= Performance::LazyProvider.new do
        case config.provider.to_sym
        when :openai then Providers::SecureOpenAIAdapter.new
        when :anthropic then Providers::SecureAnthropicAdapter.new
        when :gemini then Providers::GeminiAdapter.new
        when :dummy then Providers::DummyAdapter.new
        else Providers::DummyAdapter.new
        end
      end
    end

    # Agent management
    def agent_manager
      @agent_manager ||= Agents::AgentManager.new
    end

    def create_agent(name:, role:, capabilities: [], **opts)
      agent = Agents::BaseAgent.new(
        name: name,
        role: role,
        capabilities: capabilities,
        **opts
      )
      agent_manager.register_agent(agent)
      agent
    end

    def create_research_agent(name: "ResearchAgent", **opts)
      agent = Agents::ResearchAgent.new(name: name, **opts)
      agent_manager.register_agent(agent)
      agent
    end

    def create_creative_agent(name: "CreativeAgent", **opts)
      agent = Agents::CreativeAgent.new(name: name, **opts)
      agent_manager.register_agent(agent)
      agent
    end

    def create_technical_agent(name: "TechnicalAgent", **opts)
      agent = Agents::TechnicalAgent.new(name: name, **opts)
      agent_manager.register_agent(agent)
      agent
    end

    def create_coordinator_agent(name: "CoordinatorAgent", **opts)
      agent = Agents::CoordinatorAgent.new(name: name, **opts)
      agent_manager.register_agent(agent)
      agent
    end

    def get_agent(name)
      agent_manager.get_agent(name)
    end

    def list_agents
      agent_manager.list_agents
    end

    def start_agents!
      agent_manager.start!
    end

    def stop_agents!
      agent_manager.stop!
    end

    # Task management
    def submit_task(task)
      agent_manager.submit_task(task)
    end

    def assign_task(task, agent_name)
      agent_manager.assign_task_to_agent(task, agent_name)
    end

    def auto_assign_task(task)
      agent_manager.auto_assign_task(task)
    end

    # Agent teams
    def create_agent_team(name, agents, strategy: :round_robin)
      agent_manager.create_agent_team(name, agents, collaboration_strategy: strategy)
    end

    def orchestrate_collaboration(task, agent_names)
      agent_manager.orchestrate_collaboration(task, agent_names)
    end

    # Agent communication
    def send_agent_message(from_agent, to_agent, message)
      agent_manager.send_message(from_agent, to_agent, message)
    end

    def broadcast_agent_message(from_agent, message, exclude: [])
      agent_manager.broadcast_message(from_agent, message, exclude: exclude)
    end

    # Agent monitoring
    def agent_system_status
      agent_manager.system_status
    end

    def agent_health_check
      agent_manager.health_check
    end

    # Performance monitoring
    def performance_monitor
      @performance_monitor ||= Performance::PerformanceMonitor.new
    end

    def metrics
      performance_monitor.metrics
    end

    # Connection pool for HTTP requests
    def connection_pool
      @connection_pool ||= Performance::ConnectionPool.new(size: config.connection_pool_size)
    end

    # Smart caching with compression
    def smart_cache
      @smart_cache ||= Performance::SmartCache.new(
        compression_threshold: config.compression_threshold
      )
    end

    # Request deduplication
    def request_deduplicator
      @request_deduplicator ||= Performance::RequestDeduplicator.new
    end

    # Batch processor for multiple operations
    def batch_processor
      @batch_processor ||= Performance::BatchProcessor.new(
        batch_size: config.batch_size,
        flush_interval: config.flush_interval
      )
    end

    # Optimized text-based AI operations with performance monitoring
    def chat(prompt_or_messages, model: config.default_model, **opts)
      performance_monitor.measure(:chat) do
        messages = normalize_messages(prompt_or_messages)
        cache_key = [:chat, model, messages.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.chat!(messages: messages, model: model, **opts)
          end
        end
      end
    end

    def stream(prompt_or_messages, model: config.default_model, **opts, &block)
      performance_monitor.measure(:stream) do
        messages = normalize_messages(prompt_or_messages)
        
        # Use connection pool for streaming
        connection_pool.with_connection do |connection|
          provider.stream_chat!(messages: messages, model: model, **opts, &block)
        end
      end
    end

    def embed(texts, model: config.default_model, **opts)
      performance_monitor.measure(:embed) do
        texts = Array(texts)
        cache_key = [:embed, model, texts.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.embed!(texts: texts, model: model, **opts)
          end
        end
      end
    end

    # Optimized image operations
    def generate_image(prompt, model: "dall-e-3", size: "1024x1024", quality: "standard", **opts)
      performance_monitor.measure(:generate_image) do
        cache_key = [:image, model, prompt.hash, size, quality]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.generate_image!(prompt: prompt, model: model, size: size, quality: quality, **opts)
          end
        end
      end
    end

    def edit_image(image, prompt, mask: nil, size: "1024x1024", **opts)
      performance_monitor.measure(:edit_image) do
        cache_key = [:image_edit, prompt.hash, image.hash, size]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.edit_image!(image: image, prompt: prompt, mask: mask, size: size, **opts)
          end
        end
      end
    end

    def create_variation(image, size: "1024x1024", **opts)
      performance_monitor.measure(:create_variation) do
        cache_key = [:image_variation, image.hash, size]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.create_variation!(image: image, size: size, **opts)
          end
        end
      end
    end

    # Optimized video operations
    def generate_video(prompt, model: "sora", duration: 5, **opts)
      performance_monitor.measure(:generate_video) do
        cache_key = [:video, model, prompt.hash, duration]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.generate_video!(prompt: prompt, model: model, duration: duration, **opts)
          end
        end
      end
    end

    def edit_video(video, prompt, **opts)
      performance_monitor.measure(:edit_video) do
        cache_key = [:video_edit, prompt.hash, video.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.edit_video!(video: video, prompt: prompt, **opts)
          end
        end
      end
    end

    # Optimized audio operations
    def generate_speech(text, model: "tts-1", voice: "alloy", **opts)
      performance_monitor.measure(:generate_speech) do
        cache_key = [:speech, model, text.hash, voice]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.generate_speech!(text: text, model: model, voice: voice, **opts)
          end
        end
      end
    end

    def transcribe_audio(audio, model: "whisper-1", **opts)
      performance_monitor.measure(:transcribe_audio) do
        cache_key = [:transcription, model, audio.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.transcribe_audio!(audio: audio, model: model, **opts)
          end
        end
      end
    end

    # Optimized multimodal analysis
    def analyze_image(image, prompt, model: "gpt-4o", **opts)
      performance_monitor.measure(:analyze_image) do
        cache_key = [:image_analysis, model, prompt.hash, image.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.analyze_image!(image: image, prompt: prompt, model: model, **opts)
          end
        end
      end
    end

    def analyze_video(video, prompt, model: "gpt-4o", **opts)
      performance_monitor.measure(:analyze_video) do
        cache_key = [:video_analysis, model, prompt.hash, video.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.analyze_video!(video: video, prompt: prompt, model: model, **opts)
          end
        end
      end
    end

    # Batch operations for multiple requests
    def batch_chat(requests)
      performance_monitor.measure(:batch_chat) do
        requests.map do |request|
          batch_processor.add_operation(-> { chat(request[:prompt], **request.except(:prompt)) })
        end
      end
    end

    def batch_embed(texts_array)
      performance_monitor.measure(:batch_embed) do
        texts_array.map do |texts|
          batch_processor.add_operation(-> { embed(texts) })
        end
      end
    end

    # Context-aware AI operations (optimized)
    def analyze_image_with_context(image, prompt, user_context: {}, window_context: {}, image_context: {}, **opts)
      performance_monitor.measure(:analyze_image_with_context) do
        cache_key = [:context_image_analysis, prompt.hash, image.hash, user_context.hash, window_context.hash, image_context.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          analyzer = ContextAnalyzer.new(
            user_context: user_context,
            window_context: window_context,
            image_context: image_context
          )
          analyzer.analyze_with_context(image, prompt, **opts)
        end
      end
    end

    def generate_with_context(prompt, user_context: {}, window_context: {}, **opts)
      performance_monitor.measure(:generate_with_context) do
        cache_key = [:context_generate, prompt.hash, user_context.hash, window_context.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          analyzer = ContextAnalyzer.new(
            user_context: user_context,
            window_context: window_context
          )
          analyzer.generate_with_context(prompt, **opts)
        end
      end
    end

    def generate_image_with_context(prompt, user_context: {}, window_context: {}, **opts)
      performance_monitor.measure(:generate_image_with_context) do
        cache_key = [:context_image_generate, prompt.hash, user_context.hash, window_context.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          analyzer = ContextAnalyzer.new(
            user_context: user_context,
            window_context: window_context
          )
          analyzer.generate_image_with_context(prompt, **opts)
        end
      end
    end

    # Convenience methods for common AI tasks (optimized)
    def summarize(content, **opts)
      chat("Summarize the following content: #{content}", **opts)
    end

    def translate(content, target_language, **opts)
      chat("Translate the following content to #{target_language}: #{content}", **opts)
    end

    def classify(content, categories, **opts)
      chat("Classify the following content into one of these categories: #{categories.join(", ")}. Content: #{content}", **opts)
    end

    def extract_entities(content, **opts)
      chat("Extract named entities from the following content: #{content}", **opts)
    end

    def generate_code(prompt, language: "ruby", **opts)
      chat("Generate #{language} code for: #{prompt}", **opts)
    end

    def explain_code(code, language: "ruby", **opts)
      chat("Explain this #{language} code: #{code}", **opts)
    end

    # Performance utilities
    def warmup!
      # Pre-initialize components for faster first requests
      provider
      connection_pool
      smart_cache
      request_deduplicator
      batch_processor
      agent_manager
    end

    def clear_cache!
      Rails.cache.delete_matched("rails_ai:*") if defined?(Rails) && Rails.cache
    end

    def reset_performance_metrics!
      @performance_monitor = Performance::PerformanceMonitor.new
    end

    private

    def normalize_messages(prompt_or_messages)
      messages = prompt_or_messages.is_a?(Array) ? prompt_or_messages : [{role: "user", content: prompt_or_messages}]
      text = RailsAi::Redactor.call(messages.last[:content])
      messages[-1] = messages.last.merge(content: text)
      messages
    end
  end

  # Security methods
  def self.validate_input(input, type: :text)
    Security::InputValidator.send("validate_#{type}_input", input)
  end

  def self.sanitize_content(content)
    Security::ContentSanitizer.sanitize_content(content)
  end

  def self.secure_api_key(env_var, required: true)
    Security::APIKeyManager.secure_fetch(env_var, required: required)
  end

  def self.mask_api_key(key)
    Security::APIKeyManager.mask_key(key)
  end

  def self.log_security_event(event_type, details = {})
    Security::AuditLogger.log_security_event(event_type, details)
  end

  def self.handle_security_error(error, context = {})
    Security::ErrorHandler.handle_security_error(error, context)
  end
require_relative "rails_ai/web_search"

  # Web-enhanced chat with real-time information

  # Web-enhanced chat with real-time information
  def self.chat_with_web_search(prompt, model: config.default_model, **opts)
    # Check if the prompt needs web search
    web_keywords = ['current', 'latest', 'today', 'now', 'recent', 'weather', 'news', 'stock', 'price']
    needs_web_search = web_keywords.any? { |keyword| prompt.downcase.include?(keyword) }
    
    if needs_web_search
      begin
        # Perform web search
        search_results = WebSearch.search(prompt, num_results: 3)
        
        # Enhance the prompt with web results
        web_context = "\n\nRecent web search results:\n"
        search_results.each_with_index do |result, index|
          web_context += "#{index + 1}. #{result[:title]}\n   #{result[:snippet]}\n   Source: #{result[:link]}\n\n"
        end
        
        enhanced_prompt = "#{prompt}\n\nPlease use the following web search results to provide current, up-to-date information:#{web_context}"
        
        # Get AI response with web context
        chat(enhanced_prompt, model: model, **opts)
      rescue WebSearch::SearchError => e
        # Fallback to regular chat if web search fails
        chat(prompt, model: model, **opts)
      end
    else
      # Regular chat for non-time-sensitive queries
      chat(prompt, model: model, **opts)
    end
  end
end

  # Response cleaning utility
  def self.clean_response(raw_response)
    return nil if raw_response.nil?

    # Convert to string
    response = raw_response.to_s
    
    # Ensure UTF-8 encoding
    response = response.encode('UTF-8', 'UTF-8', invalid: :replace, undef: :replace, replace: '?')
    
    # Remove any control characters that might cause issues
    response = response.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, '')
    
    response
  end

  # Enhanced chat method with automatic response cleaning
  def self.chat_clean(prompt_or_messages, model: config.default_model, **opts)
    raw_response = chat(prompt_or_messages, model: model, **opts)
    clean_response(raw_response)
  end

  # Enhanced web search chat with automatic response cleaning
  def self.chat_with_web_search_clean(prompt, model: config.default_model, **opts)
    raw_response = chat_with_web_search(prompt, model: model, **opts)
    clean_response(raw_response)
  end
end
