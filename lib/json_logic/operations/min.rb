# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Min < JsonLogic::Operation
  def self.name = "min"

  def call(args, _data) = args.min
end
