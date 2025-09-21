# frozen_string_literal: true

require "net/http"
require "json"
require "base64"
require_relative "../security"

module RailsAi
  module Providers
    class SecureOpenAIAdapter < Base
      OPENAI_API_BASE = "https://api.openai.com/v1"
      
      def initialize
        @api_key = ENV.fetch("OPENAI_API_KEY")
        @rate_limiter = Security::RateLimiter.new(limit: 100, window: 3600)
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
          "chat/completions",
          {
            model: model,
            messages: sanitized_messages,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            temperature: opts[:temperature] || 0.7,
            top_p: opts[:top_p] || 1.0,
            frequency_penalty: opts[:frequency_penalty] || 0.0,
            presence_penalty: opts[:presence_penalty] || 0.0,
            **opts.except(:max_tokens, :temperature, :top_p, :frequency_penalty, :presence_penalty)
          }
        )
        
        response.dig("choices", 0, "message", "content")
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
          "chat/completions",
          {
            model: model,
            messages: sanitized_messages,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            temperature: opts[:temperature] || 0.7,
            top_p: opts[:top_p] || 1.0,
            frequency_penalty: opts[:frequency_penalty] || 0.0,
            presence_penalty: opts[:presence_penalty] || 0.0,
            stream: true,
            **opts.except(:max_tokens, :temperature, :top_p, :frequency_penalty, :presence_penalty, :stream)
          },
          &on_token
        )
      end

      def generate_image!(prompt:, model: "dall-e-3", size: "1024x1024", quality: "standard", **opts)
        return "(stubbed image)" if RailsAi.config.stub_responses
        
        # Security validations
        Security::InputValidator.validate_text_input(prompt, max_length: 1000)
        
        # Rate limiting
        @rate_limiter.check_limit("image_#{RailsAi::Context.user_id}")
        
        # Sanitize prompt
        sanitized_prompt = Security::ContentSanitizer.sanitize_content(prompt)
        
        response = make_request(
          "images/generations",
          {
            model: model,
            prompt: sanitized_prompt,
            size: size,
            quality: quality,
            n: opts[:n] || 1,
            **opts.except(:n)
          }
        )
        
        response.dig("data", 0, "url")
      end

      def analyze_image!(image:, prompt:, model: "gpt-4o", **opts)
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
          "chat/completions",
          {
            model: model,
            messages: [
              {
                role: "user",
                content: [
                  {
                    type: "text",
                    text: sanitized_prompt
                  },
                  {
                    type: "image_url",
                    image_url: {
                      url: image_data
                    }
                  }
                ]
              }
            ],
            max_tokens: opts[:max_tokens] || 1000,
            **opts.except(:max_tokens)
          }
        )
        
        response.dig("choices", 0, "message", "content")
      end

      private

      def make_request(endpoint, payload)
        uri = URI("#{OPENAI_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 30
        http.open_timeout = 10
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = payload.to_json
        
        response = http.request(request)
        
        case response.code.to_i
        when 200..299
          JSON.parse(response.body)
        when 429
          raise Security::RateLimitError, "OpenAI API rate limit exceeded"
        when 401
          raise Security::SecurityError, "Invalid API key"
        when 403
          raise Security::SecurityError, "API access forbidden"
        else
          raise Security::SecurityError, "API request failed: #{response.code} #{response.message}"
        end
      end

      def make_streaming_request(endpoint, payload, &on_token)
        uri = URI("#{OPENAI_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 60
        http.open_timeout = 10
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = payload.to_json
        
        http.request(request) do |response|
          case response.code.to_i
          when 200..299
            response.read_body do |chunk|
              next if chunk.strip.empty?
              
              chunk.split("\n").each do |line|
                next unless line.start_with?("data: ")
                
                data = line[6..-1]
                next if data == "[DONE]"
                
                begin
                  parsed = JSON.parse(data)
                  content = parsed.dig("choices", 0, "delta", "content")
                  on_token.call(content) if content
                rescue JSON::ParserError
                  # Skip invalid JSON
                end
              end
            end
          when 429
            raise Security::RateLimitError, "OpenAI API rate limit exceeded"
          when 401
            raise Security::SecurityError, "Invalid API key"
          when 403
            raise Security::SecurityError, "API access forbidden"
          else
            raise Security::SecurityError, "API request failed: #{response.code} #{response.message}"
          end
        end
      end

      def prepare_image_securely(image)
        if image.is_a?(String)
          if image.start_with?("data:image/")
            # Validate base64 data
            Security::InputValidator.validate_base64_data(image, expected_type: :image)
            image
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
        uri = URI(url)
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 30
        http.open_timeout = 10
        
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "RailsAI/1.0"
        
        response = http.request(request)
        
        if response.code == "200"
          base64_data = Base64.strict_encode64(response.body)
          "data:image/png;base64,#{base64_data}"
        else
          raise Security::SecurityError, "Failed to fetch image from URL: #{response.code}"
        end
      end

      def convert_file_to_base64_securely(file_path)
        file_content = Security::SecureFileHandler.safe_file_read(file_path)
        base64_data = Base64.strict_encode64(file_content)
        "data:image/png;base64,#{base64_data}"
      end
    end
  end
end
