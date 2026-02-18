# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Filter < JsonLogic::EnumerableOperation
  def self.name = "filter"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new if args.is_a?(Array) && args.size >= 2 && args[1].nil?
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2
    raise JsonLogic::InvalidArgumentsError.new if args[0].nil?

    items_rule, rule = args
    items = Array(JsonLogic.apply(items_rule, data))

    return [] if rule.nil?

    items.each_with_index.each_with_object([]) do |(item, index), filtered|
      value = JsonLogic.apply(rule, JsonLogic::Scope.new(item, data, index))
      filtered << item if value.to_bool
    end
  end
end
