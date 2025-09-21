# Changelog

All notable changes to the Rails AI gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.5] - 2024-09-21

### Fixed
- Fixed critical syntax error with unmatched `end` statements in `lib/rails_ai.rb`
- Resolved `SyntaxError: unexpected 'end'` that was preventing gem loading
- Properly structured module and method definitions within correct scope
- Fixed gem loading issues that were causing Rails applications to fail

### Added
- `clean_response` utility method for automatic UTF-8 encoding and character cleaning
- `chat_clean` method that automatically cleans AI responses
- `chat_with_web_search_clean` method with automatic response cleaning
- Enhanced error handling for malformed responses

### Changed
- Improved response handling to prevent encoding issues
- Better UTF-8 character replacement for invalid characters
- Enhanced error handling for character encoding problems

## [0.2.4] - 2024-09-21

### Fixed
- Fixed character encoding issues in AI responses
- Resolved `JSON::GeneratorError` in agent functionality
- Fixed garbled character display in agent responses

### Added
- Response cleaning utility methods
- Enhanced UTF-8 encoding handling
- Better error handling for malformed responses

### Changed
- Improved response processing to handle compressed and encoded data
- Enhanced character encoding validation

## [0.2.3] - 2024-09-21

### Fixed
- Fixed `create_agent_team` method to use correct parameter name (`collaboration_strategy` instead of `strategy`)
- Resolved `ArgumentError: unknown keyword: :strategy` in agent team creation
- Improved agent task execution to return meaningful AI-generated results instead of just task confirmation

### Changed
- Updated agent demo to show actual AI responses from collaborative agent work
- Enhanced agent controller to simulate multi-agent collaboration with specialized prompts

## [0.2.2] - 2024-09-21

### Fixed
- Fixed streaming demo EventSource MIME type error by properly handling GET requests for Server-Sent Events
- Resolved `CookieOverflow` error by implementing file-based storage for large AI responses
- Fixed compressed response display by adding Zlib decompression in streaming controller
- Updated streaming view to handle plain text responses instead of expecting JSON

### Changed
- Improved streaming response handling with proper decompression of compressed chunks
- Enhanced error handling for streaming connections
- Updated demo controller to use file storage instead of session for large responses

## [0.2.1] - 2024-09-21

### Added
- Web search integration with `WebSearch` module supporting Google Search and DuckDuckGo
- `chat_with_web_search` method for real-time information retrieval
- Support for current, latest, today, now, recent, weather, news, stock, price keywords
- Web search fallback to regular chat if search fails

### Fixed
- Fixed `ArgumentError: unknown keyword: :num_results` in web search integration
- Resolved method visibility issues with `validate_messages` method
- Fixed file loading conflicts between duplicate `InputValidator` classes

### Changed
- Updated demo app to use GPT-4o instead of non-existent GPT-5
- Enhanced chat demo with web search checkbox option
- Improved error handling for web search failures

## [0.2.0] - 2024-09-21

### Added
- Web search integration with Google Search and DuckDuckGo providers
- `WebSearch` module with `GoogleSearch` and `DuckDuckGoSearch` classes
- `chat_with_web_search` method for real-time information retrieval
- Support for current events, news, weather, and time-sensitive queries
- Web search fallback to regular chat if search fails

### Fixed
- Fixed `SyntaxError: unexpected 'end'` in `lib/rails_ai.rb`
- Resolved `ArgumentError: unknown keyword: :num_results` in web search
- Fixed method parameter passing in `WebSearch.search` method

### Changed
- Enhanced chat functionality with web search capabilities
- Improved error handling for web search failures
- Updated demo application with web search integration

## [0.1.6] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'megabytes'` by adding ActiveSupport dependency
- Resolved gem loading issues in demo application
- Fixed `ArgumentError: unknown keyword: :collaboration_strategy` in agent team creation

### Changed
- Updated `rails_ai.gemspec` to include `activesupport` dependency
- Enhanced agent team creation with proper parameter handling
- Improved error handling for missing ActiveSupport extensions

## [0.1.5] - 2024-09-21

