# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Agents::ResearchAgent do
  let(:agent) { described_class.new(name: "ResearchBot") }

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#initialize" do
    it "creates a research agent with correct capabilities" do
      expect(agent.role).to eq("Research Specialist")
      expect(agent.capabilities).to include(:research, :analysis, :data_gathering, :fact_checking)
    end
  end

  describe "#research_topic" do
    it "conducts research on a topic" do
      result = agent.research_topic("artificial intelligence")
      expect(result).to include("artificial intelligence")
    end
  end

  describe "#fact_check" do
    it "fact checks a claim" do
      result = agent.fact_check("The sky is blue")
      expect(result).to include("The sky is blue")
    end
  end
end

RSpec.describe RailsAi::Agents::CreativeAgent do
  let(:agent) { described_class.new(name: "CreativeBot") }

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#initialize" do
    it "creates a creative agent with correct capabilities" do
      expect(agent.role).to eq("Creative Specialist")
      expect(agent.capabilities).to include(:creative_writing, :ideation, :design_thinking, :storytelling)
    end
  end

  describe "#brainstorm" do
    it "generates creative ideas" do
      result = agent.brainstorm("mobile apps", quantity: 5)
      expect(result).to be_an(Array)
      expect(result.length).to eq(5)
    end
  end

  describe "#write_story" do
    it "writes a creative story" do
      result = agent.write_story("A robot learns to love")
      expect(result).to include("A robot learns to love")
    end
  end
end

RSpec.describe RailsAi::Agents::TechnicalAgent do
  let(:agent) { described_class.new(name: "TechBot") }

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#initialize" do
    it "creates a technical agent with correct capabilities" do
      expect(agent.role).to eq("Technical Specialist")
      expect(agent.capabilities).to include(:programming, :debugging, :system_design, :troubleshooting)
    end
  end

  describe "#solve_problem" do
    it "solves technical problems" do
      result = agent.solve_problem("Database performance issues")
      expect(result).to include("Database performance issues")
    end
  end

  describe "#code_review" do
    it "reviews code" do
      result = agent.code_review("def hello; puts 'world'; end", language: :ruby)
      expect(result).to include("Code review")
    end
  end
end

RSpec.describe RailsAi::Agents::CoordinatorAgent do
  let(:agent) { described_class.new(name: "CoordinatorBot") }

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#initialize" do
    it "creates a coordinator agent with correct capabilities" do
      expect(agent.role).to eq("Coordination Specialist")
      expect(agent.capabilities).to include(:coordination, :project_management, :resource_allocation, :conflict_resolution)
    end
  end

  describe "#coordinate_task" do
    it "coordinates tasks between agents" do
      available_agents = [double("agent1", name: "Agent1", role: "Test")]
      result = agent.coordinate_task({ description: "Test task" }, available_agents)
      expect(result).to include("Test task")
    end
  end
end
