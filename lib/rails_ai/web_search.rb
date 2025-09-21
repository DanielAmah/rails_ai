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
        raise SearchError, "Google Search API key not configured" unless @api_key
        raise SearchError, "Google Search Engine ID not configured" unless @search_engine_id
        
        uri = URI(@base_url)
        params = {
          key: @api_key,
          cx: @search_engine_id,
          q: query,
          num: num_results
        }
        uri.query = URI.encode_www_form(params)
        
        response = Net::HTTP.get_response(uri)
        raise SearchError, "Search failed: #{response.code}" unless response.code == '200'
        
        data = JSON.parse(response.body)
        format_results(data)
      rescue => e
        raise SearchError, "Web search error: #{e.message}"
      end
      
      private
      
      def format_results(data)
        results = data['items'] || []
        results.map do |item|
          {
            title: item['title'],
            link: item['link'],
            snippet: item['snippet']
          }
        end
      end
    end
    
    class DuckDuckGoSearch
      def search(query, num_results: 5)
        # Simple web scraping approach (for demo purposes)
        # In production, you'd want to use a proper API
        uri = URI("https://html.duckduckgo.com/html/?q=#{URI.encode_www_form_component(query)}")
        
        response = Net::HTTP.get_response(uri)
        raise SearchError, "Search failed: #{response.code}" unless response.code == '200'
        
        # Parse HTML and extract results (simplified)
        parse_duckduckgo_results(response.body, num_results)
      rescue => e
        raise SearchError, "Web search error: #{e.message}"
      end
      
      private
      
      def parse_duckduckgo_results(html, num_results)
        # This is a simplified parser - in production you'd use Nokogiri
        results = []
        lines = html.split("\n")
        
        lines.each_with_index do |line, index|
          if line.include?('class="result__title"') && results.length < num_results
            title_line = lines[index + 1] rescue ""
            snippet_line = lines[index + 3] rescue ""
            
            results << {
              title: title_line.strip,
              link: "https://duckduckgo.com",
              snippet: snippet_line.strip
            }
          end
        end
        
        results
      end
    end
    
    class WebSearch
      def initialize(provider: :google, **options)
        @provider = case provider
                   when :google
                     GoogleSearch.new(**options)
                   when :duckduckgo
                     DuckDuckGoSearch.new(**options)
                   else
                     raise SearchError, "Unsupported search provider: #{provider}"
                   end
      end
      
      def search(query, num_results: 5, **options)
        @provider.search(query, **options)
      end
    end
    
    # Convenience method
    def self.search(query, provider: :google, num_results: 5, **options)
      WebSearch.new(provider: provider, **options).search(query)
    end
  end
end
