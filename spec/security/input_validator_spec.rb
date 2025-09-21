# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Security::InputValidator do
  describe ".validate_text_input" do
    it "validates normal text" do
      result = described_class.validate_text_input("Hello world")
      expect(result).to eq("Hello world")
    end

    it "rejects nil input" do
      expect { described_class.validate_text_input(nil) }.to raise_error(RailsAi::Security::ValidationError, "Text cannot be nil")
    end

    it "rejects empty input" do
      expect { described_class.validate_text_input("") }.to raise_error(RailsAi::Security::ValidationError, "Text cannot be empty")
    end

    it "rejects text that is too long" do
      long_text = "a" * 10001
      expect { described_class.validate_text_input(long_text) }.to raise_error(RailsAi::Security::ValidationError, /Text too long/)
    end

    it "rejects text with control characters" do
      expect { described_class.validate_text_input("Hello\x00world") }.to raise_error(RailsAi::Security::ValidationError, /invalid characters/)
    end
  end

  describe ".validate_file_path" do
    it "validates normal file path" do
      # Create a temporary file for testing
      temp_file = Tempfile.new('test')
      temp_file.write("test content")
      temp_file.close
      
      result = described_class.validate_file_path(temp_file.path)
      expect(result).to eq(File.expand_path(temp_file.path))
      
      temp_file.unlink
    end

    it "rejects directory traversal attempts" do
      expect { described_class.validate_file_path("../../../etc/passwd") }.to raise_error(RailsAi::Security::ValidationError, /directory traversal/)
    end

    it "rejects tilde expansion" do
      expect { described_class.validate_file_path("~/secret_file") }.to raise_error(RailsAi::Security::ValidationError, /directory traversal/)
    end

    it "rejects non-existent files" do
      expect { described_class.validate_file_path("/nonexistent/file") }.to raise_error(RailsAi::Security::ValidationError, /File not found/)
    end
  end

  describe ".validate_url" do
    it "validates normal URLs" do
      result = described_class.validate_url("https://example.com")
      expect(result).to eq("https://example.com")
    end

    it "rejects localhost URLs" do
      expect { described_class.validate_url("http://localhost:8080") }.to raise_error(RailsAi::Security::ValidationError, /URL blocked/)
    end

    it "rejects private IP addresses" do
      expect { described_class.validate_url("http://192.168.1.1") }.to raise_error(RailsAi::Security::ValidationError, /URL blocked/)
    end

    it "rejects invalid schemes" do
      expect { described_class.validate_url("ftp://example.com") }.to raise_error(RailsAi::Security::ValidationError, /Invalid URL scheme/)
    end

    it "rejects malformed URLs" do
      expect { described_class.validate_url("not-a-url") }.to raise_error(RailsAi::Security::ValidationError, /Invalid URL format/)
    end
  end

  describe ".validate_messages" do
    it "validates normal messages" do
      messages = [
        { role: "user", content: "Hello" },
        { role: "assistant", content: "Hi there" }
      ]
      
      result = described_class.validate_messages(messages)
      expect(result).to eq(messages)
    end

    it "rejects nil messages" do
      expect { described_class.validate_messages(nil) }.to raise_error(RailsAi::Security::ValidationError, "Messages cannot be nil")
    end

    it "rejects non-array messages" do
      expect { described_class.validate_messages("not an array") }.to raise_error(RailsAi::Security::ValidationError, "Messages must be an array")
    end

    it "rejects empty messages" do
      expect { described_class.validate_messages([]) }.to raise_error(RailsAi::Security::ValidationError, "Messages cannot be empty")
    end

    it "rejects too many messages" do
      messages = Array.new(101) { { role: "user", content: "test" } }
      expect { described_class.validate_messages(messages) }.to raise_error(RailsAi::Security::ValidationError, /Too many messages/)
    end

    it "rejects invalid message format" do
      messages = [{ role: "user" }] # missing content
      expect { described_class.validate_messages(messages) }.to raise_error(RailsAi::Security::ValidationError, /missing content/)
    end

    it "rejects invalid roles" do
      messages = [{ role: "hacker", content: "test" }]
      expect { described_class.validate_messages(messages) }.to raise_error(RailsAi::Security::ValidationError, /invalid role/)
    end
  end
end
