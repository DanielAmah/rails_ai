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
      Rails.version.to_f
    end

    def ruby_version
      RUBY_VERSION.to_f
    end

    # Configuration
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end

    # Performance optimizations
    def connection_pool
      @connection_pool ||= Concurrent::ThreadPoolExecutor.new(
        min_threads: 2,
        max_threads: 10,
        max_queue: 100,
        auto_terminate: true
      )
    end

    def batch_processor
      @batch_processor ||= Concurrent::ThreadPoolExecutor.new(
        min_threads: 1,
        max_threads: 5,
        max_queue: 50,
        auto_terminate: true
      )
    end

    def smart_cache
      @smart_cache ||= Cache.new
    end

    def request_deduplicator
      @request_deduplicator ||= RequestDeduplicator.new
    end

    def performance_monitor
      @performance_monitor ||= Performance::Monitor.new
    end

    def agent_manager
      @agent_manager ||= Agents::AgentManager.new
    end

    # Core AI methods
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

    def embed(texts, model: "text-embedding-3-small", **opts)
      performance_monitor.measure(:embed) do
        texts_array = Array(texts)
        cache_key = [:embed, model, texts_array.hash]
        
        smart_cache.fetch(cache_key, expires_in: config.cache_ttl) do
          request_deduplicator.deduplicate(cache_key) do
            provider.embed!(texts: texts_array, model: model, **opts)
          end
        end
      end
    end

    # Multimodal capabilities
    def analyze_image(image, prompt, model: "gpt-4o", **opts)
      performance_monitor.measure(:analyze_image) do
        provider.analyze_image!(image: image, prompt: prompt, model: model, **opts)
      end
    end

    def generate_image(prompt, model: "dall-e-3", **opts)
      performance_monitor.measure(:generate_image) do
        provider.generate_image!(prompt: prompt, model: model, **opts)
      end
    end

    def analyze_video(video, prompt, model: "gpt-4o", **opts)
      performance_monitor.measure(:analyze_video) do
        provider.analyze_video!(video: video, prompt: prompt, model: model, **opts)
      end
    end

    def generate_video(prompt, model: "runway-gen-3", **opts)
      performance_monitor.measure(:generate_video) do
        provider.generate_video!(prompt: prompt, model: model, **opts)
      end
    end

    def analyze_audio(audio, prompt, model: "whisper-1", **opts)
      performance_monitor.measure(:analyze_audio) do
        provider.analyze_audio!(audio: audio, prompt: prompt, model: model, **opts)
      end
    end

    def generate_audio(prompt, model: "tts-1", **opts)
      performance_monitor.measure(:generate_audio) do
        provider.generate_audio!(prompt: prompt, model: model, **opts)
      end
    end

    # Context awareness
    def chat_with_context(prompt, context_objects = [], model: config.default_model, **opts)
      performance_monitor.measure(:chat_with_context) do
        context_analyzer = ContextAnalyzer.new
        enhanced_prompt = context_analyzer.enhance_prompt(prompt, context_objects)
        chat(enhanced_prompt, model: model, **opts)
      end
    end

    def analyze_window_context(url, referrer, user_agent, **opts)
      performance_monitor.measure(:analyze_window_context) do
        window_context = WindowContext.new(url: url, referrer: referrer, user_agent: user_agent)
        window_context.analyze(**opts)
      end
    end

    def analyze_image_context(image, **opts)
      performance_monitor.measure(:analyze_image_context) do
        image_context = ImageContext.new(image)
        image_context.analyze(**opts)
      end
    end

    # Agent system
    def create_agent(name, type: :general, **opts)
      agent_manager.create_agent(name, type: type, **opts)
    end

    def create_research_agent(name: "Research Agent", **opts)
      agent_manager.create_agent(name, type: :research, **opts)
    end

    def create_creative_agent(name: "Creative Agent", **opts)
      agent_manager.create_agent(name, type: :creative, **opts)
    end

    def create_technical_agent(name: "Technical Agent", **opts)
      agent_manager.create_agent(name, type: :technical, **opts)
    end

    def create_agent_team(name, agents, strategy: :round_robin, **opts)
      agent_manager.create_agent_team(name, agents, collaboration_strategy: strategy, **opts)
    end

    def submit_task(task, agent_team = nil)
      if agent_team
        agent_team.assign_task(task)
      else
        agent_manager.submit_task(task)
      end
    end

    # Provider management
    def provider
      case config.provider.to_sym
      when :openai then Providers::SecureOpenAIAdapter.new
      when :anthropic then Providers::SecureAnthropicAdapter.new
      when :gemini then Providers::GeminiAdapter.new
      when :dummy then Providers::DummyAdapter.new
      else Providers::DummyAdapter.new
      end
    end

    def provider=(new_provider)
      config.provider = new_provider
    end

    # Utility methods
    def normalize_messages(prompt_or_messages)
      if prompt_or_messages.is_a?(String)
        [{ role: "user", content: prompt_or_messages }]
      else
        prompt_or_messages
      end
    end

    def redact_sensitive_data(text)
      Redactor.call(text)
    end

    def log_event(kind:, name:, payload: {}, latency_ms: nil)
      Events.log!(kind: kind, name: name, payload: payload, latency_ms: latency_ms)
    end

    # Security methods
    def validate_input(input, type: :text)
      Security::InputValidator.validate(input, type: type)
    end

    def sanitize_content(content)
      Security::ContentSanitizer.sanitize(content)
    end

    def check_rate_limit(identifier, limit: 100, window: 1.hour)
      Security::RateLimiter.check(identifier, limit: limit, window: window)
    end

    def scan_for_vulnerabilities
      Security::VulnerabilityScanner.scan
    end

    def handle_security_error(error, context = {})
      Security::ErrorHandler.handle_security_error(error, context)
    end

    # Response cleaning utility
    def clean_response(raw_response)
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
    def chat_clean(prompt_or_messages, model: config.default_model, **opts)
      raw_response = chat(prompt_or_messages, model: model, **opts)
      clean_response(raw_response)
    end

    # Enhanced web search chat with automatic response cleaning
    def chat_with_web_search_clean(prompt, model: config.default_model, **opts)
      raw_response = chat_with_web_search(prompt, model: model, **opts)
      clean_response(raw_response)
    end
  end
end

require_relative "rails_ai/web_search"

# Web-enhanced chat with real-time information
def RailsAi.chat_with_web_search(prompt, model: RailsAi.config.default_model, **opts)
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
      RailsAi.chat(enhanced_prompt, model: model, **opts)
    rescue WebSearch::SearchError => e
      # Fallback to regular chat if web search fails
      RailsAi.chat(prompt, model: model, **opts)
    end
  else
    # Regular chat for non-time-sensitive queries
    RailsAi.chat(prompt, model: model, **opts)
  end
end
