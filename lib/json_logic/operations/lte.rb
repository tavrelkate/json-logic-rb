# frozen_string_literal: true

class JsonLogic::Operations::LTE < JsonLogic::Operation
  def self.op_name = "<="
  def call(values, _data)
    nums = values.map { |v| JsonLogic::Semantics.to_number(v) }
    return nums[0] <= nums[1] if nums.size == 2
    nums.each_cons(2).all? { |a,b| a <= b }
  end
end
