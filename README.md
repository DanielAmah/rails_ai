# Rails AI

A comprehensive AI toolkit deeply integrated into Rails applications with multi-provider support, context awareness, performance optimizations, and **Agent AI system** for autonomous multi-agent collaboration.

## 🚀 Features

### Core AI Capabilities
- **Multi-Provider Support**: OpenAI (GPT-5, GPT-4o, DALL-E 3, Sora), Anthropic (Claude 3.5 Sonnet), Google Gemini (2.0 Flash), with zero dependencies!
- **Text Generation**: Advanced text generation with streaming support
- **Image Generation & Analysis**: DALL-E 3, Gemini 2.0 Flash image generation and analysis
- **Video Generation**: Sora and Gemini 2.0 Flash video generation
- **Audio Processing**: Text-to-speech and audio transcription
- **Embeddings**: High-quality text embeddings for semantic search

### 🤖 Agent AI System (NEW!)
- **Autonomous Agents**: Create multiple AI agents that work independently and collaboratively
- **Specialized Agent Types**: Research, Creative, Technical, and Coordinator agents
- **Agent Teams**: Organize agents into teams with different collaboration strategies
- **Task Management**: Intelligent task assignment and delegation between agents
- **Agent Communication**: Built-in messaging system for agent-to-agent communication
- **Memory System**: Persistent memory for each agent with importance-based retention
- **Health Monitoring**: Comprehensive health checks and performance monitoring

### Context Awareness
- **User Context**: Track user-specific information and preferences
- **Window Context**: Capture application state and request context
- **Image Context**: Analyze and understand image metadata and content
- **Temporal Context**: Time-aware AI operations

### Performance Optimizations
- **Smart Caching**: Intelligent caching with compression and TTL
- **Request Deduplication**: Prevent duplicate API calls
- **Connection Pooling**: Efficient HTTP connection management
- **Batch Processing**: Process multiple operations efficiently
- **Performance Monitoring**: Built-in metrics and monitoring

### Rails Integration
- **Rails 5.2+ Support**: Backward compatible with Rails 5.2 through 8.0
- **Controller Concerns**: Easy integration with Rails controllers
- **Helper Methods**: View helpers for AI operations
- **Rails Events**: Integration with Rails event system
- **Configuration**: Flexible configuration system

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_ai'
```

And then execute:

```bash
$ bundle install
```

## ⚙️ Configuration

### Basic Setup

```ruby
# config/initializers/rails_ai.rb
RailsAi.configure do |config|
  config.provider = :openai  # or :anthropic, :gemini, :dummy
  config.default_model = "gpt-5"  # Latest GPT-5 model!
  config.token_limit = 4000
  config.cache_ttl = 1.hour
  config.stub_responses = false
end
```

### Environment Variables

```bash
# .env
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

## 🎯 Quick Start

### Basic AI Operations

```ruby
# Text generation
response = RailsAi.chat("Write a blog post about AI")
puts response

# Image generation
image = RailsAi.generate_image("A sunset over mountains", model: "dall-e-3")
puts image

# Video generation
video = RailsAi.generate_video("A cat playing with a ball", model: "sora")
puts video

# Audio generation
speech = RailsAi.generate_speech("Hello world", voice: "alloy")
puts speech

# Image analysis
analysis = RailsAi.analyze_image(image_file, "What do you see?")
puts analysis
```

### 🤖 Agent AI System

#### Creating Agents

```ruby
# Create specialized agents
research_agent = RailsAi.create_research_agent(name: "ResearchBot")
creative_agent = RailsAi.create_creative_agent(name: "CreativeBot")
tech_agent = RailsAi.create_technical_agent(name: "TechBot")
coordinator = RailsAi.create_coordinator_agent(name: "CoordinatorBot")

# Start the agent system
RailsAi.start_agents!
```

#### Agent Teams

```ruby
# Create a content creation team
content_team = RailsAi.create_agent_team(
  "ContentTeam",
  [research_agent, creative_agent, coordinator],
  strategy: :collaborative
)

# Assign tasks to the team
content_team.assign_task({
  description: "Create a comprehensive marketing strategy",
  type: :creative
})
```

