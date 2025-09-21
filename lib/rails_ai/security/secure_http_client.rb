# frozen_string_literal: true

require 'net/http'
require 'timeout'
require 'uri'

module RailsAi
  module Security
    class SecureHTTPClient
      DEFAULT_TIMEOUT = 30
      MAX_REDIRECTS = 5
      
      def self.make_request(url, options = {})
        uri = URI.parse(url)
        
        # Security validations
        validate_url(uri)
        
        http = create_secure_http_client(uri)
        request = create_secure_request(uri, options)
        
        # Set security headers
        set_security_headers(request)
        
        # Execute request with timeout
        execute_with_timeout(http, request, options[:timeout] || DEFAULT_TIMEOUT)
      end
      
      def self.make_streaming_request(url, options = {}, &block)
        uri = URI.parse(url)
        
        # Security validations
        validate_url(uri)
        
        http = create_secure_http_client(uri)
        request = create_secure_request(uri, options)
        
        # Set security headers
        set_security_headers(request)
        
        # Execute streaming request
        execute_streaming_request(http, request, options[:timeout] || DEFAULT_TIMEOUT, &block)
      end
      
      private
      
      def self.validate_url(uri)
        unless %w[http https].include?(uri.scheme)
          raise SecurityError, "Invalid URL scheme: #{uri.scheme}"
        end
        
        if blocked_host?(uri.host)
          raise SecurityError, "URL blocked for security reasons: #{uri.host}"
        end
        
        if private_ip?(uri.host)
          raise SecurityError, "Private IP addresses not allowed: #{uri.host}"
        end
      end
      
      def self.create_secure_http_client(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        
        # Security settings
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
        
        # Timeout settings
        http.read_timeout = DEFAULT_TIMEOUT
        http.open_timeout = 10
        http.ssl_timeout = 10
        
        # Disable SSL compression
        http.ssl_version = :TLSv1_2
        
        http
      end
      
      def self.create_secure_request(uri, options)
        case options[:method]&.upcase || 'GET'
        when 'GET'
          Net::HTTP::Get.new(uri)
        when 'POST'
          request = Net::HTTP::Post.new(uri)
          request.body = options[:body] if options[:body]
          request
        when 'PUT'
          request = Net::HTTP::Put.new(uri)
          request.body = options[:body] if options[:body]
          request
        else
          raise SecurityError, "Unsupported HTTP method: #{options[:method]}"
        end
      end
      
      def self.set_security_headers(request)
        request['User-Agent'] = 'RailsAI/1.0'
        request['Accept'] = 'application/json'
        request['Connection'] = 'close'
        request['Cache-Control'] = 'no-cache'
        
        # Security headers
        request['X-Requested-With'] = 'RailsAI'
        request['X-Content-Type-Options'] = 'nosniff'
        request['X-Frame-Options'] = 'DENY'
        request['X-XSS-Protection'] = '1; mode=block'
      end
      
      def self.execute_with_timeout(http, request, timeout)
        Timeout.timeout(timeout) do
          response = http.request(request)
          validate_response(response)
          response
        end
      rescue Timeout::Error
        raise SecurityError, "Request timeout after #{timeout} seconds"
      rescue => e
        raise SecurityError, "HTTP request failed: #{e.message}"
      end
      
      def self.execute_streaming_request(http, request, timeout, &block)
        Timeout.timeout(timeout) do
          http.request(request) do |response|
            validate_response(response)
            
            response.read_body do |chunk|
              block.call(chunk) if block
            end
          end
        end
      rescue Timeout::Error
        raise SecurityError, "Streaming request timeout after #{timeout} seconds"
      rescue => e
        raise SecurityError, "Streaming request failed: #{e.message}"
      end
      
      def self.validate_response(response)
        case response.code.to_i
        when 200..299
          response
        when 400..499
          raise SecurityError, "Client error: #{response.code} #{response.message}"
        when 500..599
          raise SecurityError, "Server error: #{response.code} #{response.message}"
        else
          raise SecurityError, "Unexpected response: #{response.code} #{response.message}"
        end
      end
      
      def self.blocked_host?(host)
        return true if host.nil?
        
        blocked_hosts = %w[
          localhost 127.0.0.1 0.0.0.0 ::1
          metadata.google.internal
          instance-data.ec2.internal
          169.254.169.254
        ]
        
        blocked_hosts.any? { |blocked| host == blocked || host.end_with?(".#{blocked}") }
      end
      
      def self.private_ip?(host)
        return false if host.nil?
        
        require 'ipaddr'
        begin
          ip = IPAddr.new(host)
          ip.private? || ip.loopback? || ip.link_local?
        rescue IPAddr::InvalidAddressError
          false
        end
      end
    end
  end
end
