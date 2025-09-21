# frozen_string_literal: true

module RailsAi
  class WindowContext
    attr_reader :controller, :action, :params, :request, :session, :cookies

    def initialize(controller: nil, action: nil, params: {}, request: nil, session: {}, cookies: {})
      @controller = controller
      @action = action
      @params = params || {}
      @request = request
      @session = session || {}
      @cookies = cookies || {}
    end

    def to_h
      {
        controller: controller_name,
        action: action_name,
        route: route_info,
        params: sanitized_params,
        user_agent: user_agent,
        referer: referer,
        ip_address: ip_address,
        session_data: sanitized_session,
        cookies: sanitized_cookies,
        timestamp: current_time.iso8601
      }
    end

    def self.from_controller(controller)
      new(
        controller: controller.class.name,
        action: controller.action_name,
        params: extract_params(controller),
        request: controller.request,
        session: controller.session.to_h,
        cookies: controller.cookies.to_h
      )
    end

    private

    def current_time
      if defined?(Time.current)
        Time.current
      else
        Time.now
      end
    end

    def self.extract_params(controller)
      if controller.params.respond_to?(:to_unsafe_h)
        controller.params.to_unsafe_h
      elsif controller.params.respond_to?(:to_h)
        controller.params.to_h
      else
        controller.params
      end
    end

    def controller_name
      controller&.class&.name || 'Unknown'
    end

    def action_name
      action || 'Unknown'
    end

    def route_info
      return 'Unknown' unless request
      
      "#{request.method} #{request.path}"
    end

    def sanitized_params
      # Remove sensitive parameters
      params.except('password', 'password_confirmation', 'token', 'secret', 'key')
    end

    def user_agent
      request&.user_agent || 'Unknown'
    end

    def referer
      request&.referer || 'Direct'
    end

    def ip_address
      request&.remote_ip || 'Unknown'
    end

    def sanitized_session
      # Remove sensitive session data
      session.except('password', 'token', 'secret', 'key', 'csrf_token')
    end

    def sanitized_cookies
      # Remove sensitive cookies
      cookies.except('_session_id', 'csrf_token', 'remember_token')
    end
  end
end
