# frozen_string_literal: true

module RailsAi
  module Agents
    class Collaboration
      attr_reader :id, :task, :agents, :manager, :status, :created_at

      def initialize(task:, agents:, manager:)
        @id = SecureRandom.uuid
        @task = task
        @agents = Array(agents)
        @manager = manager
        @status = :pending
        @created_at = Time.now
        @contributions = {}
        @workflow = []
        @current_phase = 0
        @phases = build_workflow_phases
      end

      def start!
        @status = :in_progress
        @started_at = Time.now
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Collaboration #{@id} started with #{@agents.length} agents")
        
        # Begin the collaboration workflow
        execute_workflow_phase
        self
      end

      def add_contribution(agent_name, contribution)
        @contributions[agent_name] = {
          content: contribution,
          timestamp: Time.now,
          phase: @current_phase
        }
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{agent_name} contributed to collaboration #{@id}")
        
        # Check if current phase is complete
        if phase_complete?
          advance_to_next_phase
        end
      end

      def get_contributions(agent_name = nil)
        if agent_name
          @contributions[agent_name]
        else
          @contributions
        end
      end

      def get_phase_contributions(phase)
        @contributions.select { |_, contrib| contrib[:phase] == phase }
      end

      def current_phase_info
        return nil if @current_phase >= @phases.length
        
        @phases[@current_phase]
      end

      def is_complete?
        @status == :completed
      end

      def is_failed?
        @status == :failed
      end

      def duration
        return nil unless @started_at
        
        end_time = @completed_at || Time.now
        end_time - @started_at
      end

      def summary
        {
          id: @id,
          task: @task,
          agents: @agents.map(&:name),
          status: @status,
          current_phase: @current_phase,
          total_phases: @phases.length,
          contributions_count: @contributions.length,
          duration: duration,
          created_at: @created_at,
          started_at: @started_at,
          completed_at: @completed_at
        }
      end

      def complete!(result = nil)
        @status = :completed
        @completed_at = Time.now
        @result = result
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Collaboration #{@id} completed in #{duration&.round(2)} seconds")
        
        # Notify all participating agents
        @agents.each do |agent|
          @manager.send_message("collaboration_system", agent.name, {
            type: :collaboration_completed,
            collaboration_id: @id,
            result: result
          })
        end
        
        self
      end

      def fail!(error)
        @status = :failed
        @failed_at = Time.now
        @error = error
        
        defined?(Rails) && Rails.logger && Rails.logger.error("Collaboration #{@id} failed: #{error}")
        
        # Notify all participating agents
        @agents.each do |agent|
          @manager.send_message("collaboration_system", agent.name, {
            type: :collaboration_failed,
            collaboration_id: @id,
            error: error
          })
        end
        
        self
      end

      private

      def build_workflow_phases
        case @task[:type] || :general
        when :analysis
          [
            { name: "data_gathering", description: "Gather and analyze data", required_agents: @agents.length },
            { name: "pattern_recognition", description: "Identify patterns and insights", required_agents: @agents.length },
            { name: "synthesis", description: "Synthesize findings into conclusions", required_agents: 1 }
          ]
        when :creative
          [
            { name: "brainstorming", description: "Generate creative ideas", required_agents: @agents.length },
            { name: "refinement", description: "Refine and improve ideas", required_agents: @agents.length },
            { name: "finalization", description: "Finalize the creative output", required_agents: 1 }
          ]
        when :problem_solving
          [
            { name: "problem_analysis", description: "Analyze the problem thoroughly", required_agents: @agents.length },
            { name: "solution_generation", description: "Generate potential solutions", required_agents: @agents.length },
            { name: "solution_evaluation", description: "Evaluate and select best solution", required_agents: @agents.length },
            { name: "implementation_plan", description: "Create implementation plan", required_agents: 1 }
          ]
        else
          [
            { name: "discussion", description: "Discuss the task", required_agents: @agents.length },
            { name: "consensus", description: "Reach consensus on approach", required_agents: @agents.length },
            { name: "execution", description: "Execute the agreed approach", required_agents: 1 }
          ]
        end
      end

      def execute_workflow_phase
        return if @current_phase >= @phases.length
        
        phase = @phases[@current_phase]
        
        # Notify agents about the new phase
        @agents.each do |agent|
          @manager.send_message("collaboration_system", agent.name, {
            type: :collaboration_phase,
            collaboration_id: @id,
            phase: phase,
            phase_number: @current_phase + 1,
            total_phases: @phases.length
          })
        end
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Collaboration #{@id} started phase #{@current_phase + 1}: #{phase[:name]}")
      end

      def phase_complete?
        return false if @current_phase >= @phases.length
        
        phase = @phases[@current_phase]
        current_contributions = get_phase_contributions(@current_phase)
        
        current_contributions.length >= phase[:required_agents]
      end

      def advance_to_next_phase
        @current_phase += 1
        
        if @current_phase >= @phases.length
          # All phases complete, synthesize final result
          synthesize_result
        else
          # Start next phase
          execute_workflow_phase
        end
      end

      def synthesize_result
        # Combine all contributions into a final result
        all_contributions = @contributions.values.map { |c| c[:content] }
        
        synthesis_prompt = build_synthesis_prompt(all_contributions)
        
        # Use the first agent to synthesize (or could use a dedicated synthesis agent)
        synthesizer = @agents.first
        result = synthesizer.think(synthesis_prompt, context: {
          task: @task,
          contributions: all_contributions,
          collaboration_id: @id
        })
        
        complete!(result)
      end

      def build_synthesis_prompt(contributions)
        <<~PROMPT
          You are synthesizing the results of a multi-agent collaboration.

          Original Task: #{@task[:description]}

          Agent Contributions:
          #{contributions.map.with_index { |c, i| "#{i + 1}. #{c}" }.join("\n")}

          Please synthesize these contributions into a coherent, comprehensive result that addresses the original task.
          Consider the different perspectives and insights provided by each agent.
        PROMPT
      end
    end
  end
end
