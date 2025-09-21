# frozen_string_literal: true

require "net/http"
require "json"
require "base64"

module RailsAi
  module Providers
    class AnthropicAdapter < Base
      ANTHROPIC_API_BASE = "https://api.anthropic.com/v1"
      
      def initialize
        @api_key = ENV.fetch("ANTHROPIC_API_KEY")
        super
      end

      # Text-based operations
      def chat!(messages:, model:, **opts)
        return "(stubbed) #{messages.last[:content]}" if RailsAi.config.stub_responses
        
        # Convert OpenAI format to Anthropic format
        anthropic_messages = convert_messages_to_anthropic(messages)
        
        response = make_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            messages: anthropic_messages,
            temperature: opts[:temperature] || 1.0,
            top_p: opts[:top_p] || 1.0,
            top_k: opts[:top_k] || 0,
            stop_sequences: opts[:stop_sequences] || [],
            **opts.except(:max_tokens, :temperature, :top_p, :top_k, :stop_sequences)
          }
        )
        
        response.dig("content", 0, "text")
      end

      def stream_chat!(messages:, model:, **opts, &on_token)
        return on_token.call("(stubbed stream)") if RailsAi.config.stub_responses
        
        # Convert OpenAI format to Anthropic format
        anthropic_messages = convert_messages_to_anthropic(messages)
        
        make_streaming_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            messages: anthropic_messages,
            temperature: opts[:temperature] || 1.0,
            top_p: opts[:top_p] || 1.0,
            top_k: opts[:top_k] || 0,
            stop_sequences: opts[:stop_sequences] || [],
            stream: true,
            **opts.except(:max_tokens, :temperature, :top_p, :top_k, :stop_sequences, :stream)
          }
        ) do |chunk|
          text = chunk.dig("delta", "text")
          on_token.call(text) if text
        end
      end

      def embed!(texts:, model:, **opts)
        return Array.new(texts.length) { [0.0] * 1024 } if RailsAi.config.stub_responses
        
        # Anthropic doesn't have a direct embedding API, but we can use their models
        # This is a placeholder implementation that could be enhanced
        texts.map do |text|
          # In a real implementation, you might use a different service for embeddings
          # or implement a workaround using Claude's text understanding
          Array.new(1024) { rand(-1.0..1.0) }
        end
      end

      # Image generation - Anthropic doesn't have image generation
      def generate_image!(prompt:, model:, **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support image generation. Use OpenAI or Gemini for image generation."
      end

      def edit_image!(image:, prompt:, **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support image editing. Use OpenAI or Gemini for image editing."
      end

      def create_variation!(image:, **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support image variations. Use OpenAI or Gemini for image variations."
      end

      # Video generation - Anthropic doesn't have video generation
      def generate_video!(prompt:, model:, **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support video generation. Use OpenAI or Gemini for video generation."
      end

      def edit_video!(video:, prompt:, **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support video editing. Use OpenAI or Gemini for video editing."
      end

      # Audio generation - Anthropic doesn't have audio generation
      def generate_speech!(text:, model:, **opts)
        return "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support speech generation. Use OpenAI or Gemini for speech generation."
      end

      def transcribe_audio!(audio:, model:, **opts)
        return "[stubbed transcription]" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support audio transcription. Use OpenAI or Gemini for audio transcription."
      end

      # Multimodal analysis - Anthropic supports image analysis with Claude 3 Vision
      def analyze_image!(image:, prompt:, model: "claude-3-5-sonnet-20241022", **opts)
        return "[stubbed] Image analysis: #{prompt}" if RailsAi.config.stub_responses
        
        # Anthropic supports image analysis with Claude 3 Vision models
        messages = [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: {
                  type: "base64",
                  media_type: detect_image_type(image),
                  data: extract_base64_data(image)
                }
              },
              {
                type: "text",
                text: prompt
              }
            ]
          }
        ]
        
        response = make_request(
          "messages",
          {
            model: model,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            messages: messages,
            temperature: opts[:temperature] || 1.0,
            top_p: opts[:top_p] || 1.0,
            top_k: opts[:top_k] || 0,
            **opts.except(:max_tokens, :temperature, :top_p, :top_k)
          }
        )
        
        response.dig("content", 0, "text")
      end

      def analyze_video!(video:, prompt:, model:, **opts)
        return "[stubbed] Video analysis: #{prompt}" if RailsAi.config.stub_responses
        raise NotImplementedError, "Anthropic doesn't support video analysis. Use OpenAI or Gemini for video analysis."
      end

      private

      def make_request(endpoint, payload)
        uri = URI("#{ANTHROPIC_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["x-api-key"] = @api_key
        request["Content-Type"] = "application/json"
        request["anthropic-version"] = "2023-06-01"
        request.body = payload.to_json
        
        response = http.request(request)
        
        if response.code == "200"
          JSON.parse(response.body)
        else
          error_body = JSON.parse(response.body) rescue response.body
          raise "Anthropic API error (#{response.code}): #{error_body}"
        end
      end

      def make_streaming_request(endpoint, payload, &block)
        uri = URI("#{ANTHROPIC_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["x-api-key"] = @api_key
        request["Content-Type"] = "application/json"
        request["anthropic-version"] = "2023-06-01"
        request.body = payload.to_json
        
        http.request(request) do |response|
          if response.code == "200"
            response.read_body do |chunk|
              # Parse streaming response chunks
              chunk.split("\n").each do |line|
                next if line.empty?
                next unless line.start_with?("data: ")
                
                data = line[6..-1] # Remove "data: " prefix
                next if data == "[DONE]"
                
                begin
                  parsed = JSON.parse(data)
                  block.call(parsed)
                rescue JSON::ParserError
                  # Skip invalid JSON chunks
                  next
                end
              end
            end
          else
            error_body = JSON.parse(response.body) rescue response.body
            raise "Anthropic API error (#{response.code}): #{error_body}"
          end
        end
      end

      def convert_messages_to_anthropic(messages)
        messages.map do |message|
          {
            role: message[:role] == "assistant" ? "assistant" : "user",
            content: message[:content]
          }
        end
      end

      def detect_image_type(image)
        if image.is_a?(String)
          if image.start_with?("data:image/")
            image.split(";")[0].split(":")[1]
          else
            "image/png" # default
          end
        else
          "image/png" # default for file objects
        end
      end

      def extract_base64_data(image)
        if image.is_a?(String) && image.include?("base64,")
          image.split("base64,")[1]
        else
          # For file objects, read and encode
          Base64.strict_encode64(image.read)
        end
      end
    end
  end
end
