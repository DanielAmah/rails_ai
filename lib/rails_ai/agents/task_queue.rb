# frozen_string_literal: true

module RailsAi
  module Agents
    class TaskQueue
      PRIORITY_LEVELS = {
        critical: 4,
        high: 3,
        normal: 2,
        low: 1
      }.freeze

      def initialize
        @tasks = []
        @total_processed = 0
        @mutex = Mutex.new
      end

      def enqueue(task, priority: :normal)
        task_with_priority = task.merge(
          id: task[:id] || SecureRandom.uuid,
          priority: priority,
          priority_score: PRIORITY_LEVELS[priority] || 2,
          enqueued_at: Time.now,
          status: :pending
        )

        @mutex.synchronize do
          @tasks << task_with_priority
          @tasks.sort_by! { |t| [-t[:priority_score], t[:enqueued_at]] }
        end

        defined?(Rails) && Rails.logger && Rails.logger.info("Task enqueued: #{task[:description]} (priority: #{priority})")
        task_with_priority
      end

      def dequeue(timeout: nil)
        start_time = Time.now
        
        loop do
          @mutex.synchronize do
            return @tasks.shift if @tasks.any?
          end

          if timeout && (Time.now - start_time) > timeout
            return nil
          end

          sleep(0.1)
        end
      end

      def peek
        @mutex.synchronize { @tasks.first }
      end

      def size
        @mutex.synchronize { @tasks.length }
      end

      def empty?
        @mutex.synchronize { @tasks.empty? }
      end

      def clear!
        @mutex.synchronize { @tasks.clear }
        defined?(Rails) && Rails.logger && Rails.logger.info("Task queue cleared")
      end

      def remove_task(task_id)
        @mutex.synchronize do
          task = @tasks.find { |t| t[:id] == task_id }
          @tasks.delete(task) if task
        end
      end

      def get_tasks_by_status(status)
        @mutex.synchronize do
          @tasks.select { |t| t[:status] == status }
        end
      end

      def get_tasks_by_priority(priority)
        @mutex.synchronize do
          @tasks.select { |t| t[:priority] == priority }
        end
      end

      def mark_processed(task_id)
        @total_processed += 1
        defined?(Rails) && Rails.logger && Rails.logger.info("Task processed: #{task_id} (total: #{@total_processed})")
      end

      def stats
        @mutex.synchronize do
          {
            total_tasks: @tasks.length,
            total_processed: @total_processed,
            by_priority: @tasks.group_by { |t| t[:priority] }.transform_values(&:length),
            by_status: @tasks.group_by { |t| t[:status] }.transform_values(&:length),
            oldest_task: @tasks.min_by { |t| t[:enqueued_at] }&.dig(:enqueued_at)
          }
        end
      end

      def total_processed
        @total_processed
      end
    end
  end
end
