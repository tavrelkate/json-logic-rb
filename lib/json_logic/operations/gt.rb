# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::GT < JsonLogic::Operation
  def self.name = ">"
  def call((a,b), _data) = a > b
end
