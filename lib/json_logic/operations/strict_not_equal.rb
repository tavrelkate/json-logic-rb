# frozen_string_literal: true

class JsonLogic::Operations::StrictNotEqual < JsonLogic::Operation
  def self.op_name = "!=="
  def call((a,b), _data) = !JsonLogic::Semantics.strict_equal(a,b)
end
