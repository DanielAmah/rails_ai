# frozen_string_literal: true

module RailsAi
  module Agents
    class AgentTeam
      attr_reader :name, :agents, :strategy, :manager, :created_at

      def initialize(name:, agents:, strategy: :round_robin, manager:)
        @name = name
        @agents = Array(agents)
        @strategy = strategy
        @manager = manager
        @created_at = Time.now
        @current_agent_index = 0
        @team_memory = {}
        @collaboration_history = []
      end

      # Team task assignment
      def assign_task(task)
        case @strategy
        when :round_robin
          assign_round_robin(task)
        when :capability_based
          assign_capability_based(task)
        when :load_balanced
          assign_load_balanced(task)
        when :collaborative
          assign_collaborative(task)
        else
          assign_round_robin(task)
        end
      end

      def collaborate_on_task(task)
        return false unless @strategy == :collaborative

        collaboration = {
          id: SecureRandom.uuid,
          task: task,
          agents: @agents.map(&:name),
          started_at: Time.now,
          status: :in_progress,
          contributions: {}
        }

        # Each agent contributes to the task
        @agents.each do |agent|
          begin
            contribution = agent.collaborate_with(agent, task, context: build_team_context)
            collaboration[:contributions][agent.name] = contribution
          rescue => e
            defined?(Rails) && Rails.logger && Rails.logger.error("Agent #{agent.name} collaboration failed: #{e.message}")
            collaboration[:contributions][agent.name] = { error: e.message }
          end
        end

        collaboration[:completed_at] = Time.now
        collaboration[:status] = :completed
        @collaboration_history << collaboration

        defined?(Rails) && Rails.logger && Rails.logger.info("Team #{@name} completed collaborative task: #{task[:description]}")
        collaboration
      end

      # Team communication
      def team_meeting(agenda)
        meeting = {
          id: SecureRandom.uuid,
          agenda: agenda,
          participants: @agents.map(&:name),
          started_at: Time.now,
          discussions: {}
        }

        # Each agent shares their perspective
        @agents.each do |agent|
          perspective = agent.think("Team meeting agenda: #{agenda}. Share your perspective and insights.", 
                                  context: build_team_context)
          meeting[:discussions][agent.name] = perspective
        end

        meeting[:ended_at] = Time.now
        meeting[:duration] = meeting[:ended_at] - meeting[:started_at]

        # Store meeting results in team memory
        @team_memory["meeting_#{meeting[:id]}"] = meeting

        defined?(Rails) && Rails.logger && Rails.logger.info("Team #{@name} meeting completed: #{agenda}")
        meeting
      end

      def share_knowledge(agent_name, knowledge)
        @team_memory["knowledge_#{Time.now.to_i}"] = {
          shared_by: agent_name,
          knowledge: knowledge,
          shared_at: Time.now
        }

        # Broadcast knowledge to other agents
        @manager.broadcast_message(agent_name, {
          type: :knowledge_share,
          knowledge: knowledge,
          shared_by: agent_name
        }, exclude: [agent_name])

        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{agent_name} shared knowledge with team #{@name}")
      end

      # Team monitoring
      def team_status
        {
          name: @name,
          strategy: @strategy,
          agent_count: @agents.length,
          active_agents: @agents.count { |a| a.state == :active },
          total_tasks: @agents.sum { |a| a.active_tasks.length },
          team_memory_size: @team_memory.length,
          collaboration_count: @collaboration_history.length,
          created_at: @created_at
        }
      end

      def team_health
        agent_health = @agents.map do |agent|
          { name: agent.name, health: agent.health_check }
        end

        {
          overall_health: agent_health.all? { |ah| ah[:health].values.all? },
          agent_health: agent_health,
          memory_usage: calculate_team_memory_usage,
          collaboration_success_rate: calculate_collaboration_success_rate
        }
      end

      # Team learning
      def learn_from_experience
        recent_collaborations = @collaboration_history.last(10)
        return if recent_collaborations.empty?

        insights = analyze_collaboration_patterns(recent_collaborations)
        
        # Share insights with all agents
        @agents.each do |agent|
          agent.remember("team_insights_#{Time.now.to_i}", insights, importance: :high)
        end

        defined?(Rails) && Rails.logger && Rails.logger.info("Team #{@name} learned from recent collaborations")
        insights
      end

      private

      def assign_round_robin(task)
        agent = @agents[@current_agent_index]
        @current_agent_index = (@current_agent_index + 1) % @agents.length
        
        agent.assign_task(task)
      end

      def assign_capability_based(task)
        required_capabilities = task[:required_capabilities] || []
        return false if required_capabilities.empty?

        best_agent = @agents
          .select { |agent| agent.state == :active }
          .max_by do |agent|
            required_capabilities.count { |cap| agent.has_capability?(cap) }
          end

        best_agent&.assign_task(task)
      end

      def assign_load_balanced(task)
        best_agent = @agents
          .select { |agent| agent.state == :active }
          .min_by { |agent| agent.active_tasks.length }

        best_agent&.assign_task(task)
      end

      def assign_collaborative(task)
        # For collaborative tasks, all agents work together
        collaborate_on_task(task)
      end

      def build_team_context
        {
          team_name: @name,
          team_strategy: @strategy,
          team_members: @agents.map { |a| { name: a.name, role: a.role, capabilities: a.capabilities } },
          team_memory: @team_memory,
          recent_collaborations: @collaboration_history.last(5)
        }
      end

      def calculate_team_memory_usage
        total_memory = @agents.sum { |agent| agent.memory.size }
        total_capacity = @agents.sum { |agent| agent.memory.instance_variable_get(:@max_size) }
        
        return 0 if total_capacity.zero?
        
        (total_memory.to_f / total_capacity * 100).round(2)
      end

      def calculate_collaboration_success_rate
        return 0 if @collaboration_history.empty?

        successful = @collaboration_history.count { |c| c[:status] == :completed }
        (successful.to_f / @collaboration_history.length * 100).round(2)
      end

      def analyze_collaboration_patterns(collaborations)
        {
          total_collaborations: collaborations.length,
          success_rate: calculate_collaboration_success_rate,
          average_contributors: collaborations.map { |c| c[:contributions].length }.sum.to_f / collaborations.length,
          common_issues: extract_common_issues(collaborations),
          best_practices: extract_best_practices(collaborations)
        }
      end

      def extract_common_issues(collaborations)
        issues = collaborations.flat_map do |collab|
          collab[:contributions].values.select { |c| c[:error] }.map { |c| c[:error] }
        end
        issues.tally.sort_by { |_, count| -count }.first(3)
      end

      def extract_best_practices(collaborations)
        successful_collaborations = collaborations.select { |c| c[:status] == :completed }
        return [] if successful_collaborations.empty?

        # Analyze what made successful collaborations work
        {
          average_duration: successful_collaborations.map { |c| c[:completed_at] - c[:started_at] }.sum / successful_collaborations.length,
          most_active_contributors: successful_collaborations.flat_map { |c| c[:contributions].keys }.tally.sort_by { |_, count| -count }.first(3)
        }
      end
    end
  end
end
