# frozen_string_literal: true

require 'uri'
require 'ipaddr'

module RailsAi
  module Security
    class InputValidator
      MAX_FILE_SIZE = 50.megabytes
      ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
      ALLOWED_VIDEO_TYPES = %w[video/mp4 video/webm video/quicktime].freeze
      ALLOWED_AUDIO_TYPES = %w[audio/mpeg audio/wav audio/ogg audio/mp4].freeze
      
      ALLOWED_SCHEMES = %w[http https].freeze
      BLOCKED_HOSTS = %w[
        localhost 127.0.0.1 0.0.0.0 ::1
        10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
        metadata.google.internal
        instance-data.ec2.internal
      ].freeze

      def self.validate_text_input(text, max_length: 10000)
        raise ValidationError, "Text cannot be nil" if text.nil?
        
        text = text.to_s.strip
        raise ValidationError, "Text cannot be empty" if text.empty?
        raise ValidationError, "Text too long (max: #{max_length})" if text.length > max_length
        
        if text.match?(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/)
          raise ValidationError, "Text contains invalid characters"
        end
        
        text
      end

      def self.validate_file_path(path)
        raise ValidationError, "File path cannot be nil" if path.nil?
        
        path = File.expand_path(path)
        
        if path.include?('..') || path.include?('~')
          raise ValidationError, "Invalid file path: directory traversal detected"
        end
        
        unless File.exist?(path) && File.readable?(path)
          raise ValidationError, "File not found or not readable: #{path}"
        end
        
        if File.size(path) > MAX_FILE_SIZE
          raise ValidationError, "File too large (max: #{MAX_FILE_SIZE} bytes)"
        end
        
        path
      end

      def self.validate_base64_data(data, expected_type: nil)
        raise ValidationError, "Base64 data cannot be nil" if data.nil?
        
        unless data.match?(/\A[A-Za-z0-9+\/]*={0,2}\z/)
          raise ValidationError, "Invalid base64 format"
        end
        
        begin
          decoded = Base64.strict_decode64(data)
          if decoded.size > MAX_FILE_SIZE
            raise ValidationError, "Base64 data too large (max: #{MAX_FILE_SIZE} bytes)"
          end
        rescue ArgumentError
          raise ValidationError, "Invalid base64 data"
        end
        
        if expected_type && data.start_with?("data:")
          mime_type = data.split(';')[0].split(':')[1]
          unless valid_mime_type?(mime_type, expected_type)
            raise ValidationError, "Invalid MIME type: #{mime_type}"
          end
        end
        
        data
      end

      def self.validate_url(url)
        raise ValidationError, "URL cannot be nil" if url.nil?
        
        begin
          uri = URI.parse(url)
        rescue URI::InvalidURIError
          raise ValidationError, "Invalid URL format"
        end
        
        unless ALLOWED_SCHEMES.include?(uri.scheme)
          raise ValidationError, "Invalid URL scheme: #{uri.scheme}"
        end
        
        if blocked_host?(uri.host)
          raise ValidationError, "URL blocked for security reasons"
        end
        
        if private_ip?(uri.host)
          raise ValidationError, "Private IP addresses not allowed"
        end
        
        url
      end

      def self.validate_messages(messages)
        raise ValidationError, "Messages cannot be nil" if messages.nil?
        raise ValidationError, "Messages must be an array" unless messages.is_a?(Array)
        raise ValidationError, "Messages cannot be empty" if messages.empty?
        raise ValidationError, "Too many messages (max: 100)" if messages.length > 100
        
        messages.each_with_index do |message, index|
          validate_message(message, index)
        end
        
        messages
      end

      private

      def self.validate_message(message, index)
        raise ValidationError, "Message #{index} must be a hash" unless message.is_a?(Hash)
        raise ValidationError, "Message #{index} missing role" unless message[:role]
        raise ValidationError, "Message #{index} missing content" unless message[:content]
        
        valid_roles = %w[system user assistant]
        unless valid_roles.include?(message[:role])
          raise ValidationError, "Message #{index} has invalid role: #{message[:role]}"
        end
        
        validate_text_input(message[:content], max_length: 50000)
      end

      def self.valid_mime_type?(mime_type, expected_type)
        case expected_type
        when :image
          ALLOWED_IMAGE_TYPES.include?(mime_type)
        when :video
          ALLOWED_VIDEO_TYPES.include?(mime_type)
        when :audio
          ALLOWED_AUDIO_TYPES.include?(mime_type)
        else
          true
        end
      end

      def self.blocked_host?(host)
        return true if host.nil?
        
        BLOCKED_HOSTS.any? do |blocked|
          if blocked.include?('/')
            begin
              blocked_network = IPAddr.new(blocked)
              blocked_network.include?(host)
            rescue IPAddr::InvalidAddressError
              false
            end
          else
            host == blocked || host.end_with?(".#{blocked}")
          end
        end
      end

      def self.private_ip?(host)
        return false if host.nil?
        
        begin
          ip = IPAddr.new(host)
          ip.private? || ip.loopback?
        rescue IPAddr::InvalidAddressError
          false
        end
      end
    end
  end
end
