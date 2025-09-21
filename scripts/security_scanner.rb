#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'
require 'time'

class SecurityScanner
  VULNERABILITY_DB = {
    'sql_injection' => {
      patterns: [
        /SELECT.*FROM/i,
        /INSERT.*INTO/i,
        /UPDATE.*SET/i,
        /DELETE.*FROM/i,
        /UNION.*SELECT/i,
        /DROP.*TABLE/i
      ],
      severity: 'HIGH',
      description: 'Potential SQL injection vulnerability'
    },
    'xss' => {
      patterns: [
        /<script[^>]*>.*?<\/script>/mi,
        /javascript:/i,
        /vbscript:/i,
        /on\w+\s*=/i,
        /<iframe[^>]*>.*?<\/iframe>/mi
      ],
      severity: 'HIGH',
      description: 'Potential XSS vulnerability'
    },
    'path_traversal' => {
      patterns: [
        /\.\.\//,
        /\.\.\\/,
        /\.\.%2f/i,
        /\.\.%5c/i,
        /\.\.%252f/i,
        /\.\.%255c/i
      ],
      severity: 'HIGH',
      description: 'Potential directory traversal vulnerability'
    },
    'command_injection' => {
      patterns: [
        /system\s*\(/,
        /exec\s*\(/,
        /`[^`]*`/,
        /%x\[/,
        /IO\.popen/,
        /Kernel\.system/
      ],
      severity: 'CRITICAL',
      description: 'Potential command injection vulnerability'
    },
    'hardcoded_secrets' => {
      patterns: [
        /password\s*=\s*['"][^'"]+['"]/i,
        /api[_-]?key\s*=\s*['"][^'"]+['"]/i,
        /secret\s*=\s*['"][^'"]+['"]/i,
        /token\s*=\s*['"][^'"]+['"]/i,
        /private[_-]?key\s*=\s*['"][^'"]+['"]/i
      ],
      severity: 'CRITICAL',
      description: 'Hardcoded secret detected'
    },
    'insecure_random' => {
      patterns: [
        /rand\s*\(/,
        /Random\.rand/,
        /SecureRandom\.random_bytes\s*\(\s*1\s*\)/,
        /Random\.new/
      ],
      severity: 'MEDIUM',
      description: 'Insecure random number generation'
    },
    'mass_assignment' => {
      patterns: [
        /params\[:.*\]\.permit!/,
        /params\[:.*\]\.permit\s*\(\s*\)/,
        /update_attributes\s*\(\s*params/,
        /assign_attributes\s*\(\s*params/
      ],
      severity: 'HIGH',
      description: 'Potential mass assignment vulnerability'
    },
    'unsafe_deserialization' => {
      patterns: [
        /Marshal\.load/,
        /YAML\.load/,
        /JSON\.parse\s*\(\s*.*\s*,\s*.*\s*\)/,
        /eval\s*\(/
      ],
      severity: 'CRITICAL',
      description: 'Unsafe deserialization detected'
    },
    'cors_misconfiguration' => {
      patterns: [
        /Access-Control-Allow-Origin\s*:\s*\*/,
        /Access-Control-Allow-Credentials\s*:\s*true.*Access-Control-Allow-Origin\s*:\s*\*/
      ],
      severity: 'MEDIUM',
      description: 'Potential CORS misconfiguration'
    },
    'insecure_redirect' => {
      patterns: [
        /redirect_to\s*\(\s*params/,
        /redirect_to\s*\(\s*request\.referer/,
        /redirect_to\s*\(\s*request\.url/
      ],
      severity: 'HIGH',
      description: 'Potential open redirect vulnerability'
    }
  }.freeze

  def initialize
    @results = []
    @scan_time = Time.now
  end

  def scan
    puts "🔍 Starting security scan..."
    puts "📅 Scan time: #{@scan_time}"
    puts "=" * 50

    scan_ruby_files
    scan_config_files
    scan_gemfile
    scan_github_workflows
    scan_documentation

    generate_report
    puts "✅ Security scan completed!"
    puts "📊 Results saved to: security_scan_report.json"
  end

  private

  def scan_ruby_files
    puts "🔍 Scanning Ruby files..."
    
    ruby_files = Dir.glob('lib/**/*.rb') + Dir.glob('spec/**/*.rb')
    
    ruby_files.each do |file|
      next unless File.file?(file)
      
      content = File.read(file)
      scan_file_content(file, content)
    end
  end

  def scan_config_files
    puts "🔍 Scanning configuration files..."
    
    config_files = [
      'config/application.rb',
      'config/environments/production.rb',
      'config/database.yml',
      'config/secrets.yml',
      'config/credentials.yml.enc'
    ]
    
    config_files.each do |file|
      next unless File.exist?(file)
      
      content = File.read(file)
      scan_file_content(file, content)
    end
  end

  def scan_gemfile
    puts "🔍 Scanning Gemfile..."
    
    return unless File.exist?('Gemfile')
    
    content = File.read('Gemfile')
    scan_file_content('Gemfile', content)
    
    # Check for known vulnerable gems
    check_vulnerable_gems(content)
  end

  def scan_github_workflows
    puts "🔍 Scanning GitHub workflows..."
    
    workflow_files = Dir.glob('.github/workflows/*.yml') + Dir.glob('.github/workflows/*.yaml')
    
    workflow_files.each do |file|
      next unless File.file?(file)
      
      content = File.read(file)
      scan_file_content(file, content)
    end
  end

  def scan_documentation
    puts "🔍 Scanning documentation files..."
    
    doc_files = Dir.glob('*.md') + Dir.glob('docs/**/*.md')
    
    doc_files.each do |file|
      next unless File.file?(file)
      
      content = File.read(file)
      scan_file_content(file, content)
    end
  end

  def scan_file_content(file_path, content)
    VULNERABILITY_DB.each do |vuln_type, config|
      config[:patterns].each do |pattern|
        matches = content.scan(pattern)
        
        next if matches.empty?
        
        matches.each_with_index do |match, index|
          line_number = find_line_number(content, match)
          
          @results << {
            file: file_path,
            line: line_number,
            vulnerability: vuln_type,
            severity: config[:severity],
            description: config[:description],
            match: match.to_s,
            context: get_context(content, line_number)
          }
        end
      end
    end
  end

  def check_vulnerable_gems(gemfile_content)
    vulnerable_gems = {
      'rails' => { min_version: '6.0.0', reason: 'Security updates required' },
      'rack' => { min_version: '2.0.0', reason: 'Security vulnerabilities in older versions' },
      'nokogiri' => { min_version: '1.10.0', reason: 'XML parsing vulnerabilities' },
      'json' => { min_version: '2.0.0', reason: 'JSON parsing vulnerabilities' }
    }
    
    gemfile_content.scan(/gem\s+['"]([^'"]+)['"]\s*(?:,\s*['"]([^'"]+)['"])?/) do |gem_name, version|
      if vulnerable_gems.key?(gem_name)
        gem_info = vulnerable_gems[gem_name]
        
        @results << {
          file: 'Gemfile',
          line: 0,
          vulnerability: 'vulnerable_gem',
          severity: 'MEDIUM',
          description: "Potentially vulnerable gem: #{gem_name}",
          match: "gem '#{gem_name}'",
          context: "Consider updating to version #{gem_info[:min_version]} or later",
          recommendation: gem_info[:reason]
        }
      end
    end
  end

  def find_line_number(content, match)
    lines = content.split("\n")
    lines.each_with_index do |line, index|
      return index + 1 if line.include?(match.to_s)
    end
    0
  end

  def get_context(content, line_number)
    lines = content.split("\n")
    start_line = [line_number - 3, 0].max
    end_line = [line_number + 2, lines.length - 1].min
    
    lines[start_line..end_line].join("\n")
  end

  def generate_report
    report = {
      scan_time: @scan_time.iso8601,
      total_vulnerabilities: @results.length,
      severity_counts: count_by_severity,
      vulnerabilities: @results,
      summary: generate_summary
    }
    
    File.write('security_scan_report.json', JSON.pretty_generate(report))
    
    # Generate markdown report
    generate_markdown_report(report)
  end

  def count_by_severity
    @results.group_by { |r| r[:severity] }.transform_values(&:count)
  end

  def generate_summary
    {
      critical: @results.count { |r| r[:severity] == 'CRITICAL' },
      high: @results.count { |r| r[:severity] == 'HIGH' },
      medium: @results.count { |r| r[:severity] == 'MEDIUM' },
      low: @results.count { |r| r[:severity] == 'LOW' }
    }
  end

  def generate_markdown_report(report)
    markdown = <<~MARKDOWN
      # Security Scan Report
      
      **Scan Time:** #{report[:scan_time]}
      **Total Vulnerabilities:** #{report[:total_vulnerabilities]}
      
      ## Summary
      
      | Severity | Count |
      |----------|-------|
      | Critical | #{report[:summary][:critical]} |
      | High     | #{report[:summary][:high]} |
      | Medium   | #{report[:summary][:medium]} |
      | Low      | #{report[:summary][:low]} |
      
      ## Vulnerabilities
      
    MARKDOWN
    
    @results.group_by { |r| r[:severity] }.each do |severity, vulns|
      markdown += "\n### #{severity.upcase} (#{vulns.count})\n\n"
      
      vulns.each do |vuln|
        markdown += <<~VULN
          **File:** `#{vuln[:file]}:#{vuln[:line]}`
          **Type:** #{vuln[:vulnerability]}
          **Description:** #{vuln[:description]}
          **Match:** `#{vuln[:match]}`
          
          ```ruby
          #{vuln[:context]}
          ```
          
          ---
          
        VULN
      end
    end
    
    File.write('security_scan_report.md', markdown)
  end
end

# Run the scanner
if __FILE__ == $0
  scanner = SecurityScanner.new
  scanner.scan
end
