# frozen_string_literal: true

module RailsAi
  module Redactor
    EMAIL = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
    PHONE = /\+?\d[\d\s().-]{7,}\d/

    def self.call(text)
      text.to_s.gsub(EMAIL, "[email]").gsub(PHONE, "[phone]")
    end
  end
end
