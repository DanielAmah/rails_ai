# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi do
  describe "version compatibility" do
    it "detects Rails version correctly" do
      expect(RailsAi.rails_version).to eq(Rails.version.to_s)
    end

    it "has correct version detection methods" do
      expect(RailsAi).to respond_to(:rails_8?)
      expect(RailsAi).to respond_to(:rails_7?)
      expect(RailsAi).to respond_to(:rails_6?)
      expect(RailsAi).to respond_to(:rails_5?)
    end
  end

  describe "configuration" do
    it "has a config object" do
      expect(RailsAi.config).to be_a(RailsAi::Config)
    end

    it "can be configured" do
      RailsAi.configure do |config|
        config.provider = :dummy
        config.default_model = "test-model"
      end

      expect(RailsAi.config.provider).to eq(:dummy)
      expect(RailsAi.config.default_model).to eq("test-model")
    end
  end

  describe "text-based AI functionality" do
    before do
      RailsAi.configure do |config|
        config.provider = :dummy
        config.stub_responses = true
      end
    end

    it "can generate chat responses" do
      response = RailsAi.chat("Hello world")
      expect(response).to be_a(String)
    end

    it "can generate embeddings" do
      embeddings = RailsAi.embed(["test text"])
      expect(embeddings).to be_an(Array)
    end

    it "can summarize content" do
      summary = RailsAi.summarize("This is a long text that needs summarization")
      expect(summary).to be_a(String)
    end
  end

  describe "image generation functionality" do
    before do
      RailsAi.configure do |config|
        config.provider = :dummy
        config.stub_responses = true
      end
    end

    it "can generate images" do
      image = RailsAi.generate_image("A beautiful sunset")
      expect(image).to be_a(String)
      expect(image).to start_with("data:image/")
    end

    it "can edit images" do
      image = RailsAi.edit_image("test_image", "Add a rainbow")
      expect(image).to be_a(String)
      expect(image).to start_with("data:image/")
    end

    it "can create image variations" do
      variation = RailsAi.create_variation("test_image")
      expect(variation).to be_a(String)
      expect(variation).to start_with("data:image/")
    end

    it "can analyze images" do
      analysis = RailsAi.analyze_image("test_image", "What do you see?")
      expect(analysis).to be_a(String)
    end
  end

  describe "video generation functionality" do
    before do
      RailsAi.configure do |config|
        config.provider = :dummy
        config.stub_responses = true
      end
    end

    it "can generate videos" do
      video = RailsAi.generate_video("A cat playing with a ball")
      expect(video).to be_a(String)
      expect(video).to start_with("data:video/")
    end

    it "can edit videos" do
      video = RailsAi.edit_video("test_video", "Add background music")
      expect(video).to be_a(String)
      expect(video).to start_with("data:video/")
    end

    it "can analyze videos" do
      analysis = RailsAi.analyze_video("test_video", "What's happening?")
      expect(analysis).to be_a(String)
    end
  end

  describe "audio generation functionality" do
    before do
      RailsAi.configure do |config|
        config.provider = :dummy
        config.stub_responses = true
      end
    end

    it "can generate speech" do
      speech = RailsAi.generate_speech("Hello, world!")
      expect(speech).to be_a(String)
      expect(speech).to start_with("data:audio/")
    end

    it "can transcribe audio" do
      transcription = RailsAi.transcribe_audio("test_audio")
      expect(transcription).to be_a(String)
    end
  end
end
