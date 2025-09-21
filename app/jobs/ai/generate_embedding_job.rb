# frozen_string_literal: true

module RailsAi
  class GenerateEmbeddingJob < ApplicationJob
    queue_as :default

    def perform(text, model: nil, **options)
      model ||= RailsAi.config.default_model

      embedding = RailsAi.provider.embed!(
        texts: [text],
        model: model,
        **options
      ).first

      RailsAi::Events.log!(
        kind: :embedding,
        name: "generated",
        payload: {text_length: text.length, model: model}
      )

      embedding
    end
  end
end
