# Changelog

All notable changes to the Rails AI gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Comprehensive security framework with input validation, rate limiting, and content sanitization
- Secure HTTP client with SSL/TLS enforcement and security headers
- API key management with encryption and secure storage
- SSRF protection and secure file handling
- Audit logging for security events
- Custom security scanner with vulnerability detection
- CI/CD security monitoring with multiple security tools

### Fixed
- Fixed syntax error with extra `end` keyword in main module
- Resolved character encoding issues with UTF-8 conversion
- Fixed method visibility and file loading conflicts

### Security
- Implemented input validation for text, file paths, URLs, and Base64 data
- Added rate limiting per user and endpoint
- Content sanitization to prevent XSS and injection attacks
- Secure file handling with path validation and size limits
- API security with SSL/TLS enforcement and error handling
- SSRF protection with URL validation and host blocking

## [0.1.9] - 2024-09-21

### Fixed
- Fixed CI validation errors by excluding `.gem` files from gemspec
- Resolved `NoMethodError: undefined method 'megabytes'` by adding ActiveSupport dependency
- Fixed method visibility issues with `validate_messages` method

### Changed
- Updated gemspec to exclude generated files and security reports
- Added `activesupport` dependency for numeric extensions
- Improved error handling and method accessibility

## [0.1.8] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by making method public
- Resolved method visibility conflicts in security module
- Fixed file loading order issues

### Changed
- Updated security module to properly load input validator
- Improved method accessibility and error handling

## [0.1.7] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` in chat functionality
- Resolved method visibility issues in security module
- Fixed file loading conflicts between duplicate classes

### Changed
- Updated security module to use proper file loading
- Improved error handling and method accessibility

## [0.1.6] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by updating security module
- Resolved method visibility issues
- Fixed file loading conflicts

### Changed
- Updated security module to properly load input validator
- Improved method accessibility

## [0.1.5] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by updating security module
- Resolved method visibility conflicts
- Fixed file loading order issues

### Changed
- Updated security module to use proper file loading
- Improved method accessibility

## [0.1.4] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by making method public
- Resolved method visibility issues in security module
- Fixed file loading conflicts

### Changed
- Updated security module to properly load input validator
- Improved method accessibility

## [0.1.3] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'validate_messages'` by making method public
- Resolved method visibility issues in security module
- Fixed file loading conflicts

### Changed
- Updated security module to properly load input validator
- Improved method accessibility

## [0.1.2] - 2024-09-21

### Fixed
- Fixed CI validation errors by excluding `.gem` files from gemspec
- Resolved `NoMethodError: undefined method 'megabytes'` by adding ActiveSupport dependency
- Fixed method visibility issues

### Changed
- Updated gemspec to exclude generated files
- Added `activesupport` dependency for numeric extensions
- Improved error handling

## [0.1.1] - 2024-09-21

### Fixed
- Fixed `NoMethodError: undefined method 'megabytes'` by adding ActiveSupport dependency
- Resolved method visibility issues in security module
- Fixed file loading conflicts

### Changed
- Added `activesupport` dependency for numeric extensions
- Updated security module to properly load input validator
- Improved method accessibility

## [0.1.0] - 2024-09-21

### Added
- Initial release of Rails AI gem
- Multi-provider support for OpenAI, Anthropic (Claude), and Google Gemini
- Direct API integration without external gem dependencies
- Full multimodal capabilities (text, image, video, audio, embeddings)
- Context awareness with UserContext, WindowContext, and ImageContext
- Performance optimizations with caching, connection pooling, and batch processing
- Agent AI system with BaseAgent, specialized agents, and team collaboration
- Memory system with importance-based retention and search
- Message bus for inter-agent communication
- Task queue with priority-based management and deduplication
- Specialized agents: ResearchAgent, CreativeAgent, TechnicalAgent, CoordinatorAgent
- Agent teams with various collaboration strategies
- Agent Manager for centralized system management
- Comprehensive security framework
- Input validation and sanitization
- Rate limiting and content filtering
- Secure file handling and API security
- SSRF protection and API key management
- Audit logging and error handling
- Custom security scanner
- CI/CD security monitoring
- Legal protection framework for Canadian jurisdiction
- Commercial license template and monitoring system
- Comprehensive documentation and wiki
- Rails 5.2+ compatibility with Ruby 3+ support
- MIT License with non-commercial use restrictions