### Fixed
- Fixed method visibility issues with `validate_messages` method
- Resolved `NoMethodError: undefined method 'validate_messages'` in security validation
- Fixed file loading conflicts between duplicate `InputValidator` classes

### Changed
- Updated `lib/rails_ai/security.rb` to properly require input validator
- Removed duplicate `InputValidator` class definition
- Enhanced security validation method availability

## [0.1.4] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by making method public
- Resolved security validation issues in demo application
- Fixed method visibility in `InputValidator` class

### Changed
- Moved `validate_messages` method above `private` keyword in `InputValidator`
- Enhanced security validation method accessibility

## [0.1.3] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` in security validation
- Resolved method availability issues in demo application
- Fixed security validation method calls

### Changed
- Updated security validation method definitions
- Enhanced error handling for security validation

## [0.1.2] - 2024-09-21

### Fixed
- Fixed CI failure with `rails_ai-0.1.1 contains itself` error
- Resolved gemspec file inclusion issues
- Fixed `.gem` file inclusion in `s.files` list

### Changed
- Updated `rails_ai.gemspec` to exclude generated `.gem` files
- Added `*.gem` to `.gitignore`
- Enhanced gemspec file filtering

## [0.1.1] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'megabytes'` by adding ActiveSupport dependency
- Resolved gem loading issues in demo application
- Fixed `ArgumentError: unknown keyword: :collaboration_strategy` in agent team creation

### Changed
- Updated `rails_ai.gemspec` to include `activesupport` dependency
- Enhanced agent team creation with proper parameter handling
- Improved error handling for missing ActiveSupport extensions

## [0.1.0] - 2024-09-21

### Added
- Initial release of Rails AI gem
- Multi-provider support (OpenAI, Anthropic, Gemini)
- Direct API integration without external gem dependencies
- Multimodal capabilities (text, image, video, audio)
- Agent system with specialized agents and collaboration
- Context awareness with user and window context
- Security features including input validation and rate limiting
- Performance optimizations with connection pooling and caching
- Web search integration for real-time information
- Comprehensive demo Rails application
- Extensive documentation and wiki pages

### Features
- **Text Generation**: Support for GPT-4o, GPT-4, GPT-3.5-turbo models
- **Image Analysis**: Vision models for image understanding
- **Image Generation**: DALL-E 3 and DALL-E 2 integration
- **Video Analysis**: Frame extraction and analysis capabilities
- **Audio Processing**: Whisper integration for speech-to-text
- **Agent System**: Multi-agent collaboration with specialized roles
- **Context Awareness**: User preferences and window context integration
- **Security**: Input validation, rate limiting, content sanitization
- **Performance**: Connection pooling, smart caching, request deduplication
- **Web Search**: Real-time information retrieval with Google and DuckDuckGo

### Security
- Input validation and sanitization
- Rate limiting and abuse prevention
- Content filtering and safety checks
- API key management and security
- SSRF protection and secure HTTP client
- Comprehensive error handling

### Performance
- Connection pooling for concurrent requests
- Smart caching with TTL support
- Request deduplication to prevent duplicate API calls
- Performance monitoring and metrics
- Batch processing capabilities
- Memory optimization

### Documentation
- Comprehensive README with usage examples
- API documentation with all methods and parameters
- Architecture overview and design decisions
- Security guide and best practices
- Contributing guidelines and development setup
- Wiki pages with detailed feature explanations

### Legal
- Non-commercial license with commercial licensing available
- Legal protection guide for Canadian jurisdiction
- Monitoring system for unauthorized commercial use
- Cease and desist template for enforcement
- Commercial license template ($999/year)

### Demo Application
- Complete Rails demo application (`rails_ai_demo`)
- All features demonstrated with working examples
- Modern UI with responsive design
- Real-time streaming chat
- Image analysis and generation demos
- Agent system demonstration
- Context awareness examples

### Breaking Changes
- None (initial release)

### Deprecations
- None (initial release)

### Removals
- None (initial release)

---

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

For support and questions:
- Create an issue on GitHub
- Check the wiki documentation
- Review the API documentation

## License

This project is licensed under the PolyForm-Noncommercial-1.0.0 License - see the [LICENSE](LICENSE) file for details.

For commercial use, please contact the author for licensing terms.
