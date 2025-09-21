# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Agents::BaseAgent do
  let(:agent) do
    described_class.new(
      name: "TestAgent",
      role: "Test Role",
      capabilities: [:test, :analysis]
    )
  end

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#initialize" do
    it "creates an agent with correct attributes" do
      expect(agent.name).to eq("TestAgent")
      expect(agent.role).to eq("Test Role")
      expect(agent.capabilities).to eq([:test, :analysis])
      expect(agent.state).to eq(:idle)
      expect(agent.memory).to be_a(RailsAi::Agents::Memory)
    end
  end

  describe "#start!" do
    it "changes state to active" do
      agent.start!
      expect(agent.state).to eq(:active)
    end
  end

  describe "#stop!" do
    it "changes state to stopped" do
      agent.start!
      agent.stop!
      expect(agent.state).to eq(:stopped)
    end
  end

  describe "#assign_task" do
    before { agent.start! }

    it "assigns a task when agent can handle it" do
      task = { id: "1", description: "Test task", required_capabilities: [:test] }
      result = agent.assign_task(task)
      
      expect(result).to be true
      expect(agent.active_tasks.any? { |t| t[:id] == task[:id] }).to be true
    end

    it "rejects task when agent cannot handle it" do
      task = { id: "1", description: "Test task", required_capabilities: [:unknown] }
      result = agent.assign_task(task)
      
      expect(result).to be false
      expect(agent.active_tasks).to be_empty
    end
  end

  describe "#complete_task" do
    before do
      agent.start!
      agent.assign_task({ id: "1", description: "Test task" })
    end

    it "completes a task successfully" do
      result = agent.complete_task("1", "Task completed")
      
      expect(result).to be true
      expect(agent.active_tasks).to be_empty
      expect(agent.completed_tasks).not_to be_empty
    end
  end

  describe "#think" do
    it "generates AI response" do
      result = agent.think("What is 2+2?")
      expect(result).to include("2+2")
    end
  end

  describe "#remember" do
    it "stores information in memory" do
      agent.remember("test_key", "test_value")
      expect(agent.recall("test_key")).to eq("test_value")
    end
  end

  describe "#has_capability?" do
    it "returns true for existing capability" do
      expect(agent.has_capability?(:test)).to be true
    end

    it "returns false for non-existing capability" do
      expect(agent.has_capability?(:unknown)).to be false
    end
  end

  describe "#status" do
    it "returns comprehensive status information" do
      status = agent.status
      
      expect(status[:name]).to eq("TestAgent")
      expect(status[:role]).to eq("Test Role")
      expect(status[:state]).to eq(:idle)
      expect(status[:capabilities]).to eq([:test, :analysis])
    end
  end
end
