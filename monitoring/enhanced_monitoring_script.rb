#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'date'
require 'csv'

class EnhancedRailsAIMonitor
  def initialize
    @search_terms = [
      '"rails_ai" gem commercial',
      '"rails_ai" business usage',
      '"rails_ai" enterprise',
      '"rails_ai" license commercial',
      '"Rails AI" gem commercial',
      '"Rails AI" business usage',
      '"Rails AI" enterprise',
      '"Rails AI" license commercial'
    ]
    
    @exclude_terms = [
      'rails_ai_tag',
      'rails-ai-tag',
      'rails_ai_image_tag',
      'rails_ai_helper'
    ]
    
    @results = []
    @log_file = "monitoring_log_#{Date.today.strftime('%Y%m%d')}.txt"
    @csv_file = "monitoring_results_#{Date.today.strftime('%Y%m%d')}.csv"
  end

  def run_enhanced_checks
    puts "🔍 Starting Enhanced Rails AI monitoring checks..."
    puts "📅 Date: #{Date.today}"
    puts "🎯 Monitoring: rails_ai gem (excluding rails_ai_tag)"
    puts "=" * 50
    
    check_rubygems_enhanced
    check_github_enhanced
    check_web_mentions
    check_social_media_mentions
    check_competitor_analysis
    
    save_results
    generate_csv_report
    send_alerts_if_needed
    
    puts "✅ Enhanced monitoring checks completed."
    puts "📊 Results saved to: #{@log_file}"
    puts "📈 CSV report saved to: #{@csv_file}"
  end

  private

  def check_rubygems_enhanced
    puts "🔍 Enhanced RubyGems monitoring..."
    
    begin
      # Check for your gem specifically
      uri = URI('https://rubygems.org/api/v1/gems/rails_ai.json')
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        gem_info = JSON.parse(response.body)
        puts "  📦 Your gem stats:"
        puts "    - Downloads: #{gem_info['downloads']}"
        puts "    - Version: #{gem_info['version']}"
        puts "    - Info: #{gem_info['info']}"
        
        @results << {
          type: 'rubygems_own',
          name: 'rails_ai',
          downloads: gem_info['downloads'],
          version: gem_info['version'],
          timestamp: Time.now
        }
      end
      
      # Check for similar gems
      uri = URI('https://rubygems.org/api/v1/search.json')
      params = { query: 'rails_ai' }
      uri.query = URI.encode_www_form(params)
      
      response = Net::HTTP.get_response(uri)
      if response.code == '200'
        gems = JSON.parse(response.body)
        
        suspicious_gems = gems.select do |gem|
          name = gem['name'].downcase
          (name.include?('rails') && name.include?('ai') && 
           !@exclude_terms.any? { |exclude| name.include?(exclude) } &&
           name != 'rails_ai')
        end
        
        if suspicious_gems.any?
          puts "  ⚠️  Found potentially related gems:"
          suspicious_gems.each do |gem|
            puts "    - #{gem['name']}: #{gem['info']}"
            @results << {
              type: 'rubygems_similar',
              name: gem['name'],
              info: gem['info'],
              downloads: gem['downloads'],
              timestamp: Time.now
            }
          end
        else
          puts "  ✅ No suspicious gems found"
        end
      end
    rescue => e
      puts "  ❌ Error checking RubyGems: #{e.message}"
    end
  end

  def check_github_enhanced
    puts "🔍 Enhanced GitHub monitoring..."
    
    # This would use GitHub API with authentication
    # For now, we'll simulate the check
    puts "  📝 GitHub API check would go here"
    puts "  🔑 Add GITHUB_PAT secret for full functionality"
  end

  def check_web_mentions
    puts "🔍 Checking web mentions..."
    
    # This would use web scraping or APIs
    # For now, we'll simulate the check
    puts "  📝 Web mention check would go here"
    puts "  🔑 Add GOOGLE_API_KEY secret for full functionality"
  end

  def check_social_media_mentions
    puts "�� Checking social media mentions..."
    
    # This would use social media APIs
    # For now, we'll simulate the check
    puts "  📝 Social media check would go here"
    puts "  🔑 Add social media API keys for full functionality"
  end

  def check_competitor_analysis
    puts "🔍 Competitor analysis..."
    
    # Check for similar AI gems
    similar_gems = [
      'openai-ruby',
      'anthropic-ruby',
      'gemini-ruby',
      'ai-ruby',
      'rails-ai-tools'
    ]
    
    similar_gems.each do |gem_name|
      begin
        uri = URI("https://rubygems.org/api/v1/gems/#{gem_name}.json")
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          gem_info = JSON.parse(response.body)
          puts "  📊 Competitor: #{gem_name} - #{gem_info['downloads']} downloads"
          
          @results << {
            type: 'competitor',
            name: gem_name,
            downloads: gem_info['downloads'],
            version: gem_info['version'],
            timestamp: Time.now
          }
        end
      rescue => e
        puts "  ⚠️  Could not check #{gem_name}: #{e.message}"
      end
    end
  end

  def save_results
    return if @results.empty?
    
    File.open(@log_file, 'a') do |file|
      file.puts "\n" + "=" * 50
      file.puts "Enhanced Rails AI Monitoring Results - #{Time.now}"
      file.puts "Excluding: rails_ai_tag and similar legitimate products"
      file.puts "=" * 50
      
      @results.each do |result|
        file.puts "Type: #{result[:type]}"
        file.puts "Name: #{result[:name]}"
        file.puts "Info: #{result[:info]}" if result[:info]
        file.puts "Downloads: #{result[:downloads]}" if result[:downloads]
        file.puts "Version: #{result[:version]}" if result[:version]
        file.puts "Timestamp: #{result[:timestamp]}"
        file.puts "-" * 30
      end
    end
  end

  def generate_csv_report
    return if @results.empty?
    
    CSV.open(@csv_file, 'w') do |csv|
      csv << ['Type', 'Name', 'Info', 'Downloads', 'Version', 'Timestamp']
      
      @results.each do |result|
        csv << [
          result[:type],
          result[:name],
          result[:info] || '',
          result[:downloads] || '',
          result[:version] || '',
          result[:timestamp]
        ]
      end
    end
  end

  def send_alerts_if_needed
    return if @results.empty?
    
    puts "🚨 ALERT: Found #{@results.length} potential issues!"
    puts "Check #{@log_file} for details"
    puts "📈 CSV report available: #{@csv_file}"
    
    # Here you could add email notifications
    # send_email_alert(@results)
  end
end

# Run the enhanced monitor
if __FILE__ == $0
  monitor = EnhancedRailsAIMonitor.new
  monitor.run_enhanced_checks
end
