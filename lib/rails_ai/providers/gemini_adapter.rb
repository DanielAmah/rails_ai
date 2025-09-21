# frozen_string_literal: true

require "net/http"
require "json"
require "base64"

module RailsAi
  module Providers
    class GeminiAdapter < Base
      GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta"
      
      def initialize
        @api_key = ENV.fetch("GEMINI_API_KEY")
        super
      end

      # Text-based operations
      def chat!(messages:, model:, **opts)
        return "(stubbed) #{messages.last[:content]}" if RailsAi.config.stub_responses
        
        # Convert OpenAI format to Gemini format
        gemini_messages = convert_messages_to_gemini(messages)
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: gemini_messages,
            generationConfig: {
              maxOutputTokens: opts[:max_tokens] || RailsAi.config.token_limit,
              temperature: opts[:temperature] || 0.7,
              topP: opts[:top_p] || 0.8,
              topK: opts[:top_k] || 40,
              **opts.except(:max_tokens, :temperature, :top_p, :top_k)
            }
          }
        )
        
        response.dig("candidates", 0, "content", "parts", 0, "text")
      end

      def stream_chat!(messages:, model:, **opts, &on_token)
        return on_token.call("(stubbed stream)") if RailsAi.config.stub_responses
        
        # Convert OpenAI format to Gemini format
        gemini_messages = convert_messages_to_gemini(messages)
        
        make_streaming_request(
          "models/#{model}:streamGenerateContent",
          {
            contents: gemini_messages,
            generationConfig: {
              maxOutputTokens: opts[:max_tokens] || RailsAi.config.token_limit,
              temperature: opts[:temperature] || 0.7,
              topP: opts[:top_p] || 0.8,
              topK: opts[:top_k] || 40,
              **opts.except(:max_tokens, :temperature, :top_p, :top_k)
            }
          }
        ) do |chunk|
          text = chunk.dig("candidates", 0, "content", "parts", 0, "text")
          on_token.call(text) if text
        end
      end

      def embed!(texts:, model:, **opts)
        return Array.new(texts.length) { [0.0] * 768 } if RailsAi.config.stub_responses
        
        # Gemini has embedding models
        response = make_request(
          "models/#{model}:embedContent",
          {
            content: {
              parts: texts.map { |text| { text: text } }
            }
          }
        )
        
        # Handle both single and batch embedding responses
        if texts.length == 1
          [response.dig("embedding", "values")]
        else
          # For multiple texts, we need to make separate requests or use batch embedding
          texts.map do |text|
            single_response = make_request(
              "models/#{model}:embedContent",
              {
                content: {
                  parts: [{ text: text }]
                }
              }
            )
            single_response.dig("embedding", "values")
          end
        end
      end

      # Image generation - Gemini 2.0 Flash supports image generation
      def generate_image!(prompt:, model: "gemini-2.0-flash-exp", **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        # Use Gemini 2.0 Flash for image generation
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: [
              {
                parts: [
                  {
                    text: "Generate an image: #{prompt}"
                  }
                ]
              }
            ],
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.7,
              **opts
            }
          }
        )
        
        # Extract image data from response
        image_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if image_data
          "data:image/png;base64,#{image_data}"
        else
          # Fallback: return a placeholder or raise error
          raise "Image generation failed: No image data in response"
        end
      end

      def edit_image!(image:, prompt:, **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        # Gemini doesn't have direct image editing, but we can use it to generate variations
        image_prompt = "Edit this image: #{prompt}. Show the edited version."
        
        contents = [
          {
            parts: [
              { text: image_prompt },
              {
                inlineData: {
                  mimeType: detect_image_type(image),
                  data: extract_base64_data(image)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/gemini-2.0-flash-exp:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.7,
              **opts
            }
          }
        )
        
        # Extract generated image data
        image_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if image_data
          "data:image/png;base64,#{image_data}"
        else
          raise "Image editing failed: No image data in response"
        end
      end

      def create_variation!(image:, **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        # Create variations using Gemini 2.0 Flash
        variation_prompt = "Create a variation of this image with similar style but different composition."
        
        contents = [
          {
            parts: [
              { text: variation_prompt },
              {
                inlineData: {
                  mimeType: detect_image_type(image),
                  data: extract_base64_data(image)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/gemini-2.0-flash-exp:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.8,
              **opts
            }
          }
        )
        
        image_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if image_data
          "data:image/png;base64,#{image_data}"
        else
          raise "Image variation failed: No image data in response"
        end
      end

      # Video generation - Gemini 2.0 Flash supports video generation
      def generate_video!(prompt:, model: "gemini-2.0-flash-exp", **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: [
              {
                parts: [
                  {
                    text: "Generate a video: #{prompt}"
                  }
                ]
              }
            ],
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.7,
              **opts
            }
          }
        )
        
        video_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if video_data
          "data:video/mp4;base64,#{video_data}"
        else
          raise "Video generation failed: No video data in response"
        end
      end

      def edit_video!(video:, prompt:, **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        
        video_prompt = "Edit this video: #{prompt}. Show the edited version."
        
        contents = [
          {
            parts: [
              { text: video_prompt },
              {
                inlineData: {
                  mimeType: "video/mp4",
                  data: extract_base64_data(video)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/gemini-2.0-flash-exp:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.7,
              **opts
            }
          }
        )
        
        video_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if video_data
          "data:video/mp4;base64,#{video_data}"
        else
          raise "Video editing failed: No video data in response"
        end
      end

      # Audio generation - Gemini 2.0 Flash supports audio generation
      def generate_speech!(text:, model: "gemini-2.0-flash-exp", **opts)
        return "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU" if RailsAi.config.stub_responses
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: [
              {
                parts: [
                  {
                    text: "Generate speech for: #{text}"
                  }
                ]
              }
            ],
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.7,
              **opts
            }
          }
        )
        
        audio_data = response.dig("candidates", 0, "content", "parts", 0, "inlineData", "data")
        if audio_data
          "data:audio/mp3;base64,#{audio_data}"
        else
          raise "Speech generation failed: No audio data in response"
        end
      end

      def transcribe_audio!(audio:, model: "gemini-2.0-flash-exp", **opts)
        return "[stubbed transcription]" if RailsAi.config.stub_responses
        
        contents = [
          {
            parts: [
              {
                text: "Transcribe this audio:"
              },
              {
                inlineData: {
                  mimeType: "audio/mp3",
                  data: extract_base64_data(audio)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: 1000,
              temperature: opts[:temperature] || 0.1,
              **opts
            }
          }
        )
        
        response.dig("candidates", 0, "content", "parts", 0, "text")
      end

      # Multimodal analysis - Gemini supports image and video analysis
      def analyze_image!(image:, prompt:, model: "gemini-2.0-flash-exp", **opts)
        return "[stubbed] Image analysis: #{prompt}" if RailsAi.config.stub_responses
        
        contents = [
          {
            parts: [
              { text: prompt },
              {
                inlineData: {
                  mimeType: detect_image_type(image),
                  data: extract_base64_data(image)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: opts[:max_tokens] || RailsAi.config.token_limit,
              temperature: opts[:temperature] || 0.7,
              topP: opts[:top_p] || 0.8,
              topK: opts[:top_k] || 40,
              **opts.except(:max_tokens, :temperature, :top_p, :top_k)
            }
          }
        )
        
        response.dig("candidates", 0, "content", "parts", 0, "text")
      end

      def analyze_video!(video:, prompt:, model: "gemini-2.0-flash-exp", **opts)
        return "[stubbed] Video analysis: #{prompt}" if RailsAi.config.stub_responses
        
        contents = [
          {
            parts: [
              { text: prompt },
              {
                inlineData: {
                  mimeType: "video/mp4",
                  data: extract_base64_data(video)
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "models/#{model}:generateContent",
          {
            contents: contents,
            generationConfig: {
              maxOutputTokens: opts[:max_tokens] || RailsAi.config.token_limit,
              temperature: opts[:temperature] || 0.7,
              topP: opts[:top_p] || 0.8,
              topK: opts[:top_k] || 40,
              **opts.except(:max_tokens, :temperature, :top_p, :top_k)
            }
          }
        )
        
        response.dig("candidates", 0, "content", "parts", 0, "text")
      end

      private

      def make_request(endpoint, payload)
        uri = URI("#{GEMINI_API_BASE}/#{endpoint}?key=#{@api_key}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = payload.to_json
        
        response = http.request(request)
        
        if response.code == "200"
          JSON.parse(response.body)
        else
          error_body = JSON.parse(response.body) rescue response.body
          raise "Gemini API error (#{response.code}): #{error_body}"
        end
      end

      def make_streaming_request(endpoint, payload, &block)
        uri = URI("#{GEMINI_API_BASE}/#{endpoint}?key=#{@api_key}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
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
            raise "Gemini API error (#{response.code}): #{error_body}"
          end
        end
      end

      def convert_messages_to_gemini(messages)
        messages.map do |message|
          {
            role: message[:role] == "assistant" ? "model" : "user",
            parts: [{ text: message[:content] }]
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
