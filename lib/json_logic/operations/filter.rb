# frozen_string_literal: true

class JsonLogic::Operations::Filter < JsonLogic::EnumerableOperation
  def self.op_name = "filter"

  def call(args, data)
    items, rule_applied_to_each_item = resolve_items_and_per_item_rule(args, data)

    items.filter do |item|
      truthy?(JsonLogic.apply(rule_applied_to_each_item, item))
    end
  end
end
