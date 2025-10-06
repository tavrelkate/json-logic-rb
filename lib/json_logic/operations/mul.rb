# frozen_string_literal: true

class JsonLogic::Operations::Mul < JsonLogic::Operation
  def self.op_name = "*"
  def call(values, _data) = values.map!(&:to_f).inject(1){|m,v| m * v }
end
