# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Coalesce < JsonLogic::Operation
  def self.name = "??"

  def call(args, _data) = args.find { |v| !v.nil? }
end
