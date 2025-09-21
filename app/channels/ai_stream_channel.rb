# frozen_string_literal: true

module RailsAi
  class AiStreamChannel < ApplicationCable::Channel
    def subscribed
      stream_from "ai_stream_#{params[:stream_id]}"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end

    def stream_ai(data)
      stream_id = data["stream_id"]
      prompt = data["prompt"]
      model = data["model"] || RailsAi.config.default_model

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
