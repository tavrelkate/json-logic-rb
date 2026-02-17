# frozen_string_literal: true

module JsonLogic
  class NaNError < LogicError
    def initialize(operation: nil)
      payload = { "type" => "NaN" }
      payload["operation"] = operation if operation
      super(payload)
    end
  end
end
