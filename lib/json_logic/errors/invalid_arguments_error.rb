# frozen_string_literal: true

module JsonLogic
  class InvalidArgumentsError < LogicError
    def initialize(operation: nil)
      payload = { "type" => "Invalid Arguments" }
      payload["operation"] = operation if operation
      super(payload)
    end
  end
end
