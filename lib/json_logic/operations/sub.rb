# frozen_string_literal: true

class JsonLogic::Operations::Sub < JsonLogic::Operation
  def self.op_name = "-"
  def call(values, _data) = (values.size == 1 ? -values[0].to_f : values[0].to_f - values[1].to_f)
end
