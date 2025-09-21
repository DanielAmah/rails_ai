#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'date'

class RailsAIMonitor
  def initialize
    # Focus on YOUR specific gem, not rails_ai_tag
    @search_terms = [
      '"rails_ai" gem commercial',
      '"rails_ai" business usage',
      '"rails_ai" enterprise',
      '"rails_ai" license commercial',
      '"rails_ai" ruby gem',
      '"Rails AI" gem commercial',
      '"Rails AI" business usage',
      '"Rails AI" enterprise',
      '"Rails AI" license commercial'
    ]
    
    # Exclude rails_ai_tag and similar legitimate products
    @exclude_terms = [
      'rails_ai_tag',
      'rails-ai-tag',
      'rails_ai_image_tag',
      'rails_ai_helper'
    ]
    
    @results = []
    @log_file = "monitoring_log_#{Date.today.strftime('%Y%m%d')}.txt"
  end

  def run_daily_checks
    puts "🔍 Starting Rails AI monitoring checks..."
    puts "📅 Date: #{Date.today}"
    puts "🎯 Monitoring: rails_ai gem (excluding rails_ai_tag)"
    puts "=" * 50
    
    check_github
    check_rubygems
    check_google_search
    
    save_results
    send_alerts_if_needed
    
    puts "✅ Monitoring checks completed."
    puts "📊 Results saved to: #{@log_file}"
  end

  private

  def check_github
    puts "🔍 Checking GitHub repositories..."
    
    # Search for repositories using YOUR rails_ai gem specifically
    search_queries = [
      'rails_ai gem language:ruby',
      'Rails AI gem language:ruby',
      'rails-ai gem language:ruby',
      'rails_ai provider language:ruby',
      'rails_ai agent language:ruby'
    ]
    
    search_queries.each do |query|
      puts "  Searching: #{query}"
      # Note: GitHub API requires authentication for search
      # You would need to add your GitHub token here
    end
  end

  def check_rubygems
    puts "🔍 Checking RubyGems.org..."
    
    begin
      uri = URI('https://rubygems.org/api/v1/search.json')
      params = { query: 'rails_ai' }
      uri.query = URI.encode_www_form(params)
      
      response = Net::HTTP.get_response(uri)
      if response.code == '200'
        gems = JSON.parse(response.body)
        
        # Filter out rails_ai_tag and similar legitimate products
        suspicious_gems = gems.select do |gem|
          name = gem['name'].downcase
          # Look for your specific gem or potential infringements
          (name.include?('rails') && name.include?('ai') && 
           !@exclude_terms.any? { |exclude| name.include?(exclude) } &&
           name != 'rails_ai') # Exclude your own gem
        end
        
        if suspicious_gems.any?
          puts "  ⚠️  Found potentially related gems:"
          suspicious_gems.each do |gem|
            puts "    - #{gem['name']}: #{gem['info']}"
            @results << {
              type: 'rubygems',
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

  def check_google_search
    puts "🔍 Checking Google search results..."
    
    @search_terms.each do |term|
      puts "  Searching: #{term}"
      # Note: Google Search API requires API key
      # You would need to add your Google API key here
    end
  end

  def save_results
    return if @results.empty?
    
    File.open(@log_file, 'a') do |file|
      file.puts "\n" + "=" * 50
      file.puts "Rails AI Gem Monitoring Results - #{Time.now}"
      file.puts "Excluding: rails_ai_tag and similar legitimate products"
      file.puts "=" * 50
      
      @results.each do |result|
        file.puts "Type: #{result[:type]}"
        file.puts "Name: #{result[:name]}"
        file.puts "Info: #{result[:info]}"
        file.puts "Downloads: #{result[:downloads]}" if result[:downloads]
        file.puts "Timestamp: #{result[:timestamp]}"
        file.puts "-" * 30
      end
    end
  end

  def send_alerts_if_needed
    return if @results.empty?
    
    puts "🚨 ALERT: Found #{@results.length} potential issues!"
    puts "Check #{@log_file} for details"
    
    # Here you could add email notifications
    # send_email_alert(@results)
  end
end

# Run the monitor
if __FILE__ == $0
  monitor = RailsAIMonitor.new
  monitor.run_daily_checks
end
