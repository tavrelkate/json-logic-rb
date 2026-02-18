# frozen_string_literal: true

using JsonLogic::Semantics

class JsonLogic::Operations::Reduce < JsonLogic::EnumerableOperation
  def self.name = "reduce"

  def call(args, data)
    raise JsonLogic::InvalidArgumentsError.new unless args.is_a?(Array) && args.size >= 2

    rule_that_returns_items = args[0]
    step_rule_applied_per_item = args[1]
    rule_that_returns_initial_accumulator = args[2]
    raise JsonLogic::InvalidArgumentsError.new if step_rule_applied_per_item.nil?

    items_value = JsonLogic.apply(rule_that_returns_items, data)
    items = Array(items_value)
    acc = rule_that_returns_initial_accumulator.nil? ? nil : JsonLogic.apply(rule_that_returns_initial_accumulator, data)

    items.each_with_index.reduce(acc) do |memo, (item, idx)|
      base_data = data.is_a?(Hash) ? data : {}
      JsonLogic.apply(
        step_rule_applied_per_item,
        base_data.merge(
          "" => item,
          "current" => item,
          "accumulator" => memo,
          "index" => idx,
          "__parent__" => data,
          "__scope__" => true
        )
      )
    end
  end
end
