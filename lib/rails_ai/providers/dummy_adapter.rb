# frozen_string_literal: true

module RailsAi
  module Providers
    class DummyAdapter < Base
      # Text-based operations
      def chat!(messages:, model:, **opts) = "[dummy] #{messages.last[:content].to_s.reverse}"
      def stream_chat!(messages:, model:, **opts, &on_token) = messages.last[:content].chars.each { |c| on_token.call(c) }
      def embed!(texts:, model:, **opts) = texts.map { |t| [t.length.to_f] }

      # Image generation
      def generate_image!(prompt:, model:, **opts) = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      def edit_image!(image:, prompt:, **opts) = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      def create_variation!(image:, **opts) = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

      # Video generation
      def generate_video!(prompt:, model:, **opts) = "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ="
      def edit_video!(video:, prompt:, **opts) = "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ="

      # Audio generation
      def generate_speech!(text:, model:, **opts) = "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU"
      def transcribe_audio!(audio:, model:, **opts) = "[dummy transcription] #{audio.class.name}"

      # Multimodal analysis
      def analyze_image!(image:, prompt:, model:, **opts) = "[dummy] Image analysis: #{prompt}"
      def analyze_video!(video:, prompt:, model:, **opts) = "[dummy] Video analysis: #{prompt}"
    end
  end
end
