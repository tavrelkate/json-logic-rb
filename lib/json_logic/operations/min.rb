# frozen_string_literal: true

class JsonLogic::Operations::Min < JsonLogic::Operation
  def self.op_name = "min"

  def call(values, _data) = values.min
end
