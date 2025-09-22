# frozen_string_literal: true

require 'openssl'
require 'securerandom'

module RailsAi
  module Security
    class APIKeyManager
      class << self
        def secure_fetch(key_name)
          key = ENV[key_name]
          raise "Missing required environment variable: #{key_name}" if key.nil? || key.empty?
          key
        end

        def encrypt(plaintext, key_name = 'RAILS_AI_SECRET')
          return plaintext if plaintext.nil? || plaintext.empty?
          
          key = derive_key(key_name)
          iv = SecureRandom.random_bytes(16)
          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          cipher.encrypt
          cipher.key = key
          cipher.iv = iv
          
          encrypted = cipher.update(plaintext) + cipher.final
          Base64.strict_encode64(iv + encrypted)
        end

        def decrypt(encrypted_data, key_name = 'RAILS_AI_SECRET')
          return encrypted_data if encrypted_data.nil? || encrypted_data.empty?
          
          begin
            data = Base64.strict_decode64(encrypted_data)
            iv = data[0, 16]
            encrypted = data[16..-1]
            
            key = derive_key(key_name)
            cipher = OpenSSL::Cipher.new('AES-256-CBC')
            cipher.decrypt
            cipher.key = key
            cipher.iv = iv
            
            cipher.update(encrypted) + cipher.final
          rescue => e
            Rails.logger.error "Decryption failed: #{e.message}" if defined?(Rails) && Rails.logger
            encrypted_data
          end
        end

        def generate_secure_key(length = 32)
          SecureRandom.hex(length)
        end

        def hash_key(key)
          return nil if key.nil? || key.empty?
          Digest::SHA256.hexdigest(key)
        end

        def validate_key_format(key, expected_pattern = nil)
          return false if key.nil? || key.empty?
          return true if expected_pattern.nil?
          
          key.match?(expected_pattern)
        end

        def rotate_key(old_key, new_key)
          # Implementation for key rotation
          # This would typically involve re-encrypting all data with the new key
          Rails.logger.info "Key rotation requested" if defined?(Rails) && Rails.logger
          true
        end

        def secure_store(key, value, ttl = nil)
          # Store encrypted value with optional TTL
          encrypted_value = encrypt(value)
          store_data = {
            encrypted: encrypted_value,
            created_at: Time.now.to_i,
            ttl: ttl
          }
          
          if defined?(Rails) && Rails.cache
            Rails.cache.write("secure_#{key}", store_data, expires_in: ttl)
          end
          
          store_data
        end

        def secure_retrieve(key)
          # Retrieve and decrypt stored value
          return nil unless defined?(Rails) && Rails.cache
          
          store_data = Rails.cache.read("secure_#{key}")
          return nil if store_data.nil?
          
          # Check TTL if present
          if store_data[:ttl] && (Time.now.to_i - store_data[:created_at]) > store_data[:ttl]
            Rails.cache.delete("secure_#{key}")
            return nil
          end
          
          decrypt(store_data[:encrypted])
        end

        private

        def derive_key(key_name = 'RAILS_AI_SECRET')
          secret = ENV[key_name] || Rails.application&.secret_key_base
          
          if secret.nil? || secret.empty?
            raise "Missing required secret: #{key_name}. Please set #{key_name} environment variable or configure Rails secret_key_base"
          end
          
          salt = ENV['RAILS_AI_SALT'] || 'rails_ai_secure_salt_2024'
          OpenSSL::PKCS5.pbkdf2_hmac_sha256(secret, salt, 100000, 32)
        end
      end
    end
  end
end
