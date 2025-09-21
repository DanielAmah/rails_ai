# frozen_string_literal: true

require "net/http"
require "json"
require "base64"

module RailsAi
  module Providers
    class OpenAIAdapter < Base
      OPENAI_API_BASE = "https://api.openai.com/v1"
      
      def initialize
        @api_key = ENV.fetch("OPENAI_API_KEY")
        super
      end

      # Text-based operations
      def chat!(messages:, model:, **opts)
        return "(stubbed) #{messages.last[:content]}" if RailsAi.config.stub_responses
        
        response = make_request(
          "chat/completions",
          {
            model: model,
            messages: messages,
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
        
        make_streaming_request(
          "chat/completions",
          {
            model: model,
            messages: messages,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            temperature: opts[:temperature] || 0.7,
            top_p: opts[:top_p] || 1.0,
            frequency_penalty: opts[:frequency_penalty] || 0.0,
            presence_penalty: opts[:presence_penalty] || 0.0,
            stream: true,
            **opts.except(:max_tokens, :temperature, :top_p, :frequency_penalty, :presence_penalty, :stream)
          }
        ) do |chunk|
          text = chunk.dig("choices", 0, "delta", "content")
          on_token.call(text) if text
        end
      end

      def embed!(texts:, model:, **opts)
        return Array.new(texts.length) { [0.0] * 1536 } if RailsAi.config.stub_responses
        
        # Handle both single and batch embedding requests
        if texts.length == 1
          response = make_request(
            "embeddings",
            {
              model: model,
              input: texts.first,
              **opts
            }
          )
          [response.dig("data", 0, "embedding")]
        else
          response = make_request(
            "embeddings",
            {
              model: model,
              input: texts,
              **opts
            }
          )
          response.dig("data").map { |item| item["embedding"] }
        end
      end

      # Image generation - DALL-E 3 and DALL-E 2
      def generate_image!(prompt:, model: "dall-e-3", size: "1024x1024", quality: "standard", **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        response = make_request(
          "images/generations",
          {
            model: model,
            prompt: prompt,
            size: size,
            quality: quality,
            n: opts[:n] || 1,
            response_format: opts[:response_format] || "url",
            **opts.except(:n, :response_format)
          }
        )
        
        # Return the first image URL or base64 data
        image_data = response.dig("data", 0, "url") || response.dig("data", 0, "b64_json")
        if image_data
          if image_data.start_with?("http")
            # Convert URL to base64 for consistency
            convert_url_to_base64(image_data)
          else
            "data:image/png;base64,#{image_data}"
          end
        else
          raise "Image generation failed: No image data in response"
        end
      end

      def edit_image!(image:, prompt:, mask: nil, size: "1024x1024", **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        # Prepare form data for image editing
        form_data = {
          image: prepare_image_file(image),
          prompt: prompt,
          size: size,
          n: opts[:n] || 1,
          response_format: opts[:response_format] || "url",
          **opts.except(:n, :response_format)
        }
        
        form_data[:mask] = prepare_image_file(mask) if mask
        
        response = make_form_request("images/edits", form_data)
        
        image_data = response.dig("data", 0, "url") || response.dig("data", 0, "b64_json")
        if image_data
          if image_data.start_with?("http")
            convert_url_to_base64(image_data)
          else
            "data:image/png;base64,#{image_data}"
          end
        else
          raise "Image editing failed: No image data in response"
        end
      end

      def create_variation!(image:, size: "1024x1024", **opts)
        return "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" if RailsAi.config.stub_responses
        
        form_data = {
          image: prepare_image_file(image),
          size: size,
          n: opts[:n] || 1,
          response_format: opts[:response_format] || "url",
          **opts.except(:n, :response_format)
        }
        
        response = make_form_request("images/variations", form_data)
        
        image_data = response.dig("data", 0, "url") || response.dig("data", 0, "b64_json")
        if image_data
          if image_data.start_with?("http")
            convert_url_to_base64(image_data)
          else
            "data:image/png;base64,#{image_data}"
          end
        else
          raise "Image variation failed: No image data in response"
        end
      end

      # Video generation - Sora and other video models
      def generate_video!(prompt:, model: "sora", duration: 5, **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        
        response = make_request(
          "video/generations",
          {
            model: model,
            prompt: prompt,
            duration: duration,
            size: opts[:size] || "1280x720",
            quality: opts[:quality] || "standard",
            **opts.except(:size, :quality)
          }
        )
        
        video_data = response.dig("data", 0, "url") || response.dig("data", 0, "b64_json")
        if video_data
          if video_data.start_with?("http")
            convert_url_to_base64(video_data, "video/mp4")
          else
            "data:video/mp4;base64,#{video_data}"
          end
        else
          raise "Video generation failed: No video data in response"
        end
      end

      def edit_video!(video:, prompt:, **opts)
        return "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ=" if RailsAi.config.stub_responses
        
        form_data = {
          video: prepare_video_file(video),
          prompt: prompt,
          **opts
        }
        
        response = make_form_request("video/edits", form_data)
        
        video_data = response.dig("data", 0, "url") || response.dig("data", 0, "b64_json")
        if video_data
          if video_data.start_with?("http")
            convert_url_to_base64(video_data, "video/mp4")
          else
            "data:video/mp4;base64,#{video_data}"
          end
        else
          raise "Video editing failed: No video data in response"
        end
      end

      # Audio generation - TTS models
      def generate_speech!(text:, model: "tts-1", voice: "alloy", **opts)
        return "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU" if RailsAi.config.stub_responses
        
        response = make_request(
          "audio/speech",
          {
            model: model,
            input: text,
            voice: voice,
            response_format: opts[:response_format] || "mp3",
            speed: opts[:speed] || 1.0,
            **opts.except(:response_format, :speed)
          }
        )
        
        # TTS returns binary data, not JSON
        if response.is_a?(String)
          "data:audio/mp3;base64,#{Base64.strict_encode64(response)}"
        else
          raise "Speech generation failed: No audio data in response"
        end
      end

      def transcribe_audio!(audio:, model: "whisper-1", **opts)
        return "[stubbed transcription]" if RailsAi.config.stub_responses
        
        form_data = {
          file: prepare_audio_file(audio),
          model: model,
          language: opts[:language],
          prompt: opts[:prompt],
          response_format: opts[:response_format] || "json",
          temperature: opts[:temperature] || 0.0,
          **opts.except(:language, :prompt, :response_format, :temperature)
        }
        
        response = make_form_request("audio/transcriptions", form_data)
        
        if response.is_a?(String)
          response
        else
          response.dig("text")
        end
      end

      # Multimodal analysis - GPT-4 Vision and other vision models
      def analyze_image!(image:, prompt:, model: "gpt-4o", **opts)
        return "[stubbed] Image analysis: #{prompt}" if RailsAi.config.stub_responses
        
        # Prepare image for vision models
        image_data = prepare_image_for_vision(image)
        
        messages = [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: prompt
              },
              {
                type: "image_url",
                image_url: {
                  url: image_data
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "chat/completions",
          {
            model: model,
            messages: messages,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            temperature: opts[:temperature] || 0.7,
            **opts.except(:max_tokens, :temperature)
          }
        )
        
        response.dig("choices", 0, "message", "content")
      end

      def analyze_video!(video:, prompt:, model: "gpt-4o", **opts)
        return "[stubbed] Video analysis: #{prompt}" if RailsAi.config.stub_responses
        
        # For video analysis, we'll extract frames and analyze them
        # This is a simplified implementation
        video_data = prepare_video_for_vision(video)
        
        messages = [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "#{prompt}\n\nAnalyze this video content:"
              },
              {
                type: "image_url",
                image_url: {
                  url: video_data
                }
              }
            ]
          }
        ]
        
        response = make_request(
          "chat/completions",
          {
            model: model,
            messages: messages,
            max_tokens: opts[:max_tokens] || RailsAi.config.token_limit,
            temperature: opts[:temperature] || 0.7,
            **opts.except(:max_tokens, :temperature)
          }
        )
        
        response.dig("choices", 0, "message", "content")
      end

      private

      def make_request(endpoint, payload)
        uri = URI("#{OPENAI_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = payload.to_json
        
        response = http.request(request)
        
        if response.code == "200"
          JSON.parse(response.body)
        else
          error_body = JSON.parse(response.body) rescue response.body
          raise "OpenAI API error (#{response.code}): #{error_body}"
        end
      end

      def make_form_request(endpoint, form_data)
        uri = URI("#{OPENAI_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        
        # Create multipart form data
        form = []
        form_data.each do |key, value|
          if value.respond_to?(:read)
            form << [key.to_s, value, { filename: "file.#{key}" }]
          else
            form << [key.to_s, value.to_s]
          end
        end
        
        request.set_form(form, "multipart/form-data")
        
        response = http.request(request)
        
        if response.code == "200"
          # Check if response is JSON or binary
          content_type = response["content-type"]
          if content_type&.include?("application/json")
            JSON.parse(response.body)
          else
            response.body
          end
        else
          error_body = JSON.parse(response.body) rescue response.body
          raise "OpenAI API error (#{response.code}): #{error_body}"
        end
      end

      def make_streaming_request(endpoint, payload, &block)
        uri = URI("#{OPENAI_API_BASE}/#{endpoint}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
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
            raise "OpenAI API error (#{response.code}): #{error_body}"
          end
        end
      end

      def prepare_image_file(image)
        if image.is_a?(String)
          if image.start_with?("data:image/")
            # Extract base64 data
            base64_data = image.split(",")[1]
            StringIO.new(Base64.decode64(base64_data))
          else
            # Assume it's a file path
            File.open(image, "rb")
          end
        else
          image
        end
      end

      def prepare_video_file(video)
        if video.is_a?(String)
          if video.start_with?("data:video/")
            # Extract base64 data
            base64_data = video.split(",")[1]
            StringIO.new(Base64.decode64(base64_data))
          else
            # Assume it's a file path
            File.open(video, "rb")
          end
        else
          video
        end
      end

      def prepare_audio_file(audio)
        if audio.is_a?(String)
          if audio.start_with?("data:audio/")
            # Extract base64 data
            base64_data = audio.split(",")[1]
            StringIO.new(Base64.decode64(base64_data))
          else
            # Assume it's a file path
            File.open(audio, "rb")
          end
        else
          audio
        end
      end

      def prepare_image_for_vision(image)
        if image.is_a?(String)
          if image.start_with?("data:image/")
            image
          else
            # Convert file to base64 data URI
            image_data = Base64.strict_encode64(File.read(image))
            "data:image/png;base64,#{image_data}"
          end
        else
          # Convert file object to base64 data URI
          image_data = Base64.strict_encode64(image.read)
          "data:image/png;base64,#{image_data}"
        end
      end

      def prepare_video_for_vision(video)
        # For video analysis, we'll extract a frame and convert to image
        # This is a simplified implementation
        if video.is_a?(String)
          if video.start_with?("data:video/")
            # Convert video to image (simplified)
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
          else
            # Extract frame from video file (simplified)
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
          end
        else
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFc5JAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
        end
      end

      def convert_url_to_base64(url, mime_type = "image/png")
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        
        if response.code == "200"
          base64_data = Base64.strict_encode64(response.body)
          "data:#{mime_type};base64,#{base64_data}"
        else
          raise "Failed to fetch image from URL: #{response.code}"
        end
      end
    end
  end
end
