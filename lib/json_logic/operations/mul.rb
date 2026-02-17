# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Mul < JsonLogic::Operation
  def self.name = "*"

  def call(args, _data) = args.map(&:to_f).reduce(1.0, :*)
end
