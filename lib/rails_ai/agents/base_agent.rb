# frozen_string_literal: true

module RailsAi
  module Agents
    class BaseAgent
      attr_reader :name, :role, :capabilities, :memory, :state, :created_at, :last_activity, :active_tasks, :completed_tasks, :failed_tasks

      def initialize(name:, role:, capabilities: [], memory_size: 1000, **opts)
        @name = name
        @role = role
        @capabilities = Array(capabilities)
        @memory = Memory.new(max_size: memory_size)
        @state = :idle
        @created_at = Time.now
        @last_activity = Time.now
        @config = opts
        @message_queue = []
        @active_tasks = []
        @completed_tasks = []
        @failed_tasks = []
      end

      # Core agent lifecycle methods
      def start!
        @state = :active
        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} started")
        self
      end

      def stop!
        @state = :stopped
        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} stopped")
        self
      end

      def pause!
        @state = :paused
        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} paused")
        self
      end

      def resume!
        @state = :active
        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} resumed")
        self
      end

      # Task management
      def assign_task(task)
        return false unless can_handle_task?(task)

        @active_tasks << task.merge(
          assigned_at: Time.now,
          status: :in_progress
        )
        @last_activity = Time.now
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} assigned task: #{task[:description]}")
        true
      end

      def complete_task(task_id, result)
        task = @active_tasks.find { |t| t[:id] == task_id }
        return false unless task

        @active_tasks.delete(task)
        @completed_tasks << task.merge(
          completed_at: Time.now,
          status: :completed,
          result: result
        )
        @last_activity = Time.now
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} completed task: #{task[:description]}")
        true
      end

      def fail_task(task_id, error)
        task = @active_tasks.find { |t| t[:id] == task_id }
        return false unless task

        @active_tasks.delete(task)
        @failed_tasks << task.merge(
          failed_at: Time.now,
          status: :failed,
          error: error
        )
        @last_activity = Time.now
        
        defined?(Rails) && Rails.logger && Rails.logger.error("Agent #{@name} failed task: #{task[:description]} - #{error}")
        true
      end

      # Communication methods
      def send_message(to_agent, message)
        message_obj = {
          from: @name,
          to: to_agent,
          content: message,
          timestamp: Time.now,
          id: SecureRandom.uuid
        }
        
        @message_queue << message_obj
        @last_activity = Time.now
        
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} sent message to #{to_agent}")
        message_obj
      end

      def receive_message(message)
        @memory.add(:message, message)
        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} received message from #{message[:from]}")
      end

      def get_messages(from_agent = nil)
        messages = @message_queue
        messages = messages.select { |m| m[:from] == from_agent } if from_agent
        messages
      end

      # AI-powered decision making
      def think(prompt, context: {})
        return "[stubbed] Agent #{@name} thinking: #{prompt}" if RailsAi.config.stub_responses

        full_context = build_context(context)
        enhanced_prompt = build_agent_prompt(prompt, full_context)
        
        RailsAi.chat(enhanced_prompt, model: RailsAi.config.default_model)
      end

      def decide_next_action(context: {})
        return { action: :wait, reason: "Stubbed response" } if RailsAi.config.stub_responses

        decision_prompt = build_decision_prompt(context)
        response = think(decision_prompt, context: context)
        
        parse_decision(response)
      end

      def collaborate_with(other_agent, task, context: {})
        return "[stubbed] Collaboration between #{@name} and #{other_agent.name}" if RailsAi.config.stub_responses

        collaboration_prompt = build_collaboration_prompt(other_agent, task, context)
        response = think(collaboration_prompt, context: context)
        
        # Send collaboration result to other agent
        send_message(other_agent.name, {
          type: :collaboration_result,
          task: task,
          result: response,
          from_agent: @name
        })
        
        response
      end

      # Capability checks
      def can_handle_task?(task)
        return false unless @state == :active
        return false if @active_tasks.length >= max_concurrent_tasks

        required_capabilities = task[:required_capabilities] || []
        required_capabilities.all? { |cap| @capabilities.include?(cap) }
      end

      def has_capability?(capability)
        @capabilities.include?(capability.to_sym)
      end

      # Status and monitoring
      def status
        {
          name: @name,
          role: @role,
          state: @state,
          capabilities: @capabilities,
          active_tasks: @active_tasks.length,
          completed_tasks: @completed_tasks.length,
          failed_tasks: @failed_tasks.length,
          memory_usage: @memory.usage_percentage,
          last_activity: @last_activity,
          uptime: Time.now - @created_at
        }
      end

      def health_check
        {
          state: @state,
          memory_healthy: @memory.usage_percentage < 90,
          no_stuck_tasks: @active_tasks.none? { |t| Time.now - t[:assigned_at] > max_task_duration },
          last_activity_recent: Time.now - @last_activity < 5 * 60
        }
      end

      # Memory management
      def remember(key, value, importance: :normal)
        @memory.add(key, value, importance: importance)
        @last_activity = Time.now
      end

      def recall(key)
        @memory.get(key)
      end

      def forget(key)
        @memory.remove(key)
        @last_activity = Time.now
      end

      # Task delegation
      def delegate_task(task, target_agent, reason: nil)
        return false unless can_delegate_task?(task, target_agent)

        delegation = {
          task: task,
          from_agent: @name,
          to_agent: target_agent.name,
          reason: reason,
          delegated_at: Time.now,
          status: :pending
        }

        send_message(target_agent.name, {
          type: :task_delegation,
          delegation: delegation
        })

        @last_activity = Time.now
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{@name} delegated task to #{target_agent.name}")
        delegation
      end

      def accept_delegated_task(delegation)
        task = delegation[:delegation][:task]
        return false unless can_handle_task?(task)

        assign_task(task.merge(
          delegated_from: delegation[:from],
          delegation_id: delegation[:delegation][:id]
        ))
      end

      private

      def max_concurrent_tasks
        @config[:max_concurrent_tasks] || 3
      end

      def max_task_duration
        @config[:max_task_duration] || 30.minutes
      end

      def can_delegate_task?(task, target_agent)
        target_agent.can_handle_task?(task) && 
        target_agent.state == :active &&
        @state == :active
      end

      def build_context(context)
        {
          agent_name: @name,
          agent_role: @role,
          agent_capabilities: @capabilities,
          current_tasks: @active_tasks,
          recent_memory: @memory.recent(10),
          current_time: Time.now,
          **context
        }
      end

      def build_agent_prompt(prompt, context)
        <<~PROMPT
          You are #{@name}, a #{@role} AI agent with the following capabilities: #{@capabilities.join(', ')}.

          Current context:
          #{context.map { |k, v| "#{k}: #{v}" }.join("\n")}

          Your task: #{prompt}

          Respond as this agent would, considering your role and capabilities.
        PROMPT
      end

      def build_decision_prompt(context)
        <<~PROMPT
          As #{@name}, analyze the current situation and decide what to do next.

          Current context:
          #{context.map { |k, v| "#{k}: #{v}" }.join("\n")}

          Available actions:
          - :wait (if no immediate action needed)
          - :think (if need more information)
          - :act (if ready to take action)
          - :collaborate (if need help from other agents)
          - :delegate (if task should be handled by another agent)

          Respond with a JSON object: {"action": "action_name", "reason": "explanation", "details": {...}}
        PROMPT
      end

      def build_collaboration_prompt(other_agent, task, context)
        <<~PROMPT
          You are #{@name} collaborating with #{other_agent.name} (#{other_agent.role}).

          Task: #{task[:description]}
          Other agent's capabilities: #{other_agent.capabilities.join(', ')}

          Context:
          #{context.map { |k, v| "#{k}: #{v}" }.join("\n")}

          Provide your contribution to this collaboration.
        PROMPT
      end

      def parse_decision(response)
        begin
          JSON.parse(response)
        rescue JSON::ParserError
          { action: :wait, reason: "Failed to parse decision", error: response }
        end
      end
    end
  end
end
