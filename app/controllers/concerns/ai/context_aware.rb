# frozen_string_literal: true

module RailsAi
  module ContextAware
    extend ActiveSupport::Concern

    included do
      before_action :set_ai_context, if: :ai_context_enabled?
    end

    def ai_context_analyzer
      @ai_context_analyzer ||= RailsAi::ContextAnalyzer.new(
        user_context: ai_user_context,
        window_context: ai_window_context,
        image_context: ai_image_context
      )
    end

    def analyze_image_with_context(image, prompt, **opts)
      ai_context_analyzer.analyze_with_context(image, prompt, **opts)
    end

    def generate_with_context(prompt, **opts)
      ai_context_analyzer.generate_with_context(prompt, **opts)
    end

    def generate_image_with_context(prompt, **opts)
      ai_context_analyzer.generate_image_with_context(prompt, **opts)
    end

    private

    def set_ai_context
      RailsAi::Context.current_user_id = current_user&.id
      RailsAi::Context.current_request_id = request.uuid
    end

    def ai_context_enabled?
      respond_to?(:current_user) || respond_to?(:current_admin)
    end

    def ai_user_context
      return {} unless respond_to?(:current_user) && current_user

      {
        id: current_user.id,
        email: current_user.respond_to?(:email) ? current_user.email : nil,
        role: current_user.respond_to?(:role) ? current_user.role : 'user',
        created_at: current_user.created_at,
        last_sign_in_at: current_user.respond_to?(:last_sign_in_at) ? current_user.last_sign_in_at : nil,
        preferences: extract_user_preferences
      }.compact
    end

    def ai_window_context
      RailsAi::WindowContext.from_controller(self).to_h
    end

    def ai_image_context
      # This can be overridden in controllers to provide image-specific context
      {}
    end

    def extract_user_preferences
      return {} unless current_user.respond_to?(:preferences)

      case current_user.preferences
      when Hash
        current_user.preferences
      when String
        JSON.parse(current_user.preferences) rescue {}
      else
        {}
      end
    end
  end
end
