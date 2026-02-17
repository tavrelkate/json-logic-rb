# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Cat < JsonLogic::Operation
  def self.name = "cat"

  def call(args, _data) = args.map!(&:to_s).join
end
