# frozen_string_literal: true

class JsonLogic::Operations::Not < JsonLogic::Operation
  def self.op_name = "!";
  def call((a), _data) = !truthy?(a)
end
