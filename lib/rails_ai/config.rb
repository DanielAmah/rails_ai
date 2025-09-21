# frozen_string_literal: true

module RailsAi
  Config = Struct.new(
    :provider, 
    :default_model, 
    :token_limit, 
    :cache_ttl, 
    :stub_responses,
    :connection_pool_size,
    :compression_threshold,
    :batch_size,
    :flush_interval,
    :enable_performance_monitoring,
    :enable_request_deduplication,
    :enable_compression,
    keyword_init: true
  )

  def self.config
    @config ||= Config.new(
      provider: :openai,
      default_model: "gpt-4o-mini",
      token_limit: 4000,
      cache_ttl: 3600, # 1 hour in seconds
      stub_responses: false,
      connection_pool_size: 10,
      compression_threshold: 1024, # bytes
      batch_size: 10,
      flush_interval: 0.1, # seconds
      enable_performance_monitoring: true,
      enable_request_deduplication: true,
      enable_compression: true
    )
  end

  def self.configure
    yield config
  end
end
