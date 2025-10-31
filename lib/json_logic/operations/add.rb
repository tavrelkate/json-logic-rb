# frozen_string_literal: true

class JsonLogic::Operations::Add < JsonLogic::Operation
  def self.op_name = "+"

  def call(values, _data)
    values.map!(&:to_f).sum
  end
end
