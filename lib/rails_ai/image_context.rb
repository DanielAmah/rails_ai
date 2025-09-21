# frozen_string_literal: true

module RailsAi
  class ImageContext
    attr_reader :metadata, :source, :dimensions, :file_size, :format, :created_at

    def initialize(image_data, metadata: {})
      @metadata = metadata || {}
      @source = determine_source(image_data)
      @dimensions = extract_dimensions(image_data)
      @file_size = extract_file_size(image_data)
      @format = extract_format(image_data)
      @created_at = current_time
    end

    def to_h
      {
        source: source,
        dimensions: dimensions,
        file_size: file_size,
        format: format,
        created_at: created_at.iso8601,
        metadata: metadata,
        analysis_ready: analysis_ready?
      }
    end

    def analysis_ready?
      dimensions.present? && format.present?
    end

    def self.from_file(image_file)
      new(image_file, metadata: extract_file_metadata(image_file))
    end

    def self.from_url(image_url)
      new(image_url, metadata: { url: image_url })
    end

    def self.from_base64(image_data)
      new(image_data, metadata: { encoding: 'base64' })
    end

    private

    def current_time
      if defined?(Time.current)
        Time.current
      else
        Time.now
      end
    end

    def determine_source(image_data)
      case image_data
      when String
        if image_data.start_with?('data:')
          'base64'
        elsif image_data.start_with?('http')
          'url'
        else
          'file_path'
        end
      when File, ActionDispatch::Http::UploadedFile
        'uploaded_file'
      else
        'unknown'
      end
    end

    def extract_dimensions(image_data)
      # This would need to be implemented with image processing library
      # For now, return placeholder
      { width: 'unknown', height: 'unknown' }
    end

    def extract_file_size(image_data)
      case image_data
      when String
        image_data.bytesize
      when File, ActionDispatch::Http::UploadedFile
        image_data.size
      else
        'unknown'
      end
    end

    def extract_format(image_data)
      case image_data
      when String
        if image_data.start_with?('data:')
          image_data.split(';')[0].split(':')[1]
        else
          File.extname(image_data).downcase[1..-1]
        end
      when File, ActionDispatch::Http::UploadedFile
        image_data.content_type&.split('/')&.last
      else
        'unknown'
      end
    end

    def self.extract_file_metadata(image_file)
      {
        filename: image_file.respond_to?(:original_filename) ? image_file.original_filename : 'unknown',
        content_type: image_file.respond_to?(:content_type) ? image_file.content_type : 'unknown'
      }
    end
  end
end
