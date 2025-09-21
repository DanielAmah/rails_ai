# frozen_string_literal: true

module RailsAi
  module Agents
    class Memory
      IMPORTANCE_LEVELS = {
        critical: 4,
        high: 3,
        normal: 2,
        low: 1
      }.freeze

      def initialize(max_size: 1000)
        @max_size = max_size
        @memories = []
        @index = {}
      end

      def add(key, value, importance: :normal)
        memory_item = {
          key: key,
          value: value,
          importance: importance,
          importance_score: IMPORTANCE_LEVELS[importance] || 2,
          created_at: Time.now,
          accessed_at: Time.now,
          access_count: 0
        }

        # Remove oldest low-importance memory if at capacity
        if @memories.length >= @max_size
          remove_oldest_low_importance
        end

        @memories << memory_item
        @index[key] = memory_item
        memory_item
      end

      def get(key)
        memory_item = @index[key]
        return nil unless memory_item

        memory_item[:accessed_at] = Time.now
        memory_item[:access_count] += 1
        memory_item[:value]
      end

      def remove(key)
        memory_item = @index.delete(key)
        return nil unless memory_item

        @memories.delete(memory_item)
        memory_item[:value]
      end

      def search(query, limit: 10)
        query_lower = query.downcase
        
        @memories
          .select do |memory|
            memory[:value].to_s.downcase.include?(query_lower) ||
            memory[:key].to_s.downcase.include?(query_lower)
          end
          .sort_by { |memory| -memory[:importance_score] }
          .first(limit)
          .map { |memory| memory[:value] }
      end

      def recent(count = 10)
        @memories
          .sort_by { |memory| -memory[:created_at].to_f }
          .first(count)
          .map { |memory| { key: memory[:key], value: memory[:value], created_at: memory[:created_at] } }
      end

      def important(count = 5)
        @memories
          .select { |memory| memory[:importance_score] >= 3 }
          .sort_by { |memory| -memory[:importance_score] }
          .first(count)
          .map { |memory| { key: memory[:key], value: memory[:value], importance: memory[:importance] } }
      end

      def usage_percentage
        (@memories.length.to_f / @max_size * 100).round(2)
      end

      def clear!
        @memories.clear
        @index.clear
      end

      def size
        @memories.length
      end

      def empty?
        @memories.empty?
      end

      private

      def remove_oldest_low_importance
        oldest_low_importance = @memories
          .select { |memory| memory[:importance_score] <= 2 }
          .min_by { |memory| memory[:created_at] }

        if oldest_low_importance
          @memories.delete(oldest_low_importance)
          @index.delete(oldest_low_importance[:key])
        end
      end
    end
  end
end