### Features
- **Text Generation**: Support for GPT-4o, GPT-4, GPT-3.5-turbo, Claude, and Gemini models
- **Image Generation**: DALL-E 3, DALL-E 2, and Gemini image generation
- **Image Analysis**: Vision models for image understanding and analysis
- **Video Generation**: Video creation and editing capabilities
- **Audio Processing**: Speech generation and audio transcription
- **Embeddings**: Vector embeddings for semantic search and similarity
- **Streaming**: Real-time streaming responses for better user experience
- **Caching**: Intelligent caching system for improved performance
- **Context Awareness**: User, window, and image context integration
- **Agent System**: Autonomous AI agents with collaboration capabilities
- **Security**: Comprehensive security framework with multiple protection layers
- **Performance**: Optimized for speed with connection pooling and batch processing
- **Monitoring**: Continuous monitoring for security and unauthorized use
- **Legal Protection**: Canadian legal framework with commercial licensing

### Technical Details
- **Rails Compatibility**: Rails 5.2, 6.x, 7.x, 8.x
- **Ruby Compatibility**: Ruby 3.0+
- **Dependencies**: Minimal external dependencies for maximum compatibility
- **Performance**: Optimized for speed with caching and connection pooling
- **Security**: Multiple security layers with input validation and sanitization
- **Monitoring**: Continuous monitoring with CI/CD integration
- **Documentation**: Comprehensive documentation and wiki
- **Legal**: Non-commercial license with commercial licensing available

### Breaking Changes
- None in initial release

### Deprecated
- None in initial release

### Removed
- None in initial release

### Security
- Comprehensive security framework implemented
- Input validation and sanitization
- Rate limiting and content filtering
- Secure file handling and API security
- SSRF protection and API key management
- Audit logging and error handling
- Custom security scanner
- CI/CD security monitoring

### Performance
- Intelligent caching system
- Connection pooling for HTTP requests
- Batch processing capabilities
- Lazy loading for improved performance
- Performance monitoring and optimization
- Memory management and optimization

### Documentation
- Comprehensive README with usage examples
- Complete API documentation
- Installation and setup guides
- Contributing guidelines
- Security documentation
- Legal protection guide
- Commercial license template
- GitHub wiki with detailed documentation

### Legal
- MIT License with non-commercial use restrictions
- Commercial licensing available for $999/year
- Canadian legal framework
- Copyright protection and monitoring
- Cease and desist templates
- Legal protection guide

---

## Version History Summary

- **0.2.3**: Fixed agent team creation and improved task execution
- **0.2.2**: Fixed streaming demo and cookie overflow issues
- **0.2.1**: Added web search integration and real-time information
- **0.2.0**: Added comprehensive security framework
- **0.1.9**: Fixed CI validation and ActiveSupport dependencies
- **0.1.8**: Fixed method visibility and file loading issues
- **0.1.7**: Fixed validate_messages method accessibility
- **0.1.6**: Updated security module and method accessibility
- **0.1.5**: Fixed method visibility and file loading conflicts
- **0.1.4**: Made validate_messages method public
- **0.1.3**: Fixed method visibility issues
- **0.1.2**: Fixed CI validation and added ActiveSupport dependency
- **0.1.1**: Fixed megabytes method and added ActiveSupport dependency
- **0.1.0**: Initial release with comprehensive AI capabilities

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

## License

This project is licensed under the MIT License with Non-Commercial Use Restrictions - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue on GitHub or contact the maintainer at amahdanieljack@gmail.com.

## Commercial Licensing

For commercial use, please contact amahdanieljack@gmail.com for licensing information. Commercial license fee: $999/year.
