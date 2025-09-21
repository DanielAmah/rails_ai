# frozen_string_literal: true

require "net/http"
require "json"
require_relative "../security"

module RailsAi
  module Providers
    class SecureAnthropicAdapter < Base
      ANTHROPIC_API_BASE = "https://api.anthropic.com/v1"
      
      def initialize
        @api_key = Security::APIKeyManager.secure_fetch("ANTHROPIC_API_KEY")
        @rate_limiter = Security::RateLimiter.new(limit: 50, window: 3600)
        super
      end

      def chat!(messages:, model:, **opts)
        return "(stubbed) #{messages.last[:content]}" if RailsAi.config.stub_responses
        
        # Security validations
        Security::InputValidator.validate_messages(messages)
        
        # Rate limiting
        @rate_limiter.check_limit("chat_#{RailsAi::Context.user_id}")
        
        # Sanitize content
        sanitized_messages = messages.map do |message|
          {
            role: message[:role],
            content: Security::ContentSanitizer.sanitize_content(message[:content])
          }
        end
        
        response = make_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            messages: sanitized_messages,
            **opts.except(:max_tokens)
          }
        )
        
        response.dig("content", 0, "text")
      end

      def stream_chat!(messages:, model:, **opts, &on_token)
        return on_token.call("(stubbed stream)") if RailsAi.config.stub_responses
        
        # Security validations
        Security::InputValidator.validate_messages(messages)
        
        # Rate limiting
        @rate_limiter.check_limit("stream_#{RailsAi::Context.user_id}")
        
        # Sanitize content
        sanitized_messages = messages.map do |message|
          {
            role: message[:role],
            content: Security::ContentSanitizer.sanitize_content(message[:content])
          }
        end
        
        make_streaming_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            messages: sanitized_messages,
            stream: true,
            **opts.except(:max_tokens, :stream)
          },
          &on_token
        )
      end

      def analyze_image!(image:, prompt:, model: "claude-3-5-sonnet-20241022", **opts)
        return "(stubbed analysis)" if RailsAi.config.stub_responses
        
        # Security validations
        Security::InputValidator.validate_text_input(prompt, max_length: 1000)
        
        # Rate limiting
        @rate_limiter.check_limit("vision_#{RailsAi::Context.user_id}")
        
        # Sanitize prompt
        sanitized_prompt = Security::ContentSanitizer.sanitize_content(prompt)
        
        # Prepare image securely
        image_data = prepare_image_securely(image)
        
        response = make_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || 1000,
            messages: [
              {
                role: "user",
                content: [
                  {
                    type: "text",
                    text: sanitized_prompt
                  },
                  {
                    type: "image",
                    source: {
                      type: "base64",
                      media_type: "image/png",
                      data: image_data
                    }
                  }
                ]
              }
            ],
            **opts.except(:max_tokens)
          }
        )
        
        response.dig("content", 0, "text")
      end

      private

      def make_request(endpoint, payload)
        Security::SecureHTTPClient.make_request(
          "#{ANTHROPIC_API_BASE}/#{endpoint}",
          method: 'POST',
          body: payload.to_json,
          headers: {
            'Authorization' => "Bearer #{@api_key}",
            'Content-Type' => 'application/json',
            'Anthropic-Version' => '2023-06-01'
          }
        )
      end

      def make_streaming_request(endpoint, payload, &on_token)
        Security::SecureHTTPClient.make_streaming_request(
          "#{ANTHROPIC_API_BASE}/#{endpoint}",
          method: 'POST',
          body: payload.to_json,
          headers: {
            'Authorization' => "Bearer #{@api_key}",
            'Content-Type' => 'application/json',
            'Anthropic-Version' => '2023-06-01'
          }
        ) do |chunk|
          parse_streaming_chunk(chunk, &on_token)
        end
      end

      def parse_streaming_chunk(chunk, &on_token)
        return if chunk.strip.empty?
        
        chunk.split("\n").each do |line|
          next unless line.start_with?("data: ")
          
          data = line[6..-1]
          next if data == "[DONE]"
          
          begin
            parsed = JSON.parse(data)
            content = parsed.dig("delta", "text")
            on_token.call(content) if content
          rescue JSON::ParserError
            # Skip invalid JSON
          end
        end
      end

      def prepare_image_securely(image)
        if image.is_a?(String)
          if image.start_with?("data:image/")
            # Validate base64 data
            Security::InputValidator.validate_base64_data(image, expected_type: :image)
            # Extract base64 data
            image.split(",")[1]
          elsif image.start_with?("http")
            # Validate URL
            Security::InputValidator.validate_url(image)
            convert_url_to_base64_securely(image)
          else
            # Validate file path
            Security::InputValidator.validate_file_path(image)
            convert_file_to_base64_securely(image)
          end
        else
          # File object - convert to base64
          convert_file_to_base64_securely(image)
        end
      end

      def convert_url_to_base64_securely(url)
        response = Security::SecureHTTPClient.make_request(url, method: 'GET')
        Base64.strict_encode64(response.body)
      end

      def convert_file_to_base64_securely(file_path)
        file_content = Security::SecureFileHandler.safe_file_read(file_path)
        Base64.strict_encode64(file_content)
      end
    end
  end
end
