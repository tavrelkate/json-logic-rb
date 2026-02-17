# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Merge < JsonLogic::Operation
  def self.name = "merge"

  def call(args, _data) = args.flat_map { |v| v.is_a?(Array) ? v : [v] }
end
