# frozen_string_literal: true

module RailsAi
  class ContextAnalyzer
    attr_reader :user_context, :window_context, :image_context

    def initialize(user_context: nil, window_context: nil, image_context: nil)
      @user_context = user_context || {}
      @window_context = window_context || {}
      @image_context = image_context || {}
    end

    def analyze_with_context(image, prompt, **opts)
      enhanced_prompt = build_context_aware_prompt(image, prompt)
      
      RailsAi.analyze_image(image, enhanced_prompt, **opts)
    end

    def generate_with_context(prompt, **opts)
      enhanced_prompt = build_context_aware_prompt(nil, prompt)
      
      RailsAi.chat(enhanced_prompt, **opts)
    end

    def generate_image_with_context(prompt, **opts)
      enhanced_prompt = build_context_aware_prompt(nil, prompt)
      
      RailsAi.generate_image(enhanced_prompt, **opts)
    end

    private

    def build_context_aware_prompt(image, original_prompt)
      context_parts = []
      
      # Add user context
      if user_context.any?
        context_parts << "User Context: #{format_context(user_context)}"
      end
      
      # Add window/application context
      if window_context.any?
        context_parts << "Application Context: #{format_context(window_context)}"
      end
      
      # Add image context if analyzing an image
      if image && image_context.any?
        context_parts << "Image Context: #{format_context(image_context)}"
      end
      
      # Add current time and date context
      context_parts << "Current Time: #{current_time}"
      
      # Add Rails environment context
      context_parts << "Environment: #{Rails.env}" if defined?(Rails)
      
      # Combine all context with the original prompt
      if context_parts.any?
        "#{context_parts.join('\n\n')}\n\nOriginal Request: #{original_prompt}"
      else
        original_prompt
      end
    end

    def format_context(context_hash)
      context_hash.map do |key, value|
        case value
        when Hash
          "#{key}: #{format_context(value)}"
        when Array
          "#{key}: #{value.join(', ')}"
        else
          "#{key}: #{value}"
        end
      end.join('\n')
    end

    def current_time
      if defined?(Time.current)
        Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')
      else
        Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')
      end
    end
  end
end
