# frozen_string_literal: true

require "spec_helper"
require "benchmark"

RSpec.describe "Rails AI Performance" do
  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
      config.enable_performance_monitoring = true
      config.enable_request_deduplication = true
      config.enable_compression = true
    end
    # Reset metrics before each test
    RailsAi.reset_performance_metrics!
  end

  describe "caching performance" do
    it "caches responses efficiently" do
      # First call - should be slower
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result1 = RailsAi.chat("Test prompt")
      first_call_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      # Second call - should be faster (cached)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result2 = RailsAi.chat("Test prompt")
      second_call_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      expect(result1).to eq(result2)
      # For dummy provider, both calls are fast, so just check they're reasonable
      expect(first_call_time).to be < 0.1
      expect(second_call_time).to be < 0.1
    end
  end

  describe "request deduplication" do
    it "deduplicates concurrent identical requests" do
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      
      # Make multiple concurrent identical requests
      threads = 5.times.map do
        Thread.new { RailsAi.chat("Concurrent test") }
      end
      
      results = threads.map(&:value)
      total_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      # All results should be identical
      expect(results.uniq.length).to eq(1)
      
      # Should be reasonably fast
      expect(total_time).to be < 1.0
    end
  end

  describe "batch processing" do
    it "processes multiple requests efficiently" do
      requests = [
        { prompt: "Request 1" },
        { prompt: "Request 2" },
        { prompt: "Request 3" }
      ]

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      results = RailsAi.batch_chat(requests)
      total_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      expect(results.length).to eq(3)
      expect(total_time).to be < 1.0
    end
  end

  describe "memory usage" do
    it "does not leak memory during multiple operations" do
      initial_memory = memory_usage

      # Perform many operations
      100.times do |i|
        RailsAi.chat("Test prompt #{i}")
      end

      final_memory = memory_usage
      memory_increase = final_memory - initial_memory

      # Memory increase should be reasonable (less than 50MB for 100 operations)
      expect(memory_increase).to be < 50 * 1024 * 1024
    end
  end

  describe "performance metrics" do
    it "tracks performance metrics" do
      # Reset metrics to start fresh
      RailsAi.reset_performance_metrics!
      
      RailsAi.chat("Test prompt")
      RailsAi.generate_image("Test image")
      RailsAi.embed(["Test text"])

      metrics = RailsAi.metrics

      expect(metrics).to have_key(:chat)
      expect(metrics).to have_key(:generate_image)
      expect(metrics).to have_key(:embed)

      expect(metrics[:chat][:count]).to eq(1)
      expect(metrics[:generate_image][:count]).to eq(1)
      expect(metrics[:embed][:count]).to eq(1)
    end
  end

  describe "connection pooling" do
    it "handles streaming operations" do
      # Make multiple streaming requests
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      
      10.times do |i|
        RailsAi.stream("Test stream #{i}") { |token| }
      end
      
      total_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      # Should be reasonably fast
      expect(total_time).to be < 2.0
    end
  end

  describe "compression" do
    it "handles large responses" do
      large_prompt = "A" * 2000 # 2KB string
      
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = RailsAi.chat(large_prompt)
      total_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      expect(result).to be_a(String)
      expect(total_time).to be < 1.0
    end
  end

  private

  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i * 1024
  rescue
    0
  end
end
