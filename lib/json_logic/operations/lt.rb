# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::LT < JsonLogic::LazyOperation
  def self.name = "<"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    args.drop(1).reduce(JsonLogic.apply(args.first, data)) do |previous, rule|
      current = JsonLogic.apply(rule, data)
      return false unless previous < current
      current
    end
    true
  end
end
