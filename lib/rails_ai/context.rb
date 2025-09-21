# frozen_string_literal: true

module RailsAi
  class Context < ActiveSupport::CurrentAttributes
    attribute :user_id, :request_id
  end
end