#### Agent Communication

```ruby
# Agents can communicate with each other
RailsAi.send_agent_message("ResearchBot", "CreativeBot", {
  type: :research_findings,
  data: "AI market will reach $1.8T by 2030"
})

# Broadcast messages to all agents
RailsAi.broadcast_agent_message("CoordinatorBot", {
  type: :status_update,
  message: "All systems operational"
})
```

#### Task Management

```ruby
# Submit tasks to the system
task = RailsAi.submit_task({
  id: "task_001",
  description: "Analyze customer feedback data",
  required_capabilities: [:analysis, :data_processing],
  priority: :high
})

# Auto-assign to best agent
RailsAi.auto_assign_task(task)

# Or manually assign
RailsAi.assign_task(task, "ResearchBot")
```

## 🎨 Real-World Examples

### Content Creation Pipeline

```ruby
# Create content creation workflow
def create_blog_post(topic)
  # Research phase
  research_task = {
    description: "Research #{topic} for blog post",
    type: :analysis
  }
  content_team.assign_task(research_task)
  
  # Writing phase
  writing_task = {
    description: "Write blog post about #{topic}",
    type: :creative,
    dependencies: [research_task[:id]]
  }
  content_team.assign_task(writing_task)
  
  # Editing phase
  editing_task = {
    description: "Edit and optimize blog post",
    type: :problem_solving,
    dependencies: [writing_task[:id]]
  }
  content_team.assign_task(editing_task)
end
```

### Customer Support System

```ruby
# Create support agents
triage_agent = RailsAi.create_agent(
  name: "TriageAgent",
  role: "Support Triage",
  capabilities: [:classification, :routing]
)

technical_agent = RailsAi.create_technical_agent(name: "TechSupport")
billing_agent = RailsAi.create_agent(
  name: "BillingAgent",
  role: "Billing Support",
  capabilities: [:billing, :account_management]
)

# Support workflow
def handle_support_ticket(ticket)
  # Triage the ticket
  triage_result = triage_agent.think("Classify this support ticket: #{ticket[:description]}")
  
  case triage_result
  when /technical/
    technical_agent.assign_task(ticket)
  when /billing/
    billing_agent.assign_task(ticket)
  else
    # Escalate to human
    Rails.logger.info("Ticket requires human intervention: #{ticket[:id]}")
  end
end
```

### Research and Development

```ruby
# Create R&D team
researcher = RailsAi.create_research_agent(name: "R&D_Researcher")
architect = RailsAi.create_technical_agent(name: "SystemArchitect")
prototyper = RailsAi.create_creative_agent(name: "PrototypeDesigner")
coordinator = RailsAi.create_coordinator_agent(name: "R&D_Coordinator")

# R&D workflow
def develop_new_feature(requirements)
  # Research phase
  research_task = {
    description: "Research existing solutions for #{requirements[:feature]}",
    type: :analysis
  }
  researcher.assign_task(research_task)
  
  # Architecture phase
  architecture_task = {
    description: "Design architecture for #{requirements[:feature]}",
    type: :problem_solving,
    dependencies: [research_task[:id]]
  }
  architect.assign_task(architecture_task)
  
  # Prototype phase
  prototype_task = {
    description: "Create prototype for #{requirements[:feature]}",
    type: :creative,
    dependencies: [architecture_task[:id]]
  }
  prototyper.assign_task(prototype_task)
  
  # Coordination
  coordinator.coordinate_task(requirements, [researcher, architect, prototyper])
end
```

## �� Advanced Usage

### Context-Aware AI

```ruby
# User context
user_context = RailsAi::UserContext.new(
  id: 123,
  email: "user@example.com",
  role: "premium",
  preferences: { language: "en", theme: "dark" }
)

# Window context
window_context = RailsAi::WindowContext.from_controller(self)

# Generate with context
response = RailsAi.generate_with_context(
  "Write a personalized email",
  user_context: user_context,
  window_context: window_context
)
```

### Performance Optimization

```ruby
# Warm up the system
RailsAi.warmup!

# Check performance metrics
metrics = RailsAi.metrics
puts "Average response time: #{metrics[:average_response_time]}ms"

# Clear cache if needed
RailsAi.clear_cache!
```

