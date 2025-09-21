# frozen_string_literal: true

module RailsAi
  module Embeddable
    extend ActiveSupport::Concern

    included do
      has_many :ai_embeddings, as: :embeddable, dependent: :destroy
    end

    def generate_embedding!(field: :content, model: nil)
      text = send(field)
      return if text.blank?

      model ||= RailsAi.config.default_model

      embedding = RailsAi.provider.embed!(
        texts: [text],
        model: model
      ).first

      ai_embeddings.create!(
        content: text,
        embedding: embedding,
        model: model,
        field: field.to_s
      )
    end

    def similar_records(limit: 5, threshold: 0.8)
      return [] unless ai_embeddings.any?

      # This would need to be implemented based on your vector database
      # For now, return empty array
      []
    end
  end
end
