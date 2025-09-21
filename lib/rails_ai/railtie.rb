# frozen_string_literal: true

module RailsAi
  class Railtie < ::Rails::Railtie
    config.rails_ai = ActiveSupport::OrderedOptions.new

    # Rails version compatibility
    if Rails.version >= "8.0"
      # Rails 8 specific configuration
      initializer "rails_ai.configure", before: :load_config_initializers do |app|
        RailsAi.configure do |c|
          c.provider ||= app.config.rails_ai.provider || :openai
          c.default_model ||= app.config.rails_ai.default_model || "gpt-4o-mini"
          c.token_limit ||= app.config.rails_ai.token_limit || 4000
          c.cache_ttl ||= app.config.rails_ai.cache_ttl || 1.hour
          c.stub_responses ||= app.config.rails_ai.stub_responses || false
        end
      end
    elsif Rails.version >= "7.0"
      # Rails 7 specific configuration
      initializer "rails_ai.configure", before: :load_config_initializers do |app|
        RailsAi.configure do |c|
          c.provider ||= app.config.rails_ai.provider || :openai
          c.default_model ||= app.config.rails_ai.default_model || "gpt-4o-mini"
          c.token_limit ||= app.config.rails_ai.token_limit || 4000
          c.cache_ttl ||= app.config.rails_ai.cache_ttl || 1.hour
          c.stub_responses ||= app.config.rails_ai.stub_responses || false
        end
      end
    else
      # Rails 5.2+ and 6.x configuration
      initializer "rails_ai.configure" do |app|
        RailsAi.configure do |c|
          c.provider ||= app.config.rails_ai.provider || :openai
          c.default_model ||= app.config.rails_ai.default_model || "gpt-4o-mini"
          c.token_limit ||= app.config.rails_ai.token_limit || 4000
          c.cache_ttl ||= app.config.rails_ai.cache_ttl || 1.hour
          c.stub_responses ||= app.config.rails_ai.stub_responses || false
        end
      end
    end

    # Common configuration for all Rails versions
    initializer "rails_ai.logger" do
      Rails.logger.info "Rails AI #{RailsAi::VERSION} loaded for Rails #{Rails.version}"
    end
  end
end
