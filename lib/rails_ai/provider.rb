# frozen_string_literal: true

module RailsAi
  class Provider
    class RateLimited < StandardError; end
    class UnsafeInputError < StandardError; end
  end
end
