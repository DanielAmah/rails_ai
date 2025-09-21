# frozen_string_literal: true

module RailsAi
  module Security
    class ErrorHandler
      def self.handle_security_error(error, context = {})
        # Log security error
        AuditLogger.log_security_event(:security_error, {
          error_class: error.class.name,
          error_message: error.message,
          context: context,
          timestamp: Time.now
        })
        
        # Return sanitized error message
        sanitized_message = sanitize_error_message(error)
        
        # In production, don't expose internal details
        if Rails.env.production?
          case error
          when ValidationError
            "Invalid input provided"
          when RateLimitError
            "Rate limit exceeded. Please try again later"
          when SecurityError
            "Security error occurred"
          else
            "An error occurred while processing your request"
          end
        else
          sanitized_message
        end
      end
      
      def self.sanitize_error_message(error)
        message = error.message.to_s
        
        # Remove sensitive information
        message = message.gsub(/api[_-]?key/i, 'API_KEY')
        message = message.gsub(/password/i, 'PASSWORD')
        message = message.gsub(/secret/i, 'SECRET')
        message = message.gsub(/token/i, 'TOKEN')
        
        # Remove file paths
        message = message.gsub(%r{/[a-zA-Z0-9_/.-]+}, '[PATH]')
        
        # Remove IP addresses
        message = message.gsub(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/, '[IP]')
        
        # Remove URLs
        message = message.gsub(%r{https?://[^\s]+}, '[URL]')
        
        message
      end
      
      def self.log_and_raise(error, context = {})
        handle_security_error(error, context)
        raise error
      end
    end
  end
end
