# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Throw < JsonLogic::Operation
  def self.name = "throw"

  def call((value), _data)
    payload = value.is_a?(Hash) ? value : { "type" => value.to_s }
    raise JsonLogic::LogicError, payload
  end
end
