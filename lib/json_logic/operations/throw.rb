# frozen_string_literal: true

class JsonLogic::Operations::Throw < JsonLogic::Operation
  def self.name = "throw"

  def call((value), _data)
    type = value.is_a?(Hash) ? (value["type"] || value[:type]).to_s : value.to_s
    raise JsonLogic::Error, type
  end
end
