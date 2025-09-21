# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Providers::AnthropicAdapter do
  let(:adapter) { described_class.new }

  before do
    allow(ENV).to receive(:fetch).with("ANTHROPIC_API_KEY").and_return("test_anthropic_key")
    RailsAi.configure do |config|
      config.provider = :anthropic
      config.stub_responses = true
    end
  end

  describe "#chat!" do
    it "generates text using Anthropic" do
      messages = [{ role: "user", content: "Hello" }]
      result = adapter.chat!(messages: messages, model: "claude-3-5-sonnet-20241022")
      
      expect(result).to be_a(String)
      expect(result).to include("Hello")
    end
  end

  describe "#stream_chat!" do
    it "streams text using Anthropic" do
      messages = [{ role: "user", content: "Hello" }]
      tokens = []
      
      adapter.stream_chat!(messages: messages, model: "claude-3-5-sonnet-20241022") do |token|
        tokens << token
      end
      
      expect(tokens).not_to be_empty
    end
  end

  describe "#embed!" do
    it "generates embeddings" do
      texts = ["Hello world", "Test text"]
      result = adapter.embed!(texts: texts, model: "claude-3-5-sonnet-20241022")
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result.first).to be_an(Array)
    end
  end

  describe "#analyze_image!" do
    it "analyzes images using Claude 3 Vision" do
      image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
      result = adapter.analyze_image!(image: image, prompt: "What do you see?", model: "claude-3-5-sonnet-20241022")
      
      expect(result).to be_a(String)
      expect(result).to include("What do you see?")
    end
  end

  describe "unsupported operations" do
    before do
      # Disable stubbing for error tests
      allow(RailsAi.config).to receive(:stub_responses).and_return(false)
    end

    it "raises NotImplementedError for image generation" do
      expect {
        adapter.generate_image!(prompt: "A sunset", model: "claude-3-5-sonnet-20241022")
      }.to raise_error(NotImplementedError, /Anthropic doesn't support image generation/)
    end

    it "raises NotImplementedError for video generation" do
      expect {
        adapter.generate_video!(prompt: "A cat playing", model: "claude-3-5-sonnet-20241022")
      }.to raise_error(NotImplementedError, /Anthropic doesn't support video generation/)
    end

    it "raises NotImplementedError for audio generation" do
      expect {
        adapter.generate_speech!(text: "Hello", model: "claude-3-5-sonnet-20241022")
      }.to raise_error(NotImplementedError, /Anthropic doesn't support speech generation/)
    end
  end

  describe "API key handling" do
    it "raises error if ANTHROPIC_API_KEY is not set" do
      allow(ENV).to receive(:fetch).with("ANTHROPIC_API_KEY").and_raise(KeyError)
      
      expect {
        described_class.new
      }.to raise_error(KeyError)
    end
  end
end
