# frozen_string_literal: true

module RailsAi
  module Providers
    class Base
      # Text-based AI operations
      def chat!(messages:, model:, **opts)
        raise NotImplementedError
      end

      def stream_chat!(messages:, model:, **opts, &on_token)
        raise NotImplementedError
      end

      def embed!(texts:, model:, **opts)
        raise NotImplementedError
      end

      # Image generation
      def generate_image!(prompt:, model: "dall-e-3", size: "1024x1024", quality: "standard", **opts)
        raise NotImplementedError
      end

      def edit_image!(image:, prompt:, mask: nil, size: "1024x1024", **opts)
        raise NotImplementedError
      end

      def create_variation!(image:, size: "1024x1024", **opts)
        raise NotImplementedError
      end

      # Video generation
      def generate_video!(prompt:, model: "sora", duration: 5, **opts)
        raise NotImplementedError
      end

      def edit_video!(video:, prompt:, **opts)
        raise NotImplementedError
      end

      # Audio generation
      def generate_speech!(text:, model: "tts-1", voice: "alloy", **opts)
        raise NotImplementedError
      end

      def transcribe_audio!(audio:, model: "whisper-1", **opts)
        raise NotImplementedError
      end

      # Multimodal operations
      def analyze_image!(image:, prompt:, model: "gpt-4-vision-preview", **opts)
        raise NotImplementedError
      end

      def analyze_video!(video:, prompt:, model: "gpt-4-vision-preview", **opts)
        raise NotImplementedError
      end
    end
  end
end