### Agent Monitoring

```ruby
# Check system status
status = RailsAi.agent_system_status
puts "Active agents: #{status[:active_agents]}"
puts "Pending tasks: #{status[:pending_tasks]}"

# Health check
health = RailsAi.agent_health_check
puts "System healthy: #{health[:system_healthy]}"
```

## 📚 Documentation

- [Features Guide](FEATURES.md) - Comprehensive feature overview
- [Usage Guide](USAGE_GUIDE.md) - Detailed usage examples
- [Agent Guide](AGENT_GUIDE.md) - Complete Agent AI system documentation
- [Providers Guide](PROVIDERS.md) - AI provider configuration and capabilities
- [Wiki](wiki/) - Developer documentation and guides

## 🧪 Testing

```ruby
# In your tests
RSpec.describe "AI Features" do
  before do
    RailsAi.configure do |config|
      config.provider = :dummy
      config.stub_responses = true
    end
  end

  it "generates content" do
    result = RailsAi.chat("Hello")
    expect(result).to include("Hello")
  end
end
```

## 🚀 Performance

Rails AI is optimized for performance with:

- **Smart Caching**: Intelligent caching with compression
- **Request Deduplication**: Prevents duplicate API calls
- **Connection Pooling**: Efficient HTTP connection management
- **Batch Processing**: Process multiple operations efficiently
- **Lazy Loading**: Components loaded only when needed
- **Memory Management**: Efficient memory usage with cleanup

## 🔒 Security

- **Input Sanitization**: Automatic redaction of sensitive information
- **API Key Management**: Secure API key handling
- **Error Handling**: Comprehensive error handling and logging
- **Audit Logging**: Full audit trail of AI operations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

**⚠️ IMPORTANT: This is a NON-COMMERCIAL license**

- ✅ **Personal use**: Allowed
- ✅ **Open source projects**: Allowed  
- ✅ **Forking**: Allowed for non-commercial purposes
- ❌ **Commercial use**: Prohibited without explicit permission
- 💰 **Commercial license**: $999 per year
- 📧 **Contact**: amahdanieljack@gmail.com

See [LICENSE_SUMMARY.md](LICENSE_SUMMARY.md) for complete details.

## 📄 License

This project is licensed under the MIT License with Non-Commercial Use Restriction - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- OpenAI for GPT-5, GPT-4o, DALL-E 3, and Sora
- Anthropic for Claude 3.5 Sonnet
- Google for Gemini 2.0 Flash
- The Rails community for inspiration and support

---

**Rails AI - The future of AI in Rails applications!** 🚀

**Now with Agent AI system for autonomous multi-agent collaboration!** 🤖

**Zero dependencies, maximum performance, infinite possibilities!** ✨

## 📄 License

**⚠️ IMPORTANT: This is a NON-COMMERCIAL license**

- ✅ **Personal use**: Allowed
- ✅ **Open source projects**: Allowed  
- ✅ **Forking**: Allowed for non-commercial purposes
- ❌ **Commercial use**: Prohibited without explicit permission
- 💰 **Commercial license**: $999 per year
- 📧 **Contact**: amahdanieljack@gmail.com

See [LICENSE_SUMMARY.md](LICENSE_SUMMARY.md) for complete details.

## 📄 License

This project is licensed under the **MIT License with Non-Commercial Use Restriction**.

### ✅ Permitted Uses (No Permission Required)
- Personal projects and learning
- Educational purposes
- Open source projects (non-commercial)
- Forking and contributing to the project
- Research and development

### ❌ Restricted Uses (Permission Required)
- Commercial software products
- Commercial web applications
- Commercial services or platforms
- Any use that generates revenue
- Use by commercial entities for business operations

### 🔒 Commercial Licensing
For commercial use, you must:
1. Contact the author at amahdanieljack@gmail.com
2. Obtain explicit written permission
3. Agree to commercial licensing terms
4. Pay the required annual licensing fee of $999 per year

**Important**: This license change protects the intellectual property while still allowing open source collaboration and personal use.

