# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Throw < JsonLogic::Operation
  def self.name = "throw"

  def call((value), _data) = raise JsonLogic::LogicError, (value.is_a?(Hash) ? value : { "type" => value.to_s })
end
