# frozen_string_literal: true

module RailsAi
  class GenerateSummaryJob < ApplicationJob
    queue_as :default

    def perform(content, model: nil, **options)
      model ||= RailsAi.config.default_model

      summary = RailsAi.chat(
        "Please provide a concise summary of the following content: #{content}",
        model: model,
        **options
      )

      RailsAi::Events.log!(
        kind: :summary,
        name: "generated",
        payload: {content_length: content.length, model: model}
      )

      summary
    end
  end
end
