# frozen_string_literal: true

require "bundler/setup"
require "rails_ai"

# Simple RSpec configuration without Rails-specific features for now
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure Rails AI for testing
  config.before(:each) do
    RailsAi.configure do |c|
      c.provider = :dummy
      c.stub_responses = true
      c.cache_ttl = 60 # 1 minute in seconds
    end
  end
end
