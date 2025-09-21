# frozen_string_literal: true

module RailsAi
  module Events
    def self.log!(kind:, name:, payload: {}, latency_ms: nil)
      ActiveSupport::Notifications.instrument("rails_ai.#{kind}", {name:, payload:, latency_ms:, user_id: RailsAi::Context.user_id, request_id: RailsAi::Context.request_id})
    end
  end
end
