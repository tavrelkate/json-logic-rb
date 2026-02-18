# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Missing < JsonLogic::Operation
  def self.name = "missing"

  def call(args, data)
    Array.wrap(args).select { |key| JsonLogic::Tree.new(data).dig(key).nil? }
  end
end
