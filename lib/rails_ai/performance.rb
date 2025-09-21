# frozen_string_literal: true

module RailsAi
  module Performance
    # Connection pooling for HTTP clients
    class ConnectionPool
      def initialize(size: 10)
        @pool = Concurrent::Array.new(size) { create_connection }
        @semaphore = Concurrent::Semaphore.new(size)
      end

      def with_connection
        @semaphore.acquire
        connection = @pool.pop
        yield(connection)
      ensure
        @pool.push(connection) if connection
        @semaphore.release
      end

      private

      def create_connection
        # Simple connection object for now
        Object.new
      end
    end

    # Request batching for multiple operations
    class BatchProcessor
      def initialize(batch_size: 10, flush_interval: 0.1)
        @batch_size = batch_size
        @flush_interval = flush_interval
        @queue = Concurrent::Array.new
        @mutex = Mutex.new
        @last_flush = Time.now
      end

      def add_operation(operation)
        @mutex.synchronize do
          @queue << operation
          flush_if_needed
        end
      end

      private

      def flush_if_needed
        return unless should_flush?

        operations = @queue.shift(@batch_size)
        process_batch(operations) if operations.any?
        @last_flush = Time.now
      end

      def should_flush?
        @queue.size >= @batch_size || 
        (Time.now - @last_flush) > @flush_interval
      end

      def process_batch(operations)
        # Process operations in parallel
        operations.map do |operation|
          Concurrent::Future.execute { operation.call }
        end.each(&:value!)
      end
    end

    # Memory-efficient streaming
    class StreamProcessor
      def initialize(chunk_size: 1024)
        @chunk_size = chunk_size
      end

      def process_stream(stream, &block)
        buffer = String.new(capacity: @chunk_size)
        
        stream.each_chunk(@chunk_size) do |chunk|
          buffer << chunk
          
          if buffer.bytesize >= @chunk_size
            yield(buffer.dup)
            buffer.clear
          end
        end
        
        yield(buffer) if buffer.bytesize > 0
      end
    end

    # Smart caching with compression
    class SmartCache
      def initialize(compression_threshold: 1024)
        @compression_threshold = compression_threshold
      end

      def fetch(key, **opts, &block)
        return block.call unless block_given?

        if defined?(Rails) && Rails.cache
          compressed_key = compress_key(key)
          Rails.cache.fetch(compressed_key, **opts) do
            result = block.call
            compress_if_needed(result)
          end
        else
          block.call
        end
      end

      private

      def compress_key(key)
        # Use consistent hashing for better distribution
        Digest::MD5.hexdigest(key.inspect)
      end

      def compress_if_needed(data)
        return data unless data.is_a?(String) && data.bytesize > @compression_threshold
        
        compressed = Zlib::Deflate.deflate(data)
        { compressed: true, data: compressed }
      end

      def decompress_if_needed(data)
        return data unless data.is_a?(Hash) && data[:compressed]
        
        Zlib::Inflate.inflate(data[:data])
      end
    end

    # Request deduplication
    class RequestDeduplicator
      def initialize
        @pending_requests = Concurrent::Hash.new
        @mutex = Mutex.new
      end

      def deduplicate(key, &block)
        @mutex.synchronize do
          if @pending_requests[key]
            # Wait for existing request
            @pending_requests[key].value
          else
            # Start new request
            future = Concurrent::Future.execute(&block)
            @pending_requests[key] = future
            
            begin
              future.value
            ensure
              @pending_requests.delete(key)
            end
          end
        end
      end
    end

    # Performance monitoring
    class PerformanceMonitor
      def initialize
        @metrics = Concurrent::Hash.new
      end

      def measure(operation, &block)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        memory_before = memory_usage
        
        result = block.call
        
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        memory_after = memory_usage
        
        record_metric(operation, duration, memory_after - memory_before)
        result
      end

      def metrics
        @metrics.dup
      end

      private

      def record_metric(operation, duration, memory_delta)
        @metrics[operation] ||= {
          count: 0,
          total_duration: 0.0,
          total_memory: 0,
          min_duration: Float::INFINITY,
          max_duration: 0.0
        }
        
        metric = @metrics[operation]
        metric[:count] += 1
        metric[:total_duration] += duration
        metric[:total_memory] += memory_delta
        metric[:min_duration] = [metric[:min_duration], duration].min
        metric[:max_duration] = [metric[:max_duration], duration].max
      end

      def memory_usage
        `ps -o rss= -p #{Process.pid}`.to_i * 1024
      rescue
        0
      end
    end

    # Lazy loading for providers
    class LazyProvider
      def initialize(&provider_factory)
        @provider_factory = provider_factory
        @provider = nil
        @mutex = Mutex.new
      end

      def method_missing(method, *args, **kwargs, &block)
        @mutex.synchronize do
          @provider ||= @provider_factory.call
        end
        @provider.public_send(method, *args, **kwargs, &block)
      end

      def respond_to_missing?(method, include_private = false)
        @mutex.synchronize do
          @provider ||= @provider_factory.call
        end
        @provider.respond_to?(method, include_private)
      end
    end
  end
end
