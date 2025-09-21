# frozen_string_literal: true

module RailsAi
  module Security
    class AuditLogger
      def self.log_security_event(event_type, details = {})
        return unless defined?(Rails) && Rails.logger
        
        log_entry = {
          timestamp: Time.now.iso8601,
          event_type: event_type,
          details: details,
          user_id: RailsAi::Context.user_id,
          request_id: RailsAi::Context.request_id
        }
        
        Rails.logger.info("[SECURITY] #{log_entry.to_json}")
      end

      def self.log_api_call(endpoint, user_id, success: true)
        log_security_event(:api_call, {
          endpoint: endpoint,
          user_id: user_id,
          success: success,
          timestamp: Time.now
        })
      end

      def self.log_validation_error(error_type, details)
        log_security_event(:validation_error, {
          error_type: error_type,
          details: details,
          timestamp: Time.now
        })
      end

      def self.log_rate_limit_exceeded(identifier, limit)
        log_security_event(:rate_limit_exceeded, {
          identifier: identifier,
          limit: limit,
          timestamp: Time.now
        })
      end
    end
  end
end
