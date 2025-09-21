# frozen_string_literal: true

require_relative "lib/rails_ai/version"

Gem::Specification.new do |s|
  s.name = "rails_ai"
  s.version = RailsAi::VERSION
  s.authors = ["Daniel Amah"]
  s.email = ["amahdanieljack@gmail.com"]
  s.summary = "AI toolkit deeply integrated into Rails applications"
  s.description = "A comprehensive AI toolkit for Rails with multi-provider support, context awareness, and performance optimizations"
  s.homepage = "https://github.com/DanielAmah/rails_ai"
  s.license = "Nonstandard"
  s.licenses = ["Nonstandard"]
  s.required_ruby_version = ">= 2.7.0"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = s.homepage
  s.metadata["changelog_uri"] = "#{s.homepage}/blob/main/CHANGELOG.md"

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  s.bindir = "exe"
  s.executables = s.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Core dependencies
  s.add_dependency "rails", ">= 5.2", "< 9"
  s.add_dependency "concurrent-ruby", "~> 1.0"

  # Performance dependencies
  s.add_dependency "benchmark-ips", "~> 2.10"
  s.add_dependency "connection_pool", "~> 2.4"
  s.add_dependency "memory_profiler", "~> 1.0"

  # Development dependencies
  s.add_development_dependency "rspec", "~> 3.12"
  s.add_development_dependency "rspec-rails", "~> 6.0"
  s.add_development_dependency "standard", "~> 1.0"
  s.add_development_dependency "appraisal", "~> 2.4"
  s.add_development_dependency "pry", "~> 0.14"
  s.add_development_dependency "pry-byebug", "~> 3.10"
  s.add_development_dependency "webmock", "~> 3.19"
  s.add_development_dependency "vcr", "~> 6.2"
  s.add_development_dependency "simplecov", "~> 0.22"
  s.add_development_dependency "rubocop", "~> 1.50"
  s.add_development_dependency "rubocop-rspec", "~> 2.20"
  s.add_development_dependency "rubocop-performance", "~> 1.17"
  s.add_development_dependency "rubocop-rails", "~> 2.20"
end
