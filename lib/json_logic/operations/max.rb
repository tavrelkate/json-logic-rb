# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Max < JsonLogic::Operation
  def self.name = "max"

  def call(args, _data) = args.max
end
