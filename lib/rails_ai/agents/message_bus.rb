# frozen_string_literal: true

module RailsAi
  module Agents
    class MessageBus
      def initialize
        @subscribers = {}
        @message_history = []
        @max_history = 10000
      end

      def subscribe(agent_name, agent)
        @subscribers[agent_name] = agent
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{agent_name} subscribed to message bus")
      end

      def unsubscribe(agent_name)
        @subscribers.delete(agent_name)
        defined?(Rails) && Rails.logger && Rails.logger.info("Agent #{agent_name} unsubscribed from message bus")
      end

      def send_message(from_agent, to_agent, message)
        return false unless @subscribers[to_agent]

        message_obj = {
          id: SecureRandom.uuid,
          from: from_agent,
          to: to_agent,
          content: message,
          timestamp: Time.now,
          delivered: false
        }

        begin
          @subscribers[to_agent].receive_message(message_obj)
          message_obj[:delivered] = true
          @message_history << message_obj
          trim_history
          defined?(Rails) && Rails.logger && Rails.logger.info("Message sent from #{from_agent} to #{to_agent}")
          true
        rescue => e
          defined?(Rails) && Rails.logger && Rails.logger.error("Failed to deliver message: #{e.message}")
          false
        end
      end

      def broadcast(from_agent, message, exclude: [])
        delivered_count = 0
        
        @subscribers.each do |agent_name, agent|
          next if exclude.include?(agent_name) || agent_name == from_agent

          if send_message(from_agent, agent_name, message)
            delivered_count += 1
          end
        end

        defined?(Rails) && Rails.logger && Rails.logger.info("Broadcast message from #{from_agent} to #{delivered_count} agents")
        delivered_count
      end

      def get_messages_for_agent(agent_name, from_agent: nil, limit: 100)
        messages = @message_history.select { |m| m[:to] == agent_name }
        messages = messages.select { |m| m[:from] == from_agent } if from_agent
        messages.last(limit)
      end

      def get_message_history(limit: 1000)
        @message_history.last(limit)
      end

      def clear_history!
        @message_history.clear
        defined?(Rails) && Rails.logger && Rails.logger.info("Message history cleared")
      end

      def stats
        {
          total_subscribers: @subscribers.length,
          total_messages: @message_history.length,
          delivered_messages: @message_history.count { |m| m[:delivered] },
          failed_messages: @message_history.count { |m| !m[:delivered] }
        }
      end

      private

      def trim_history
        return if @message_history.length <= @max_history

        @message_history = @message_history.last(@max_history)
      end
    end
  end
end
