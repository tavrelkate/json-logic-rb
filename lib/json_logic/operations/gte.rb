# frozen_string_literal: true

class JsonLogic::Operations::GTE < JsonLogic::Operation
  def self.op_name = ">="
  def call((a,b), _data) = JsonLogic::Semantics.to_number(a) >= JsonLogic::Semantics.to_number(b)
end
