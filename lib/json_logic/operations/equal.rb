# frozen_string_literal: true

class JsonLogic::Operations::Equal < JsonLogic::Operation
  def self.op_name = "=="
  def call((a,b), _data) = JsonLogic::Semantics.loose_equal(a,b)
end
