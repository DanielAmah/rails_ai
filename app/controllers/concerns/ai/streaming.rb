# frozen_string_literal: true

module RailsAi
  module Streaming
    extend ActiveSupport::Concern

    def stream_ai_response(prompt, model: nil, &block)
      model ||= RailsAi.config.default_model

      RailsAi.provider.stream_chat!(
        messages: [{role: "user", content: prompt}],
        model: model
      ) do |token|
        block.call(token) if block_given?
      end
    end

    def broadcast_ai_stream(stream_id, prompt, model: nil)
      model ||= RailsAi.config.default_model

      ActionCable.server.broadcast("ai_stream_#{stream_id}", {
        type: "start",
        stream_id: stream_id
      })

      RailsAi.provider.stream_chat!(
        messages: [{role: "user", content: prompt}],
        model: model
      ) do |token|
        ActionCable.server.broadcast("ai_stream_#{stream_id}", {
          type: "token",
          content: token
        })
      end

      ActionCable.server.broadcast("ai_stream_#{stream_id}", {
        type: "complete"
      })
    end
  end
end
