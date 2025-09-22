# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module RailsAi
  module WebSearch
    class SearchError < StandardError; end

    class GoogleSearch
      def initialize(api_key: nil, search_engine_id: nil)
        @api_key = api_key || ENV['GOOGLE_SEARCH_API_KEY']
        @search_engine_id = search_engine_id || ENV['GOOGLE_SEARCH_ENGINE_ID']
        @base_url = 'https://www.googleapis.com/customsearch/v1'
      end
      
      def search(query, num_results: 5)
        unless @api_key && !@api_key.empty?
          Rails.logger.warn "Google Search API key not configured, skipping web search" if defined?(Rails) && Rails.logger
          return []
        end
        
        unless @search_engine_id && !@search_engine_id.empty?
          Rails.logger.warn "Google Search Engine ID not configured, skipping web search" if defined?(Rails) && Rails.logger
          return []
        end
        
        uri = URI("#{@base_url}?key=#{@api_key}&cx=#{@search_engine_id}&q=#{URI.encode_www_form_component(query)}&num=#{num_results}")
        
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          parse_results(data)
        else
          Rails.logger.error "Google Search API error: #{response.code} - #{response.body}" if defined?(Rails) && Rails.logger
          []
        end
      rescue => e
        Rails.logger.error "Web search error: #{e.message}" if defined?(Rails) && Rails.logger
        []
      end
      
      private
      
      def parse_results(data)
        items = data['items'] || []
        items.map do |item|
          {
            title: item['title'],
            link: item['link'],
            snippet: item['snippet']
          }
        end
      end
    end

    class DuckDuckGoSearch
      def initialize
        @base_url = 'https://api.duckduckgo.com'
      end
      
      def search(query, num_results: 5)
        uri = URI("#{@base_url}/?q=#{URI.encode_www_form_component(query)}&format=json&no_html=1&skip_disambig=1")
        
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          parse_results(data, num_results)
        else
          Rails.logger.error "DuckDuckGo API error: #{response.code} - #{response.body}" if defined?(Rails) && Rails.logger
          []
        end
      rescue => e
        Rails.logger.error "DuckDuckGo search error: #{e.message}" if defined?(Rails) && Rails.logger
        []
      end
      
      private
      
      def parse_results(data, num_results)
        results = []
        
        # Add instant answer if available
        if data['Abstract'] && !data['Abstract'].empty?
          results << {
            title: data['Heading'] || 'Instant Answer',
            link: data['AbstractURL'] || '',
            snippet: data['Abstract']
          }
        end
        
        # Add related topics
        if data['RelatedTopics']
          data['RelatedTopics'].first(num_results - results.length).each do |topic|
            if topic.is_a?(Hash) && topic['Text']
              results << {
                title: topic['FirstURL'] ? topic['FirstURL'].split('/').last : 'Related Topic',
                link: topic['FirstURL'] || '',
                snippet: topic['Text']
              }
            end
          end
        end
        
        results.first(num_results)
      end
    end

    def self.search(query, num_results: 5, provider: :google)
      case provider.to_sym
      when :google
        GoogleSearch.new.search(query, num_results: num_results)
      when :duckduckgo
        DuckDuckGoSearch.new.search(query, num_results: num_results)
      else
        # Try Google first, fallback to DuckDuckGo
        google_results = GoogleSearch.new.search(query, num_results: num_results)
        return google_results if google_results.any?
        
        DuckDuckGoSearch.new.search(query, num_results: num_results)
      end
    end
  end
end
