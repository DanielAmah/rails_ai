# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rails AI Security Integration" do
  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "Input Validation" do
    it "validates text input" do
      expect { RailsAi.validate_input("valid text") }.not_to raise_error
      expect { RailsAi.validate_input(nil) }.to raise_error(RailsAi::Security::ValidationError)
      expect { RailsAi.validate_input("") }.to raise_error(RailsAi::Security::ValidationError)
    end

    it "validates file paths" do
      temp_file = Tempfile.new('test')
      temp_file.write("test content")
      temp_file.close
      
      expect { RailsAi.validate_input(temp_file.path, type: :file_path) }.not_to raise_error
      expect { RailsAi.validate_input("../../../etc/passwd", type: :file_path) }.to raise_error(RailsAi::Security::ValidationError)
      
      temp_file.unlink
    end

    it "validates URLs" do
      expect { RailsAi.validate_input("https://example.com", type: :url) }.not_to raise_error
      expect { RailsAi.validate_input("http://localhost:8080", type: :url) }.to raise_error(RailsAi::Security::ValidationError)
    end
  end

  describe "Content Sanitization" do
    it "sanitizes dangerous content" do
      dangerous_content = "<script>alert('xss')</script>Hello"
      sanitized = RailsAi.sanitize_content(dangerous_content)
      expect(sanitized).not_to include("<script>")
      expect(sanitized).to include("Hello")
    end

    it "handles nil content" do
      expect(RailsAi.sanitize_content(nil)).to be_nil
    end
  end

  describe "API Key Management" do
    it "masks API keys" do
      masked = RailsAi.mask_api_key("sk-1234567890abcdef")
      expect(masked).to eq("sk-1***cdef")
    end

    it "handles short keys" do
      masked = RailsAi.mask_api_key("short")
      expect(masked).to eq("***")
    end
  end

  describe "Security Event Logging" do
    it "logs security events" do
      expect { RailsAi.log_security_event(:test_event, { test: "data" }) }.not_to raise_error
    end
  end

  describe "Error Handling" do
    it "handles security errors gracefully" do
      error = RailsAi::Security::ValidationError.new("Test error")
      result = RailsAi.handle_security_error(error, { context: "test" })
      expect(result).to be_a(String)
    end
  end

  describe "Provider Security" do
    it "uses secure adapters" do
      expect(RailsAi.provider).to be_a(RailsAi::Providers::SecureOpenAIAdapter)
    end

    it "validates inputs in chat" do
      expect { RailsAi.chat("test") }.not_to raise_error
    end

    it "validates inputs in stream" do
      expect { RailsAi.stream("test") { |token| } }.not_to raise_error
    end
  end

  describe "Rate Limiting" do
    it "enforces rate limits" do
      # This would need to be tested with actual rate limiting
      expect { RailsAi.chat("test") }.not_to raise_error
    end
  end

  describe "File Security" do
    it "validates file operations" do
      temp_file = Tempfile.new('test')
      temp_file.write("test content")
      temp_file.close
      
      expect { RailsAi.analyze_image(temp_file.path, "test prompt") }.not_to raise_error
      
      temp_file.unlink
    end
  end
end
