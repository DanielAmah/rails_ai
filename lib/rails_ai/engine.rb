# frozen_string_literal: true

module RailsAi
  class Engine < ::Rails::Engine
    isolate_namespace RailsAi

    # Rails version compatibility
    if Rails.version >= "8.0"
      # Rails 8 specific configuration
      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.orm :active_record
      end
    elsif Rails.version >= "7.0"
      # Rails 7 specific configuration
      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
      end

      # Importmap support for Rails 7+
      initializer "rails_ai.importmap", before: "importmap" do |app|
        app.config.importmap.paths << root.join("app/assets/javascripts")
      end
    else
      # Rails 5.2+ and 6.x configuration
      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
      end
    end

    # Asset precompilation (compatible with all Rails versions)
    initializer "rails_ai.assets.precompile" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[rails_ai_manifest.js]
      end
    end

    # Routes configuration
    initializer "rails_ai.routes" do |app|
      app.routes.prepend do
        mount RailsAi::Engine, at: "/rails_ai"
      end
    end
  end
end
