# frozen_string_literal: true

class JsonLogic::Operations::Max < JsonLogic::Operation
  def self.op_name = "max"
  def call(values, _data) = values.max_by { |v| JsonLogic::Semantics.to_number(v) }
end
