# frozen_string_literal: true

class JsonLogic::Operations::Missing < JsonLogic::Operation
  def self.name = "missing"

  def call(args, data)
    Array.wrap(args).select { |key| JsonLogic::Json.new(data).dig(key).nil? }
  end
end
