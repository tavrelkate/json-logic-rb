# frozen_string_literal: true

module JsonLogic
  class LogicError < StandardError
    attr_reader :payload

    def initialize(payload)
      @payload =
        if payload.is_a?(Hash)
          payload.transform_keys(&:to_s)
        else
          { "type" => payload.to_s }
        end
      super(@payload["type"].to_s)
    end
  end
end
