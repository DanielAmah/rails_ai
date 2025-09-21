# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Providers::GeminiAdapter do
  let(:adapter) { described_class.new }

  before do
    allow(ENV).to receive(:fetch).with("GEMINI_API_KEY").and_return("test_gemini_key")
    RailsAi.configure do |config|
      config.provider = :gemini
      config.stub_responses = true
    end
  end

  describe "#chat!" do
    it "generates text using Gemini" do
      messages = [{ role: "user", content: "Hello" }]
      result = adapter.chat!(messages: messages, model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
      expect(result).to include("Hello")
    end
  end

  describe "#stream_chat!" do
    it "streams text using Gemini" do
      messages = [{ role: "user", content: "Hello" }]
      tokens = []
      
      adapter.stream_chat!(messages: messages, model: "gemini-2.0-flash-exp") do |token|
        tokens << token
      end
      
      expect(tokens).not_to be_empty
    end
  end

  describe "#embed!" do
    it "generates embeddings" do
      texts = ["Hello world", "Test text"]
      result = adapter.embed!(texts: texts, model: "gemini-2.0-flash-exp")
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result.first).to be_an(Array)
    end
  end

  describe "#analyze_image!" do
    it "analyzes images using Gemini Vision" do
      image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      result = adapter.analyze_image!(image: image, prompt: "What do you see?", model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
      expect(result).to include("What do you see?")
    end
  end

  describe "#generate_image!" do
    it "generates images using Gemini 2.0 Flash" do
      result = adapter.generate_image!(prompt: "A sunset", model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end

  describe "#generate_video!" do
    it "generates videos using Gemini 2.0 Flash" do
      result = adapter.generate_video!(prompt: "A cat playing", model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:video/")
    end
  end

  describe "#generate_speech!" do
    it "generates speech using Gemini 2.0 Flash" do
      result = adapter.generate_speech!(text: "Hello", model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:audio/")
    end
  end

  describe "#transcribe_audio!" do
    it "transcribes audio using Gemini 2.0 Flash" do
      audio = "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU"
      result = adapter.transcribe_audio!(audio: audio, model: "gemini-2.0-flash-exp")
      
      expect(result).to be_a(String)
    end
  end

  describe "API key handling" do
    it "raises error if GEMINI_API_KEY is not set" do
      allow(ENV).to receive(:fetch).with("GEMINI_API_KEY").and_raise(KeyError)
      
      expect {
        described_class.new
      }.to raise_error(KeyError)
    end
  end
end
