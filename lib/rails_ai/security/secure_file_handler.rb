# frozen_string_literal: true

require 'tempfile'

module RailsAi
  module Security
    class SecureFileHandler
      def self.safe_file_read(path)
        validate_path = InputValidator.validate_file_path(path)
        
        File.open(validate_path, 'rb') do |file|
          content = file.read(InputValidator::MAX_FILE_SIZE)
          if file.eof?
            content
          else
            raise ValidationError, "File too large"
          end
        end
      end

      def self.safe_temp_file(content, extension = '.tmp')
        temp_file = Tempfile.new(['rails_ai', extension])
        temp_file.binmode
        temp_file.write(content)
        temp_file.rewind
        temp_file
      end

      def self.safe_file_size(path)
        File.size(InputValidator.validate_file_path(path))
      end

      def self.safe_file_exists?(path)
        return false if path.nil?
        
        begin
          InputValidator.validate_file_path(path)
          true
        rescue ValidationError
          false
        end
      end
    end
  end
end
