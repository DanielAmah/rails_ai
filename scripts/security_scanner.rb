#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

class SecurityScanner
  def initialize
    @issues = []
    @patterns = {
      hardcoded_api_key: /api[_-]?key\s*[:=]\s*['"][^'"]{10,}['"]/i,
      hardcoded_secret: /secret\s*[:=]\s*['"][^'"]{10,}['"]/i,
      hardcoded_password: /password\s*[:=]\s*['"][^'"]{6,}['"]/i,
      hardcoded_token: /token\s*[:=]\s*['"][^'"]{10,}['"]/i,
      private_key: /-----BEGIN\s+PRIVATE\s+KEY-----/i,
      ssh_key: /-----BEGIN\s+SSH\s+PRIVATE\s+KEY-----/i,
      aws_key: /AKIA[0-9A-Z]{16}/i,
      github_token: /ghp_[A-Za-z0-9]{36}/i,
      slack_token: /xox[baprs]-[A-Za-z0-9-]+/i,
      default_secret: /'default_secret'|"default_secret"/i
    }
  end

  def scan
    puts "🔍 Starting security scan..."
    
    scan_directory('lib')
    scan_directory('spec')
    # Skip scanning scripts directory to avoid false positives
    
    if @issues.empty?
      puts "✅ No security issues found"
      exit 0
    else
      puts "❌ Found #{@issues.length} security issues:"
      @issues.each_with_index do |issue, index|
        puts "#{index + 1}. #{issue[:file]}:#{issue[:line]} - #{issue[:type]}"
        puts "   #{issue[:content].strip}"
        puts
      end
      exit 1
    end
  end

  private

  def scan_directory(dir)
    return unless Dir.exist?(dir)
    
    Dir.glob("#{dir}/**/*.rb").each do |file|
      scan_file(file)
    end
  end

  def scan_file(file)
    File.readlines(file).each_with_index do |line, index|
      @patterns.each do |type, pattern|
        if pattern.match?(line) && !false_positive?(line)
          @issues << {
            file: file,
            line: index + 1,
            type: type.to_s.upcase,
            content: line
          }
        end
      end
    end
  end

  def false_positive?(line)
    # Skip comments and documentation
    return true if line.strip.start_with?('#')
    return true if line.strip.start_with?('//')
    return true if line.strip.start_with?('*')
    
    # Skip example values
    return true if line.include?('example')
    return true if line.include?('placeholder')
    return true if line.include?('your_')
    return true if line.include?('REPLACE_WITH_')
    
    # Skip test files with mock values
    return true if line.include?('test_')
    return true if line.include?('mock_')
    return true if line.include?('dummy_')
    
    # Skip environment variable references (these are safe)
    return true if line.include?('ENV[')
    return true if line.include?('ENV.fetch')
    
    # Skip configuration defaults
    return true if line.include?('config.')
    return true if line.include?('Rails.application')
    
    # Skip error messages
    return true if line.include?('raise')
    return true if line.include?('error')
    return true if line.include?('warning')
    
    # Skip pattern definitions in scanner itself
    return true if line.include?('@patterns')
    return true if line.include?('pattern =')
    
    false
  end
end

if __FILE__ == $0
  scanner = SecurityScanner.new
  scanner.scan
end
