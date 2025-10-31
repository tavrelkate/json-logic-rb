# frozen_string_literal: true

using JsonLogic::Semantics
class JsonLogic::Operations::BoolCast < JsonLogic::Operation
  def self.op_name = "!!"

  def call((a), _data)
    !!a
  end
end
