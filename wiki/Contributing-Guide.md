# Contributing to Rails AI

Thank you for your interest in contributing to Rails AI! This guide will help you get started with contributing to the project.

## 🚀 Getting Started

### Prerequisites

- Ruby 2.7+ (3.x recommended)
- Rails 5.2+ (8.0 recommended)
- Git
- Bundler

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/yourusername/rails_ai.git
   cd rails_ai
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run tests**
   ```bash
   bundle exec rspec
   ```

4. **Run linter**
   ```bash
   bundle exec standardrb
   ```

## 📝 Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number
```

### 2. Make Your Changes

- Write your code following the [Code Style](Code-Style.md) guidelines
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Test Your Changes

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/rails_ai_spec.rb
bundle exec rspec spec/performance_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

### 4. Lint Your Code

```bash
# Check code style
bundle exec standardrb

# Auto-fix issues
bundle exec standardrb --fix
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "Add feature: brief description

- Detailed description of changes
- Any breaking changes
- Related issues: #123"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## 🧪 Testing

### Test Structure

```
spec/
├── rails_ai_spec.rb           # Core functionality tests
├── performance_spec.rb        # Performance tests
├── context_aware_spec.rb      # Context-aware tests
└── generators/                # Generator tests
    ├── install_generator_spec.rb
    └── feature_generator_spec.rb
```

### Writing Tests

```ruby
# spec/your_feature_spec.rb
RSpec.describe "Your Feature" do
  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
    end
  end

  it "does something" do
    result = RailsAi.your_method("input")
    expect(result).to be_a(String)
  end
end
```

### Test Requirements

- All new features must have tests
- Tests must pass on all supported Rails versions
- Performance tests must meet performance targets
- Context-aware tests must verify context inclusion

## 📋 Code Style

### Ruby Style

We use [StandardRB](https://github.com/standardrb/standardrb) for code style enforcement.

```ruby
# Good
def method_name(param1, param2: "default")
  result = do_something(param1)
  result.to_s
end

# Bad
def methodName( param1, param2 = "default" )
  result=do_something( param1 )
  return result.to_s
end
```

### Documentation Style

- Use YARD for method documentation
- Include examples in documentation
- Update README for user-facing changes
- Update wiki for architectural changes

```ruby
# Good documentation
# Generates an image using AI
#
# @param prompt [String] Description of the image to generate
# @param model [String] AI model to use (default: "dall-e-3")
# @param size [String] Image size (default: "1024x1024")
# @return [String] Base64-encoded image data
# @example
#   image = RailsAi.generate_image("A sunset over mountains")
#   # => "data:image/png;base64,..."
def generate_image(prompt, model: "dall-e-3", size: "1024x1024")
  # implementation
end
```

## 🏗️ Architecture Guidelines

### Adding New Providers

1. Create provider class in `lib/rails_ai/providers/`
2. Inherit from `RailsAi::Providers::Base`
3. Implement required methods
4. Add to provider selection in `RailsAi.provider`
5. Add tests for the provider

```ruby
# lib/rails_ai/providers/my_provider.rb
module RailsAi
  module Providers
    class MyProvider < Base
      def chat!(messages:, model:, **opts)
        # Implementation
      end

      def generate_image!(prompt:, model:, **opts)
        # Implementation
      end
    end
  end
end
```

### Adding New Features

1. Add methods to main `RailsAi` module
2. Implement in all providers
3. Add caching if appropriate
4. Add performance monitoring
5. Add comprehensive tests
6. Update documentation

### Performance Requirements

- New features must not significantly impact performance
- Caching should be implemented for expensive operations
- Memory usage should be monitored
- Concurrent operations should be thread-safe

## 📊 Performance Guidelines

### Benchmarking

```ruby
# Use benchmark-ips for performance testing
require 'benchmark/ips'

Benchmark.ips do |x|
  x.report("cached") { RailsAi.chat("test") }
  x.report("uncached") { RailsAi.clear_cache!; RailsAi.chat("test") }
  x.compare!
end
```

### Memory Profiling

```ruby
# Use memory_profiler for memory analysis
require 'memory_profiler'

report = MemoryProfiler.report do
  RailsAi.chat("test")
end

puts report.pretty_print
```

## 🐛 Bug Reports

### Before Reporting

1. Check existing issues
2. Update to latest version
3. Check documentation
4. Try to reproduce the issue

### Bug Report Template

```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Rails version: 8.0.2
- Ruby version: 3.2.0
- Rails AI version: 0.1.0
- OS: macOS 14.0

## Additional Context
Any other relevant information
```

## ✨ Feature Requests

### Before Requesting

1. Check existing issues and discussions
2. Consider if it fits the project's scope
3. Think about implementation complexity
4. Consider backward compatibility

### Feature Request Template

```markdown
## Feature Description
Brief description of the feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should this feature work?

## Alternatives Considered
What other approaches were considered?

## Additional Context
Any other relevant information
```

## 🔄 Pull Request Process

### Before Submitting

- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Performance impact is considered
- [ ] Breaking changes are documented

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added
- [ ] Performance tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Breaking changes documented
```

## 🏷️ Release Process

### Version Bumping

- **Patch** (0.1.1): Bug fixes, minor improvements
- **Minor** (0.2.0): New features, backward compatible
- **Major** (1.0.0): Breaking changes, major features

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped
- [ ] Tagged and released

## 🤝 Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow

### Communication

- Use GitHub Issues for bugs and features
- Use GitHub Discussions for questions
- Use Discord for real-time chat
- Be patient with maintainers

## 📞 Getting Help

- **Documentation**: Check the wiki first
- **Issues**: Search existing issues
- **Discussions**: Ask questions in discussions
- **Discord**: Join our community chat

## 🎯 Contribution Ideas

### Good First Issues

- Documentation improvements
- Test coverage improvements
- Performance optimizations
- Bug fixes

### Advanced Contributions

- New provider implementations
- Major feature additions
- Performance improvements
- Architecture enhancements

---

Thank you for contributing to Rails AI! 🚀
