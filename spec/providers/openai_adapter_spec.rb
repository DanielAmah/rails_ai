# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Providers::OpenAIAdapter do
  let(:adapter) { described_class.new }

  before do
    allow(ENV).to receive(:fetch).with("OPENAI_API_KEY").and_return("test_openai_key")
    RailsAi.configure do |config|
      config.provider = :openai
      config.stub_responses = true
    end
  end

  describe "#chat!" do
    it "generates text using OpenAI" do
      messages = [{ role: "user", content: "Hello" }]
      result = adapter.chat!(messages: messages, model: "gpt-4o")
      
      expect(result).to be_a(String)
      expect(result).to include("Hello")
    end
  end

  describe "#stream_chat!" do
    it "streams text using OpenAI" do
      messages = [{ role: "user", content: "Hello" }]
      tokens = []
      
      adapter.stream_chat!(messages: messages, model: "gpt-4o") do |token|
        tokens << token
      end
      
      expect(tokens).not_to be_empty
    end
  end

  describe "#embed!" do
    it "generates embeddings" do
      texts = ["Hello world", "Test text"]
      result = adapter.embed!(texts: texts, model: "text-embedding-3-small")
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result.first).to be_an(Array)
    end
  end

  describe "#generate_image!" do
    it "generates images using DALL-E" do
      result = adapter.generate_image!(prompt: "A sunset", model: "dall-e-3")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end

  describe "#edit_image!" do
    it "edits images using DALL-E" do
      image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      result = adapter.edit_image!(image: image, prompt: "Add a rainbow")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end

  describe "#create_variation!" do
    it "creates image variations using DALL-E" do
      image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      result = adapter.create_variation!(image: image)
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end

  describe "#generate_video!" do
    it "generates videos using Sora" do
      result = adapter.generate_video!(prompt: "A cat playing", model: "sora")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:video/")
    end
  end

  describe "#edit_video!" do
    it "edits videos using Sora" do
      video = "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ="
      result = adapter.edit_video!(video: video, prompt: "Add background music")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:video/")
    end
  end

  describe "#generate_speech!" do
    it "generates speech using TTS" do
      result = adapter.generate_speech!(text: "Hello", model: "tts-1", voice: "alloy")
      
      expect(result).to be_a(String)
      expect(result).to start_with("data:audio/")
    end
  end

  describe "#transcribe_audio!" do
    it "transcribes audio using Whisper" do
      audio = "data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA//tQxAADB8AhSmAhIIEVWWWU"
      result = adapter.transcribe_audio!(audio: audio, model: "whisper-1")
      
      expect(result).to be_a(String)
    end
  end

  describe "#analyze_image!" do
    it "analyzes images using GPT-4 Vision" do
      image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      result = adapter.analyze_image!(image: image, prompt: "What do you see?", model: "gpt-4o")
      
      expect(result).to be_a(String)
      expect(result).to include("What do you see?")
    end
  end

  describe "#analyze_video!" do
    it "analyzes videos using GPT-4 Vision" do
      video = "data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAAB1tZGF0AQAAARxtYXNrAAAAAG1wNDEAAAAAIG1kYXQ="
      result = adapter.analyze_video!(video: video, prompt: "What's happening?", model: "gpt-4o")
      
      expect(result).to be_a(String)
      expect(result).to include("What's happening?")
    end
  end

  describe "API key handling" do
    it "raises error if OPENAI_API_KEY is not set" do
      allow(ENV).to receive(:fetch).with("OPENAI_API_KEY").and_raise(KeyError)
      
      expect {
        described_class.new
      }.to raise_error(KeyError)
    end
  end
end
