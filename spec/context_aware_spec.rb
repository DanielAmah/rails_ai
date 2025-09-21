# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::ContextAnalyzer do
  let(:user_context) { { id: 1, email: "user@example.com", role: "admin" } }
  let(:window_context) { { controller: "PostsController", action: "show", params: { id: 123 } } }
  let(:image_context) { { source: "upload", format: "png", dimensions: { width: 800, height: 600 } } }
  let(:analyzer) { described_class.new(user_context: user_context, window_context: window_context, image_context: image_context) }

  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
    end
  end

  describe "#analyze_with_context" do
    it "enhances prompts with context information" do
      result = analyzer.analyze_with_context("test_image", "What do you see?")
      expect(result).to be_a(String)
      # Check for actual context content in the response
      expect(result).to include("User Context")
      expect(result).to include("Application Context")
      expect(result).to include("Image Context")
      expect(result).to include("Original Request")
    end
  end

  describe "#generate_with_context" do
    it "enhances text generation with context" do
      result = analyzer.generate_with_context("Write a summary")
      expect(result).to be_a(String)
      # The dummy adapter reverses the content, so we check for the presence of context
      # by looking for key identifiers that would be in the context
      expect(result).to include("resU") # "User" reversed
      expect(result).to include("noitacilppA") # "Application" reversed
    end
  end

  describe "#generate_image_with_context" do
    it "enhances image generation with context" do
      result = analyzer.generate_image_with_context("Create an image")
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end
end

RSpec.describe RailsAi::WindowContext do
  let(:controller) { double("Controller", class: double(name: "PostsController"), action_name: "show") }
  let(:request) { double("Request", method: "GET", path: "/posts/123", user_agent: "Mozilla/5.0", referer: "https://example.com", remote_ip: "192.168.1.1") }
  let(:params) { { id: 123, title: "Test Post" } }
  let(:session) { { user_id: 1, last_activity: Time.now } }
  let(:cookies) { { session_id: "abc123", theme: "dark" } }

  describe ".from_controller" do
    it "creates window context from controller" do
      allow(controller).to receive(:params).and_return(params)
      allow(controller).to receive(:request).and_return(request)
      allow(controller).to receive(:session).and_return(session)
      allow(controller).to receive(:cookies).and_return(cookies)

      context = described_class.from_controller(controller)
      expect(context.to_h).to include(:controller, :action, :route, :params)
    end
  end

  describe "#to_h" do
    it "returns sanitized context hash" do
      context = described_class.new(
        controller: controller,
        action: "show",
        params: params,
        request: request,
        session: session,
        cookies: cookies
      )

      result = context.to_h
      expect(result[:controller]).to eq("PostsController")
      expect(result[:action]).to eq("show")
      expect(result[:route]).to eq("GET /posts/123")
      expect(result[:params]).to eq(params)
    end
  end
end

RSpec.describe RailsAi::ImageContext do
  describe ".from_file" do
    it "creates image context from file" do
      file = double("File", size: 1024, content_type: "image/png")
      context = described_class.from_file(file)
      expect(context.to_h).to include(:source, :format, :file_size)
    end
  end

  describe ".from_url" do
    it "creates image context from URL" do
      context = described_class.from_url("https://example.com/image.jpg")
      expect(context.to_h[:source]).to eq("url")
    end
  end

  describe ".from_base64" do
    it "creates image context from base64" do
      context = described_class.from_base64("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
      expect(context.to_h[:source]).to eq("base64")
    end
  end
end

RSpec.describe "Context-aware AI operations" do
  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
    end
  end

  describe "RailsAi.analyze_image_with_context" do
    it "analyzes images with context" do
      result = RailsAi.analyze_image_with_context(
        "test_image",
        "What do you see?",
        user_context: { id: 1, role: "admin" },
        window_context: { controller: "PostsController" },
        image_context: { format: "png" }
      )
      expect(result).to be_a(String)
    end
  end

  describe "RailsAi.generate_with_context" do
    it "generates text with context" do
      result = RailsAi.generate_with_context(
        "Write a summary",
        user_context: { id: 1, role: "admin" },
        window_context: { controller: "PostsController" }
      )
      expect(result).to be_a(String)
    end
  end

  describe "RailsAi.generate_image_with_context" do
    it "generates images with context" do
      result = RailsAi.generate_image_with_context(
        "Create an image",
        user_context: { id: 1, role: "admin" },
        window_context: { controller: "PostsController" }
      )
      expect(result).to be_a(String)
      expect(result).to start_with("data:image/")
    end
  end
end
