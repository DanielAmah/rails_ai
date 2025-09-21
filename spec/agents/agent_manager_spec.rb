# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAi::Agents::AgentManager do
  let(:manager) { described_class.new }
  let(:agent1) do
    RailsAi::Agents::BaseAgent.new(
      name: "Agent1",
      role: "Test Role",
      capabilities: [:test, :analysis]
    )
  end
  let(:agent2) do
    RailsAi::Agents::BaseAgent.new(
      name: "Agent2",
      role: "Test Role 2",
      capabilities: [:creative, :writing]
    )
  end

  before do
    RailsAi.configure do |config|
      config.stub_responses = true
    end
  end

  describe "#register_agent" do
    it "registers an agent successfully" do
      result = manager.register_agent(agent1)
      
      expect(result).to eq(agent1)
      expect(manager.get_agent("Agent1")).to eq(agent1)
    end
  end

  describe "#unregister_agent" do
    before { manager.register_agent(agent1) }

    it "unregisters an agent successfully" do
      result = manager.unregister_agent("Agent1")
      
      expect(result).to be true
      expect(manager.get_agent("Agent1")).to be_nil
    end
  end

  describe "#submit_task" do
    it "submits a task to the queue" do
      task = { id: "1", description: "Test task" }
      result = manager.submit_task(task)
      
      expect(result).to eq(task)
      expect(manager.task_queue.size).to eq(1)
    end
  end

  describe "#find_best_agent_for_task" do
    before do
      manager.register_agent(agent1)
      manager.register_agent(agent2)
      agent1.start!
      agent2.start!
    end

    it "finds the best agent based on capabilities" do
      task = { description: "Test task", required_capabilities: [:test] }
      best_agent = manager.find_best_agent_for_task(task)
      
      expect(best_agent).to eq(agent1)
    end

    it "returns nil when no agents are available" do
      agent1.stop!
      agent2.stop!
      
      task = { description: "Test task" }
      best_agent = manager.find_best_agent_for_task(task)
      
      expect(best_agent).to be_nil
    end
  end

  describe "#auto_assign_task" do
    before do
      manager.register_agent(agent1)
      agent1.start!
    end

    it "automatically assigns task to best agent" do
      task = { description: "Test task", required_capabilities: [:test] }
      result = manager.auto_assign_task(task)
      
      expect(result).to be true
      expect(agent1.active_tasks).not_to be_empty
    end
  end

  describe "#system_status" do
    before do
      manager.register_agent(agent1)
      manager.register_agent(agent2)
    end

    it "returns comprehensive system status" do
      status = manager.system_status
      
      expect(status[:total_agents]).to eq(2)
      expect(status[:running]).to be false
    end
  end

  describe "#create_agent_team" do
    it "creates a team with multiple agents" do
      team = manager.create_agent_team("TestTeam", [agent1, agent2])
      
      expect(team).to be_a(RailsAi::Agents::AgentTeam)
      expect(team.name).to eq("TestTeam")
      expect(team.agents).to include(agent1, agent2)
    end
  end
end
