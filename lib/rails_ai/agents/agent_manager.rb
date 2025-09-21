# frozen_string_literal: true

module RailsAi
  module Agents
    class AgentManager
      attr_reader :agents, :message_bus, :task_queue

      def initialize
        @agents = {}
        @message_bus = MessageBus.new
        @task_queue = TaskQueue.new
        @running = false
        @thread_pool = Concurrent::ThreadPoolExecutor.new(
          min_threads: 2,
          max_threads: 10,
          max_queue: 100
        )
      end

      # Agent lifecycle management
      def register_agent(agent)
        @agents[agent.name] = agent
        @message_bus.subscribe(agent.name, agent)
        defined?(Rails) && Rails.logger && Rails.logger.info("Registered agent: #{agent.name}")
        agent
      end

      def unregister_agent(agent_name)
        agent = @agents.delete(agent_name)
        return false unless agent

        @message_bus.unsubscribe(agent_name)
        agent.stop!
        defined?(Rails) && Rails.logger && Rails.logger.info("Unregistered agent: #{agent_name}")
        true
      end

      def get_agent(agent_name)
        @agents[agent_name]
      end

      def list_agents
        @agents.values.map(&:status)
      end

      # Task management
      def submit_task(task)
        @task_queue.enqueue(task)
        defined?(Rails) && Rails.logger && Rails.logger.info("Submitted task: #{task[:description]}")
        task
      end

      def assign_task_to_agent(task, agent_name)
        agent = get_agent(agent_name)
        return false unless agent

        agent.assign_task(task)
      end

      def find_best_agent_for_task(task)
        available_agents = @agents.values.select { |agent| agent.state == :active }
        
        return nil if available_agents.empty?

        # Score agents based on capabilities and current workload
        scored_agents = available_agents.map do |agent|
          score = calculate_agent_score(agent, task)
          { agent: agent, score: score }
        end

        scored_agents.max_by { |item| item[:score] }&.dig(:agent)
      end

      def auto_assign_task(task)
        best_agent = find_best_agent_for_task(task)
        return false unless best_agent

        assign_task_to_agent(task, best_agent.name)
      end

      # Communication
      def send_message(from_agent, to_agent, message)
        @message_bus.send_message(from_agent, to_agent, message)
      end

      def broadcast_message(from_agent, message, exclude: [])
        @message_bus.broadcast(from_agent, message, exclude: exclude)
      end

      # System control
      def start!
        return false if @running

        @running = true
        start_task_processor
        start_agent_monitor
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent Manager started")
        true
      end

      def stop!
        return false unless @running

        @running = false
        @thread_pool.shutdown
        @thread_pool.wait_for_termination(30)
        
        @agents.each_value(&:stop!)
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent Manager stopped")
        true
      end

      def pause!
        @running = false
        @agents.each_value(&:pause!)
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent Manager paused")
      end

      def resume!
        @running = true
        @agents.each_value(&:resume!)
        start_task_processor
        start_agent_monitor
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent Manager resumed")
      end

      # Monitoring and health
      def system_status
        {
          running: @running,
          total_agents: @agents.length,
          active_agents: @agents.values.count { |a| a.state == :active },
          paused_agents: @agents.values.count { |a| a.state == :paused },
          stopped_agents: @agents.values.count { |a| a.state == :stopped },
          pending_tasks: @task_queue.size,
          total_tasks_processed: @task_queue.total_processed,
          thread_pool_status: @thread_pool.running?
        }
      end

      def health_check
        agent_health = @agents.values.map do |agent|
          { name: agent.name, health: agent.health_check }
        end

        {
          system_healthy: @running && @thread_pool.running?,
          agent_health: agent_health,
          memory_usage: calculate_memory_usage,
          task_queue_healthy: @task_queue.size < 1000
        }
      end

      # Agent collaboration
      def create_agent_team(team_name, agents, collaboration_strategy: :round_robin)
        team = AgentTeam.new(
          name: team_name,
          agents: agents,
          strategy: collaboration_strategy,
          manager: self
        )
        
        team.agents.each { |agent| register_agent(agent) }
        team
      end

      def orchestrate_collaboration(task, agent_names)
        agents = agent_names.map { |name| get_agent(name) }.compact
        return false if agents.empty?

        collaboration = Collaboration.new(
          task: task,
          agents: agents,
          manager: self
        )

        collaboration.start!
        collaboration
      end

      private

      def calculate_agent_score(agent, task)
        score = 0

        # Capability match (40% of score)
        required_capabilities = task[:required_capabilities] || []
        capability_match = required_capabilities.count { |cap| agent.has_capability?(cap) }
        score += (capability_match.to_f / required_capabilities.length * 40) if required_capabilities.any?

        # Current workload (30% of score)
        workload_score = [0, 30 - (agent.active_tasks.length * 10)].max
        score += workload_score

        # Memory health (20% of score)
        memory_score = agent.memory.usage_percentage < 80 ? 20 : 10
        score += memory_score

        # Recent activity (10% of score)
        activity_score = (Time.now - agent.last_activity) < 5 * 60 ? 10 : 5
        score += activity_score

        score
      end

      def calculate_memory_usage
        total_memory = @agents.values.sum { |agent| agent.memory.size }
        total_capacity = @agents.values.sum { |agent| agent.memory.instance_variable_get(:@max_size) }
        
        return 0 if total_capacity.zero?
        
        (total_memory.to_f / total_capacity * 100).round(2)
      end

      def start_task_processor
        @thread_pool.post do
          while @running
            begin
              task = @task_queue.dequeue(timeout: 1)
              next unless task

              best_agent = find_best_agent_for_task(task)
              if best_agent
                assign_task_to_agent(task, best_agent.name)
              else
                # No available agent, re-queue task
                @task_queue.enqueue(task, priority: :high)
                sleep(5) # Wait before retrying
              end
            rescue => e
              defined?(Rails) && Rails.logger && Rails.logger.error("Task processor error: #{e.message}")
              sleep(1)
            end
          end
        end
      end

      def start_agent_monitor
        @thread_pool.post do
          while @running
            begin
              @agents.each_value do |agent|
                health = agent.health_check
                unless health.values.all?
                  defined?(Rails) && Rails.logger && Rails.logger.warn("Agent #{agent.name} health issues: #{health}")
                end
              end
              sleep(30) # Check every 30 seconds
            rescue => e
              defined?(Rails) && Rails.logger && Rails.logger.error("Agent monitor error: #{e.message}")
              sleep(5)
            end
          end
        end
      end
    end
  end
end
