# frozen_string_literal: true

class JsonLogic::Operations::In < JsonLogic::Operation
  def self.op_name = "in"

  def call((a,b), _data) = (b.respond_to?(:include?) && b.include?(a))
end
