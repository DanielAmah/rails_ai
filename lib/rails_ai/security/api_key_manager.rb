# frozen_string_literal: true

require 'openssl'
require 'securerandom'

module RailsAi
  module Security
    class APIKeyManager
      def self.encrypt_key(key)
        return nil if key.nil? || key.empty?
        
        cipher = OpenSSL::Cipher.new('AES-256-GCM')
        cipher.encrypt
        cipher.key = derive_key
        cipher.iv = SecureRandom.random_bytes(12)
        
        encrypted = cipher.update(key) + cipher.final
        auth_tag = cipher.auth_tag
        
        Base64.strict_encode64({
          data: Base64.strict_encode64(encrypted),
          iv: Base64.strict_encode64(cipher.iv),
          auth_tag: Base64.strict_encode64(auth_tag)
        }.to_json)
      end

      def self.decrypt_key(encrypted_key)
        return nil if encrypted_key.nil? || encrypted_key.empty?
        
        begin
          key_data = JSON.parse(Base64.strict_decode64(encrypted_key))
          
          cipher = OpenSSL::Cipher.new('AES-256-GCM')
          cipher.decrypt
          cipher.key = derive_key
          cipher.iv = Base64.strict_decode64(key_data['iv'])
          cipher.auth_tag = Base64.strict_decode64(key_data['auth_tag'])
          
          encrypted_data = Base64.strict_decode64(key_data['data'])
          cipher.update(encrypted_data) + cipher.final
        rescue => e
          raise SecurityError, "Failed to decrypt API key: #{e.message}"
        end
      end

      def self.mask_key(key)
        return nil if key.nil? || key.empty?
        return "***" if key.length < 8
        
        "#{key[0..3]}***#{key[-4..-1]}"
      end

      def self.secure_fetch(env_var, required: true)
        key = ENV[env_var]
        
        if key.nil? || key.empty?
          if required
            raise SecurityError, "Required environment variable #{env_var} is not set"
          else
            return nil
          end
        end
        
        # Check if key is already encrypted
        if key.start_with?('{') && key.include?('"data"')
          decrypt_key(key)
        else
          key
        end
      end

      private

      def self.derive_key
        secret = ENV['RAILS_AI_SECRET'] || Rails.application&.secret_key_base || 'default_secret'
        salt = ENV['RAILS_AI_SALT'] || 'rails_ai_default_salt'
        
        OpenSSL::PKCS5.pbkdf2_hmac_sha256(secret, salt, 100000, 32)
      end
    end
  end
end
