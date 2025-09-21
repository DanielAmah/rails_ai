# frozen_string_literal: true

module RailsAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        copy_file "initializer.rb", "config/initializers/rails_ai.rb"
      end

      def create_migrations
        copy_file "ai_migrations.rb", "db/migrate/#{Time.current.strftime("%Y%m%d%H%M%S")}_create_ai_tables.rb"
      end

      def create_jobs
        copy_file "summarizer_job.rb", "app/jobs/ai/generate_summary_job.rb"
        copy_file "summarizer_service.rb", "app/services/ai/summarizer_service.rb"
      end

      def create_helpers
        copy_file "ai_helper.rb", "app/helpers/ai_helper.rb"
      end

      def create_components
        copy_file "ai_widget_component.rb", "app/components/ai/prompt_component.rb"
      end

      def add_routes
        route 'mount RailsAi::Engine, at: "/rails_ai"'
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
