# frozen_string_literal: true

module RailsAi
  module Cache
    def self.fetch(key, **opts, &block)
      if defined?(Rails) && Rails.cache
        Rails.cache.fetch([:rails_ai, key], {expires_in: RailsAi.config.cache_ttl}.merge(opts), &block)
      elsif block_given?
        # Fallback for when Rails cache is not available (e.g., in tests)
        block.call
      end
    end
  end
end
