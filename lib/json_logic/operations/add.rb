# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Add < JsonLogic::Operation
  def self.name = "+"

  def call(args, _data) = args.map(&:to_f).sum
end
