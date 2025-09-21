# frozen_string_literal: true

module RailsAi
  class PromptComponent < ViewComponent::Base
    def initialize(prompt:, model: nil, stream_id: nil, placeholder: "Ask me anything...", **options)
      @prompt = prompt
      @model = model || RailsAi.config.default_model
      @stream_id = stream_id || SecureRandom.uuid
      @placeholder = placeholder
      @options = options
    end

    private

    attr_reader :prompt, :model, :stream_id, :placeholder, :options

    def ai_endpoint
      Rails.application.routes.url_helpers.rails_ai_api_v1_chat_index_path
    end

    def stream_endpoint
      Rails.application.routes.url_helpers.rails_ai_streams_path
    end
  end
end
